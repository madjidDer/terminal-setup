# Terminal Setup

Un kit pour retrouver **mon environnement de terminal Ubuntu** sur un nouveau PC, en une commande : Kitty, Zsh, Oh My Zsh, Powerlevel10k, tmux, fzf, Zoxide, Yazi, Neovim et btop.

Les fichiers du dossier `config/` proviennent de la configuration d'origine : **le thème Powerlevel10k et les raccourcis tmux sont conservés**.

## Prérequis

- Ubuntu avec `apt` et accès à Internet ; compte utilisateur autorisé à utiliser `sudo`.
- Une session graphique pour utiliser Kitty.
- Ne **pas** exécuter l'installateur en tant que root.

## Installation sur un nouveau PC

Télécharger le projet (ZIP GitHub ou `git clone`), ouvrir un terminal dans son dossier puis lancer :

```bash
bash install.sh
```

Le script installe les paquets, les plugins Zsh et **JetBrainsMono Nerd Font**, restaure les fichiers de configuration, vérifie leur syntaxe et propose Zsh comme shell par défaut. Il peut demander le mot de passe `sudo` et celui de `chsh`.

Ensuite, **fermer le terminal et ouvrir Kitty** : il rejoint ou crée automatiquement la session tmux `travail`.

> **Attention :** les fichiers `.zshrc`, `.p10k.zsh`, `.tmux.conf` et `~/.config/kitty/kitty.conf` existants sont remplacés, après sauvegarde dans des fichiers `.backup.DATE`. Les anciennes sessions tmux, clés SSH, historiques et données personnelles ne sont pas transférés.

## Outils et rôles

| Outil | Usage | Remplace / complète |
| --- | --- | --- |
| Kitty | Terminal graphique | GNOME Terminal |
| Zsh | Interpréteur de commandes | Bash |
| Oh My Zsh | Plugins et configuration | Configuration Zsh manuelle |
| Powerlevel10k | Invite de commande personnalisée | Prompt standard |
| tmux | Fenêtres, panneaux, sessions persistantes | Multiples terminaux indépendants |
| fzf | Recherche interactive | Recherche manuelle dans l'historique |
| Zoxide | Navigation rapide entre dossiers | `cd` pour les dossiers fréquents |
| Yazi | Explorateur de fichiers en terminal | Complète Nautilus |
| Neovim | Éditeur de texte | Nano/Vim |
| btop | Moniteur système | `top`/`htop` |

Plugins Zsh activés : `git`, `sudo`, `docker`, `docker-compose`, `ssh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`. Les plugins Docker n'installent **pas** Docker.

## Manuel d'utilisation et raccourcis

### tmux — préfixe `Ctrl+A`

| Action | Raccourci / commande |
| --- | --- |
| Séparer en panneaux gauche/droite | `Ctrl+A`, puis `|` |
| Séparer en panneaux haut/bas | `Ctrl+A`, puis `-` |
| Passer au panneau voisin | `Alt+←/→/↑/↓` |
| Créer une fenêtre | `Ctrl+A`, puis `c` |
| Fenêtre suivante / précédente | `Ctrl+A`, puis `n` / `p` |
| Aller à la fenêtre 1, 2… | `Ctrl+A`, puis `1`, `2`… |
| Agrandir / restaurer un panneau | `Ctrl+A`, puis `z` |
| Fermer un panneau | `Ctrl+A`, puis `x` |
| Détacher sans arrêter la session | `Ctrl+A`, puis `d` |
| Revenir à la session | `tmux attach -t travail` |
| Voir les sessions | `tmux ls` |

`Ctrl+A` remplace ici le préfixe tmux standard `Ctrl+B`. Les raccourcis `c`, `n`, `p`, `z`, `x` et `d` sont des commandes natives de tmux.

### Zsh, fzf, Zoxide et Yazi

| Action | Commande / raccourci |
| --- | --- |
| Recherche dans l'historique | `Ctrl+R` |
| Compléter une suggestion grisée | `→` ou `Fin` |
| Naviguer vers un dossier connu | `z nom_du_dossier` |
| Sélectionner un dossier fréquent | `zi` |
| Ouvrir Yazi et conserver le dossier choisi | `yy` |
| Ouvrir Yazi sans changement du répertoire du shell | `yazi` |
| Éditer un fichier | `nvim fichier` |
| Surveiller le système | `btop` |
| Reconfigurer le thème (facultatif) | `p10k configure` |

### Kitty

- Ouvrir Kitty lance directement tmux dans la session `travail`.
- Pour lancer exceptionnellement Kitty **sans tmux** :

```bash
kitty --override 'shell=/usr/bin/zsh'
```

## Personnalisation

Les réglages à versionner sont dans `config/` :

- `.zshrc` : Zsh, plugins, intégrations fzf/Zoxide et fonction `yy`.
- `.p10k.zsh` : thème Powerlevel10k choisi.
- `.tmux.conf` : préfixe et raccourcis tmux.
- `kitty.conf` : démarrage de tmux et police (ajoutée à l'installation).

Pour mettre à jour les préférences du projet, modifier les fichiers dans `config/`, puis relancer `bash install.sh`.

## Dépannage

- **Icônes incorrectes** : vérifier que Kitty utilise `JetBrainsMono Nerd Font` ; relancer Kitty après installation.
- **tmux ne démarre pas** : lancer `tmux new-session -A -s travail` dans un terminal Zsh et consulter `~/.config/kitty/kitty.conf`.
- **Erreur Zsh** : exécuter `zsh -n ~/.zshrc`.
- **Yazi introuvable** : vérifier `snap list yazi` et ouvrir un nouveau terminal.
- **Restauration** : les fichiers précédents sont sauvegardés sous le suffixe `.backup.DATE` dans leurs dossiers d'origine.


## Limites

Conçu pour Ubuntu. Versions et disponibilité des paquets varient selon la version d'Ubuntu.
