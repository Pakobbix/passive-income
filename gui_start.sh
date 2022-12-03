#!/bin/bash
red='\033[0;31m'   # ${red}
cyan='\033[0;36m'  # ${cyan}
green='\033[0;32m' # ${green}
white='\033[0;37m' # ${white}

erfolgreich=0
fehler=0
skip=0
export DEBIAN_FRONTEND=noninteractive
new_task() {
  echo -e "\n\n$(printf %"$(tput cols)"s | tr " " "=")\n$1\n$(printf %"$(tput cols)"s | tr " " "=")"
}

erfolg() {
  whiptail --title "Erfolgreich!" --msgbox "$1" 20 70
  erfolgreich=$((erfolgreich + 1))
}

fehler() {
  whiptail --title "Fehler!" --msgbox "$1" 20 70
  fehler=$((fehler + 1))
}

skip() {
  echo -e "${cyan}$1${white}"
  skip=$((skip + 1))
}

install_dep() {
  if sudo apt-get install -y "$@" >/dev/null; then
    erfolg "$@ Pakete wurden installiert"
  else
    fehler "$@ Pakete konnten nicht installiert werden"
  fi
}

messagebox() {
  whiptail --title "$1" --msgbox "$2" 30 100 3>&1 1>&2 2>&3
}

inputbox() {
  whiptail --title "$1" --inputbox "$2" 30 100 3>&1 1>&2 2>&3
}

[ -d /etc/needrestart/ ] && sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf 2>/dev/null
sudo echo
if ! which whiptail >/dev/null; then
  sudo apt-get install whiptail -y
fi
linux_user=$(who | awk '{print $1}')
{
  echo 0
  sudo apt-get update >/dev/null
  echo 14
  sudo apt-get upgrade -y >/dev/null
  echo 30
  sudo apt-get install ca-certificates curl gnupg lsb-release zip unzip bc apt-utils cron -y >/dev/null
  echo 44
  [ -d /etc/apt/keyrings ] || sudo mkdir -p /etc/apt/keyrings
  echo 61
  [ -f /etc/apt/keyrings/docker.gpg ] || curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo 75
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
  echo 90
  if ! sudo apt-get update >/dev/null; then
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    sudo apt-get update
  fi
  echo 100
} | whiptail --gauge "Aktualisiere System und Füge Docker den System-Repositories hinzu" 6 50 0

if ! which docker >/dev/null; then
  messagebox "Kleinen Moment Geduld, Docker wird Installiert." "Das Fenster wird sich automatisch schließen, sobald Docker installiert wurde." &
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null
  messagebox "Docker wurde installiert" "Leider ist es notwendig, dass wir nun den PC Neustarten.\nNach dem Neustart, starte einfach von vorne. Es wird dann aber durchlaufen"
  sudo usermod -aG docker $linux_user
  sudo reboot
fi

whiptail --title "Passive Income Helperskript" --msgbox "Dieses Skript richtet mehrere Einkommenshelfer für dich ein.
Du brauchst lediglich einige Anmeldedaten ausfüllen.

Auf folgende Seiten kannst du dich regestrieren:

Im nächsten Fenster kannst du auswählen, was eingerichtet werden soll. 
Du bist also nicht gezwungen, dich überall zu regestrieren.

Ebesucher - Ruft werbepartner links auf und Zahlt dich in Punkten aus
http://www.ebesucher.de/?ref=Pakobbix

Honeygain! Vermiete deine IP-Adresse als Proxy
https://r.honeygain.me/PAKOB7875D

Peer2Profit. Vermiete deine IP-Adresse als Proxy
https://p2pr.me/1664028004632f0d64483e3

Earnapp.Vermiete deine IP-Adresse als Proxy
https://earnapp.com/i/VF8ygUXG

Packetstream. Vermiete deine IP-Adresse als Proxy
https://packetstream.io/?psr=4HUh

IpRoyal Pawns.app. Vermiete deine IP-Adresse als Proxy
https://pawns.app?r=905162

Traffmonetizer. Vermiete deine IP-Adresse als Proxy
https://traffmonetizer.com/?aff=607897" 32 80

