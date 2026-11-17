% creer_qpsk_hamming.m - QPSK de Gray avec code de Hamming (7,4) (partie 5, Q6)
% Trame = 2 mots-codes = 14 bits = 7 symboles QPSK, toutes les 8Tb. Es = 1.
clear; clc; close all;
parametres;
mdl = 'chaine_qpsk_hamming';
load_system('chaine_hamming');            % pour copier le codeur
load_system('decodeur_hamming');          % pour copier le décodeur

if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', '8*Tb', 'StopTime', '(N/8 - 1)*8*Tb', 'SolverMode', 'SingleTasking');

%% Source : 8 bits d'information par trame
add_block('simulink/Sources/Uniform Random Number', [mdl '/Source 8 bits'], ...
          'Minimum', 'zeros(1,8)', 'Maximum', 'ones(1,8)', ...
          'Seed', 'round(graine) + 7919*(0:7)', 'SampleTime', '8*Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Bits'], 'relop', '<', 'const', '0.5');
add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/Bits double'], 'OutDataTypeStr', 'double');
add_line(mdl, 'Source 8 bits/1', 'Bits/1');
add_line(mdl, 'Bits/1', 'Bits double/1');

%% Codage : deux mots de 4 bits -> deux mots-codes de 7 bits -> 14 bits
add_block('simulink/Signal Routing/Demux', [mdl '/Deux messages'], 'Outputs', '[4 4]');
add_block('chaine_hamming/Codeur Hamming', [mdl '/Codeur 1']);
add_block('chaine_hamming/Codeur Hamming', [mdl '/Codeur 2']);
add_block('simulink/Signal Routing/Mux', [mdl '/Deux mots-codes'], 'Inputs', '2');
add_line(mdl, 'Bits double/1',   'Deux messages/1');
add_line(mdl, 'Deux messages/1', 'Codeur 1/1');
add_line(mdl, 'Deux messages/2', 'Codeur 2/1');
add_line(mdl, 'Codeur 1/1',      'Deux mots-codes/1');
add_line(mdl, 'Codeur 2/1',      'Deux mots-codes/2');

%% Modulateur QPSK : couples (c1,c2), ..., (c13,c14) -> 7 symboles
mo = [mdl '/Modulateur QPSK'];
add_block('built-in/Subsystem', mo);
add_block('built-in/Inport', [mo '/c']);
add_block('simulink/Math Operations/Gain', [mo '/Gain'], 'Gain', '2/sqrt(2)');
add_block('simulink/Math Operations/Bias', [mo '/Bias'], 'Bias', '-1/sqrt(2)');
add_block('simulink/Signal Routing/Demux', [mo '/Demux'], 'Outputs', '14');
add_block('simulink/Signal Routing/Mux', [mo '/Mux I'], 'Inputs', '7');
add_block('simulink/Signal Routing/Mux', [mo '/Mux Q'], 'Inputs', '7');
add_block('simulink/Math Operations/Real-Imag to Complex', [mo '/I + jQ']);
add_block('built-in/Outport', [mo '/s']);
add_line(mo, 'c/1', 'Gain/1');  add_line(mo, 'Gain/1', 'Bias/1');  add_line(mo, 'Bias/1', 'Demux/1');
for k = 1:7
    add_line(mo, sprintf('Demux/%d', 2*k-1), sprintf('Mux I/%d', k));   % bits impairs -> voie I
    add_line(mo, sprintf('Demux/%d', 2*k),   sprintf('Mux Q/%d', k));   % bits pairs   -> voie Q
end
add_line(mo, 'Mux I/1', 'I + jQ/1');  add_line(mo, 'Mux Q/1', 'I + jQ/2');
add_line(mo, 'I + jQ/1', 's/1');
try, Simulink.BlockDiagram.arrangeSystem(mo); catch, end

%% Canal : bruit complexe, variance N0/2 par voie, sur les 7 symboles
ca = [mdl '/Canal complexe'];
add_block('built-in/Subsystem', ca);
add_block('built-in/Inport', [ca '/s']);
add_block('simulink/Sources/Random Number', [ca '/Bruit I'], 'Mean', 'zeros(1,7)', ...
          'Variance', 'N0/2*ones(1,7)', 'Seed', 'round(graine) + 50000 + 7919*(0:6)', 'SampleTime', '8*Tb');
add_block('simulink/Sources/Random Number', [ca '/Bruit Q'], 'Mean', 'zeros(1,7)', ...
          'Variance', 'N0/2*ones(1,7)', 'Seed', 'round(graine) + 90000 + 7919*(0:6)', 'SampleTime', '8*Tb');
