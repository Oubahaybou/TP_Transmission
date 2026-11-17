clear; close all; clc;
parametres;
N   = 1e6;                                 % 10^6 bits : la courbe est plate près du minimum
p0  = 1 - p1;
mdl = 'canal_gaussien';
load_system(mdl);

% Probabilité d'erreur théorique (question 7)
Q     = @(x) 0.5*erfc(x/sqrt(2));
Pe    = @(s) p0*Q((s + A)/sigma) + p1*Q((A - s)/sigma);
s_opt = sigma^2/(2*A) * log(p0/p1);

% Série de seuils, resserrée autour de s*, en incluant 0 et s*
s_list = unique([-0.6:0.2:1.2, 0.3, 0.4, 0.5, 0, s_opt]);
TEB = zeros(size(s_list));

for i = 1:numel(s_list)
    s   = s_list(i);                       % le bloc Decision lit cette variable
    out = sim(mdl);
    TEB(i) = mean(out.emis(:) ~= out.recu(:));
    fprintf('s = %6.3f : TEB simulé = %.4f, Pe théorique = %.4f\n', s, TEB(i), Pe(s));
end

[TEBmin, k] = min(TEB);
i0 = find(s_list == 0);
iS = find(s_list == s_opt);
fprintf('\nMeilleur seuil simulé : s = %.3f (TEB = %.4f)\n', s_list(k), TEBmin);
fprintf('Seuil optimal calculé : s* = %.3f (Pe = %.4f)\n', s_opt, Pe(s_opt));
fprintf('TEB simulé en s = 0   : %.4f\n', TEB(i0));
fprintf('TEB simulé en s*      : %.4f\n', TEB(iS));
fprintf('Gain du seuil optimal : %.1f %% d''erreurs en moins\n', 100*(1 - TEB(iS)/TEB(i0)));

% Tracé
ic = 1.96 * sqrt(TEB .* (1-TEB) / N);
ss = linspace(-0.8, 1.4, 1001);
figure;
plot(ss, Pe(ss), 'b', 'LineWidth', 1.5); hold on;
errorbar(s_list, TEB, ic, 'ro', 'MarkerFaceColor', 'r');
xline(s_opt, 'k--', sprintf('s* = %.3f', s_opt), 'LabelVerticalAlignment', 'middle');
grid on;
xlabel('Seuil s'); ylabel('Taux d''erreur binaire');
title(sprintf('Bruit gaussien : TEB simulé et P_e(s) théorique (\\sigma = %.2f, p_1 = %.2f)', sigma, p1));
legend('P_e(s) théorique', 'TEB simulé (10^6 bits)', 'Location', 'north');