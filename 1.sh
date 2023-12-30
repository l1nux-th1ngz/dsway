#!/bin/bash

log() {
    echo "*********** $1 ***********"
    now=$(date +"%T")
    echo "$now $1" >> ~/dsway_setup_log
}

check() {
    if [ "$1" != 0 ]; then
        echo "$2 error : $1" | tee -a ~/dsway_setup_log
        exit 1
    fi
}

log "Refreshing package db"
sudo apt-get update -y
check "$?" "apt-get update"

sudo apt-get upgrade -y
check "$?" "apt-get upgrade"

log "Installing packages"
sudo apt-get install -y \
     zsh \
     zsh-autosuggestions \
     iwd \
     bluez \
     blueman \
     fish \
     pipewire \
     pipewire-pulse \
     pipewire-audio-client-libraries \
     pipewire-bin \
     xdg-desktop-portal \
     xdg-desktop-portal-wlr \
     xdg-desktop-portal-gtk \
     xwayland \
     wayland-protocols \
     sway \
     swaybg \
     swayidle \
     swaylock \
     pamixer \
     wdisplays \
     wob \
     grim \
     slurp \
     waybar \
     wofi \
     brightnessctl \
     kitty \
     firefox-esr \
     chromium \
     thunar \
     libreoffice \
     gnome-system-monitor \
     system-config-printer \
     cups \
     xfonts-terminus \
     lxsession \
     wl-clipboard \
     pavucontrol \
     emacs-nox \
     meson \
     gnome-software \
     unzip \
     geany \
     geany-plugins \
     notepadqq \
     pkg-config \
     wayland-protocols \
     libwayland-dev \
     libfreetype-dev \
     libgtk-3-dev \
     libgtk-4-dev \
     libglew-dev \
     libqrencode-dev \
     scdoc \
     libsdl2-dev \
     libswscale-dev \
     libmupdf-dev \
     libmujs-dev \
     libopenjp2-7-dev \
     libgumbo-dev \
     libavutil-dev \
     libavcodec-dev \
     libavdevice-dev \
     libavformat-dev \
     libswscale-dev \
     synaptic \
     gparted \
     mintsticl \
     curl \
     zip \
     unzip \
     libswresample-dev \
     libxkbcommon-dev \
     libjbig2dec0-dev

# Wanna install Google Chrome? Yay or Nay
read -p "Do you want to install Google Chrome? (Y/N): " chrome_answer
if [ "$chrome_answer" == "Y" ]; then
    sudo apt install software-properties-common apt-transport-https ca-certificates curl -y
    curl -fSsL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg >> /dev/null
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main | sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo apt install google-chrome-stable
fi

# Wanna install VS Code? Yay or Nay
read -p "Do you want to install VS Code? (Y/N): " vscode_answer
if [ "$vscode_answer" == "Y" ]; then
    sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
    curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg >/dev/null
    echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt install code
fi

# Install Ly Console Display Manager
cd 
cd Downloads
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly/
make
sudo make install installsystemd

# Configure Ly to use Sway
echo "sway" > ~/.xsession

# Enable Ly service
sudo systemctl enable ly.service

log "Cloning dsway"
git clone https://github.com/l1nux-th1ngz/dsway.git
cd dsway

log "Copying settings to home folder"
cp -f -R home/. ~/
check "$?" "cp"

log "Starting services"
sudo systemctl enable iwd --now
sudo systemctl enable bluetooth --now
sudo systemctl enable cups --now

log "Installing iwgtk"
git clone https://github.com/J-Lentz/iwgtk
cd iwgtk
meson setup build --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

log "Linking software store"
sudo ln /usr/bin/gnome-software /usr/bin/appstore

log "Linking zsh-autosuggestions"
sudo mkdir -p /usr/share/zsh/plugins/zsh-autosuggestions
sudo ln /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

log "Linking polkit"
sudo mkdir -p /usr/lib/polkit-gnome
sudo ln /usr/bin/lxpolkit /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

log "Installing sov"
git clone https://github.com/milgra/sov
cd sov
meson build
ninja -C build
sudo ninja -C build install
cd ..

log "Install kuid"
git clone https://github.com/milgra/kuid
check "$?" "GIT KUID"
cd kuid
meson setup build --buildtype=release
check "$?" "BUILD KUID"
ninja -C build
check "$?" "BUILD KUID"
sudo ninja -C build install
check "$?" "INSTALL KUID"
cd ..
rm -rf kuid
log "sov installed"

log "Install wcp"
git clone https://github.com/milgra/wcp
check "$?" "GIT WCP"
cd wcp
mkdir ~/.config/wcp
cp wcp-debian.sh ~/.config/wcp/wcp.sh
cp -R res ~/.config/wcp/
cd ..

log "Install wfl"
git clone https://github.com/milgra/wfl
check "$?" "GIT WFL"
cd wfl
mkdir ~/.config/wfl
cp wfl.sh ~/.config/wfl/
cp -R res ~/.config/wfl/
cd ..

log "Installing vmp"
git clone https://github.com/milgra/vmp
cd vmp
meson build
ninja -C build
sudo ninja -C build install
cd ..

log "Installing mmfm"
git clone https://github.com/milgra/mmfm
cd mmfm
meson build
ninja -C build
sudo ninja -C build install
cd ..

log "Cleaning up"
cd ..
rm -f -R swayos.github.io
check "$?" "rm"

log "Changing shell to zsh"
chsh -s /bin/zsh
check "$?" "chsh"

log "Setup is done, auto reboot"
read -p "Do you want to reboot now? (Y/N): " answer
if [ "$answer" == "Y" ]; then
    sudo reboot
fi