einzurichten=$(whiptail --title "Was möchtest du Einrichten?" --separate-output --checklist "Wähle was du einrichten möchtest:\n\nMit Leertaste haken entfernen/hinzufügen.\nMit Enter bestätigen" 18 100 7 "Ebesucher" "Ruft werbepartner links auf und Zahlt dich in Punkten aus " ON "Honeygain" "Vermiete deine IP-Adresse als Proxy" ON "Peer2Profit" "Vermiete deine IP-Adresse als Proxy" ON "EarnAPP" "Vermiete deine IP-Adresse als Proxy" ON "Packetstream" "Vermiete deine IP-Adresse als Proxy" ON "Pawns.app" "Vermiete deine IP-Adresse als Proxy" ON "Traffmonetizer" "Vermiete deine IP-Adresse als Proxy" ON 3>&1 1>&2 2>&3)
if [ -z "$einzurichten" ]; then
  echo "Nichts wurde ausgewählt"
else
  for einrichtung in $einzurichten; do
    case $einrichtung in
    Honeygain)
      honeymail=$(whiptail --title "Honeygain E-Mail" --inputbox "Gebe deine Honeygain E-Mail adresse an: " 20 70 3>&1 1>&2 2>&3)
      honeypass=$(whiptail --title "Honeygain Password" --passwordbox "Gebe dein Honeygain Passwort ein: " 20 70 3>&1 1>&2 2>&3)
      device_name=$(whiptail --title "Honeygain Gerätenamen" --inputbox "Gebe einen Gerätenamen an: " 20 70 3>&1 1>&2 2>&3)
      if docker rm -f honeygain || true && docker run -d --name honeygain --restart=always honeygain/honeygain -tou-accept -email "$honeymail" -pass "$honeypass" -device "$device_name"; then
        erfolg "Honeygain wurde eingerichtet"
      else
        fehler "Honeygain konnte nicht eingerichtet werden"
      fi

      ;;
    Peer2Profit)
      P2P_E_MAIL=$(whiptail --title "P2PMail" --inputbox "Gebe deine Peer2Profit Emailadresse ein" 30 80 3>&1 1>&2 2>&3)
      echo "docker rm -f peer2profit || true && docker run -d --restart=always -e P2P_EMAIL=$P2P_E_MAIL --name peer2profit peer2profit/peer2profit_linux:latest" >>~/peer2profit.sh
      chmod +x ~/peer2profit.sh
      if docker rm -f peer2profit || true && docker run -d --restart=always -e P2P_EMAIL="$P2P_E_MAIL" --name peer2profit peer2profit/peer2profit_linux:latest; then
        erfolg "Peer2Profit wurde eingerichtet"
      else
        fehler "Peer2Profit konnte nicht eingerichtet werden"
      fi
      ;;
    EarnAPP)
      wget -qO- https://brightdata.com/static/earnapp/install.sh >/tmp/earnapp.sh && echo "yes" | sudo bash /tmp/earnapp.sh
      read -n1 -r -p "Drücke eine Taste, wenn du den Link im Browser geöffnet hast und das Gerät mit deinem Account verlinkt wurde..." key
      ;;

    Packetstream)
      pscidh=$(whiptail --title "Packetstream CIDH E-Mail" --inputbox "Packetstream vergibt automatisch jedem User eine ID.
      Daher müsstest du nun zur webseite von Packetstream wechseln und deine ID einsehen
      
      https://packetstream.io/dashboard/referrals
      
      Hinter dem Share PacketStream Link: https://packetstream.io/?psr=4HUh
      Steht die CIDH (4HUh ist demnach meine CIDH) " 20 70 3>&1 1>&2 2>&3)
      if docker rm -f packetstream || true && docker run -d --restart=always -e CID="$pscidh" --name packetstream packetstream/psclient:latest; then
        erfolg "Packetstream wurde eingerichtet"
      else
        fehler "Packetstream konnte nicht eingerichtet werden"
      fi
      ;;

    "Pawns.app")
      pawnsmail=$(whiptail --title "IPRoyal Pawns.app E-Mail" --inputbox "Gebe deine IPRoyal Pawns.app E-Mail adresse an: " 20 70 3>&1 1>&2 2>&3)
      pawnspass=$(whiptail --title "IPRoyal Pawns.app Password" --passwordbox "Gebe dein IPRoyal Pawns.app Passwort ein: " 20 70 3>&1 1>&2 2>&3)
      if docker rm -f IPRoyal || true && docker run -d --name IPRoyal --restart=always iproyal/pawns-cli:latest -email="$pawnsmail" -password="$pawnspass" -device-name="$device_name" -accept-tos; then
        erfolg "IPRoyal (Pawns.app) wurde eingerichtet"
      else
        fehler "IPRoyal (Pawns.app) konnte nicht eingerichtet werden"
      fi
      ;;
    Traffmonetizer)
      trafftoken=$(whiptail --title "TraffMonetizer Token" --inputbox "Gebe deinen TraffMonetizer Token an: " 20 70 3>&1 1>&2 2>&3)
      if docker rm -f traffmonetizer || true && docker run -d --name traffmonetizer --restart unless-stopped traffmonetizer/cli start accept --token "$trafftoken"; then
        erfolg "TraffMonetizer wurde eingerichtet"
      else
        fehler "TraffMonetizer konnte nicht eingerichtet werden"
      fi
      ;;
    Ebesucher)
      messagebox "Hinweis:" "WARNUNG: Ebesucher benötigt einen Firefox und ca. 3GB Arbeitsspeicher!

