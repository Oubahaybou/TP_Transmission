clear; clc;
roman = fileread('roman.txt',    'Encoding', 'UTF-8');
prof  = fileread('texte_fr.txt', 'Encoding', 'UTF-8');

analyser(roman, 'Roman complet');
analyser(prof,  'Texte du prof');

%% ------------------------------------------------------------------
function analyser(t, nom)
    c = double(t);
    [~, symb, p] = entropie(c);
    code = huffman(p);
    bits = huffman_code(c, code, symb);     % sortie du codeur de Huffman
    bits = bits(:)';
    Nb   = numel(bits);

    % Proportion de 1 et entropie d'un bit
    p1 = mean(bits);
    H1 = -p1*log2(p1) - (1-p1)*log2(1-p1);

    % Paires de bits consécutifs : 00 -> 0, 01 -> 1, 10 -> 2, 11 -> 3
    paires = 2*bits(1:end-1) + bits(2:end);
    [H2, ~, pp] = entropie(paires);

    fprintf('\n=== %s : %d bits en sortie de Huffman ===\n', nom, Nb);
    fprintf('Proportion de 1      : %.4f\n', p1);
    fprintf('Entropie d''un bit    : %.4f bit\n', H1);
    fprintf('H(paires)/2          : %.4f bit\n', H2/2);
    fprintf('Paires 00/01/10/11   : %.4f  %.4f  %.4f  %.4f\n', pp);
end