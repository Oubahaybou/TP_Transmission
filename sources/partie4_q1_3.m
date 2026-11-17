clear; clc;

%% Question 1 : restes, matrices, G*H' = 0
P = zeros(4, 3);
for i = 1:4
    m = zeros(1, 4);  m(i) = 1;
    P(i, :) = reste_g(m);
    fprintf('m = %s  ->  r = %s\n', mat2str(m), mat2str(P(i, :)));
end
[G, H] = hamming_GH();
fprintf('P calculée = P de hamming_GH : %d\n', isequal(P, G(:, 5:7)));
disp('G ='), disp(G)
disp('H ='), disp(H)
fprintf('G*H'' = 0 (mod 2) : %d\n', all(all(mod(G*H', 2) == 0)));

%% Question 2 : colonnes de H, distance minimale
fprintf('Colonnes de H non nulles : %d\n', all(any(H, 1)));
fprintf('Colonnes de H distinctes : %d\n', size(unique(H', 'rows'), 1) == 7);
msgs = dec2bin(0:15, 4) - '0';            % les 16 messages
C = hamming_code(msgs);                   % les 16 mots-codes
fprintf('Distance minimale : %d\n', min(sum(C(2:end, :), 2)));

%% Question 3 : validation du codeur et du décodeur
ok = isequal(hamming_decode(C), msgs);
fprintf('Sans erreur : %d\n', ok);
for pos = 1:7
    E = zeros(16, 7);  E(:, pos) = 1;     % une erreur à la position pos
    ok = isequal(hamming_decode(mod(C + E, 2)), msgs);
    fprintf('Erreur en position %d : corrigée pour les 16 messages : %d\n', pos, ok);
end