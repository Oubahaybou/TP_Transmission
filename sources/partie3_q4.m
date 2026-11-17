clear; close all; clc;
parametres;                                   % A, a, p1
p0 = 1 - p1;

r  = linspace(-A-a-0.5, A+a+0.5, 2001);
f0 = (abs(r + A) <= a) / (2*a);               % f(r|0) : uniforme sur [-A-a, -A+a]
f1 = (abs(r - A) <= a) / (2*a);               % f(r|1) : uniforme sur [ A-a,  A+a]

figure;
subplot(2,1,1);
plot(r, f0, 'b', r, f1, 'r', 'LineWidth', 1.5); hold on;
xline(A-a, 'k:'); xline(a-A, 'k:');
grid on; ylim([0 1.3/(2*a)]);
xlabel('r'); ylabel('densité');
title(sprintf('Vraisemblances, bruit uniforme sur [-%.2f ; %.2f]', a, a));
legend('f(r|0)', 'f(r|1)', 'Location', 'north');

subplot(2,1,2);
plot(r, p0*f0, 'b', r, p1*f1, 'r', 'LineWidth', 1.5); hold on;
xline(a-A, 'k--', sprintf('s* = %.2f', a-A));
grid on;
xlabel('r'); ylabel('densité pondérée');
title(sprintf('p_0 f(r|0) et p_1 f(r|1)   (p_1 = %.2f)', p1));
legend('p_0 f(r|0)', 'p_1 f(r|1)', 'Location', 'north');

fprintf('Zone de recouvrement : [%.2f ; %.2f]\n', A-a, a-A);
fprintf('Seuil optimal        : s* = %.2f\n', a-A);