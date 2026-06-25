source /usr/share/cachyos-fish-config/cachyos-config.fish

set -Ux DOCKER_HOST "unix:///run/user/"(id -u)"/podman/podman.sock"

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
