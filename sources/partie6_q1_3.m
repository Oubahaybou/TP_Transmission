clear; close all; clc;
parametres;                                % alpha, L
span = 10;
h = rrc_coeffs(alpha, L, span);
g = conv(h, h);                            % filtre d'émission puis filtre adapté
c = (numel(g) + 1) / 2;                    % indice du centre (t = 0)
ch = (numel(h) + 1) / 2;

%% Question 2 : vérification des limites
h0 = 1 - alpha + 4*alpha/pi;
hl = alpha/sqrt(2) * ((1 + 2/pi)*sin(pi/(4*alpha)) + (1 - 2/pi)*cos(pi/(4*alpha)));
x  = 1/(4*alpha) + 1e-6;                   % juste à côté de T/(4 alpha)
hx = (sin(pi*x*(1-alpha)) + 4*alpha*x*cos(pi*x*(1+alpha))) / (pi*x*(1 - (4*alpha*x)^2));
fprintf('alpha = %.2f, L = %d, %d coefficients\n', alpha, L, numel(h));
fprintf('h(0) (avant normalisation)     : %.4f\n', h0);
fprintf('h(T/4alpha) : limite %.4f, formule juste à côté %.4f\n', hl, hx);

%% Question 3 : zéros aux multiples de T
k = 1:span;
fprintf('\nh*h au centre             : %.4f\n', g(c));
fprintf('max |h*h(kT)|, k ~= 0     : %.4f   (IES résiduelle)\n', max(abs(g(c + k*L))));
fprintf('h(kT)/h(0) pour k = 1,2,3 : %s\n', mat2str(h(ch + (1:3)*L) / h(ch), 3));

t1 = ((1:numel(h)) - ch) / L;              % temps en multiples de T
t2 = ((1:numel(g)) - c)  / L;
figure;
subplot(2,1,1);
plot(t1, h, 'b.-'); hold on;
stem(t1(1:L:end), h(1:L:end), 'r', 'filled');
grid on; xlabel('t / T'); ylabel('h(t)');
title(sprintf('Racine de cosinus surélevé (\\alpha = %.2f) : h ne s''annule pas en kT', alpha));
subplot(2,1,2);
plot(t2, g, 'b.-'); hold on;
stem(t2(1:L:end), g(1:L:end), 'r', 'filled');
grid on; xlabel('t / T'); ylabel('(h * h)(t)');
title('Cosinus surélevé h * h : nul aux multiples non nuls de T');