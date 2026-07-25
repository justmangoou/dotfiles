source /usr/share/cachyos-fish-config/cachyos-config.fish

set -Ux DOCKER_HOST "unix:///run/user/"(id -u)"/podman/podman.sock"
set -Ux fish_user_paths $HOME/.cargo/bin $fish_user_paths

starship init fish | source

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# pnpm
set -gx PNPM_HOME "/home/justmango/.local/share/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end
