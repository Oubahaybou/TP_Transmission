% creer_chaine_texte.m - copie de chaine_hamming avec une source From Workspace (partie 7, Q3)
clear; clc; close all;
src = 'chaine_hamming';
mdl = 'chaine_texte';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
if bdIsLoaded(src), close_system(src, 0); end
load_system(src);
save_system(src, mdl);                     % copie du modèle sous le nouveau nom
open_system(mdl);

% Remplacement de la source aléatoire par les bits du texte
supprimer([mdl '/Source 4 bits']);
supprimer([mdl '/Bits']);
add_block('simulink/Sources/From Workspace', [mdl '/Texte'], 'VariableName', 'bits_in', ...
          'SampleTime', '4*Tb', 'Interpolate', 'off', ...
          'OutputAfterFinalValue', 'Holding final value');
add_line(mdl, 'Texte/1', 'Bits double/1', 'autorouting', 'on');
save_system(mdl);
fprintf('Modèle %s.slx créé.\n', mdl);

function supprimer(blk)
% Supprime un bloc et les fils qui y sont branchés
    if getSimulinkBlockHandle(blk) > 0
        lh = get_param(blk, 'LineHandles');
        l  = [lh.Inport lh.Outport];
        delete_line(l(l > 0));
        delete_block(blk);
    end
end