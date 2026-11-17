clear; clc;

%% Validation sur l'exemple du sujet
msg = 'ABAABABAABAB';
[idx, sym] = lz78_code(msg);

fprintf('Couples : ');
for i = 1:numel(idx)
    fprintf('(%d, %s) ', idx(i), char(sym(i)));
end
fprintf('\n');

dec = lz78_decode(idx, sym);
fprintf('Décodé  : %s\n', char(dec));
fprintf('Restitution exacte : %d\n', isequal(char(dec), msg));

%% Coût en bits (formule du sujet)
n = numel(idx);
A = numel(unique(msg));                       % taille de l'alphabet
bits_idx = sum(ceil(log2(1:n)));              % le i-ème indice coûte ceil(log2 i) bits
bits_sym = n * ceil(log2(A));
fprintf('Coût : %d bits (%d pour les indices, %d pour les symboles)\n', ...
        bits_idx + bits_sym, bits_idx, bits_sym);
fprintf('Soit %.3f bits par symbole\n', (bits_idx + bits_sym) / numel(msg));

%% Test sur le texte du prof
texte = fileread('texte_fr.txt', 'Encoding', 'UTF-8');
[idx2, sym2] = lz78_code(texte);
fprintf('\nTexte du prof : %d couples, restitution exacte : %d\n', ...
        numel(idx2), isequal(lz78_decode(idx2, sym2), double(texte)));