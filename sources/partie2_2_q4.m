clear; clc;
p = [0.4 0.2 0.2 0.1 0.1];
code = huffman(p);
len  = cellfun(@numel, code);            % longueur de chaque mot

%% Affichage du code
for i = 1:numel(p)
    fprintf('Symbole %d  p = %.1f  mot = %s\n', i, p(i), code{i});
end

%% Test 1 : code préfixe (aucun mot n'est le début d'un autre)
prefixe = true;
for i = 1:numel(p)
    for j = 1:numel(p)
        if i ~= j && strncmp(code{i}, code{j}, len(i))
            prefixe = false;
        end
    end
end
fprintf('Code préfixe     : %d\n', prefixe);

%% Test 2 : somme de Kraft
fprintf('Somme de Kraft   : %.4f\n', sum(2.^(-len)));

%% Test 3 : longueur moyenne
Lmoy = sum(p(:) .* len);
H    = -sum(p .* log2(p));
fprintf('Longueur moyenne : %.4f bits\n', Lmoy);
fprintf('Entropie         : %.4f bits\n', H);
fprintf('Efficacité H/L   : %.1f %%\n', 100*H/Lmoy);


%% Comparaison avec huffmandict (Communications Toolbox)
if exist('huffmandict', 'file')
    [dict, Ltb] = huffmandict(1:numel(p), p);
    fprintf('\nhuffmandict : longueur moyenne %.4f bits\n', Ltb);
    for i = 1:numel(p)
        mot_tb = sprintf('%d', dict{i,2});     % [1 0 1] -> '101'
        fprintf('Symbole %d : mon code = %-4s | huffmandict = %s\n', i, code{i}, mot_tb);
    end
else
    disp('Communications Toolbox absente : pas de comparaison.');
end