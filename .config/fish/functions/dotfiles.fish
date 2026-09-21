function dotfiles --description 'Manage the bare dotfiles repository'
    command git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" $argv
end
