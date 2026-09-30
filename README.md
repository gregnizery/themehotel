# Theme Hotel — Édition V2 (réédition)

Réédition du jeu Flash **Theme Hotel** (Toffee Games, 2011).
Le SWF original a été décompilé, les classes AS3 concernées ont été modifiées
puis recompilées dans le SWF d'origine : graphismes, sons, équilibrage et
sauvegardes restent 100 % identiques, seuls le confort de jeu et les liens
morts changent.

**Le jeu V2 : [`dist/theme-hotel-v2.swf`](dist/theme-hotel-v2.swf)**
(l'original est conservé dans [`original/theme-hotel-v1.swf`](original/theme-hotel-v1.swf)).

![Menu V2](docs/menu-v2.png)

## Nouveautés de la V2

| | Nouveauté |
|---|---|
| ⏩ | **Vitesse x8** (touche `4`) — simulée en sous-pas x4 pour garder la même stabilité que le jeu d'origine |
| ⌨️ | **Raccourcis clavier** pour toutes les actions (voir tableau ci-dessous) |
| 🖱️ | **Zoom à la molette** (le code existait dans la V1 mais n'avait jamais été branché) |
| ❓ | **Écran d'aide** des contrôles : bouton *Controls* du menu, ou `H` / `F1` en jeu (met le jeu en pause) |
| 💾 | **Sauvegarde automatique en quittant** vers le menu (emplacement *Autosave*), en plus de celle de chaque début de mois |
| 🔌 | **Jeu 100 % hors-ligne** : suppression du pistage (`track.g-bot.net`) et des liens vers le portail disparu `gamesfree.com` |
| 🚀 | **Démarrage plus rapide** : l'écran pub du sponsor est sauté |
| 🏷️ | Menu remis en page : badge « V2 Edition », *Credits* remonté, nouveau bouton *Controls* à la place de *More Games* |

### Raccourcis clavier (en jeu)

| Touche | Action | Touche | Action |
|---|---|---|---|
| `Espace` / `P` | Pause / reprise | `F` | Avis des clients |
| `1` `2` `3` `4` | Vitesse x1 / x2 / x4 / x8 | `G` | Graphiques de l'hôtel |
| Molette, `+` / `-`, `E` / `Q` | Zoom | `L` | Emprunt bancaire |
| Flèches / `WASD` | Déplacer la vue | `K` | Sauvegarder |
| `B` | Construire | `M` / `N` | Musique / sons |
| `R` | Recruter du personnel | `H` / `F1` | Aide |
| `X` / `Suppr` | Démolir | `Échap` | Outil sélection / fermer l'aide |

Les raccourcis sont inactifs pendant la saisie d'un texte et lorsqu'une fenêtre
modale (pause, sauvegarde, confirmation, étoile gagnée…) est ouverte.

![Aide V2](docs/controles-v2.png)
![Partie en x8](docs/partie-x8.png)

## Jouer

Le Flash Player n'existe plus : utilisez [Ruffle](https://ruffle.rs)
(extension navigateur ou application de bureau) et ouvrez
`dist/theme-hotel-v2.swf`. La V2 a été testée entièrement sous Ruffle
(menu, nouvelle partie, construction, personnel, x8 pendant plusieurs mois de
jeu, sauvegarde/chargement).

## Structure du dépôt

```
original/theme-hotel-v1.swf   SWF d'origine (non modifié)
src/                          classes AS3 modifiées (seules celles-ci sont recompilées)
  Hotel/Application.as               version 2.0
  Hotel/Preloader.as                 suppression du pistage et du logo sponsor
  Hotel/AppStates/StartupState.as    saut de l'écran sponsor
  Hotel/MainMenuWindow.as            nouveau menu (badge V2, bouton Controls)
  HotelCommon/SponsorLink.as         liens sponsor désactivés
  HotelCommon/HotelGameLogic.as      raccourcis, vitesse x8 en sous-pas
  HotelCommon/GUI/InGameGui.as       raccourcis, molette, aide, badge x8, autosave en quittant
build.sh                      reconstruit dist/theme-hotel-v2.swf
dist/theme-hotel-v2.swf       résultat
tools/                        banc de test : lance un SWF dans Ruffle (Chromium headless) et prend des captures
```

## Reconstruire

```bash
./build.sh
```

Il faut Java 11+. Le script télécharge le décompilateur/recompilateur
[JPEXS FFDec](https://github.com/jindrapetrik/jpexs-decompiler) (paquet npm
`jpexs-ts`) et `playerglobal.swc` (API Flash Player 11.1), puis injecte les
classes de `src/` dans `original/theme-hotel-v1.swf`.

> ⚠️ Le compilateur AS3 de FFDec compile mal une instruction isolée
> `new X(...);` (il l'appelle comme une fonction) : toujours utiliser la valeur
> retournée (affectation, `push`…). Le script échoue si FFDec signale une erreur.

### Tests

```bash
cd tools && npm install
node run-swf.js dist/theme-hotel-v2.swf "$(cat scenario-x8.json)"
```

Les captures sont écrites dans `tools/shots/`. Chromium est attendu dans
`/opt/pw-browsers/chromium` (ou variable `CHROMIUM_PATH`).

## Crédits

Jeu original © 2011 Toffee Games. Cette réédition est un projet de fan non
officiel.
