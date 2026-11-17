function [idx, sym] = lz78_code(seq)
% Codeur LZ78 : rend les couples (indice de la phrase connue, symbole ajouté)
    seq = double(seq(:)');
    dico = containers.Map('KeyType', 'double', 'ValueType', 'double');
    parent = zeros(1, numel(seq));   % pour chaque phrase : indice de la phrase connue
    dernier = zeros(1, numel(seq));  % pour chaque phrase : symbole ajouté
    nc = 0;                          % nombre de phrases (= nombre de couples)
    courant = 0;                     % phrase en cours de lecture (0 = vide)

    for s = seq
        cle = courant*65536 + s;     % code unique pour (phrase courante, symbole)
        if isKey(dico, cle)
            courant = dico(cle);     % phrase connue : on continue à lire
        else
            nc = nc + 1;             % phrase nouvelle : on émet un couple
            parent(nc) = courant;
            dernier(nc) = s;
            dico(cle) = nc;          % et on l'ajoute au dictionnaire
            courant = 0;
        end
    end
    if courant > 0                   % le message finit sur une phrase déjà connue
        nc = nc + 1;
        parent(nc)  = parent(courant);
        dernier(nc) = dernier(courant);
    end
    idx = parent(1:nc);
    sym = dernier(1:nc);
end