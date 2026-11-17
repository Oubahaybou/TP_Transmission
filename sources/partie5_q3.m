clear; close all; clc;
parametres;
Es = 1;  mdl = 'chaine_qpsk';  load_system(mdl);
N  = 4000;                                % 2000 symboles par constellation
liste = [0 5 10];
Q = @(x) 0.5*erfc(x/sqrt(2));

figure('Position', [100 100 1100 380]);
for i = 1:3
    g   = 10^(liste(i)/10);
    N0  = Es / (2*g);
    out = sim(mdl);
    R   = out.r(:);
    sym = out.emis * [2; 1];               % numéro du symbole émis (0 à 3)
    subplot(1, 3, i);
    scatter(real(R), imag(R), 6, sym, 'filled');  hold on;
    plot([-1 1 1 -1]/sqrt(2), [1 1 -1 -1]/sqrt(2), 'k+', 'MarkerSize', 14, 'LineWidth', 2);
    xline(0, 'k-');  yline(0, 'k-');
    axis equal;  axis([-2.5 2.5 -2.5 2.5]);  grid on;
    xlabel('Voie I');  ylabel('Voie Q');
    title(sprintf('E_b/N_0 = %d dB (TEB = %.1e)', liste(i), ...
          nnz(out.emis ~= out.recu) / numel(out.emis)));
    fprintf('%2d dB : écart-type par voie = %.3f, TEB théorique = %.1e\n', ...
            liste(i), sqrt(N0/2), Q(sqrt(2*g)));
end
colormap(lines(4));