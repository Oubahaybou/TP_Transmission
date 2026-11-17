clear; clc;
parametres;
out = sim('cbs');

emis = out.emis(:);
recu = out.recu(:);
Nb   = numel(emis);
nerr = sum(emis ~= recu);            % nombre d'erreurs
TEB  = nerr / Nb;
ic   = 1.96 * sqrt(pe*(1-pe)/Nb);    % demi-largeur de l'IC à 95 %

fprintf('Bits simulés      : %d\n', Nb);
fprintf('Erreurs           : %d\n', nerr);
fprintf('TEB mesuré        : %.4f\n', TEB);
fprintf('pe                : %.4f\n', pe);
fprintf('Intervalle à 95 %% : [%.4f ; %.4f]\n', pe-ic, pe+ic);
fprintf('Compatible        : %d\n', abs(TEB-pe) <= ic);