clear; close all; clc;
parametres;                                    % alpha (= 0.35), graine
span = 10;
mdl  = 'chaine_rrc';  load_system(mdl);
Q    = @(x) 0.5*erfc(x/sqrt(2));
Lq   = 16;                                     % T/4 = 4 échantillons
d    = Lq/4;                                   % décalage de T/4
alphas = [0.22 alpha 1];
EbN0dB = 8;
g  = 10^(EbN0dB/10);
N0 = 1/(2*g);

%% 1) TEB et constellations, à l'instant optimal et décalé de T/4
Ns = 1e5;
fprintf('Eb/N0 = %d dB, TEB théorique sans décalage : %.2e\n\n', EbN0dB, Q(sqrt(2*g)));
figure('Name', 'Constellations décalées', 'Position', [50 100 1100 360]);
for i = 1:numel(alphas)
    h = rrc_coeffs(alphas(i), Lq, span);
    gg = conv(h, h);  c = (numel(gg) + 1)/2;
    [y, b, idx] = lancer(mdl, h, Lq, Ns, N0, graine);
    teb0 = mean(reshape(y(idx, :)     > 0, [], 1) ~= b(:));
    tebd = mean(reshape(y(idx + d, :) > 0, [], 1) ~= b(:));
    fprintf('alpha = %.2f : h*h(T/4) = %.3f | TEB optimal %.2e | TEB décalé de T/4 %.2e\n', ...
            alphas(i), gg(c + d), teb0, tebd);

    z = y(idx(1:2000) + d, :);
    subplot(1, 3, i);
    plot(z(:,1), z(:,2), '.', 'MarkerSize', 5);  hold on;
    xline(0, 'k');  yline(0, 'k');
    axis equal;  axis([-1.6 1.6 -1.6 1.6]);  grid on;
    xlabel('Voie I');  ylabel('Voie Q');
    title(sprintf('\\alpha = %.2f, décalage T/4 (TEB = %.1e)', alphas(i), tebd));
end

%% 2) Diagrammes de l'oeil sans bruit, avec l'instant décalé
figure('Name', 'Oeil et décalage', 'Position', [50 50 1100 360]);
for i = 1:numel(alphas)
    h = rrc_coeffs(alphas(i), Lq, span);
    [y, b, idx] = lancer(mdl, h, Lq, 2000, 0, graine);
    subplot(1, 3, i);
    oeil(y, idx, Lq, 300);
    xline(0.25, 'm-', 'T/4', 'LineWidth', 1.5);
    title(sprintf('\\alpha = %.2f, sans bruit', alphas(i)));
end