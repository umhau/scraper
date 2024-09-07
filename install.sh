#!/bin/bash

set -e

[ `whoami` != 'root' ] && echo "must run as root!" && exit 1

venv_path=/opt/scraper/venv
urlsfolder=/var/lib/scraper/pool
wireguardconfigs=/opt/scraper/wireguard
useragents=/opt/scraper/useragents.txt

[ "$1" != 'quick' ] && rm -rf /opt/scraper /var/lib/scraper

mkdir -pv /opt/scraper/venv /var/lib/scraper/pool /opt/scraper/wireguard
chmod 777 /var/lib/scraper/pool

install -v download.py scraper randomvpn randomsleep /bin/
install -v ./useragents.txt   /opt/scraper
install ./wireguard/*.conf /opt/scraper/wireguard/

# we need to manage wireguard as a non-root user
echo 'root ALL=(ALL:ALL) ALL' > /etc/sudoers
echo 'mal ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
echo 'mal ALL=(root) NOPASSWD: /usr/bin/wg-quick up *, /usr/bin/wg-quick down *, /bin/cp */etc/wireguard/*.conf, /bin/chmod 755 /etc/wireguard/*.conf' >> /etc/sudoers 

usermod -aG wheel mal

# this *might* be auto logging us in. or it's just starting the display server
# ln -sv /etc/sv/dbus /var/service/    2>/dev/null
# ln -sv /etc/sv/lightdm /var/service/ 2>/dev/null

echo 'TERM=xterm-256color' >> /root/.bashrc

packages=(

    # tough to do without these basics on a bare system
    rsync net-tools tmux vim nano htop

    # so we can log the vpn ip address
    curl

    # basic python tooling
    python3-pip

    # virtual chrome windows for downloading
    python3-tkinter xvfb-run chromium 
    
    # vpn
    wireguard-tools wireguard

    # virtual chrome windows need to not be headless
    xorg-fonts xinit xorg xfce4 lightdm lightdm-gtk-greeter

)

[ "$1" == 'quick' ] && echo "skipping package installation" && exit 0

# comment these out to avoid breaking stuff with updates
sudo xbps-install -ySu
sudo xbps-install -uy xbps
sudo xbps-install -y ${packages[@]}

echo "creating python3 virtual environment at $venv_path"

rm -rf "$venv_path"
python3 -m venv "$venv_path"
source "$venv_path/bin/activate"
pip3 install --upgrade pip
pip3 install selenium argparse pyautogui bs4 lxml requests
deactivate

# chmod -R 777 $dir $urlsfolder $doneurlsfolder $venv_path $tmp_download_dir $dir/agents

echo "finished installation of scraper"

# echo -n 'reboot to finish > ' ; read ; reboot
