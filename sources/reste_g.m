function r = reste_g(m)
% Reste de x^3 m(x) modulo g(x) = 1 + x + x^3, en binaire.
% m = [m0 m1 m2 m3] (puissances croissantes), r = [r0 r1 r2].
    g = [1 1 0 1];                    % coefficients de g, degrés 0 à 3
    a = [0 0 0 m];                    % x^3 m(x), degrés 0 à 6
    for d = 6:-1:3                    % on élimine les termes de degré 6 à 3
        if a(d+1)
            a(d-2:d+1) = mod(a(d-2:d+1) + g, 2);
        end
    end
    r = a(1:3);
end