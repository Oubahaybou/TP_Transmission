clear; clc;
fichier = 'texte_fr.txt';
texte = fileread(fichier, 'Encoding', 'UTF-8');
c = double(texte);
N = numel(c);

%% Code de Huffman du texte
[H, symb, p] = entropie(c);
code = huffman(p);
len  = cellfun(@numel, code);
Lmoy = sum(p .* len);

fprintf('Entropie H         : %.4f bit/car\n', H);
fprintf('Longueur moyenne L : %.4f bit/car\n', Lmoy);
fprintf('Efficacité H/L     : %.2f %%\n', 100*H/Lmoy);
fprintf('H <= L < H+1       : %d\n', H <= Lmoy && Lmoy < H+1);
fprintf('Mots de %d à %d bits\n', min(len), max(len));

%% Codeur, décodeur, vérification
bits  = huffman_code(c, code, symb);
c_dec = huffman_decode(bits, code, symb);
fprintf('Texte restitué sans erreur : %d\n', isequal(c(:), c_dec(:)));

%% Taux de compression (référence : 8 bits par caractère)
fprintf('Taille initiale    : %d bits\n', 8*N);
fprintf('Taille compressée  : %d bits\n', numel(bits));
fprintf('Taux de compression: %.3f (gain de %.1f %%)\n', ...
        8*N/numel(bits), 100*(1 - numel(bits)/(8*N)));

%% Question 6 : coût de la table de codage
M     = numel(symb);                    % taille de l'alphabet
nbLen = ceil(log2(max(len) + 1));       % bits pour écrire une longueur
cout  = M*(8 + nbLen) + sum(len);       % caractère + longueur + mot

fprintf('\n--- Question 6 ---\n');
fprintf('Coût de la table          : %d bits\n', cout);
fprintf('Part du message compressé : %.1f %%\n', 100*cout/numel(bits));
fprintf('Taux avec la table        : %.3f (gain de %.1f %%)\n', ...
        8*N/(numel(bits) + cout), 100*(1 - (numel(bits) + cout)/(8*N)));
fprintf('Rentable à partir de      : %.0f caractères\n', cout/(8 - Lmoy));
fprintf('Table < 1 %% à partir de   : %.0f caractères\n', 100*cout/Lmoy);