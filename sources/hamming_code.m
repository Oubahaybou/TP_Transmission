function c = hamming_code(m)
% Codeur de Hamming (7,4) : m est une matrice K x 4, c une matrice K x 7.
    [G, ~] = hamming_GH();
    c = mod(m * G, 2);
end