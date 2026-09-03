#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero statu
set -e

# Check if /etc/os-release exists
if [ ! -f /etc/os-release ]; then
    echo "Error: /etc/os-release not found. Cannot determine distribution."
    exit 1
fi

# Source the os-release file to load variables like $ID and $ID_LIKE
. /etc/os-release

echo "Detected Distribution ID: $ID"
if [ -n "$ID_LIKE" ]; then
    echo "Fallback Distribution Group: $ID_LIKE"
fi

# Match the distribution ID or its base lineage
case "$ID" in
    ubuntu|debian|pop|mint)
        echo "-> Installing fastfetch"
        sudo apt update
        # If it's an older Ubuntu version where fastfetch isn't in default repos, use the PPA
        if [ "$ID" = "ubuntu" ] && ! apt-cache show fastfetch >/dev/null 2>&1; then
            echo "Fastfetch not in standard repo. Adding official PPA..."
            sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
            sudo apt update
        fi
        sudo apt install -y fastfetch
        ;;

    fedora|rhel|centos|almalinux|rocky)
        echo "-> Installing fastfetch"
        sudo dnf install -y fastfetch
        ;;

    arch|manjaro|endeavouros)
        echo "-> Installing fastfetch"
        sudo pacman -S --noconfirm fastfetch
        ;;

    opensuse*|suse)
        echo "-> Installing fastfetch"
        sudo zypper install -y fastfetch
        ;;

    alpine)
        echo "-> Installing fastfetch"
        sudo apk add fastfetch
        ;;

    void)
        echo "-> Installing fastfetch"
        sudo xbps-install -S -y fastfetch
        ;;

    *)
        # Final catch-all loop checking ID_LIKE variants if the main ID didn't explicitly match
        for base in $ID_LIKE; do
            case "$base" in
                debian|ubuntu)
                    sudo apt update && sudo apt install -y fastfetch
                    exit 0
                    ;;
                fedora)
                    sudo dnf install -y fastfetch
                    exit 0
                    ;;
                arch)
                    sudo pacman -S --noconfirm fastfetch
                    exit 0
                    ;;
            esac
        done

        # If it drops through the loop without an exit 0, it means it's unsupported
        echo "Failed: Distribution '$ID' is not supported. Please install fastfetch manually."
        exit 1
        ;;
esac

echo "-> Applying settings"
if [ -f logo.txt ]; then
    cp logo.txt ~/.logo.txt
else
    echo "[INFO] logo.txt not found in current folder, skipping move."
fi

printf '\nclear\nalias fastfetch='\''fastfetch --color "#ff751f" --logo-color-1 "#ff751f" --logo ~/.logo.txt'\''\nclear\nfastfetch\n' >> ~/.bashrc
echo "Successfully set up tanjafetch"
