function dotfiles --wraps='/usr/bin/git --git-dir=/home/justmango/.dotfiles/ --work-tree=/home/justmango' --description 'alias dotfiles=/usr/bin/git --git-dir=/home/justmango/.dotfiles/ --work-tree=/home/justmango'
    /usr/bin/git --git-dir=/home/justmango/.dotfiles/ --work-tree=/home/justmango $argv
end
