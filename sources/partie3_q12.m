clear; close all; clc;
parametres;
mdl = 'detecteur_optimal';
load_system(mdl);
Q = @(x) 0.5*erfc(x/sqrt(2));

EbN0_list = 0:9;
TEB_avec = zeros(size(EbN0_list));   TEB_sans = TEB_avec;

for i = 1:numel(EbN0_list)
    EbN0dB = EbN0_list(i);
    sig2   = A^2 * L / (2 * 10^(EbN0dB/10));        % variance par échantillon
    Pth    = Q(sqrt(2*10^(EbN0dB/10)));
    N      = min(max(1e5, ceil(200/Pth)), 4e6);     % au moins ~200 erreurs attendues
    out    = sim(mdl);
    e = out.emis(:);

    [TEB_avec(i), d1] = teb_aligne(e, out.recu(:),      5);
    [TEB_sans(i), d2] = teb_aligne(e, out.recu_sans(:), 5);
    fprintf('%d dB : N = %7d, retards = %d/%d bit(s), TEB avec = %.2e (th. %.2e), sans = %.2e (th. %.2e)\n', ...
            EbN0dB, numel(e), d1, d2, TEB_avec(i), Pth, TEB_sans(i), Q(sqrt(2*10^(EbN0dB/10)/L)));
end

% Courbes
x = linspace(0, 9, 200);  g = 10.^(x/10);
figure;
semilogy(x, Q(sqrt(2*g)),   'b-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_list, TEB_avec, 'bo', 'MarkerFaceColor', 'b');
semilogy(x, Q(sqrt(2*g/L)), 'r-', 'LineWidth', 1.5);
semilogy(EbN0_list, TEB_sans, 'rs', 'MarkerFaceColor', 'r');
grid on;  ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title(sprintf('TEB de la chaîne de base (L = %d)', L));
legend('Théorie avec intégration', 'Simulation avec intégration', ...
       'Théorie sans intégration', 'Simulation sans intégration', 'Location', 'southwest');

%% ------------------------------------------------------------------
function [teb, d] = teb_aligne(e, b, dmax)
% Compare les bits émis e et reçus b pour des retards de 0 à dmax bits,
% et rend le TEB du meilleur alignement et le retard correspondant.
    teb = inf;  d = 0;
    for k = 0:dmax
        t = mean(e(1:end-k) ~= b(1+k:end));
        if t < teb, teb = t;  d = k; end
    end
end