clear; close all; clc;
parametres;
p0 = 1 - p1;

Q  = @(x) 0.5 * erfc(x / sqrt(2));                 % fonction Q
Pe = @(s) p0*Q((s + A)/sigma) + p1*Q((A - s)/sigma);

s_opt = sigma^2 / (2*A) * log(p0/p1);
fprintf('Seuil optimal s*      : %.4f\n', s_opt);
fprintf('Pe(s*)                : %.4f\n', Pe(s_opt));
fprintf('Pe(0)                 : %.4f\n', Pe(0));
fprintf('Gain relatif          : %.1f %% d''erreurs en moins\n', 100*(1 - Pe(s_opt)/Pe(0)));

% Vérification : minimum numérique de Pe(s)
s_num = fminbnd(Pe, -A, A);
fprintf('Minimum numérique de Pe : s = %.4f\n', s_num);

% Densités pondérées : elles se croisent au seuil optimal
r  = linspace(-A-4*sigma, A+4*sigma, 1001);
g0 = p0 * exp(-(r + A).^2/(2*sigma^2)) / (sigma*sqrt(2*pi));
g1 = p1 * exp(-(r - A).^2/(2*sigma^2)) / (sigma*sqrt(2*pi));

figure;
subplot(2,1,1);
plot(r, g0, 'b', r, g1, 'r', 'LineWidth', 1.5); hold on;
xline(s_opt, 'k--', sprintf('s* = %.3f', s_opt), 'LabelVerticalAlignment', 'middle');
grid on; xlabel('r'); ylabel('densité pondérée');
title(sprintf('p_0 f(r|0) et p_1 f(r|1)  (\\sigma = %.2f, p_1 = %.2f)', sigma, p1));
legend('p_0 f(r|0)', 'p_1 f(r|1)', 'Location', 'northeastoutside');

subplot(2,1,2);
ss = linspace(-1.5, 1.5, 1001);
plot(ss, Pe(ss), 'b', 'LineWidth', 1.5); hold on;
plot(s_opt, Pe(s_opt), 'ro', 'MarkerFaceColor', 'r');
grid on; xlabel('Seuil s'); ylabel('P_e(s)');
title('Probabilité d''erreur théorique');
legend('P_e(s)', 's*', 'Location', 'northeastoutside');