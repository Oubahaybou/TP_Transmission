function code = huffman(p)
% Code de Huffman d'une source de probabilités p.
% code{i} est le mot binaire (texte de '0' et de '1') du symbole i.
    M = numel(p);
    code = repmat({''}, M, 1);          % M mots vides au départ
    if M == 1, code{1} = '0'; return; end

    groupes = num2cell(1:M);            % chaque noeud = liste de ses symboles
    prob    = p(:)';                    % probabilité de chaque noeud

    while numel(prob) > 1
        [~, ordre] = sort(prob);        % tri croissant
        i1 = ordre(1);  i2 = ordre(2);  % les deux noeuds les moins probables

        for k = groupes{i1}, code{k} = ['0' code{k}]; end   % bit 0 devant
        for k = groupes{i2}, code{k} = ['1' code{k}]; end   % bit 1 devant

        groupes{i1} = [groupes{i1} groupes{i2}];   % fusion des deux noeuds
        prob(i1)    = prob(i1) + prob(i2);
        groupes(i2) = [];  prob(i2) = [];          % suppression du second
    end
end