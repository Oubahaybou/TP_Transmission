clear; close all; clc;
parametres;                                    % alpha, graine
span = 10;
mdl  = 'chaine_rrc';  load_system(mdl);
Q    = @(x) 0.5*erfc(x/sqrt(2));

filtres = {'porte', 'RRC'};
hfun    = {@(Lq) ones(1, Lq)/sqrt(Lq), @(Lq) rrc_coeffs(alpha, Lq, span)};

%% 1) Diagrammes de l'oeil (L = 16, 2000 symboles)
Lq = 16;  Ns = 2000;
figure('Name', 'Diagrammes de l''oeil', 'Position', [50 50 900 600]);
for f = 1:2
    for cas = 1:2                              % 1 : sans bruit, 2 : 10 dB
        if cas == 1, N0 = 0; else, N0 = 1/(2*10^(10/10)); end
        [y, b, idx] = lancer(mdl, hfun{f}(Lq), Lq, Ns, N0, graine);
        subplot(2, 2, (f-1)*2 + cas);
        oeil(y, idx, Lq, 300);
        if cas == 1, txt = 'sans bruit'; else, txt = 'E_b/N_0 = 10 dB'; end
        title(sprintf('Filtre %s, voie I, %s', filtres{f}, txt));
    end
end

%% 2) Constellations à 10 dB
figure('Name', 'Constellations', 'Position', [100 100 800 380]);
N0 = 1/(2*10^(10/10));
for f = 1:2
    [y, b, idx] = lancer(mdl, hfun{f}(Lq), Lq, Ns, N0, graine);
    z = y(idx, :);
    subplot(1, 2, f);
    plot(z(:,1), z(:,2), '.', 'MarkerSize', 6);  hold on;
    xline(0, 'k');  yline(0, 'k');
    axis equal;  axis([-1.5 1.5 -1.5 1.5]);  grid on;
    xlabel('Voie I');  ylabel('Voie Q');
    title(sprintf('Filtre %s, E_b/N_0 = 10 dB', filtres{f}));
end

%% 3) TEB avec le filtre porte et le filtre RRC (L = 4)
Lq = 4;
EbN0_list = 0:2:8;
TEB = zeros(2, numel(EbN0_list));
for i = 1:numel(EbN0_list)
    g  = 10^(EbN0_list(i)/10);
    N0 = 1/(2*g);                              % Es = 1, Eb = 1/2
    q  = Q(sqrt(2*g));
    Ns = round(min(max(5e4, 150/q/2), 4e5));   % au moins ~150 erreurs attendues
    for f = 1:2
        [y, b, idx] = lancer(mdl, hfun{f}(Lq), Lq, Ns, N0, graine);
        bh = y(idx, :) > 0;                    % décision sur le signe de chaque voie
        TEB(f, i) = mean(bh(:) ~= b(:));
    end
    fprintf('%d dB : %6d symboles | porte %.2e | RRC %.2e | théorie %.2e\n', ...
            EbN0_list(i), Ns, TEB(1,i), TEB(2,i), q);
end

x = linspace(0, 8, 200);
figure('Name', 'TEB');
semilogy(x, Q(sqrt(2*10.^(x/10))), 'k-', 'LineWidth', 1.2); hold on;
semilogy(EbN0_list, TEB(1,:), 'bo', 'MarkerFaceColor', 'b');
semilogy(EbN0_list, TEB(2,:), 'r*', 'MarkerSize', 9, 'LineWidth', 1.2);
grid on;  ylim([1e-5 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title(sprintf('QPSK avec mise en forme (\\alpha = %.2f)', alpha));
legend('Théorie Q(\surd(2E_b/N_0))', 'Filtre porte', 'Filtre RRC', 'Location', 'southwest');

