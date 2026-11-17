function [G, H] = hamming_GH()
% Matrices du code de Hamming (7,4), g(x) = 1 + x + x^3, forme systématique
    P = [1 1 0; 0 1 1; 1 1 1; 1 0 1];
    G = [eye(4) P];
    H = [P' eye(3)];
end