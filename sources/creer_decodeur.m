% creer_decodeur.m - décodeur de Hamming (7,4) en logique combinatoire (partie 4, Q6)
clear; clc; close all;
mdl  = 'decodeur_hamming';
LO   = 'simulink/Logic and Bit Operations/Logical Operator';
[~, H] = hamming_GH();

%% Mots de test : 16 mots-codes, sans erreur puis avec une erreur en position 1 à 7
msgs = dec2bin(0:15, 4) - '0';
C    = hamming_code(msgs);
Y = [];  M = [];  POS = [];
for pos = 0:7
    E = zeros(16, 7);
    if pos > 0, E(:, pos) = 1; end
    Y   = [Y; mod(C + E, 2)];
    M   = [M; msgs];
    POS = [POS; pos * ones(16, 1)];
end
W    = size(Y, 1);                         % 128 mots
y_in = [(0:W-1)' Y];                       % un mot de 7 bits par coup d'horloge

%% Modèle
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', '1', 'StopTime', num2str(W - 1), 'SolverMode', 'SingleTasking');

add_block('simulink/Sources/From Workspace', [mdl '/Mots recus'], 'VariableName', 'y_in', ...
          'SampleTime', '1', 'Interpolate', 'off', ...
          'OutputAfterFinalValue', 'Holding final value', 'Position', [30 100 120 140]);

%% Sous-système décodeur
dec = [mdl '/Decodeur Hamming'];
add_block('built-in/Subsystem', dec, 'Position', [200 90 320 160]);
add_block('built-in/Inport', [dec '/y']);
add_block('simulink/Signal Attributes/Data Type Conversion', [dec '/Bool'], 'OutDataTypeStr', 'boolean');
add_block('simulink/Signal Routing/Demux', [dec '/Demux'], 'Outputs', '7');
add_block('simulink/Signal Routing/Mux',   [dec '/Mux'],   'Inputs',  '4');
add_block('simulink/Signal Attributes/Data Type Conversion', [dec '/Double m'], 'OutDataTypeStr', 'double');
add_block('simulink/Signal Attributes/Data Type Conversion', [dec '/Double d'], 'OutDataTypeStr', 'double');
add_block(LO, [dec '/Detection'], 'Operator', 'OR', 'Inputs', '3');
add_block('built-in/Outport', [dec '/m']);
add_block('built-in/Outport', [dec '/erreur detectee']);
add_line(dec, 'y/1', 'Bool/1');
add_line(dec, 'Bool/1', 'Demux/1');

% Syndrome : s(i) = XOR des bits désignés par la ligne i de H
for i = 1:3
    nom = sprintf('S%d', i-1);
    add_block(LO, [dec '/' nom], 'Operator', 'XOR', 'Inputs', '4');
    add_block(LO, [dec '/Non ' nom], 'Operator', 'NOT');
    bits = find(H(i, :));
    for k = 1:4
        add_line(dec, sprintf('Demux/%d', bits(k)), sprintf('%s/%d', nom, k));
    end
    add_line(dec, [nom '/1'], ['Non ' nom '/1']);
    add_line(dec, [nom '/1'], sprintf('Detection/%d', i));
end

% Localisation (ET) et correction (XOR) des 4 bits du message
for j = 1:4
    add_block(LO, [dec sprintf('/E%d', j)], 'Operator', 'AND', 'Inputs', '3');
    add_block(LO, [dec sprintf('/C%d', j)], 'Operator', 'XOR', 'Inputs', '2');
    for i = 1:3
        if H(i, j), src = sprintf('S%d/1', i-1); else, src = sprintf('Non S%d/1', i-1); end
        add_line(dec, src, sprintf('E%d/%d', j, i));     % e_j = 1 si syndrome = colonne j
    end
    add_line(dec, sprintf('Demux/%d', j), sprintf('C%d/1', j));
    add_line(dec, sprintf('E%d/1', j),    sprintf('C%d/2', j));   % m_j = y_j xor e_j
    add_line(dec, sprintf('C%d/1', j),    sprintf('Mux/%d', j));
end
add_line(dec, 'Mux/1', 'Double m/1');
add_line(dec, 'Double m/1', 'm/1');
add_line(dec, 'Detection/1', 'Double d/1');
add_line(dec, 'Double d/1', 'erreur detectee/1');
try, Simulink.BlockDiagram.arrangeSystem(dec); catch, end

add_block('simulink/Sinks/To Workspace', [mdl '/m_dec'], 'VariableName', 'm_dec', ...
          'SaveFormat', 'Array', 'Position', [400 90 480 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/detect'], 'VariableName', 'detect', ...
          'SaveFormat', 'Array', 'Position', [400 150 480 180]);
add_line(mdl, 'Mots recus/1',       'Decodeur Hamming/1');
add_line(mdl, 'Decodeur Hamming/1', 'm_dec/1');
add_line(mdl, 'Decodeur Hamming/2', 'detect/1');
save_system(mdl);

%% Simulation et validation
out  = sim(mdl);
Mdec = double(out.m_dec);
D    = double(out.detect(:));
ok   = all(Mdec == M, 2);
for pos = 0:7
    if pos == 0, txt = 'sans erreur      '; else, txt = sprintf('erreur position %d', pos); end
    fprintf('%s : %2d/16 messages retrouvés, erreur détectée %2d/16\n', ...
            txt, sum(ok(POS == pos)), sum(D(POS == pos)));
end
fprintf('Identique à hamming_decode : %d\n', isequal(Mdec, hamming_decode(Y)));