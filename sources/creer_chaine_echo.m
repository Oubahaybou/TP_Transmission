% creer_chaine_echo.m - chaîne QPSK + RRC avec canal à écho (partie 7, Q1-Q2)
% hc(t) = delta(t) + beta*delta(t - tau*T), coefficients dans la variable hc.
clear; clc; close all;
mdl = 'chaine_echo';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', 'Te', 'StopTime', '1', 'SolverMode', 'SingleTasking');

add_block('simulink/Sources/From Workspace', [mdl '/Symboles'], 'VariableName', 'xin', ...
          'SampleTime', 'Te', 'Interpolate', 'off', 'OutputAfterFinalValue', 'Holding final value');
add_block('simulink/Discrete/Discrete FIR Filter', [mdl '/Filtre emission'], 'Coefficients', 'hcoef');
add_block('simulink/Discrete/Discrete FIR Filter', [mdl '/Echo'],            'Coefficients', 'hc');
add_block('simulink/Sources/Random Number', [mdl '/Bruit I et Q'], 'Mean', '[0 0]', ...
          'Variance', 'N0/2*[1 1]', 'Seed', 'round(graine) + [50000 90000]', 'SampleTime', 'Te');
add_block('simulink/Math Operations/Sum', [mdl '/Canal'], 'Inputs', '++');
add_block('simulink/Discrete/Discrete FIR Filter', [mdl '/Filtre adapte'], 'Coefficients', 'hcoef');
add_block('simulink/Sinks/To Workspace', [mdl '/y'], 'VariableName', 'y', 'SaveFormat', 'Array');

add_line(mdl, 'Symboles/1',        'Filtre emission/1');
add_line(mdl, 'Filtre emission/1', 'Echo/1');
add_line(mdl, 'Echo/1',            'Canal/1');
add_line(mdl, 'Bruit I et Q/1',    'Canal/2');
add_line(mdl, 'Canal/1',           'Filtre adapte/1');
add_line(mdl, 'Filtre adapte/1',   'y/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);