% creer_chaine_hamming.m - chaîne avec et sans codage de Hamming (partie 4, Q10)
% Traitement par mot (4 bits d'information toutes les 4Tb), canal équivalent
% après intégrateur : bit reçu = ±amplitude + bruit de variance sig2/L.
clear; clc; close all;
parametres;
Ac  = A * sqrt(4/7);                    % amplitude d'un bit codé
mdl = 'chaine_hamming';
LO  = 'simulink/Logic and Bit Operations/Logical Operator';
load_system('decodeur_hamming');        % pour copier le décodeur de la question 6

if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', '4*Tb', 'StopTime', '(N/4 - 1)*4*Tb', 'SolverMode', 'SingleTasking');

%% Source : 4 bits équiprobables par mot (graines entières et éloignées)
add_block('simulink/Sources/Uniform Random Number', [mdl '/Source 4 bits'], ...
          'Minimum', 'zeros(1,4)', 'Maximum', 'ones(1,4)', ...
          'Seed', 'round(graine) + 7919*(0:3)', 'SampleTime', '4*Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Bits'], ...
          'relop', '<', 'const', '0.5');
add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/Bits double'], ...
          'OutDataTypeStr', 'double');
add_line(mdl, 'Source 4 bits/1', 'Bits/1');
add_line(mdl, 'Bits/1', 'Bits double/1');

%% Codeur de Hamming parallèle : c = [m0 m1 m2 m3 r0 r1 r2]
cod = [mdl '/Codeur Hamming'];
add_block('built-in/Subsystem', cod);
add_block('built-in/Inport', [cod '/m']);
add_block('simulink/Signal Attributes/Data Type Conversion', [cod '/Bool'], 'OutDataTypeStr', 'boolean');
add_block('simulink/Signal Routing/Demux', [cod '/Demux'], 'Outputs', '4');
add_block('simulink/Signal Routing/Mux',   [cod '/Mux'],   'Inputs',  '7');
add_block('simulink/Signal Attributes/Data Type Conversion', [cod '/Double'], 'OutDataTypeStr', 'double');
add_block('built-in/Outport', [cod '/c']);
add_line(cod, 'm/1', 'Bool/1');
add_line(cod, 'Bool/1', 'Demux/1');
for j = 1:4
    add_line(cod, sprintf('Demux/%d', j), sprintf('Mux/%d', j));     % bits du message
end
entrees = {[1 3 4], [1 2 3], [2 3 4]};      % r0 = m0+m2+m3, r1 = m0+m1+m2, r2 = m1+m2+m3
for i = 1:3
    nom = sprintf('R%d', i-1);
    add_block(LO, [cod '/' nom], 'Operator', 'XOR', 'Inputs', '3');
    for k = 1:3
        add_line(cod, sprintf('Demux/%d', entrees{i}(k)), sprintf('%s/%d', nom, k));
    end
    add_line(cod, [nom '/1'], sprintf('Mux/%d', 4 + i));
end
add_line(cod, 'Mux/1', 'Double/1');
add_line(cod, 'Double/1', 'c/1');
try, Simulink.BlockDiagram.arrangeSystem(cod); catch, end

%% Branche codée : modulation (±Ac), canal équivalent, décision, décodeur
add_block('simulink/Math Operations/Gain', [mdl '/Gain c'], 'Gain', '2*Ac');
add_block('simulink/Math Operations/Bias', [mdl '/Bias c'], 'Bias', '-Ac');
add_block('simulink/Sources/Random Number', [mdl '/Bruit c'], 'Mean', 'zeros(1,7)', ...
          'Variance', 'sig2/L*ones(1,7)', 'Seed', 'round(graine) + 50000 + 7919*(0:6)', ...
          'SampleTime', '4*Tb');
add_block('simulink/Math Operations/Sum', [mdl '/Canal c'], 'Inputs', '++');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Decision c'], ...
          'relop', '>', 'const', '0');
add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/Decision c double'], ...
          'OutDataTypeStr', 'double');
add_block('decodeur_hamming/Decodeur Hamming', [mdl '/Decodeur Hamming']);
add_block('simulink/Sinks/Terminator', [mdl '/Fin detection']);

add_line(mdl, 'Bits double/1',       'Codeur Hamming/1');
add_line(mdl, 'Codeur Hamming/1',    'Gain c/1');
add_line(mdl, 'Gain c/1',            'Bias c/1');
add_line(mdl, 'Bias c/1',            'Canal c/1');
add_line(mdl, 'Bruit c/1',           'Canal c/2');
add_line(mdl, 'Canal c/1',           'Decision c/1');
add_line(mdl, 'Decision c/1',        'Decision c double/1');
add_line(mdl, 'Decision c double/1', 'Decodeur Hamming/1');
add_line(mdl, 'Decodeur Hamming/2',  'Fin detection/1');

%% Branche non codée : modulation (±A), canal équivalent, décision
add_block('simulink/Math Operations/Gain', [mdl '/Gain nc'], 'Gain', '2*A');
add_block('simulink/Math Operations/Bias', [mdl '/Bias nc'], 'Bias', '-A');
add_block('simulink/Sources/Random Number', [mdl '/Bruit nc'], 'Mean', 'zeros(1,4)', ...
          'Variance', 'sig2/L*ones(1,4)', 'Seed', 'round(graine) + 90000 + 7919*(0:3)', ...
          'SampleTime', '4*Tb');
add_block('simulink/Math Operations/Sum', [mdl '/Canal nc'], 'Inputs', '++');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Decision nc'], ...
          'relop', '>', 'const', '0');
add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/Decision nc double'], ...
          'OutDataTypeStr', 'double');
add_line(mdl, 'Bits double/1', 'Gain nc/1');
add_line(mdl, 'Gain nc/1',     'Bias nc/1');
add_line(mdl, 'Bias nc/1',     'Canal nc/1');
add_line(mdl, 'Bruit nc/1',    'Canal nc/2');
add_line(mdl, 'Canal nc/1',    'Decision nc/1');
add_line(mdl, 'Decision nc/1', 'Decision nc double/1');

%% Enregistrement
add_block('simulink/Sinks/To Workspace', [mdl '/emis'],  'VariableName', 'emis',  'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/m_dec'], 'VariableName', 'm_dec', 'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/m_nc'],  'VariableName', 'm_nc',  'SaveFormat', 'Array');
add_line(mdl, 'Bits double/1',        'emis/1');
add_line(mdl, 'Decodeur Hamming/1',   'm_dec/1');
add_line(mdl, 'Decision nc double/1', 'm_nc/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

%% Vérification à Eb/N0 = 5 dB
Q  = @(x) 0.5*erfc(x/sqrt(2));
g  = 10^(EbN0dB/10);
p  = Q(sqrt(2*4/7*g));
j  = 2:7;
Pb = sum(j/7 .* arrayfun(@(k) nchoosek(7, k), j) .* p.^j .* (1-p).^(7-j));
out = sim(mdl);
fprintf('Sans codage : TEB = %.2e (théorie %.2e)\n', nnz(out.emis ~= out.m_nc)  / numel(out.emis), Q(sqrt(2*g)));
fprintf('Avec codage : TEB = %.2e (théorie %.2e)\n', nnz(out.emis ~= out.m_dec) / numel(out.emis), Pb);