Außerdem wird durch das aufrufen von webseiten relativ viel CPU verbraucht!

Ebesucher braucht leider etwas mehr Einrichtung. Aber keine Sorge, ich mach es dir relativ einfach.

Zunächst erstellen wir einen Firefox Container. 
Dieser soll im Hintergrund die Werbeseiten aufrufen."

      if [ -d ~/ebesucher ]; then
        skip "Ordner ebesucher exestiert bereits"
        if ! [ -f ~/ebesucher/config.zip ]; then
          if whiptail --title "Alte config gefunden" --yesno "Es wurde bereits ein Firefox Profil angelegt, soll dieses gelöscht und überschrieben werden?" 20 100; then
            rm -f ~/ebesucher/config.zip
            wget -O ~/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
            unzip ~/ebesucher/config.zip -d ~/ebesucher/
          else
            unzip ~/ebesucher/config.zip -d ~/ebesucher/
          fi
        fi
      else
        if [ "$linux_user" == "root" ]; then
          if mkdir /root/ebesucher; then
            wget -O /root/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
            unzip /root/ebesucher/config.zip -d /root/ebesucher/
            erfolg "Ordner für ebesucher konnte erstellt werden"
          else
            fehler "Der Ordner für ebesucher konnte nicht angelegt werden"
          fi
        else
          if mkdir /home/"$linux_user"/ebesucher; then
            wget -O /home/"$linux_user"/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
            unzip /home/"$linux_user"/ebesucher/config.zip -d /home/"$linux_user"/ebesucher/
            erfolg "Ordner für ebesucher konnte erstellt werden"
          else
            fehler "Der Ordner für ebesucher konnte nicht angelegt werden"
          fi
        fi
      fi
      ebesucher_docker() {
        if docker rm -f ebesucher || true && docker run -d --name=ebesucher -p 3000:5800 -m "$1" -v ~/ebesucher/config:/config:rw --shm-size 2g jlesage/firefox; then
          erfolg "Firefox-Ebesucher wurde eingerichtet"
          messagebox "Jetzt bist du gefragt!" "Öffne im browser deiner Wahl von einem anderen Gerät aus $(hostname -I | awk '{print $1}'):3000"
        else
          fehler "Firefox-Ebesucher konnte nicht eingerichtet werden"
        fi
      }
      ram_avail=$(bc <<<"scale=2;$(($(free | awk 'NR==2 {print $2}') / 1000000))")
      if [[ $ram_avail -ge "2" ]]; then
        ebesucher_docker "1g"
      elif [[ $ram_avail -eq "4" ]]; then
        ebesucher_docker "3g"
      elif [[ $ram_avail -ge "5" ]]; then
        ebesucher_docker "4g"
      fi
      messagebox "" "Oben Rechts im Firefox Browser, öffne das Ebesucher addon.
Gebe in das Feld deinen Ebesucher Nutzernamen ein und mache einen Haken bei Privacy"
      nutzername=$(inputbox "Ebesucher Nutzername" "Gebe hier deinen Ebesucher Nutzernamen ein: ")
      messagebox 'Schließt nun alle Tabs im Browser und fahrt fort.'
      messagebox "Erstelle Sicherungen" "Damit die Einstellungen auch für immer gespeichert werden,
