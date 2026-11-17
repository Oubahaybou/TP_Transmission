# TP Théorie de l'information et du codage — Chaîne de transmission numérique

**Auteure :** Nouhayla Oubahaybou — ENSIM 5A ASTRE 2026
**Enseignant :** Youssef Serrestou
**Outils :** MATLAB R2023b et Simulink.

---
## Présentation (partie 2)
Vidéo : https://drive.google.com/file/d/1q13F6tjrXd0tRXkhyFMa5_aQSE-KdAqW/view?usp=sharing

## 1. Avant de commencer

1. Placer **tous les fichiers dans un même dossier** et en faire le dossier courant de MATLAB.
2. Vérifier la présence de :
   - `parametres_perso.m` (fourni par l'enseignant) ;
   - `mes_parametres.mat` (tirage des paramètres personnels, à ne pas supprimer) ;
   - `texte_fr.txt` (texte fourni) et `roman.txt` (roman du domaine public, plus de 100 000 caractères).
3. Les scripts appellent eux-mêmes `parametres` : il n'y a rien à lancer à la main avant eux.

### Paramètres personnels

`parametres.m` relit le tirage enregistré dans `mes_parametres.mat`. S'il n'existe pas, il appelle **une seule fois** `parametres_perso` et l'enregistre. La version distribuée de `parametres_perso` utilise `rand` : sans ce fichier, chaque appel donnerait d'autres valeurs.

Tirage utilisé de la partie 3 à la partie 7 : p1 = 0,19 ; pe = 0,116 ; a = 1,41 ; σ = 0,71 ; L = 4 ; α = 0,35 ; β = 0,47 ; τ = 1 ; A = 1 ; Tb = 1.

### Règle générale

Les scripts `creer_*.m` **construisent les modèles Simulink** (`.slx`) par programme. Il faut les lancer **avant** les scripts de simulation qui utilisent ces modèles. Ils effacent et reconstruisent le modèle à chaque lancement.

---

## 2. Ordre de lancement

### Partie 2 — Codage de source (MATLAB seul, sauf 2.1)

| Ordre | Script | Rôle |
|---|---|---|
| 1 | `partie2_1.m` | Source binaire : fréquence des 1, intervalle de confiance, entropie H(p), débit d'information |
| 2 | `partie2_2.m` | Entropie d'un texte, alphabet, redondance, histogramme des caractères (Q3) |
| 3 | `partie2_2_q4.m` | Validation de la fonction `huffman` (préfixe, Kraft, longueur moyenne 2,2) |
| 4 | `partie2_2_q5.m` | Huffman sur le texte : codeur, décodeur, taux de compression, coût de la table (Q5–Q6) |
| 5 | `partie2_3_q7.m` | Extension de la source : codage par blocs de k = 1 à 10 bits |
| 6 | `partie2_4_q8.m` | Entropie des paires, comparaison avec Huffman et gzip |
| 7 | `partie2_4_q9.m` | Proportion de 1 et entropie des paires en sortie de Huffman |
| 8 | `partie2_5_q10.m` | Validation du codeur/décodeur LZ78 sur ABAABABAABAB |
| 9 | `partie2_5_q11.m` | Performances de LZ78 sur le texte et sur une source binaire (1 à 2 min) |

Modèle Simulink associé à 2.1 : `source_test.slx` (sous-système masqué « Source binaire »).

### Partie 3 — Chaîne de base

| Ordre | Script | Rôle |
|---|---|---|
| 1 | `creer_cbs.m` | Construit `cbs.slx` (source + canal binaire symétrique) |
| 2 | `partie3_q2.m` | TEB du CBS et intervalle de confiance |
| 3 | `partie3_q3.m` | Capacité C(pe) et comparaison avec R = 4/7 |
| 4 | `partie3_q4.m` | Densités du canal uniforme et seuil optimal |
| 5 | `partie3_q5.m` | Pe(s) théorique du canal uniforme |
| 6 | `creer_uniforme.m` | Construit `canal_uniforme.slx` et vérifie P(e\|0), P(e\|1) |
| 7 | `partie3_q6.m` | TEB simulé du canal uniforme pour 19 seuils |
| 8 | `partie3_q7.m` | Seuil optimal et Pe(s) du canal gaussien |
| 9 | `creer_gaussien.m` | Construit `canal_gaussien.slx` |
| 10 | `partie3_q8.m` | TEB simulé du canal gaussien (10⁶ bits par seuil, quelques minutes) |
| 11 | `creer_detecteur.m` | Construit `detecteur_optimal.slx` (L échantillons par bit, intégrateur, échantillonneur, comparateur) |
| 12 | `ajouter_sans_integration.m` | Ajoute au modèle la branche « un échantillon au milieu du bit » |
| 13 | `partie3_q12.m` | TEB de 0 à 9 dB avec et sans intégration (retard compensé automatiquement) |
| 14 | `partie3_q13.m` | Facultatif : loi du bruit uniforme après intégration |

### Partie 4 — Code de Hamming (7,4)

| Ordre | Fichier | Rôle |
|---|---|---|
| — | `hamming_GH.m` | Matrices G et H |
| — | `reste_g.m` | Reste de x³m(x) modulo g(x) = 1 + x + x³ |
| — | `hamming_code.m`, `hamming_decode.m` | Codeur matriciel et décodeur par syndrome (référence) |
| 1 | `partie4_q1_3.m` | Restes, matrices, G·Hᵀ = 0, distance minimale, validation codeur/décodeur |
| 2 | `creer_codeur.m` | Construit `codeur_hamming.slx` (registre à décalage), table des états, comparaison sur 16 messages |
| 3 | `creer_decodeur.m` | Construit `decodeur_hamming.slx` (logique combinatoire) et le valide sur 128 mots |
| 4 | `creer_chaine_hamming.m` | Construit `chaine_hamming.slx` (branches avec et sans codage) |
| 5 | `partie4_q10.m` | TEB de 0 à 9 dB avec et sans codage, limites de Shannon ; enregistre `resultats_q10.mat` |

`creer_chaine_hamming.m` nécessite `decodeur_hamming.slx` (étape 3).

### Partie 5 — Modulation QPSK

| Ordre | Script | Rôle |
|---|---|---|
| 1 | `creer_qpsk.m` | Construit `chaine_qpsk.slx`, vérifie le mapping de Gray et le TEB à 5 dB |
| 2 | `partie5_q3.m` | Constellations à 0, 5 et 10 dB |
| 3 | `partie5_q4_5.m` | TEB QPSK de Gray et mapping naturel |
| 4 | `creer_qpsk_hamming.m` | Construit `chaine_qpsk_hamming.slx` (2 mots-codes = 7 symboles) |
| 5 | `partie5_q6.m` | TEB QPSK + Hamming, comparé à la partie 4 (lit `resultats_q10.mat`) |

`creer_qpsk_hamming.m` nécessite `chaine_hamming.slx` et `decodeur_hamming.slx`.

### Partie 6 — Filtres de mise en forme

| Ordre | Fichier | Rôle |
|---|---|---|
| — | `rrc_coeffs.m` | Coefficients du filtre en racine de cosinus surélevé (énergie unité) |
| — | `lancer.m` | Prépare les symboles, lance `chaine_rrc.slx`, rend la sortie du filtre adapté |
| — | `oeil.m` | Trace un diagramme de l'œil |
| 1 | `partie6_q1_3.m` | Limites de h(t), tracé de h et h∗h, IES résiduelle |
| 2 | `partie6_q4.m` | Densités spectrales et bande à 99 % |
| 3 | `creer_chaine_rrc.m` | Construit `chaine_rrc.slx` |
| 4 | `partie6_q5.m` | Diagrammes de l'œil, constellations et TEB (filtre porte et RRC) |
| 5 | `partie6_q6.m` | Décalage de T/4 pour α = 0,22, 0,35 et 1 |

### Partie 7 — Complément : écho et texte

| Ordre | Fichier | Rôle |
|---|---|---|
| — | `lancer_echo.m` | Comme `lancer.m`, avec le filtre d'écho |
| 1 | `creer_chaine_echo.m` | Construit `chaine_echo.slx` |
| 2 | `partie7_q1_2.m` | Œil et TEB avec écho, égaliseur à retour de décision |
| 3 | `creer_chaine_texte.m` | Construit `chaine_texte.slx` (copie de `chaine_hamming` avec source From Workspace) |
| 4 | `partie7_q3.m` | Transmission d'un texte à 3 et 6 dB, sans puis avec Hamming |

---

## 3. Fichiers de base

| Fichier | Rôle |
|---|---|
| `parametres.m` | Paramètres communs (lit `mes_parametres.mat`, définit Tb, N, Te, σ² par échantillon) |
| `parametres_perso.m` | Fonction fournie par l'enseignant |
| `source.m` | Source binaire : `source(N, p1)` rend N bits avec P(1) = p1 |
| `entropie.m` | Entropie empirique d'une séquence de symboles |
| `huffman.m` | Construction du code de Huffman (arbre en tableau de cellules) |
| `huffman_code.m`, `huffman_decode.m` | Codeur et décodeur de Huffman |
| `lz78_code.m`, `lz78_decode.m` | Codeur et décodeur LZ78 |

---

## 4. Remarques

- Les graines des générateurs d'une même simulation sont **entières et éloignées** (`round(graine)`, `round(graine) + 5000`…) : des graines voisines produisaient des tirages dépendants (voir rapport, partie 3, Q6).
- Les modèles à deux cadences sont réglés en mode **SingleTasking**, et les retards restants sont mesurés puis compensés par les scripts.
- Les durées indiquées sont approximatives ; les simulations à 10⁶ ou 10⁷ bits peuvent prendre plusieurs minutes.
