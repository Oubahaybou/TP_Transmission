clear; close all; clc;
parametres;
p0 = 1 - p1;

% Probabilité d'erreur théorique en fonction du seuil s
pe0 = @(s) min(1, max(0, (a - A - s) / (2*a)));   % P(erreur | 0)
pe1 = @(s) min(1, max(0, (s - A + a) / (2*a)));   % P(erreur | 1)
Pe  = @(s) p0*pe0(s) + p1*pe1(s);

s_opt = a - A;
fprintf('Seuil optimal s*  : %.2f\n', s_opt);
fprintf('Pe(s*)            : %.4f  (formule p1(a-A)/a = %.4f)\n', Pe(s_opt), p1*(a-A)/a);
fprintf('Pe(0)             : %.4f\n', Pe(0));
fprintf('Rapport Pe(0)/Pe(s*) : %.2f\n', Pe(0)/Pe(s_opt));

s = linspace(-A-a, A+a, 1001);
figure;
plot(s, Pe(s), 'b', 'LineWidth', 1.5); hold on;
plot(s_opt, Pe(s_opt), 'ro', 'MarkerFaceColor', 'r');
xline(A-a, 'k:'); xline(a-A, 'k:');
grid on;
xlabel('Seuil s'); ylabel('P_e(s)');
title(sprintf('Bruit uniforme : P_e(s)  (a = %.2f, p_1 = %.2f)', a, p1));
legend('P_e(s) théorique', sprintf('s* = %.2f', s_opt), 'Location', 'north');