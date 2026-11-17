clear; close all; clc;
parametres;
Es = 1;  mdl = 'chaine_qpsk';  load_system(mdl);
Q = @(x) 0.5*erfc(x/sqrt(2));

EbN0_list = 0:9;
TEB_gray = zeros(size(EbN0_list));   TEB_nat = TEB_gray;

for i = 1:numel(EbN0_list)
    g   = 10^(EbN0_list(i)/10);
    N0  = Es / (2*g);                               % Eb = Es/2
    q   = Q(sqrt(2*g));
    N   = 2 * ceil(min(max(1e5, 300/q), 4e6) / 2);  % au moins ~300 erreurs attendues
    out = sim(mdl);

    % Mapping de Gray : les bits sont directement les signes des voies
    gI = out.emis(:,1);  gQ = out.emis(:,2);         % émis
    hI = out.recu(:,1);  hQ = out.recu(:,2);         % décidés
    TEB_gray(i) = nnz(out.emis ~= out.recu) / numel(out.emis);

    % Mapping naturel : même symbole, autre étiquette (n1 = NON gQ, n2 = gI xor gQ)
    nE = [~gQ, xor(gI, gQ)];
    nR = [~hQ, xor(hI, hQ)];
    TEB_nat(i) = nnz(nE ~= nR) / numel(nE);

    fprintf('%d dB : %7d bits | Gray %.2e (th. %.2e) | naturel %.2e (th. %.2e) | rapport %.2f\n', ...
            EbN0_list(i), numel(out.emis), TEB_gray(i), q, TEB_nat(i), 1.5*q - q^2, ...
            TEB_nat(i)/TEB_gray(i));
end

% Tracé
x = linspace(0, 9, 300);   qx = Q(sqrt(2*10.^(x/10)));
figure;
semilogy(x, qx, 'b-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_list, TEB_gray, 'bo', 'MarkerFaceColor', 'b');
semilogy(x, 1.5*qx - qx.^2, 'r--', 'LineWidth', 1.5);
semilogy(EbN0_list, TEB_nat, 'rs', 'MarkerFaceColor', 'r');
grid on;  ylim([1e-6 1]);
xlabel('E_b/N_0 (dB)');  ylabel('TEB');
title('QPSK : mapping de Gray et mapping naturel');
legend('Gray et chaîne binaire : Q(\surd(2E_b/N_0))', 'QPSK Gray : simulation', ...
       'Naturel : théorie 1,5q - q^2', 'QPSK naturel : simulation', 'Location', 'southwest');