#!/bin/bash

download(){
	version="0.11.5"
	# version="0.10.4" # old version without new lsp feature
	echo "[nvim] removing any old nvim files"
        sudo rm -rf "/opt/nvim"
        sudo rm -rf "/usr/local/bin/nvim"

	echo "[nvim] installing nvim v$version"
	wget https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-x86_64.appimage
	chmod u+x nvim-linux-x86_64.appimage
	./nvim-linux-x86_64.appimage --appimage-extract > /dev/null 2>&1
	sudo mv squashfs-root /opt/nvim
	sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
	rm nvim-linux-x86_64.appimage
	echo "[nvim] installed"
}

update_config(){
	local folder="${1:-nvim}" 
	echo "[nvim] removing any leftover nvim configs"
	rm -rf ~/.config/nvim
	echo "[nvim] updating config using $folder as source"
	cp -r ${folder} ~/.config/nvim

	sudo apt install fzf ripgrep nodejs -y
}

tools(){
	cd
	sudo apt install nodejs xclip npm pipx
	curl https://sh.rustup.rs -sSf | sh
	cargo install stylua

	sudo apt remove fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
}

download
update_config nvim
