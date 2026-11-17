clear; close all; clc;
parametres;
Ac  = A * sqrt(4/7);
mdl = 'chaine_hamming';
load_system(mdl);
Q = @(x) 0.5*erfc(x/sqrt(2));

EbN0_list = 0:9;
TEB_nc = zeros(size(EbN0_list));   TEB_c = TEB_nc;   Nbits = TEB_nc;

for i = 1:numel(EbN0_list)
    EbN0dB = EbN0_list(i);
    g      = 10^(EbN0dB/10);
    sig2   = A^2 * L / (2*g);                         % variance par échantillon
    N      = 4 * ceil(min(max(1e5, 200/pb_hamming(g)), 1e7) / 4);
    out    = sim(mdl);
    Nbits(i)  = numel(out.emis);
    TEB_nc(i) = nnz(out.emis ~= out.m_nc)  / Nbits(i);
    TEB_c(i)  = nnz(out.emis ~= out.m_dec) / Nbits(i);
    fprintf('%d dB : %8d bits | sans codage %.2e (th. %.2e) | avec codage %.2e (th. %.2e)\n', ...
            EbN0dB, Nbits(i), TEB_nc(i), Q(sqrt(2*g)), TEB_c(i), pb_hamming(g));
end
save('resultats_q10.mat', 'EbN0_list', 'TEB_nc', 'TEB_c', 'Nbits');

%% Limites de Shannon
R    = 4/7;
limR = 10*log10((2^(2*R) - 1) / (2*R));              % limite pour R = 4/7
lim0 = 10*log10(log(2));                             % limite absolue
fprintf('\nLimite de Shannon pour R = 4/7 : %.2f dB\n', limR);
fprintf('Limite absolue ln 2           : %.2f dB\n', lim0);

%% Tracé
x = linspace(0, 9, 300);
figure;
semilogy(x, Q(sqrt(2*10.^(x/10))), 'b-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_list, TEB_nc, 'bo', 'MarkerFaceColor', 'b');
semilogy(x, arrayfun(@pb_hamming, 10.^(x/10)), 'r-', 'LineWidth', 1.5);
semilogy(EbN0_list, TEB_c, 'rs', 'MarkerFaceColor', 'r');
xline(limR, 'k--', sprintf('Shannon R = 4/7 : %.2f dB', limR), 'LabelVerticalAlignment', 'bottom');
xline(lim0, 'k:',  sprintf('Limite absolue : %.2f dB', lim0), 'LabelVerticalAlignment', 'bottom');
grid on;  xlim([-2 10]);  ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title('Chaîne avec et sans codage de Hamming (7,4)');
legend('Sans codage : théorie', 'Sans codage : simulation', ...
       'Hamming : théorie (Q8)', 'Hamming : simulation', 'Location', 'southwest');

%% ------------------------------------------------------------------
function Pb = pb_hamming(g)
% Probabilité d'erreur par bit après décodage (formule de la question 8)
    Q  = @(x) 0.5*erfc(x/sqrt(2));
    p  = Q(sqrt(2*4/7*g));
    j  = 2:7;
    Pb = sum(j/7 .* arrayfun(@(k) nchoosek(7, k), j) .* p.^j .* (1-p).^(7-j));
end