function seq = huffman_decode(bits, code, symb)
% Retrouve la séquence de symboles à partir des bits.

    % 1) Reconstruction de l'arbre à partir de la table de codage
    fils = [0 0];        % fils(n, b+1) = noeud atteint depuis n en lisant le bit b
    feuille = 0;         % feuille(n) = numéro du symbole si n est une feuille
    nb = 1;              % nombre de noeuds (le noeud 1 est la racine)
    for i = 1:numel(code)
        n = 1;
        for b = code{i} - '0'
            if fils(n, b+1) == 0             % branche pas encore créée
                nb = nb + 1;
                fils(nb, :) = [0 0];  feuille(nb) = 0;
                fils(n, b+1) = nb;
            end
            n = fils(n, b+1);
        end
        feuille(n) = i;
    end

    % 2) Décodage : on descend dans l'arbre bit par bit
    seq = zeros(1, numel(bits));  ns = 0;  n = 1;
    for b = bits(:)'
        n = fils(n, b+1);
        if feuille(n) > 0                    % feuille atteinte : un symbole décodé
            ns = ns + 1;
            seq(ns) = symb(feuille(n));
            n = 1;                           % retour à la racine
        end
    end
    seq = seq(1:ns);
end