add_block('simulink/Math Operations/Real-Imag to Complex', [ca '/Bruit complexe']);
add_block('simulink/Math Operations/Sum', [ca '/Somme'], 'Inputs', '++');
add_block('built-in/Outport', [ca '/r']);
add_line(ca, 'Bruit I/1', 'Bruit complexe/1');  add_line(ca, 'Bruit Q/1', 'Bruit complexe/2');
add_line(ca, 's/1', 'Somme/1');  add_line(ca, 'Bruit complexe/1', 'Somme/2');
add_line(ca, 'Somme/1', 'r/1');
try, Simulink.BlockDiagram.arrangeSystem(ca); catch, end

%% Démodulateur : signe de chaque voie, puis remise en ordre des 14 bits
de = [mdl '/Demodulateur QPSK'];
add_block('built-in/Subsystem', de);
add_block('built-in/Inport', [de '/r']);
add_block('simulink/Math Operations/Complex to Real-Imag', [de '/Re Im']);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [de '/Signe I'], 'relop', '>', 'const', '0');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [de '/Signe Q'], 'relop', '>', 'const', '0');
add_block('simulink/Signal Routing/Demux', [de '/Demux I'], 'Outputs', '7');
add_block('simulink/Signal Routing/Demux', [de '/Demux Q'], 'Outputs', '7');
add_block('simulink/Signal Routing/Mux', [de '/Mux'], 'Inputs', '14');
add_block('simulink/Signal Attributes/Data Type Conversion', [de '/Double'], 'OutDataTypeStr', 'double');
add_block('built-in/Outport', [de '/c']);
add_line(de, 'r/1', 'Re Im/1');
add_line(de, 'Re Im/1', 'Signe I/1');  add_line(de, 'Re Im/2', 'Signe Q/1');
add_line(de, 'Signe I/1', 'Demux I/1');  add_line(de, 'Signe Q/1', 'Demux Q/1');
for k = 1:7
    add_line(de, sprintf('Demux I/%d', k), sprintf('Mux/%d', 2*k-1));
    add_line(de, sprintf('Demux Q/%d', k), sprintf('Mux/%d', 2*k));
end
add_line(de, 'Mux/1', 'Double/1');  add_line(de, 'Double/1', 'c/1');
try, Simulink.BlockDiagram.arrangeSystem(de); catch, end

add_line(mdl, 'Deux mots-codes/1', 'Modulateur QPSK/1');
add_line(mdl, 'Modulateur QPSK/1', 'Canal complexe/1');
add_line(mdl, 'Canal complexe/1',  'Demodulateur QPSK/1');

%% Décodage : 14 bits -> deux mots de 7 -> deux messages de 4 -> 8 bits
add_block('simulink/Signal Routing/Demux', [mdl '/Deux mots recus'], 'Outputs', '[7 7]');
add_block('decodeur_hamming/Decodeur Hamming', [mdl '/Decodeur 1']);
add_block('decodeur_hamming/Decodeur Hamming', [mdl '/Decodeur 2']);
add_block('simulink/Sinks/Terminator', [mdl '/Fin 1']);
add_block('simulink/Sinks/Terminator', [mdl '/Fin 2']);
add_block('simulink/Signal Routing/Mux', [mdl '/Deux messages recus'], 'Inputs', '2');
add_line(mdl, 'Demodulateur QPSK/1', 'Deux mots recus/1');
add_line(mdl, 'Deux mots recus/1',   'Decodeur 1/1');
add_line(mdl, 'Deux mots recus/2',   'Decodeur 2/1');
add_line(mdl, 'Decodeur 1/2', 'Fin 1/1');
add_line(mdl, 'Decodeur 2/2', 'Fin 2/1');
add_line(mdl, 'Decodeur 1/1', 'Deux messages recus/1');
add_line(mdl, 'Decodeur 2/1', 'Deux messages recus/2');

%% Enregistrement
add_block('simulink/Sinks/To Workspace', [mdl '/emis'],  'VariableName', 'emis',  'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/m_dec'], 'VariableName', 'm_dec', 'SaveFormat', 'Array');
add_line(mdl, 'Bits double/1',         'emis/1');
add_line(mdl, 'Deux messages recus/1', 'm_dec/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

%% Vérifications
Q  = @(x) 0.5*erfc(x/sqrt(2));
N0 = 0;  out = sim(mdl);
fprintf('Sans bruit : restitution exacte : %d\n', isequal(out.emis, out.m_dec));
g  = 10^(5/10);  Eb = 7/8;  N0 = Eb/g;
out = sim(mdl);
p  = Q(sqrt(2*4/7*g));  j = 2:7;
Pb = sum(j/7 .* arrayfun(@(k) nchoosek(7, k), j) .* p.^j .* (1-p).^(7-j));
fprintf('Eb/N0 = 5 dB : TEB = %.2e (formule Q8 : %.2e, partie 4 simulée : 6,7e-03)\n', ...
        nnz(out.emis ~= out.m_dec) / numel(out.emis), Pb);