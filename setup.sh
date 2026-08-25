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
	echo "Remove old neovim files. Install neovim version 0.11.5"
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
	echo "Setup neovim configuration and remove old files (if exist). Install ripgrep, fzf, nodejs and xclip"
	local folder="${1:-nvim}" 
	echo "[nvim] removing current configuration"
	rm -rf "$HOME/.config/nvim"
	echo "[nvim] updating config using $folder as source"
	cp -r ${folder} "$HOME/.config/nvim"
	sudo apt install fzf ripgrep nodejs xclip -y
	sudo apt remove fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
	"$HOME/.fzf/install"
}

nvim_prerequisites(){
	echo "Install prerequisites for neovim"
	cd
	sudo apt install nodejs npm pipx
	curl https://sh.rustup.rs -sSf | sh
	cargo install stylua
}

pi_install(){
	echo "Install pi. Downloads plugins - context mode"
	curl -fsSL https://pi.dev/install.sh | sh
	pi install npm:context-mode
}

lazygit_install(){
	echo "Install lazygit"
	sudo apt install lazygit -y
}

tmux_configuration(){
	echo "Update tmux configuration"
	echo "[${FUNCNAME[0]}]"
	cp tmux/.tmux.conf "$HOME" || echo "[${FUNCNAME[0]}] copy failed"
}

bashrc(){
    echo "Update .bashrc aliases - v=nvim, c=clear, lg=lazygit, t=tmux"
    local bashrc="$HOME/.bashrc"

    # Append only if aliases don't already exist to avoid duplicate spam
    grep -q 'alias v="nvim"' "$bashrc" 2>/dev/null || echo 'alias v="nvim"' >> "$bashrc"
    grep -q 'alias c="clear"' "$bashrc" 2>/dev/null || echo 'alias c="clear"' >> "$bashrc"
    grep -q 'alias t="tmux"' "$bashrc" 2>/dev/null || echo 'alias t="tmux"' >> "$bashrc"
    grep -q 'alias lg="lazygit"' "$bashrc" 2>/dev/null || echo 'alias lg="lazygit"' >> "$bashrc"

    # shellcheck disable=SC1090
    . "$bashrc" 2>/dev/null || true
    echo "[bashrc] aliases configured & sourced"
}

get_func_desc(){
	type "$1" 2>/dev/null | sed -n 's/^[[:blank:]]*echo[[:blank:]]*//p' | head -n 1 | sed -e 's/^[ "'\'']*//' -e 's/[ "'\'';]*$//'
}

funcs=(nvim_install_with_purge nvim_prerequisites nvim_update_config pi_install tmux_configuration lazygit_install bashrc)
descs=()
for f in "${funcs[@]}"; do
    descs+=("$(get_func_desc "$f")")
done


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
    # line="$p [$m] ${funcs[$i]}"; [ "$i" -eq "$cursor" ] && printf '\033[7m%s\033[0m\n' "$line" || printf '%s\n' "$line"
    # Current (ignores descs):
    # Fix (prints description with column padding):
    line=$(printf "%s [%s] %-25s | %s" "$p" "$m" "${funcs[$i]}" "${descs[$i]}")
    [ "$i" -eq "$cursor" ] && printf '\033[7m%s\033[0m\n' "$line" || printf '%s\n' "$line"
    
  done
  printf '\n\n%s[d]%s start installation' "$CYAN" "$RESET"
  IFS= read -rsn1 key || key=
  [ "$key" = $'\033' ] && { IFS= read -rsn2 -t .05 rest || rest=; key+="$rest"; }
  case "$key" in $'\003'|q) exit 130;; $'\033[A'|k) [ "$cursor" -gt 0 ] && cursor=$((cursor-1));; $'\033[B'|j) [ "$cursor" -lt "$((${#funcs[@]}-1))" ] && cursor=$((cursor+1));; ' '|$'\n'|'') checked[$cursor]=$((1-checked[$cursor]));; d) break;; esac
done

cleanup; trap - EXIT INT TERM
for i in "${!funcs[@]}"; do [ "${checked[$i]}" -eq 1 ] && "${funcs[$i]}"; done
printf '\n%sSetup complete%s\n' "$GREEN" "$RESET"
echo "NOTE: if changes were made to .bashrc, make sure to run source ~/.bashrc"
