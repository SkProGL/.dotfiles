#!/usr/bin/env bash
set -u

confirm_yn(){
  local ans
  printf "%s [Y/n] " "$1"
  IFS= read -r ans
  case "${ans:-Y}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}


nvim_install_with_purge(){
	echo "[nvim] removing any old nvim files"
	confirm_yn "[nvim] remove old nvim files?" || {
	    echo "[nvim] cancelled"
	    return 0
	}

	version="0.11.5"
	# version="0.10.4" # old version without new lsp feature
        sudo rm -rf "/opt/nvim" "/usr/local/bin/nvim"

	echo "[nvim] installing nvim v$version"
	wget https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-x86_64.appimage
	chmod u+x nvim-linux-x86_64.appimage
	./nvim-linux-x86_64.appimage --appimage-extract > /dev/null 2>&1
	sudo mv squashfs-root /opt/nvim
	sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
	rm nvim-linux-x86_64.appimage
	echo "[nvim] installed"
}

nvim_update_config(){
	local folder="${1:-nvim}" 
	echo "[nvim] removing any leftover nvim configs"
	rm -rf ~/.config/nvim
	echo "[nvim] updating config using $folder as source"
	cp -r ${folder} ~/.config/nvim

	sudo apt install fzf ripgrep nodejs -y
}

nvim_prerequisites(){
	echo "[nvim] installing prerequisites"
	cd
	sudo apt install nodejs xclip npm pipx
	curl https://sh.rustup.rs -sSf | sh
	cargo install stylua

	sudo apt remove fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
}

pi_install(){
	curl -fsSL https://pi.dev/install.sh | sh
	pi install npm:context-mode
}

funcs=(nvim_install_with_purge nvim_prerequisites nvim_update_config pi_install)
checked=(); for _ in "${funcs[@]}"; do checked+=(0); done
cursor=0; old=$(stty -g)
GREEN=$'\033[32m' RESET=$'\033[0m' CYAN=$'\033[36m';
cleanup(){ stty "$old"; printf '\033[?25h\033[0m\033[2J\033[H'; }
die(){ cleanup; exit 130; }
trap cleanup EXIT; trap die INT TERM
stty -echo -icanon isig intr ^C time 0 min 0; printf '\033[?25l'

while :; do
  printf '\033[H\033[2J%s[↑/↓]%s %s[j/k]%s move, %s[Space/Enter]%s toggle, %s[q]%s quit\n\n' "$CYAN" "$RESET" "$CYAN" "$RESET" "$CYAN" "$RESET" "$CYAN" "$RESET"
  printf "Packages to install:\n"
  for i in "${!funcs[@]}"; do
    p=' '; m=' '; [ "$i" -eq "$cursor" ] && p='>'; [ "${checked[$i]}" -eq 1 ] && m='x'
    line="$p [$m] ${funcs[$i]}"; [ "$i" -eq "$cursor" ] && printf '\033[7m%s\033[0m\n' "$line" || printf '%s\n' "$line"
  done
  printf '\n\n%s[d]%s start installation' "$CYAN" "$RESET"
  IFS= read -rsn1 key || key=
  [ "$key" = $'\033' ] && { IFS= read -rsn2 -t .05 rest || rest=; key+="$rest"; }
  case "$key" in $'\003'|q) exit 130;; $'\033[A'|k) [ "$cursor" -gt 0 ] && cursor=$((cursor-1));; $'\033[B'|j) [ "$cursor" -lt "$((${#funcs[@]}-1))" ] && cursor=$((cursor+1));; ' '|$'\n'|'') checked[$cursor]=$((1-checked[$cursor]));; d) break;; esac
done

cleanup; trap - EXIT INT TERM
for i in "${!funcs[@]}"; do [ "${checked[$i]}" -eq 1 ] && "${funcs[$i]}"; done
printf '\n%sSetup complete%s\n' "$GREEN" "$RESET"
