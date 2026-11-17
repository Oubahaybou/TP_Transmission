clear; close all; clc;
P = parametres_perso('Oubahaybou nouhayla');

graine = P.graine;   % graine des tirages aléatoires
A      = P.A;        % amplitude
p1     = P.p1;       % probabilité d'émettre un 1
p1_ext = P.p1_ext;   % source très déséquilibrée
pe     = P.pe_cbs;   % probabilité d'erreur du CBS
a      = P.a_unif;   % bruit uniforme sur [-a, a]
sigma  = P.sigma;    % écart-type du bruit gaussien
L      = P.L;        % échantillons par bit
alpha  = P.alpha;    % roll-off du filtre RRC
beta   = P.beta;     % amplitude de l'écho
tau    = P.retard_trajet;  % retard de l'écho

Tb = 1;              % durée d'un bit
N  = 1e5;            % nombre de bits simulés
rng(graine);          % fixe le hasard : mêmes résultats à chaque lancement
%% Fréquence empirique des 1
b     = source(N, p1);                 % 100 000 bits
p_hat = mean(b);                       % proportion de 1 observée
ic    = 1.96 * sqrt(p1*(1-p1)/N);      % marge d'erreur à 95 %

fprintf('p1 théorique : %.4f\n', p1);
fprintf('p1 mesuré    : %.4f\n', p_hat);
fprintf('Intervalle   : [%.4f ; %.4f]\n', p1-ic, p1+ic);
%% Entropie de la source
H = @(p) -p.*log2(p) - (1-p).*log2(1-p);     % formule du sujet
fprintf('Entropie H(p1) : %.4f bit/symbole\n', H(p1));

%% Tracé de H(p)
p  = linspace(0, 1, 1001);          % 1001 valeurs de p entre 0 et 1
Hp = H(p);
Hp(isnan(Hp)) = 0;                  % en p = 0 et p = 1, H vaut 0

figure;
plot(p, Hp, 'b', 'LineWidth', 1.5); hold on;
plot(p1, H(p1), 'ro', 'MarkerFaceColor', 'r');
grid on;
xlabel('p = P(1)');
ylabel('H(p) (bit/symbole)');
title('Entropie d''une source binaire');
legend('H(p)', sprintf('Ma source (p_1 = %.2f)', p1), 'Location', 'south');
%% Débit d'information
D = 1/Tb;                            % débit binaire : 1 bit/s
fprintf('Débit binaire       : %.0f bit/s\n', D);
fprintf('Débit d''information : %.4f bit/s\n', D*H(p1));