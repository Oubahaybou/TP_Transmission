% ajouter_sans_integration.m - ajoute un détecteur à un seul échantillon (partie 3, Q12)
% Relançable sans erreur : supprime l'ancienne branche et les fils orphelins.
clear; clc;
parametres;
mdl = 'detecteur_optimal';
load_system(mdl);  open_system(mdl);
set_param(mdl, 'SolverMode', 'SingleTasking');      % pas de retard dans le Rate Transition

%% 1) Nettoyage : ancienne branche et fils non connectés
sdi = [mdl '/Detecteur sans integration'];
blk = [mdl '/recu_sans'];
supprimer(sdi);
supprimer(blk);
nettoyer_fils(mdl);

%% 2) Détecteur sans intégration : échantillon du milieu du bit, puis comparateur
add_block('built-in/Subsystem', sdi, 'Position', [480 190 580 240]);
add_block('built-in/Inport', [sdi '/r']);
add_block('simulink/Discrete/Zero-Order Hold', [sdi '/Echantillon milieu'], ...
          'SampleTime', '[Tb floor(L/2)*Te]');
add_block('simulink/Logic and Bit Operations/Compare To Constant', [sdi '/Comparateur'], ...
          'relop', '>', 'const', '0');
add_block('simulink/Signal Attributes/Data Type Conversion', [sdi '/Conversion'], ...
          'OutDataTypeStr', 'double');
add_block('built-in/Outport', [sdi '/bit recu']);
add_line(sdi, 'r/1', 'Echantillon milieu/1');
add_line(sdi, 'Echantillon milieu/1', 'Comparateur/1');
add_line(sdi, 'Comparateur/1', 'Conversion/1');
add_line(sdi, 'Conversion/1', 'bit recu/1');

add_block('simulink/Sinks/To Workspace', blk, 'VariableName', 'recu_sans', ...
          'SaveFormat', 'Array', 'Position', [630 200 710 230]);

%% 3) Liaisons
add_line(mdl, 'Canal gaussien/1', 'Detecteur sans integration/1', 'autorouting', 'on');
add_line(mdl, 'Detecteur sans integration/1', 'recu_sans/1', 'autorouting', 'on');
save_system(mdl);
fprintf('Branche sans intégration ajoutée.\n');

%% 4) Vérification à Eb/N0 = 5 dB
Q = @(x) 0.5*erfc(x/sqrt(2));
out = sim(mdl);
e = out.emis(:);
fprintf('Avec intégration : TEB = %.5f (théorie %.5f)\n', ...
        mean(e ~= out.recu(:)),      Q(sqrt(2*10^(EbN0dB/10))));
fprintf('Sans intégration : TEB = %.5f (théorie %.5f)\n', ...
        mean(e ~= out.recu_sans(:)), Q(sqrt(2*10^(EbN0dB/10)/L)));

%% ------------------------------------------------------------------
function supprimer(blk)
% Supprime un bloc ET les fils qui y sont branchés
    if getSimulinkBlockHandle(blk) > 0
        lh = get_param(blk, 'LineHandles');
        l  = [lh.Inport lh.Outport];
        delete_line(l(l > 0));
        delete_block(blk);
    end
end

function nettoyer_fils(mdl)
% Supprime les fils dont une extrémité n'est branchée à rien
    fils = find_system(mdl, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'line');
    for h = fils'
        if ~ishandle(h), continue; end
        if get_param(h, 'SrcBlockHandle') < 0 || any(get_param(h, 'DstBlockHandle') < 0)
            delete_line(h);
        end
    end
end