clear; close all; clc;
P   = parametres_perso('Oubahaybou nouhayla');
p1e = P.p1_ext;                      % source très déséquilibrée
rng(P.graine);
fprintf('p1_ext = %.2f\n', p1e);

H  = -p1e*log2(p1e) - (1-p1e)*log2(1-p1e);   % entropie de la source
K  = 10;                                      % blocs de 1 à 10 bits
N  = 1e5;                                     % bits pour la vérification
b  = source(N, p1e);                          % les mêmes 10^5 bits pour tous les k

Lth = zeros(1, K);   Lmes = zeros(1, K);

for k = 1:K
    %% Code de Huffman des 2^k blocs
    v    = (0:2^k-1)';                        % numéro de chaque bloc
    w    = sum(dec2bin(v, k) == '1', 2);      % nombre de 1 dans chaque bloc
    prob = p1e.^w .* (1-p1e).^(k-w);          % probabilité de chaque bloc
    code = huffman(prob);
    len  = cellfun(@numel, code);
    Lth(k) = sum(prob .* len) / k;            % longueur moyenne par bit de source

    %% Vérification sur 10^5 bits de source
    nb     = floor(N/k);                      % nombre de blocs complets
    blocs  = reshape(b(1:nb*k), k, nb);       % un bloc par colonne
    idx    = 2.^(k-1:-1:0) * blocs;           % numéro de chaque bloc observé
    Lmes(k) = sum(len(idx+1)) / (nb*k);       % bits codés / bits de source

    fprintf('k = %2d : %4d blocs, L/k théorique = %.4f, mesuré = %.4f, borne = %.4f\n', ...
            k, 2^k, Lth(k), Lmes(k), H + 1/k);
end
fprintf('Entropie H = %.4f bit/bit\n', H);

%% Tracé
kk = 1:K;
figure;
plot(kk, Lth, 'bo-', 'LineWidth', 1.5); hold on;
plot(kk, Lmes, 'rx', 'MarkerSize', 9, 'LineWidth', 1.5);
plot(kk, H*ones(1,K), 'k--', 'LineWidth', 1.2);
plot(kk, H + 1./kk, 'g-.', 'LineWidth', 1.2);
grid on;
xlabel('Taille des blocs k (bits)');
ylabel('Bits codés par bit de source');
title(sprintf('Extension de la source (p_1 = %.2f)', p1e));
legend('L_k/k théorique', 'L_k/k mesuré (10^5 bits)', 'Entropie H', 'Borne H + 1/k');