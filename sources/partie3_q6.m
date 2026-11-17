clear; close all; clc;
parametres;
p0  = 1 - p1;
mdl = 'canal_uniforme';
load_system(mdl);

% Probabilité d'erreur théorique (question 5)
pe0 = @(s) min(1, max(0, (a - A - s) / (2*a)));
pe1 = @(s) min(1, max(0, (s - A + a) / (2*a)));
Pe  = @(s) p0*pe0(s) + p1*pe1(s);

% Série de seuils, en incluant 0 et le seuil optimal
s_list = unique([-1.6:0.2:1.6, 0, a-A]);
TEB = zeros(size(s_list));

for i = 1:numel(s_list)
    s   = s_list(i);                       % le bloc Decision lit cette variable
    out = sim(mdl);
    TEB(i) = mean(out.emis(:) ~= out.recu(:));
    fprintf('s = %5.2f : TEB simulé = %.4f, Pe théorique = %.4f\n', s, TEB(i), Pe(s));
end

[TEBmin, k] = min(TEB);
fprintf('\nMeilleur seuil simulé : s = %.2f (TEB = %.4f)\n', s_list(k), TEBmin);
fprintf('Seuil optimal calculé : s* = %.2f (Pe = %.4f)\n', a-A, Pe(a-A));

% Tracé
ic = 1.96 * sqrt(TEB .* (1-TEB) / N);      % intervalles de confiance à 95 %
ss = linspace(-A-a, A+a, 1001);
figure;
plot(ss, Pe(ss), 'b', 'LineWidth', 1.5); hold on;
errorbar(s_list, TEB, ic, 'ro', 'MarkerFaceColor', 'r');
xline(a-A, 'k--', sprintf('s* = %.2f', a-A), 'LabelVerticalAlignment', 'middle');
grid on;
xlabel('Seuil s'); ylabel('Taux d''erreur binaire');
title(sprintf('Bruit uniforme : TEB simulé et P_e(s) théorique (a = %.2f, p_1 = %.2f)', a, p1));
legend('P_e(s) théorique', 'TEB simulé (10^5 bits)', 'Location', 'north');