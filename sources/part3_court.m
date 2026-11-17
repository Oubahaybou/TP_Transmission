clear; close all; clc;
parametres;
n  = (2*rand(L, 1e6) - 1) * a;            % L bruits uniformes sur [-a, a] par bit
nu = mean(n, 1);                          % bruit après intégration
fprintf('Variance mesurée : %.4f, théorie a^2/(3L) = %.4f\n', var(nu), a^2/(3*L));

x = linspace(-a, a, 400);
figure;
histogram(nu, 100, 'Normalization', 'pdf'); hold on;
plot(x, exp(-x.^2/(2*a^2/(3*L))) / sqrt(2*pi*a^2/(3*L)), 'r', 'LineWidth', 1.5);
grid on; xlabel('\nu'); ylabel('densité');
title(sprintf('Moyenne de L = %d bruits uniformes sur [-%.2f ; %.2f]', L, a, a));
legend('Histogramme', 'Gaussienne de même variance');