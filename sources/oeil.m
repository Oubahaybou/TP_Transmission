function oeil(y, idx, Lq, nb)
% Diagramme de l'oeil de la voie I : tranches de 2 symboles centrées sur l'instant optimal
    yI  = y(:, 1);                             % voie I seule (vecteur colonne)
    seg = (-Lq:Lq)';                           % 2 symboles autour de l'instant optimal
    k   = idx(20 : 20 + nb - 1);               % instants optimaux (ligne)
    M   = yI(k + seg);                         % une tranche par colonne : (2Lq+1) x nb
    plot(seg/Lq, M, 'b');  hold on;
    xline(0, 'r--', 'instant optimal');
    grid on;  xlabel('t / T');  ylabel('voie I');  ylim([-1.6 1.6]);
end