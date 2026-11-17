% parametres.m
% Les paramètres personnels sont tirés UNE SEULE FOIS par parametres_perso
% (version du prof avec rand), puis relus depuis mes_parametres.mat.
if exist('mes_parametres.mat', 'file')
    load('mes_parametres.mat', 'P');
else
    P = parametres_perso('Oubahaybou nouhayla');
    save('mes_parametres.mat', 'P');
end

graine = P.graine;
A      = P.A;
p1     = P.p1;
p1_ext = P.p1_ext;
pe     = P.pe_cbs;
a      = P.a_unif;
sigma  = P.sigma;
L      = P.L;
alpha  = P.alpha;
beta   = P.beta;
tau    = P.retard_trajet;

Tb = 1;
N  = 1e5;

%% Chaîne à L échantillons par bit (partie 3, questions 10 à 12)
Te = Tb / L;                              % période d'échantillonnage
if ~exist('EbN0dB', 'var'), EbN0dB = 5; end   % Eb/N0 en dB (modifiable par un script)
Eb   = A^2 * Tb;                          % énergie par bit
N0   = Eb / 10^(EbN0dB/10);               % densité spectrale du bruit
sig2 = N0 * L / (2*Tb);                   % variance du bruit par échantillon