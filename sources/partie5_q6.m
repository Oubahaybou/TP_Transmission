clear; close all; clc;
parametres;
mdl = 'chaine_qpsk_hamming';  load_system(mdl);
Q  = @(x) 0.5*erfc(x/sqrt(2));
Eb = 7/8;                                       % Es = 1 = (8/7) Eb

EbN0_list = 0:9;
TEB_qh = zeros(size(EbN0_list));
for i = 1:numel(EbN0_list)
    g   = 10^(EbN0_list(i)/10);
    N0  = Eb / g;
    N   = 8 * ceil(min(max(1e5, 200/pb_hamming(g)), 1e7) / 8);
    out = sim(mdl);
    TEB_qh(i) = nnz(out.emis ~= out.m_dec) / numel(out.emis);
    fprintf('%d dB : %8d bits | QPSK + Hamming %.2e | formule Q8 %.2e\n', ...
            EbN0_list(i), numel(out.emis), TEB_qh(i), pb_hamming(g));
end

% Comparaison avec la partie 4 (fichier enregistré par partie4_q10.m)
P4 = load('resultats_q10.mat');
x  = linspace(0, 9, 300);
figure;
semilogy(x, Q(sqrt(2*10.^(x/10))), 'b-', 'LineWidth', 1.2); hold on;
semilogy(P4.EbN0_list, P4.TEB_c, 'ks', 'MarkerSize', 9, 'LineWidth', 1.2);
semilogy(EbN0_list, TEB_qh, 'r*', 'MarkerSize', 8, 'LineWidth', 1.2);
semilogy(x, arrayfun(@pb_hamming, 10.^(x/10)), 'r-', 'LineWidth', 1.2);
grid on;  ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title('Code de Hamming : modulation binaire (partie 4) et QPSK');
legend('Sans codage : Q(\surd(2E_b/N_0))', 'Hamming + binaire (partie 4)', ...
       'Hamming + QPSK (simulation)', 'Hamming : formule Q8', 'Location', 'southwest');

function Pb = pb_hamming(g)
    Q  = @(x) 0.5*erfc(x/sqrt(2));
    p  = Q(sqrt(2*4/7*g));   j = 2:7;
    Pb = sum(j/7 .* arrayfun(@(k) nchoosek(7, k), j) .* p.^j .* (1-p).^(7-j));
end