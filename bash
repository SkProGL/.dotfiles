# enable vi mode
set -o vi

alias l='ls -lah'
alias v="nvim"

# (vim-like) use up and down arrow
bind '"\C-j": history-search-forward'
bind '"\C-k": history-search-backward'

change_dir() {
    local dir
    dir=$(find . -maxdepth 5 -type d | fzf) || return
    [[ -z "$dir" ]] && return    # no echo if fzf returned nothing
    cd "$dir"
    echo "jumped into $dir"
}
bind -x '"\C-f":change_dir'
