clear; close all; clc;

%% 1) Le texte : roman complet et 5000 premiers caractères
roman = fileread('roman.txt', 'Encoding', 'UTF-8');
fprintf('Roman complet       : %.3f bits/car\n', lz78_bits(roman));
fprintf('Roman, 5000 car.    : %.3f bits/car\n', lz78_bits(roman(1:5000)));

%% 2) Source binaire de probabilité p1_ext
p1e = 0.11;                                   % même valeur qu'à la question 7
H   = -p1e*log2(p1e) - (1-p1e)*log2(1-p1e);
rng(1);
b   = source(1e6, p1e);                       % un seul tirage de 10^6 bits

Ns  = [1e3 3e3 1e4 3e4 1e5 3e5 1e6];          % longueurs des messages
R   = zeros(size(Ns));
for i = 1:numel(Ns)
    R(i) = lz78_bits(b(1:Ns(i)));             % début du même tirage
    fprintf('N = %7d bits : %.4f bit/bit\n', Ns(i), R(i));
end
fprintf('Entropie H = %.4f bit/bit\n', H);

figure;
semilogx(Ns, R, 'bo-', 'LineWidth', 1.5); hold on;
semilogx(Ns, H*ones(size(Ns)), 'k--', 'LineWidth', 1.2);
semilogx(Ns, ones(size(Ns)), 'r:', 'LineWidth', 1.2);
grid on;
xlabel('Longueur du message N (bits)');
ylabel('Bits LZ78 par bit de source');
title(sprintf('LZ78 sur une source binaire (p_1 = %.2f)', p1e));
legend('LZ78', 'Entropie H', 'Sans compression (1 bit/bit)');

%% ------------------------------------------------------------------
function r = lz78_bits(seq)
% Nombre de bits par symbole du codage LZ78 (formule du sujet)
    [idx, ~] = lz78_code(seq);
    n = numel(idx);                           % nombre de couples
    A = numel(unique(seq));                   % taille de l'alphabet
    nbits = sum(ceil(log2(1:n))) + n*ceil(log2(A));
    r = nbits / numel(seq);
end