% creer_qpsk.m - modulation QPSK de Gray en bande de base (partie 5, Q1-Q2)
% Traitement symbole par symbole : 2 bits toutes les 2Tb, Es = 1.
clear; clc; close all;
parametres;
Es = 1;
mdl = 'chaine_qpsk';

if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', '2*Tb', 'StopTime', '(N/2 - 1)*2*Tb', 'SolverMode', 'SingleTasking');

%% Source : 2 bits équiprobables par symbole
add_block('simulink/Sources/Uniform Random Number', [mdl '/Source 2 bits'], ...
          'Minimum', 'zeros(1,2)', 'Maximum', 'ones(1,2)', ...
          'Seed', 'round(graine) + 7919*(0:1)', 'SampleTime', '2*Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [mdl '/Bits'], ...
          'relop', '<', 'const', '0.5');
add_block('simulink/Signal Attributes/Data Type Conversion', [mdl '/Bits double'], ...
          'OutDataTypeStr', 'double');
add_line(mdl, 'Source 2 bits/1', 'Bits/1');
add_line(mdl, 'Bits/1', 'Bits double/1');

%% Modulateur QPSK (Gray) : I = (2 b1 - 1)/sqrt(2), Q = (2 b2 - 1)/sqrt(2)
mo = [mdl '/Modulateur QPSK'];
add_block('built-in/Subsystem', mo);
add_block('built-in/Inport',  [mo '/bits']);
add_block('simulink/Signal Routing/Demux', [mo '/Demux'], 'Outputs', '2');
add_block('simulink/Math Operations/Gain', [mo '/Gain I'], 'Gain', '2/sqrt(2)');
add_block('simulink/Math Operations/Bias', [mo '/Bias I'], 'Bias', '-1/sqrt(2)');
add_block('simulink/Math Operations/Gain', [mo '/Gain Q'], 'Gain', '2/sqrt(2)');
add_block('simulink/Math Operations/Bias', [mo '/Bias Q'], 'Bias', '-1/sqrt(2)');
add_block('simulink/Math Operations/Real-Imag to Complex', [mo '/I + jQ']);
add_block('built-in/Outport', [mo '/s']);
add_line(mo, 'bits/1', 'Demux/1');
add_line(mo, 'Demux/1', 'Gain I/1');   add_line(mo, 'Gain I/1', 'Bias I/1');
add_line(mo, 'Demux/2', 'Gain Q/1');   add_line(mo, 'Gain Q/1', 'Bias Q/1');
add_line(mo, 'Bias I/1', 'I + jQ/1');  add_line(mo, 'Bias Q/1', 'I + jQ/2');
add_line(mo, 'I + jQ/1', 's/1');
try, Simulink.BlockDiagram.arrangeSystem(mo); catch, end

%% Canal : bruit complexe, variance N0/2 par voie
ca = [mdl '/Canal complexe'];
add_block('built-in/Subsystem', ca);
add_block('built-in/Inport', [ca '/s']);
add_block('simulink/Sources/Random Number', [ca '/Bruit I'], 'Mean', '0', ...
          'Variance', 'N0/2', 'Seed', 'round(graine) + 50000', 'SampleTime', '2*Tb');
add_block('simulink/Sources/Random Number', [ca '/Bruit Q'], 'Mean', '0', ...
          'Variance', 'N0/2', 'Seed', 'round(graine) + 60000', 'SampleTime', '2*Tb');
add_block('simulink/Math Operations/Real-Imag to Complex', [ca '/Bruit complexe']);
add_block('simulink/Math Operations/Sum', [ca '/Somme'], 'Inputs', '++');
add_block('built-in/Outport', [ca '/r']);
add_line(ca, 'Bruit I/1', 'Bruit complexe/1');
add_line(ca, 'Bruit Q/1', 'Bruit complexe/2');
add_line(ca, 's/1', 'Somme/1');
add_line(ca, 'Bruit complexe/1', 'Somme/2');
add_line(ca, 'Somme/1', 'r/1');
try, Simulink.BlockDiagram.arrangeSystem(ca); catch, end

%% Démodulateur : décision sur le signe de chaque voie
de = [mdl '/Demodulateur QPSK'];
add_block('built-in/Subsystem', de);
add_block('built-in/Inport', [de '/r']);
add_block('simulink/Math Operations/Complex to Real-Imag', [de '/Re Im']);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [de '/Signe I'], 'relop', '>', 'const', '0');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [de '/Signe Q'], 'relop', '>', 'const', '0');
add_block('simulink/Signal Routing/Mux', [de '/Mux'], 'Inputs', '2');
add_block('simulink/Signal Attributes/Data Type Conversion', [de '/Double'], 'OutDataTypeStr', 'double');
add_block('built-in/Outport', [de '/bits']);
add_line(de, 'r/1', 'Re Im/1');
add_line(de, 'Re Im/1', 'Signe I/1');
add_line(de, 'Re Im/2', 'Signe Q/1');
add_line(de, 'Signe I/1', 'Mux/1');
add_line(de, 'Signe Q/1', 'Mux/2');
add_line(de, 'Mux/1', 'Double/1');
add_line(de, 'Double/1', 'bits/1');
try, Simulink.BlockDiagram.arrangeSystem(de); catch, end

%% Liaisons et enregistrement
add_block('simulink/Sinks/To Workspace', [mdl '/emis'], 'VariableName', 'emis', 'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/recu'], 'VariableName', 'recu', 'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/s'],    'VariableName', 's',    'SaveFormat', 'Array');
add_block('simulink/Sinks/To Workspace', [mdl '/r'],    'VariableName', 'r',    'SaveFormat', 'Array');
add_line(mdl, 'Bits double/1',       'Modulateur QPSK/1');
add_line(mdl, 'Bits double/1',       'emis/1');
add_line(mdl, 'Modulateur QPSK/1',   'Canal complexe/1');
add_line(mdl, 'Modulateur QPSK/1',   's/1');
add_line(mdl, 'Canal complexe/1',    'Demodulateur QPSK/1');
add_line(mdl, 'Canal complexe/1',    'r/1');
add_line(mdl, 'Demodulateur QPSK/1', 'recu/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

%% Validation 1 : mapping sans bruit
N0  = 0;
out = sim(mdl);
B = out.emis;  S = out.s(:);
fprintf('\nMapping (sans bruit) :\n b1 b2 |   I       Q     |  k\n');
for c = [1 1; 0 1; 0 0; 1 0]'
    i = find(B(:,1) == c(1) & B(:,2) == c(2), 1);
    fprintf('  %d  %d | %+.3f  %+.3f  |  %d\n', c(1), c(2), real(S(i)), imag(S(i)), ...
            round(mod(angle(S(i)), 2*pi) / (pi/4)));
end
fprintf('Démodulation sans bruit exacte : %d\n', isequal(out.emis, out.recu));

%% Validation 2 : TEB à Eb/N0 = 5 dB
Q   = @(x) 0.5*erfc(x/sqrt(2));
g   = 10^(5/10);
N0  = Es / (2*g);                         % Eb = Es/2
out = sim(mdl);
fprintf('\nEb/N0 = 5 dB : TEB = %.2e (théorie Q(sqrt(2Eb/N0)) = %.2e)\n', ...
        nnz(out.emis ~= out.recu) / numel(out.emis), Q(sqrt(2*g)));