clear; clc;
parametres;                                     % A, L, Tb, graine
Ac  = A * sqrt(4/7);                            % amplitude d'un bit codé
mdl = 'chaine_texte';  load_system(mdl);

%% Texte -> octets -> bits
texte  = fileread('texte_fr.txt', 'Encoding', 'UTF-8');
texte  = texte(1:min(end, 600));                % extrait de 600 caractères
octets = unicode2native(texte, 'UTF-8');        % caractères -> octets
bits   = reshape(dec2bin(octets, 8)' - '0', [], 1);   % 8 bits par octet, poids fort d'abord
nb     = numel(bits);
bits   = [bits; zeros(mod(-nb, 4), 1)];         % complété à un multiple de 4
W      = numel(bits) / 4;                       % nombre de mots de 4 bits
bits_in = [(0:W-1)' * 4*Tb, reshape(bits, 4, [])'];
N      = numel(bits);
fprintf('Texte : %d caractères, %d octets, %d bits\n', numel(texte), numel(octets), nb);

%% Transmission à 3 dB et 6 dB, sans puis avec Hamming
for EbN0dB = [3 6]
    g    = 10^(EbN0dB/10);
    sig2 = A^2 * L / (2*g);
    out  = sim(mdl);
    for cas = 1:2
        if cas == 1, M = out.m_nc;  nom = 'sans codage';
        else,        M = out.m_dec; nom = 'avec Hamming'; end
        br    = reshape(M', [], 1);  br = br(1:nb);                 % bits reçus
        teb   = mean(br ~= bits(1:nb));
        oct_r = uint8(bin2dec(char(reshape(br, 8, [])' + '0')))';    % bits -> octets
        nerr  = sum(oct_r ~= octets);
        txt_r = native2unicode(oct_r, 'UTF-8');                      % octets -> texte
        fprintf('\n===== %d dB, %s : TEB = %.2e, octets faux = %d/%d (%.1f %%) =====\n', ...
                EbN0dB, nom, teb, nerr, numel(octets), 100*nerr/numel(octets));
        disp(txt_r(1:min(end, 300)));
    end
end