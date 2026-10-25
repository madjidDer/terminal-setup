#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then echo 'Lance ce script avec ton utilisateur normal (sans sudo).'; exit 1; fi
if ! command -v apt-get >/dev/null; then echo 'Cet installateur est destiné à Ubuntu/Debian avec APT.'; exit 1; fi

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
backup() { if [[ -e "$1" ]]; then cp -a "$1" "${1}.backup.$(date +%Y%m%d-%H%M%S)"; fi; }

log 'Installation des paquets Ubuntu'
sudo apt-get update
sudo apt-get install -y kitty zsh tmux fzf zoxide btop neovim git curl ca-certificates file jq ripgrep fd-find fonts-dejavu-core unzip fontconfig

log 'Installation de Yazi via Snap'
if ! command -v yazi >/dev/null 2>&1; then
  if ! command -v snap >/dev/null 2>&1; then sudo apt-get install -y snapd; fi
  sudo snap install yazi --classic
fi

log 'Installation Oh My Zsh et plugins'
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended --keep-zshrc
fi
mkdir -p "$HOME/.oh-my-zsh/custom/plugins" "$HOME/.oh-my-zsh/custom/themes"
clone_if_missing() {
  local repo="$1" path="$2"
  if [[ ! -d "$path" ]]; then git clone --depth=1 "$repo" "$path"; fi
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

log 'Installation de JetBrainsMono Nerd Font'
font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
mkdir -p "$font_dir"
if [[ ! -f "$font_dir/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
  font_zip="$(mktemp --suffix=.zip)"
  if curl -fL --retry 3 -o "$font_zip" 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip'; then
    unzip -oq "$font_zip" '*.ttf' -d "$font_dir"
    fc-cache -f "$font_dir"
  else
    echo 'AVERTISSEMENT : téléchargement Nerd Font impossible, vérifie ta connexion.' >&2
  fi
  rm -f "$font_zip"
fi

# Si le dossier de configuration exportée est à côté du script, on le réutilise.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_DIR="$SCRIPT_DIR/config"

log 'Restauration des configurations personnelles'
for name in .zshrc .p10k.zsh .tmux.conf; do
  [[ -f "$CUSTOM_DIR/$name" ]] || { echo "Fichier manquant : $CUSTOM_DIR/$name" >&2; exit 1; }
  backup "$HOME/$name"
  cp "$CUSTOM_DIR/$name" "$HOME/$name"
done
# Compatibilité avec les versions anciennes de fzf disponibles via apt.
if ! fzf --zsh >/dev/null 2>&1; then
  sed -i 's|^source <(fzf --zsh)$|if fzf --zsh >/dev/null 2>\&1; then source <(fzf --zsh); else [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] \&\& source /usr/share/doc/fzf/examples/key-bindings.zsh; [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] \&\& source /usr/share/doc/fzf/examples/completion.zsh; fi|' "$HOME/.zshrc"
fi
mkdir -p "$HOME/.config/kitty"
backup "$HOME/.config/kitty/kitty.conf"
cp "$CUSTOM_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
if ! grep -Eq '^[[:space:]]*font_family[[:space:]]' "$HOME/.config/kitty/kitty.conf"; then
  printf '\nfont_family JetBrainsMono Nerd Font\n' >> "$HOME/.config/kitty/kitty.conf"
fi

log 'Vérification syntaxique'
zsh -n "$HOME/.zshrc"
tmux -f "$HOME/.tmux.conf" -L "verify-$$" new-session -d -s check
tmux -L "verify-$$" kill-server

log 'Shell par défaut'
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" != "$(command -v zsh)" ]]; then
  echo 'Le mot de passe du compte peut être demandé pour changer le shell par défaut.'
  chsh -s "$(command -v zsh)" || echo 'Changement du shell non effectué : tu pourras relancer chsh manuellement.'
fi

cat <<'DONE'

Installation terminée.
1. Ouvre Kitty : il démarrera tmux (session « travail »).
2. JetBrainsMono Nerd Font est configurée automatiquement.
3. Les choix Powerlevel10k sont restaurés automatiquement.
4. Pour ouvrir Kitty sans tmux : kitty --override 'shell=/usr/bin/zsh'

DONE