erstelle ich eine Sicherung der Firefox-Konfiguration"
      {
        echo 10
        if [ -f ~/ebesucher/config.zip ]; then
          rm -f ~/ebesucher/config.zip
        fi
        echo 15
        docker stop ebesucher
        echo 25
        cd ~/ebesucher/ || exit
        echo 30
        zip -r config.zip config/
        echo 60
        wget -O ~/ebesucher/restart.sh https://raw.githubusercontent.com/Pakobbix/passive-income/master/restart.sh
        echo 80
        chmod +x ~/ebesucher/restart.sh
        bash ~/ebesucher/restart.sh
        echo 90
        sed -i "s/username=/&$nutzername/g" ~/ebesucher/restart.sh
        echo 100
      } | whiptail --gauge "Erstelle Sicherung und Lade Restarter Skript herunter" 6 50 0

      messagebox "Erstelle Timer" "Nun muss noch ein Cronjob eingerichtet werden. 
Das ist Quasi ein Timer. Wir stellen ihn so ein,
das jede Stunde der Container, und die Firefox Daten gelöscht werden, 
die Sicherung wiedergeherstellt wird und den container ebenso.

Dies wird gemacht, damit sich nicht zuviel Müll ansammelt und um zu gewährleisten, 
dass es für immer läuft.
Selbst wenn der Container mal abstürzen sollte, wird er nächste Stunde wieder neugestartet."
      crontab -l >/tmp/ebesucher 2>/dev/null
      if [ "$linux_user" == "root" ]; then
        if ! grep -q "ebesucher/restart.sh" "/tmp/ebesucher"; then
          echo "0 * * * * /bin/bash /root/ebesucher/restart.sh" >>/tmp/ebesucher
        fi
      else
        if ! grep -q "ebesucher/restart.sh" "/tmp/ebesucher"; then
          echo "0 * * * * /bin/bash /home/$linux_user/ebesucher/restart.sh" >>/tmp/ebesucher
          crontab /tmp/ebesucher
          rm /tmp/ebesucher
        fi
        crontab -l >/tmp/rootcron
        echo "0 0 * * 0 reboot" >>/tmp/rootcron
        sudo crontab /tmp/rootcron
        rm /tmp/rootcron
      fi
      ;;
    esac
  done
fi

if [ "$linux_user" == "root" ]; then
  echo -e "#!/bin/bash\n\nexport DEBIAN_FRONTEND=noninteractive\n\nsudo apt-get update\n\nsudo apt-get upgrade -y\n\nsudo apt-get autoremove -y" >/root/update_system.sh
  chmod +x /root/update_system.sh
else
  echo -e "#!/bin/bash\n\nexport DEBIAN_FRONTEND=noninteractive\n\nsudo apt-get update\n\nsudo apt-get upgrade -y\n\nsudo apt-get autoremove -y" >/home/"$linux_user"/update_system.sh
  chmod +x /home/"$linux_user"/update_system.sh
fi
if ! grep -q "update_system.sh" "/tmp/updatecron"; then
  if [ "$linux_user" == "root" ]; then
    crontab -l /tmp/updatecron
    echo "0 4 * * * /bin/bash /root/update_system.sh" >>/tmp/updatecron
    crontab /tmp/updatecron
    rm /tmp/crontab
  else
    sudo crontab -l /tmp/updatecron
    echo "0 4 * * * /bin/bash /home/$linux_user/update_system.sh" >>/tmp/updatecron
    sudo crontab /tmp/updatecron
    rm /tmp/updatecron
  fi
fi
if docker run -d --name watchtower --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /etc/localtime:/etc/localtime:ro containrrr/watchtower --cleanup --interval 86400; then
  erfolg "Watchtower erfolgreich eingerichtet"
else
  fehler "Watchtower konnte nicht eingerichtet werden"
fi
messagebox "FERTIG!" "Wir sind nun Fertig! Ich hoffe das alles geklappt hat, wenn nicht, erstelle ein Issue auf https://gitea.zephyreone.ddnss.de/Pakobbix/passiv-income/issues"
new_task "${green}$erfolgreich Erfolgreiche Operationen\n${red}$fehler Fehlerhafte Operationen\n${cyan}$skip Übersprungene Operationen${white}"
