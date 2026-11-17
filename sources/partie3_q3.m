clear; close all; clc;
parametres;
H = @(p) -p.*log2(p) - (1-p).*log2(1-p);

C = 1 - H(pe);
R = 4/7;                                    % rendement du code de Hamming
fprintf('H(pe)             : %.4f\n', H(pe));
fprintf('Capacité du canal : C = %.4f bit/bit émis\n', C);
fprintf('Rendement Hamming : R = %.4f\n', R);
fprintf('R < C             : %d\n', R < C);
fprintf('pe maximal pour C > 4/7 : %.4f\n', fzero(@(p) 1 - H(p) - R, [0.01 0.4]));

p  = linspace(0, 1, 1001);
Cp = 1 - H(p);  Cp(isnan(Cp)) = 1;          % C(0) = C(1) = 1

figure;
plot(p, Cp, 'b', 'LineWidth', 1.5); hold on;
plot(pe, C, 'ro', 'MarkerFaceColor', 'r');
yline(R, 'k--', 'R = 4/7');
grid on;
xlabel('Probabilité d''erreur p_e');
ylabel('Capacité C (bit par bit émis)');
title('Capacité du canal binaire symétrique');
legend('C(p_e)', sprintf('Mon canal (p_e = %.3f)', pe), 'Location', 'north');