function h = rrc_coeffs(alpha, L, span)
% Coefficients du filtre en racine de cosinus surélevé (T = 1).
% alpha : roll-off, L : échantillons par symbole, span : durée en symboles.
% Rend span*L + 1 coefficients, normalisés à énergie unité.
    t = (-span*L/2 : span*L/2) / L;          % instants en multiples de T
    h = zeros(size(t));
    for i = 1:numel(t)
        x = t(i);
        if abs(x) < 1e-12                                  % limite en t = 0
            h(i) = 1 - alpha + 4*alpha/pi;
        elseif abs(abs(x) - 1/(4*alpha)) < 1e-9            % limite en t = ±T/(4 alpha)
            h(i) = alpha/sqrt(2) * ((1 + 2/pi)*sin(pi/(4*alpha)) ...
                                  + (1 - 2/pi)*cos(pi/(4*alpha)));
        else                                               % formule générale
            h(i) = (sin(pi*x*(1-alpha)) + 4*alpha*x*cos(pi*x*(1+alpha))) ...
                   / (pi*x*(1 - (4*alpha*x)^2));
        end
    end
    h = h / sqrt(sum(h.^2));                 % énergie unité
end