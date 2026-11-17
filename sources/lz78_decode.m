function seq = lz78_decode(idx, sym)
% Décodeur LZ78 : reconstruit le message à partir des couples
    n = numel(idx);
    phrases = cell(1, n);
    for i = 1:n
        if idx(i) == 0
            phrases{i} = sym(i);                    % phrase vide + symbole
        else
            phrases{i} = [phrases{idx(i)} sym(i)];  % phrase connue + symbole
        end
    end
    seq = [phrases{:}];                             % phrases mises bout à bout
end