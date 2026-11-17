clear; close all; clc;
parametres;                                 % alpha, graine
Lp   = 32;                                  % échantillons par symbole (pour voir le spectre)
span = 10;                                  % troncature du RRC
Ns   = 4e4;                                 % nombre de symboles
rng(round(graine));

% Symboles ±1 indépendants (une voie : la voie Q a le même spectre)
a = 2*(rand(1, Ns) < 0.5) - 1;
x = zeros(1, Ns*Lp);
x(1:Lp:end) = a;                            % un symbole tous les Lp échantillons

% Mise en forme
h_p = ones(1, Lp) / sqrt(Lp);               % porte, énergie unité
h_r = rrc_coeffs(alpha, Lp, span);          % racine de cosinus surélevé
s_p = filter(h_p, 1, x);
s_r = filter(h_r, 1, x);

% Densités spectrales de puissance (T = 1, fe = Lp)
[f, P_p] = dsp_moyenne(s_p, Lp);
[~, P_r] = dsp_moyenne(s_r, Lp);

% Bandes à 99 % de la puissance
B_p = bande(f, P_p, 0.99);
B_r = bande(f, P_r, 0.99);
fprintf('Bande à 99 %% de la puissance (en 1/T) :\n');
fprintf('  filtre porte : %.2f\n', B_p);
fprintf('  filtre RRC   : %.3f\n', B_r);
fprintf('Bande théorique du RRC (1+alpha)/(2T) : %.3f\n', (1+alpha)/2);
fprintf('Rapport des bandes à 99 %% : %.1f\n', B_p / B_r);

% Tracé
figure;
plot(f, 10*log10(P_p), 'b', f, 10*log10(P_r), 'r', 'LineWidth', 1.2); hold on;
xline( (1+alpha)/2, 'k--', sprintf('(1+\\alpha)/2T = %.3f', (1+alpha)/2));
xline(-(1+alpha)/2, 'k--');
grid on;  xlim([-5 5]);  ylim([-80 5]);
xlabel('Fréquence f (en 1/T)');  ylabel('DSP (dB)');
title(sprintf('DSP du signal émis : porte et racine de cosinus surélevé (\\alpha = %.2f)', alpha));
legend('Filtre porte', 'Filtre RRC', 'Location', 'south');

%% ------------------------------------------------------------------
function [f, P] = dsp_moyenne(s, fe)
% Périodogramme moyenné (fenêtre de Hann, segments de 2048 échantillons)
    Nf = 2048;
    w  = 0.5 - 0.5*cos(2*pi*(0:Nf-1)'/(Nf-1));
    ns = floor(numel(s) / Nf);
    P  = zeros(Nf, 1);
    for k = 1:ns
        seg = s((k-1)*Nf + (1:Nf)).' .* w;
        P   = P + abs(fft(seg)).^2;
    end
    P = fftshift(P) / (ns * sum(w.^2) * fe);
    f = (-Nf/2 : Nf/2-1)' * fe / Nf;
end

function B = bande(f, P, p)
% Plus petite fréquence B telle que [-B, B] contienne la fraction p de la puissance
    i  = f >= 0;
    c  = cumsum(P(i)) / sum(P(i));
    fp = f(i);
    B  = fp(find(c >= p, 1));
end