% creer_detecteur.m - chaîne à L échantillons par bit et détecteur optimal (partie 3, Q10)
clear; clc;
parametres;
mdl = 'detecteur_optimal';

if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
new_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'FixedStepDiscrete', ...
               'FixedStep', 'Te', 'StopTime', 'N*Tb - Te');

%% 1) Source binaire équiprobable, cadencée à Tb
src = [mdl '/Source binaire'];
add_block('built-in/Subsystem', src, 'Position', [30 90 130 140]);
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
set_param(src, 'p1', '0.5');                         % bits équiprobables

%% 2) Émetteur : niveau ±A répété sur L échantillons
emt = [mdl '/Emetteur'];
add_block('built-in/Subsystem', emt, 'Position', [180 90 280 140]);
add_block('built-in/Inport', [emt '/bit']);
add_block('simulink/Math Operations/Gain', [emt '/Gain'], 'Gain', '2*A');
add_block('simulink/Math Operations/Bias', [emt '/Bias'], 'Bias', '-A');
add_block('simulink/Signal Attributes/Rate Transition', [emt '/Sur-echantillonnage'], ...
          'OutPortSampleTime', 'Te');
add_block('built-in/Outport', [emt '/x']);
add_line(emt, 'bit/1', 'Gain/1');
add_line(emt, 'Gain/1', 'Bias/1');
add_line(emt, 'Bias/1', 'Sur-echantillonnage/1');
add_line(emt, 'Sur-echantillonnage/1', 'x/1');
masquer(emt, {'A','Te'}, {'Amplitude A','Période d''échantillonnage Te'});

%% 3) Canal gaussien : bruit de variance sig2 sur chaque échantillon
can = [mdl '/Canal gaussien'];
add_block('built-in/Subsystem', can, 'Position', [330 90 430 140]);
add_block('built-in/Inport', [can '/x']);
add_block('simulink/Sources/Random Number', [can '/Bruit'], ...
          'Mean', '0', 'Variance', 'sig2', 'Seed', 'round(graine)+5000', 'SampleTime', 'Te');
add_block('simulink/Math Operations/Sum', [can '/Somme'], 'Inputs', '++');
add_block('built-in/Outport', [can '/r']);
add_line(can, 'x/1', 'Somme/1');
add_line(can, 'Bruit/1', 'Somme/2');
add_line(can, 'Somme/1', 'r/1');
masquer(can, {'sig2','Te','graine'}, {'Variance par échantillon','Te','Graine'});

%% 4) Détecteur optimal : intégrateur sur Tb, échantillonneur, comparateur
dtc = [mdl '/Detecteur optimal'];
add_block('built-in/Subsystem', dtc, 'Position', [480 90 580 140]);
add_block('built-in/Inport', [dtc '/r']);
add_block('simulink/Discrete/Discrete FIR Filter', [dtc '/Integrateur'], ...
          'Coefficients', 'ones(1,L)/L', 'SampleTime', 'Te');
add_block('simulink/Discrete/Zero-Order Hold', [dtc '/Echantillonneur'], ...
          'SampleTime', '[Tb (L-1)*Te]');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [dtc '/Comparateur'], ...
          'relop', '>', 'const', '0');
add_block('simulink/Signal Attributes/Data Type Conversion', [dtc '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [dtc '/bit recu']);
add_line(dtc, 'r/1', 'Integrateur/1');
add_line(dtc, 'Integrateur/1', 'Echantillonneur/1');
add_line(dtc, 'Echantillonneur/1', 'Comparateur/1');
add_line(dtc, 'Comparateur/1', 'Conversion/1');
add_line(dtc, 'Conversion/1', 'bit recu/1');
masquer(dtc, {'L','Te','Tb'}, {'Échantillons par bit L','Te','Tb'});

%% 5) Liaisons et enregistrement
add_block('simulink/Sinks/To Workspace', [mdl '/emis'], 'VariableName', 'emis', ...
          'SaveFormat', 'Array', 'Position', [180 190 260 220]);
add_block('simulink/Sinks/To Workspace', [mdl '/recu'], 'VariableName', 'recu', ...
          'SaveFormat', 'Array', 'Position', [630 100 710 130]);
add_line(mdl, 'Source binaire/1',    'Emetteur/1',          'autorouting', 'on');
add_line(mdl, 'Source binaire/1',    'emis/1',              'autorouting', 'on');
add_line(mdl, 'Emetteur/1',          'Canal gaussien/1',    'autorouting', 'on');
add_line(mdl, 'Canal gaussien/1',    'Detecteur optimal/1', 'autorouting', 'on');
add_line(mdl, 'Detecteur optimal/1', 'recu/1',              'autorouting', 'on');

save_system(mdl);
fprintf('Modèle %s.slx créé (L = %d, Eb/N0 = %g dB, sigma^2 = %.4f).\n', mdl, L, EbN0dB, sig2);

%% 6) Vérification à Eb/N0 = 5 dB
Q   = @(x) 0.5*erfc(x/sqrt(2));
out = sim(mdl);
e = out.emis(:);  b = out.recu(:);
fprintf('Bits émis / reçus : %d / %d\n', numel(e), numel(b));
fprintf('TEB simulé        : %.5f\n', mean(e ~= b));
fprintf('TEB théorique     : %.5f\n', Q(sqrt(2*10^(EbN0dB/10))));

%% ------------------------------------------------------------------
function masquer(blk, noms, textes)
    m = Simulink.Mask.create(blk);
    for i = 1:numel(noms)
        m.addParameter('Type', 'edit', 'Name', noms{i}, ...
                       'Prompt', textes{i}, 'Value', noms{i});
    end
    try, Simulink.BlockDiagram.arrangeSystem(blk); catch, end
end