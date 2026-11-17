% creer_cbs.m - construit automatiquement le modèle cbs.slx (partie 3, question 1)
clear; clc;
parametres;                                   % pe, p1, Tb, graine, N
mdl = 'cbs';

% Repartir d'un modèle vide
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);
open_system(mdl);

% Solveur : pas fixe, discret, un pas par bit
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', 'Tb', 'StopTime', '(N-1)*Tb');

%% 1) Sous-système "Source binaire" : U < p1 -> bit
src = [mdl '/Source binaire'];
add_block('built-in/Subsystem', src, 'Position', [50 90 150 140]);
add_block('simulink/Sources/Uniform Random Number', [src '/Uniforme'], ...
          'Minimum', '0', 'Maximum', '1', 'Seed', 'graine', 'SampleTime', 'Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [src '/Comparaison'], ...
          'relop', '<', 'const', 'p1');
add_block('simulink/Signal Attributes/Data Type Conversion', [src '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [src '/bit']);
add_line(src, 'Uniforme/1',    'Comparaison/1');
add_line(src, 'Comparaison/1', 'Conversion/1');
add_line(src, 'Conversion/1',  'bit/1');
masquer(src, {'p1', 'Tb', 'graine'}, ...
        {'Probabilité d''émettre un 1', 'Durée d''un bit Tb', 'Graine'});

%% 2) Sous-système "CBS" : bit reçu = bit émis XOR erreur, avec P(erreur) = pe
cbs = [mdl '/CBS'];
add_block('built-in/Subsystem', cbs, 'Position', [250 90 350 140]);
add_block('built-in/Inport', [cbs '/bit emis']);
add_block('simulink/Sources/Uniform Random Number', [cbs '/Uniforme'], ...
          'Minimum', '0', 'Maximum', '1', 'Seed', 'graine+1', 'SampleTime', 'Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [cbs '/Erreur'], ...
          'relop', '<', 'const', 'pe');
add_block('simulink/Logic and Bit Operations/Logical Operator', [cbs '/XOR'], ...
          'Operator', 'XOR', 'Inputs', '2');
add_block('simulink/Signal Attributes/Data Type Conversion', [cbs '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [cbs '/bit recu']);
add_line(cbs, 'bit emis/1',   'XOR/1');
add_line(cbs, 'Uniforme/1',   'Erreur/1');
add_line(cbs, 'Erreur/1',     'XOR/2');
add_line(cbs, 'XOR/1',        'Conversion/1');
add_line(cbs, 'Conversion/1', 'bit recu/1');
masquer(cbs, {'pe', 'Tb', 'graine'}, ...
        {'Probabilité d''erreur pe', 'Durée d''un bit Tb', 'Graine'});

%% 3) Enregistrement des bits émis et reçus
add_block('simulink/Sinks/To Workspace', [mdl '/emis'], ...
          'VariableName', 'emis', 'SaveFormat', 'Array', 'Position', [250 180 330 210]);
add_block('simulink/Sinks/To Workspace', [mdl '/recu'], ...
          'VariableName', 'recu', 'SaveFormat', 'Array', 'Position', [450 100 530 130]);
add_line(mdl, 'Source binaire/1', 'CBS/1',  'autorouting', 'on');
add_line(mdl, 'Source binaire/1', 'emis/1', 'autorouting', 'on');
add_line(mdl, 'CBS/1',            'recu/1', 'autorouting', 'on');

save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

%% 4) Test rapide
out = sim(mdl);
fprintf('Bits simulés           : %d\n', numel(out.emis));
fprintf('Proportion de 1 émis   : %.4f (p1 = %.2f)\n', mean(out.emis), p1);
fprintf('Proportion de bits faux: %.4f (pe = %.3f)\n', mean(out.emis ~= out.recu), pe);

%% ------------------------------------------------------------------
function masquer(blk, noms, textes)
% Crée le masque d'un sous-système : un champ par paramètre,
% rempli avec la variable du même nom du script de paramètres.
    m = Simulink.Mask.create(blk);
    for i = 1:numel(noms)
        m.addParameter('Type', 'edit', 'Name', noms{i}, ...
                       'Prompt', textes{i}, 'Value', noms{i});
    end
    try
        Simulink.BlockDiagram.arrangeSystem(blk);   % range les blocs internes
    catch
    end
end