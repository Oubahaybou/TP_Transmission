clear; close all; clc;
parametres;                                    % alpha, beta, tau, graine
span = 10;
mdl  = 'chaine_echo';  load_system(mdl);
Q    = @(x) 0.5*erfc(x/sqrt(2));

%% 1) Diagrammes de l'oeil sans bruit : sans écho et avec écho (L = 16)
Lq = 16;
h  = rrc_coeffs(alpha, Lq, span);
hc_sans = 1;
hc_avec = [1, zeros(1, tau*Lq - 1), beta];     % delta(t) + beta delta(t - tau T)
figure('Name', 'Oeil avec écho', 'Position', [100 100 900 360]);
subplot(1, 2, 1);
[y, ~, idx] = lancer_echo(mdl, h, hc_sans, Lq, 2000, 0, graine);
oeil(y, idx, Lq, 300);  title('Sans écho');
subplot(1, 2, 2);
[y, ~, idx] = lancer_echo(mdl, h, hc_avec, Lq, 2000, 0, graine);
oeil(y, idx, Lq, 300);  title(sprintf('Écho \\beta = %.2f, \\tau = %d T', beta, tau));

%% 2) TEB sans écho, avec écho, avec écho + égaliseur DFE (L = 4)
Lq = 4;
h  = rrc_coeffs(alpha, Lq, span);
h_echo = [1, zeros(1, tau*Lq - 1), beta];
EbN0_list = 0:2:10;
TEB = zeros(3, numel(EbN0_list));
for i = 1:numel(EbN0_list)
    g  = 10^(EbN0_list(i)/10);
    N0 = 1/(2*g);
    Ns = round(min(max(5e4, 150/Q(sqrt(2*g))/2), 3e5));

    [y, b, idx] = lancer_echo(mdl, h, 1, Lq, Ns, N0, graine);      % sans écho
    TEB(1, i) = mean(reshape(y(idx, :) > 0, [], 1) ~= b(:));

    [y, b, idx] = lancer_echo(mdl, h, h_echo, Lq, Ns, N0, graine); % avec écho
    z = y(idx, :);
    TEB(2, i) = mean(reshape(z > 0, [], 1) ~= b(:));

    % Égaliseur à retour de décision : on retire beta * (symbole décidé précédent)
    a_hat = zeros(size(z));
    for k = 1:size(z, 1)
        if k > tau
            zk = z(k, :) - beta * a_hat(k - tau, :);
        else
            zk = z(k, :);
        end
        a_hat(k, :) = sign(zk) / sqrt(2);
    end
    TEB(3, i) = mean(reshape(a_hat > 0, [], 1) ~= b(:));

    th = 0.5*(Q((1+beta)*sqrt(2*g)) + Q((1-beta)*sqrt(2*g)));
    fprintf('%2d dB : sans écho %.2e | avec écho %.2e (th. %.2e) | écho + DFE %.2e\n', ...
            EbN0_list(i), TEB(1,i), TEB(2,i), th, TEB(3,i));
end

x = linspace(0, 10, 200);  gx = 10.^(x/10);
figure('Name', 'TEB avec écho');
semilogy(x, Q(sqrt(2*gx)), 'k-', 'LineWidth', 1.2); hold on;
semilogy(x, 0.5*(Q((1+beta)*sqrt(2*gx)) + Q((1-beta)*sqrt(2*gx))), 'r-', 'LineWidth', 1.2);
semilogy(EbN0_list, TEB(1,:), 'ko', 'MarkerFaceColor', 'k');
semilogy(EbN0_list, TEB(2,:), 'rs', 'MarkerFaceColor', 'r');
semilogy(EbN0_list, TEB(3,:), 'b^', 'MarkerFaceColor', 'b');
grid on;  ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title(sprintf('Canal à écho (\\beta = %.2f, \\tau = %d T)', beta, tau));
legend('Théorie sans écho', 'Théorie avec écho', 'Simulation sans écho', ...
       'Simulation avec écho', 'Écho + égaliseur DFE', 'Location', 'southwest');