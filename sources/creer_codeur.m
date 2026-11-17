% creer_codeur.m - codeur de Hamming (7,4) à registre à décalage (partie 4, Q5)
clear; clc; close all;
mdl  = 'codeur_hamming';
msgs = dec2bin(0:15, 4) - '0';                 % les 16 messages [m0 m1 m2 m3]
K    = size(msgs, 1);

%% Entrées : 7 coups d'horloge par message
% bit d'entrée : m3 m2 m1 m0 0 0 0 ; commande : 1 1 1 1 0 0 0
u = zeros(7*K, 1);  ctrl = zeros(7*K, 1);
for k = 1:K
    u(7*(k-1) + (1:4))    = fliplr(msgs(k, :));   % poids fort d'abord
    ctrl(7*(k-1) + (1:4)) = 1;
end
t = (0:7*K-1)';
u_in = [t u];   ctrl_in = [t ctrl];

%% Modèle
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', '1', 'StopTime', num2str(7*K - 1), 'SolverMode', 'SingleTasking');

add_block('simulink/Sources/From Workspace', [mdl '/Message'], 'VariableName', 'u_in', ...
          'SampleTime', '1', 'Interpolate', 'off', ...
          'OutputAfterFinalValue', 'Holding final value', 'Position', [30 80 110 110]);
add_block('simulink/Sources/From Workspace', [mdl '/Commande'], 'VariableName', 'ctrl_in', ...
          'SampleTime', '1', 'Interpolate', 'off', ...
          'OutputAfterFinalValue', 'Holding final value', 'Position', [30 160 110 190]);

%% Sous-système codeur
cod = [mdl '/Codeur Hamming'];
add_block('built-in/Subsystem', cod, 'Position', [200 80 320 190]);
add_block('built-in/Inport',  [cod '/m']);
add_block('built-in/Inport',  [cod '/ctrl']);
add_block('simulink/Signal Attributes/Data Type Conversion', [cod '/Bool m'],    'OutDataTypeStr', 'boolean');
add_block('simulink/Signal Attributes/Data Type Conversion', [cod '/Bool ctrl'], 'OutDataTypeStr', 'boolean');
add_block('simulink/Logic and Bit Operations/Logical Operator', [cod '/XOR entree'], 'Operator', 'XOR', 'Inputs', '2');
add_block('simulink/Logic and Bit Operations/Logical Operator', [cod '/ET'],         'Operator', 'AND', 'Inputs', '2');
add_block('simulink/Logic and Bit Operations/Logical Operator', [cod '/XOR s1'],     'Operator', 'XOR', 'Inputs', '2');
add_block('simulink/Discrete/Unit Delay', [cod '/s0'], 'InitialCondition', '0', 'SampleTime', '1');
add_block('simulink/Discrete/Unit Delay', [cod '/s1'], 'InitialCondition', '0', 'SampleTime', '1');
add_block('simulink/Discrete/Unit Delay', [cod '/s2'], 'InitialCondition', '0', 'SampleTime', '1');
add_block('simulink/Signal Routing/Switch', [cod '/Interrupteur'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Signal Routing/Mux', [cod '/Mux'], 'Inputs', '3');
add_block('built-in/Outport', [cod '/c']);
add_block('built-in/Outport', [cod '/etats']);

add_line(cod, 'm/1',          'Bool m/1');
add_line(cod, 'ctrl/1',       'Bool ctrl/1');
add_line(cod, 'Bool m/1',     'XOR entree/1');
add_line(cod, 's2/1',         'XOR entree/2');     % m xor s2
add_line(cod, 'XOR entree/1', 'ET/1');
add_line(cod, 'Bool ctrl/1',  'ET/2');             % f = (m xor s2) ET commande
add_line(cod, 'ET/1',         's0/1');             % s0 <- f
add_line(cod, 's0/1',         'XOR s1/1');
add_line(cod, 'ET/1',         'XOR s1/2');
add_line(cod, 'XOR s1/1',     's1/1');             % s1 <- s0 xor f
add_line(cod, 's1/1',         's2/1');             % s2 <- s1
add_line(cod, 'Bool m/1',     'Interrupteur/1');   % commande = 1 : bit du message
add_line(cod, 'Bool ctrl/1',  'Interrupteur/2');
add_line(cod, 's2/1',         'Interrupteur/3');   % commande = 0 : bit de redondance
add_line(cod, 'Interrupteur/1', 'c/1');
add_line(cod, 's0/1', 'Mux/1');
add_line(cod, 's1/1', 'Mux/2');
add_line(cod, 's2/1', 'Mux/3');
add_line(cod, 'Mux/1', 'etats/1');
try, Simulink.BlockDiagram.arrangeSystem(cod); catch, end

add_block('simulink/Sinks/To Workspace', [mdl '/sortie'], 'VariableName', 'sortie', ...
          'SaveFormat', 'Array', 'Position', [400 90 480 120]);
add_block('simulink/Sinks/To Workspace', [mdl '/etats'], 'VariableName', 'etats', ...
          'SaveFormat', 'Array', 'Position', [400 160 480 190]);
add_line(mdl, 'Message/1',        'Codeur Hamming/1');
add_line(mdl, 'Commande/1',       'Codeur Hamming/2');
add_line(mdl, 'Codeur Hamming/1', 'sortie/1');
add_line(mdl, 'Codeur Hamming/2', 'etats/1');
save_system(mdl);

%% Simulation et comparaison avec le codeur matriciel
out = sim(mdl);
s = double(out.sortie(:));
E = double(out.etats);                         % (s0 s1 s2) au début de chaque coup
B = reshape(s, 7, K)';                         % une ligne par message : m3 m2 m1 m0 r2 r1 r0
C_reg = [fliplr(B(:, 1:4)) fliplr(B(:, 5:7))]; % remise dans l'ordre [m0..m3 r0 r1 r2]
C_mat = hamming_code(msgs);
fprintf('Mots-codes identiques au codeur matriciel (16 messages) : %d\n', isequal(C_reg, C_mat));

%% Table des états pour m = [1 0 1 1]
k = find(ismember(msgs, [1 0 1 1], 'rows'));
fprintf('\nTable des états pour m = [1 0 1 1] (entrée m3 m2 m1 m0 = 1 1 0 1)\n');
fprintf('Coup | entrée | s0 s1 s2\n');
fprintf('  0  |   -    |  0  0  0\n');
for j = 1:4
    tj = 7*(k-1) + j;                          % l'état après le coup j se lit au coup j+1
    fprintf('  %d  |   %d    |  %d  %d  %d\n', j, u(tj), E(tj+1, :));
end
fprintf('Reste (r0 r1 r2) = %s, mot-code = %s\n', mat2str(E(7*(k-1)+5, :)), mat2str(C_reg(k, :)));