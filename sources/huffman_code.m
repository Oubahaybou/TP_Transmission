function bits = huffman_code(seq, code, symb)
% Remplace chaque symbole de seq par son mot de code. Rend un vecteur de 0 et de 1.
    [~, idx] = ismember(seq(:), symb);   % numéro de chaque symbole dans l'alphabet
    bits = [code{idx}] - '0';            % mots mis bout à bout, puis texte -> nombres
end