clear; clc;
roman = fileread('roman.txt',    'Encoding', 'UTF-8');
prof  = fileread('texte_fr.txt', 'Encoding', 'UTF-8');

comparer(roman,            'Roman complet');
comparer(roman(1:5000),    'Roman, 5000 premiers caractères');
comparer(prof,             'Texte du prof');

%% ------------------------------------------------------------------
function comparer(t, nom)
    c = double(t);
    N = numel(c);

    % Entropie d'ordre 0, code fixe, Huffman
    [H0, symb, p] = entropie(c);
    Lfixe = ceil(log2(numel(symb)));
    code  = huffman(p);
    Lhuff = sum(p .* cellfun(@numel, code));

    % Entropie des paires de caractères consécutifs
    paires = c(1:end-1) * 65536 + c(2:end);   % chaque paire -> un seul nombre
    H2 = entropie(paires) / 2;

    % gzip : on écrit le texte dans un fichier, on le compresse, on mesure
    f = 'tmp_q8.txt';
    fid = fopen(f, 'w', 'n', 'UTF-8');  fprintf(fid, '%s', t);  fclose(fid);
    gzip(f);
    d0 = dir(f);            d1 = dir([f '.gz']);
    Lfich = d0.bytes * 8 / N;                  % fichier UTF-8 non compressé
    Lgz   = d1.bytes * 8 / N;                  % fichier gzip
    delete(f);  delete([f '.gz']);

    fprintf('\n=== %s (%d caractères) ===\n', nom, N);
    fprintf('Fichier UTF-8 brut    : %.3f bits/car\n', Lfich);
    fprintf('Code de longueur fixe : %d bits/car\n',   Lfixe);
    fprintf('Entropie d''ordre 0    : %.3f bits/car\n', H0);
    fprintf('Huffman               : %.3f bits/car\n', Lhuff);
    fprintf('H(X1X2)/2             : %.3f bits/car\n', H2);
    fprintf('gzip                  : %.3f bits/car\n', Lgz);
    fprintf('Paires différentes    : %d\n', numel(unique(paires)));
end