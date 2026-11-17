% creer_chaine_rrc.m - chaîne QPSK avec filtre de mise en forme et filtre adapté (partie 6, Q5)
% Une seule cadence (Te). Coefficients des filtres dans la variable hcoef.
clear; clc; close all;
mdl = 'chaine_rrc';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', 'Te', 'StopTime', '1', 'SolverMode', 'SingleTasking');

add_block('simulink/Sources/From Workspace', [mdl '/Symboles'], 'VariableName', 'xin', ...
          'SampleTime', 'Te', 'Interpolate', 'off', 'OutputAfterFinalValue', 'Holding final value');
add_block('simulink/Discrete/Discrete FIR Filter', [mdl '/Filtre emission'], 'Coefficients', 'hcoef');
add_block('simulink/Sources/Random Number', [mdl '/Bruit I et Q'], 'Mean', '[0 0]', ...
          'Variance', 'N0/2*[1 1]', 'Seed', 'round(graine) + [50000 90000]', 'SampleTime', 'Te');
add_block('simulink/Math Operations/Sum', [mdl '/Canal'], 'Inputs', '++');
add_block('simulink/Discrete/Discrete FIR Filter', [mdl '/Filtre adapte'], 'Coefficients', 'hcoef');
add_block('simulink/Sinks/To Workspace', [mdl '/y'], 'VariableName', 'y', 'SaveFormat', 'Array');

add_line(mdl, 'Symboles/1',        'Filtre emission/1');
add_line(mdl, 'Filtre emission/1', 'Canal/1');
add_line(mdl, 'Bruit I et Q/1',    'Canal/2');
add_line(mdl, 'Canal/1',           'Filtre adapte/1');
add_line(mdl, 'Filtre adapte/1',   'y/1');
try, Simulink.BlockDiagram.arrangeSystem(mdl); catch, end
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);