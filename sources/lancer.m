function [y, b, idx] = lancer(mdl, hcoef, Lq, Ns, N0, graine)
% Prépare les symboles QPSK de Gray, lance le modèle, rend la sortie du filtre adapté,
% les bits émis et les indices des instants d'échantillonnage optimaux.
    rng(round(graine));
    b   = rand(Ns, 2) < 0.5;                   % b1 -> voie I, b2 -> voie Q
    sym = (2*b - 1) / sqrt(2);
    nh  = numel(hcoef);
    x   = zeros(Ns*Lq + nh, 2);
    x(1:Lq:Ns*Lq, :) = sym;                    % un symbole tous les Lq échantillons
    Te  = 1/Lq;                                % T = 1
    assignin('base', 'xin',    [(0:size(x,1)-1)'*Te, x]);
    assignin('base', 'hcoef',  hcoef);
    assignin('base', 'Te',     Te);
    assignin('base', 'N0',     N0);
    assignin('base', 'graine', graine);
    set_param(mdl, 'StopTime', num2str((size(x,1)-1)*Te));
    out = sim(mdl);
    y   = out.y;
    idx = (0:Ns-1)*Lq + nh;                    % retard des deux filtres : nh - 1 échantillons
end
