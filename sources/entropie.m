function [H, symb, p] = entropie(seq)
% Entropie empirique (bit/symbole) d'une séquence de symboles
    [symb, ~, idx] = unique(seq(:));       % alphabet, et numéro de chaque symbole
    p = accumarray(idx, 1) / numel(seq);   % fréquence de chaque symbole
    H = -sum(p .* log2(p));                % formule de l'entropie
end