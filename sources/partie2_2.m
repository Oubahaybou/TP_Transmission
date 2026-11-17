clear; close all; clc;

%% Lecture du texte
fichier = 'roman.txt';
texte = fileread(fichier, 'Encoding', 'UTF-8');
c = double(texte);                    % un nombre par caractère

%% Question 3 : entropie et grandeurs dérivées
[H, symb, p] = entropie(c);
M      = numel(symb);                 % taille de l'alphabet
Lfixe  = ceil(log2(M));               % bits d'un code de longueur fixe
redond = 1 - H/8;                     % redondance par rapport à 8 bits/caractère

fprintf('Nombre de caractères : %d\n', numel(c));
fprintf('Taille de l''alphabet : %d\n', M);
fprintf('Entropie             : %.4f bit/caractère\n', H);
fprintf('Code de longueur fixe: %d bits\n', Lfixe);
fprintf('Redondance / 8 bits  : %.1f %%\n', 100*redond);

%% Fréquences des 20 caractères les plus fréquents
[ps, i] = sort(p, 'descend');
n = 20;
noms = cell(1, n);
for k = 1:n
    car = symb(i(k));
    if car == 32,      noms{k} = 'espace';
    elseif car == 10,  noms{k} = 'saut';
    elseif car == 13,  noms{k} = 'retour';
    else,              noms{k} = char(car);
    end
end

figure;
bar(ps(1:n)); grid on;
xticks(1:n); xticklabels(noms);
xlabel('Caractère'); ylabel('Fréquence');
title('Les 20 caractères les plus fréquents');