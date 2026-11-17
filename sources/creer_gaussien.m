% creer_gaussien.m - construit le modèle canal_gaussien.slx (partie 3, question 8)
% Graines : round(graine) pour la source, round(graine)+5000 pour le bruit.
clear; clc;
parametres;
s = sigma^2/(2*A) * log((1-p1)/p1);           % valeur initiale du seuil
mdl = 'canal_gaussien';

if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', 'Tb', 'StopTime', '(N-1)*Tb');

%% 1) Source binaire : U < p1 -> bit
src = [mdl '/Source binaire'];
add_block('built-in/Subsystem', src, 'Position', [40 90 140 140]);
add_block('simulink/Sources/Uniform Random Number', [src '/Uniforme'], ...
          'Minimum', '0', 'Maximum', '1', 'Seed', 'round(graine)', 'SampleTime', 'Tb');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [src '/Comparaison'], ...
          'relop', '<', 'const', 'p1');
add_block('simulink/Signal Attributes/Data Type Conversion', [src '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [src '/bit']);
add_line(src, 'Uniforme/1', 'Comparaison/1');
add_line(src, 'Comparaison/1', 'Conversion/1');
add_line(src, 'Conversion/1', 'bit/1');
masquer(src, {'p1','Tb','graine'}, {'Probabilité d''un 1','Durée d''un bit','Graine'});

%% 2) Émetteur : x = 2A*bit - A  (0 -> -A, 1 -> +A)
emt = [mdl '/Emetteur'];
add_block('built-in/Subsystem', emt, 'Position', [200 90 300 140]);
add_block('built-in/Inport', [emt '/bit']);
add_block('simulink/Math Operations/Gain', [emt '/Gain'], 'Gain', '2*A');
add_block('simulink/Math Operations/Bias', [emt '/Bias'], 'Bias', '-A');
add_block('built-in/Outport', [emt '/x']);
add_line(emt, 'bit/1', 'Gain/1');
add_line(emt, 'Gain/1', 'Bias/1');
add_line(emt, 'Bias/1', 'x/1');
masquer(emt, {'A'}, {'Amplitude A'});

%% 3) Canal gaussien : r = x + n, n gaussien centré d'écart-type sigma
can = [mdl '/Canal gaussien'];
add_block('built-in/Subsystem', can, 'Position', [360 90 460 140]);
add_block('built-in/Inport', [can '/x']);
add_block('simulink/Sources/Random Number', [can '/Bruit'], ...
          'Mean', '0', 'Variance', 'sigma^2', 'Seed', 'round(graine)+5000', 'SampleTime', 'Tb');
add_block('simulink/Math Operations/Sum', [can '/Somme'], 'Inputs', '++');
add_block('built-in/Outport', [can '/r']);
add_line(can, 'x/1', 'Somme/1');
add_line(can, 'Bruit/1', 'Somme/2');
add_line(can, 'Somme/1', 'r/1');
masquer(can, {'sigma','Tb','graine'}, {'Écart-type du bruit sigma','Durée d''un bit','Graine'});

%% 4) Décision : bit reçu = 1 si r > s
dec = [mdl '/Decision'];
add_block('built-in/Subsystem', dec, 'Position', [520 90 620 140]);
add_block('built-in/Inport', [dec '/r']);
add_block('simulink/Logic and Bit Operations/Compare To Constant', [dec '/Seuil'], ...
          'relop', '>', 'const', 's');
add_block('simulink/Signal Attributes/Data Type Conversion', [dec '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [dec '/bit recu']);
add_line(dec, 'r/1', 'Seuil/1');
add_line(dec, 'Seuil/1', 'Conversion/1');
add_line(dec, 'Conversion/1', 'bit recu/1');
masquer(dec, {'s'}, {'Seuil de décision s'});

%% 5) Liaisons et enregistrement
add_block('simulink/Sinks/To Workspace', [mdl '/emis'], 'VariableName', 'emis', ...
          'SaveFormat', 'Array', 'Position', [200 190 280 220]);
add_block('simulink/Sinks/To Workspace', [mdl '/recu'], 'VariableName', 'recu', ...
          'SaveFormat', 'Array', 'Position', [680 100 760 130]);
add_line(mdl, 'Source binaire/1', 'Emetteur/1',       'autorouting', 'on');
add_line(mdl, 'Source binaire/1', 'emis/1',           'autorouting', 'on');
add_line(mdl, 'Emetteur/1',       'Canal gaussien/1', 'autorouting', 'on');
add_line(mdl, 'Canal gaussien/1', 'Decision/1',       'autorouting', 'on');
add_line(mdl, 'Decision/1',       'recu/1',           'autorouting', 'on');

save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

%% 6) Vérification : erreurs par type de bit, au seuil optimal
Q = @(x) 0.5*erfc(x/sqrt(2));
out = sim(mdl);
e = out.emis(:);  b = out.recu(:);
fprintf('Proportion de 1 émis : %.4f\n', mean(e));
fprintf('P(e|0) = %.4f (théorie %.4f)\n', mean(b(e==0) == 1), Q((s + A)/sigma));
fprintf('P(e|1) = %.4f (théorie %.4f)\n', mean(b(e==1) == 0), Q((A - s)/sigma));

%% ------------------------------------------------------------------
function masquer(blk, noms, textes)
    m = Simulink.Mask.create(blk);
    for i = 1:numel(noms)
        m.addParameter('Type', 'edit', 'Name', noms{i}, ...
                       'Prompt', textes{i}, 'Value', noms{i});
    end
    try, Simulink.BlockDiagram.arrangeSystem(blk); catch, end
end