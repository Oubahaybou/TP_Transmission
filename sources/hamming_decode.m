function m = hamming_decode(y)
% Décodeur par syndrome : y est une matrice K x 7, m une matrice K x 4.
    [~, H] = hamming_GH();
    s = mod(y * H', 2);                       % syndromes (K x 3)
    v = s * [4; 2; 1];                        % syndrome converti en nombre de 0 à 7
    tab = zeros(1, 7);                        % tab(v) = position de l'erreur
    for j = 1:7
        tab(H(:, j)' * [4; 2; 1]) = j;
    end
    k = find(v > 0);                          % mots à corriger
    lin = sub2ind(size(y), k, tab(v(k))');
    y(lin) = 1 - y(lin);                      % inversion du bit erroné
    m = y(:, 1:4);
end