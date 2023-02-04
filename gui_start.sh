#!/bin/bash
red='\033[0;31m'   # ${red}
cyan='\033[0;36m'  # ${cyan}
green='\033[0;32m' # ${green}
white='\033[0;37m' # ${white}

erfolgreich=0
fehler=0
skip=0

# Disable prompts, like which service should be restartet
export DEBIAN_FRONTEND=noninteractive

# Visually seperate different tasks
new_task() {
	echo -e "\n\n$(printf %"$(tput cols)"s | tr " " "=")\n$1\n$(printf %"$(tput cols)"s | tr " " "=")"
}

# Message and count +1 for success
erfolg() {
	whiptail --title "Erfolgreich!" --msgbox "$1" 20 70
	erfolgreich=$((erfolgreich + 1))
}

# Message and count +1 for failed
fehler() {
	whiptail --title "Fehler!" --msgbox "$1" 20 70
	fehler=$((fehler + 1))
}

# Message and count +1 for skipped
skip() {
	echo -e "${cyan}$1${white}"
	skip=$((skip + 1))
}

# Function to install dependencies
install_dep() {
	if sudo apt-get install -y "$@" >/dev/null; then
		# shellcheck disable=SC2145
		erfolg "$@ Pakete wurden installiert"
	else
		# shellcheck disable=SC2145
		fehler "$@ Pakete konnten nicht installiert werden"
	fi
}

messagebox() {
	whiptail --title "$1" --msgbox "$2" 30 100 3>&1 1>&2 2>&3
}

inputbox() {
	whiptail --title "$1" --inputbox "$2" 30 100 3>&1 1>&2 2>&3
}

# get the last logged in User
linux_user=$(w | awk '{print $1}' | tail -n1)

# get OS
distrib=$(awk 'NR==1 {print $1}' /etc/issue)

# Check how many Cores are available (For later use in Limits for ebesucher)
availablecores=$(grep -c "processor" /proc/cpuinfo)

# Check if it is possible to deactivate all prompts (for future automated Updates)
[ -d /etc/needrestart/ ] && sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf 2>/dev/null

# Just for sudo access.
sudo echo

# Check if whiptail is already installed (not standard on minimal installation)
if ! which whiptail >/dev/null; then
	sudo apt-get update
	sudo apt-get install whiptail -y
fi

# Whiptail Progressbar
{
	echo 0
	sudo apt-get update >/dev/null
	echo 14
	sudo apt-get upgrade -y >/dev/null
	echo 30
	sudo apt-get install ca-certificates curl gnupg lsb-release zip unzip bc apt-utils cron -y >/dev/null
	echo 44
	# Check if keyrings is present, if not, create folder for keyrings
	[ -d /etc/apt/keyrings ] || sudo mkdir -p /etc/apt/keyrings
	echo 61
	# check if docker.gpg is in keyrings, if not get docker.gpg and save it in keyrings.
	# Also check if debian or ubuntu is used.
	case "$distrib" in
	Debian)
		[ -f /etc/apt/keyrings/docker.gpg ] || curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		echo 75
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
		;;
	Ubuntu)
		[ -f /etc/apt/keyrings/docker.gpg ] || curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		echo 75
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
		;;
	esac
	echo 90
	if ! sudo apt-get update >/dev/null; then
		sudo chmod a+r /etc/apt/keyrings/docker.gpg
		sudo apt-get update
	fi
	echo 100
	# end whiptail progressbar
} | whiptail --gauge "Aktualisiere System installiere Docker" 6 50 0

# Check if Docker is not installed
if ! which docker >/dev/null; then
	# it's not installed, so do:
	messagebox "Kleinen Moment Geduld, Docker wird Installiert." "Das Fenster wird sich automatisch schließen, sobald Docker installiert wurde." &
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null
	# Info to user, we need a restart. It's needed, because we add the linux_user to the docker group
	messagebox "Docker wurde installiert" "Leider ist es notwendig, dass wir nun den PC Neustarten.\nNach dem Neustart, starte einfach von vorne. Das Skript wird dann aber durchlaufen"
	sudo usermod -aG docker "$linux_user"
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

# Selection menu.
einzurichten=$(whiptail --title "Was möchtest du Einrichten?" --separate-output --checklist "Wähle was du einrichten möchtest:\n\nMit Leertaste haken entfernen/hinzufügen.\nMit Enter bestätigen" 18 100 7 "Ebesucher" "Ruft werbepartner links auf und Zahlt dich in Punkten aus " ON "Honeygain" "Vermiete deine IP-Adresse als Proxy" ON "Peer2Profit" "Vermiete deine IP-Adresse als Proxy" ON "EarnAPP" "Vermiete deine IP-Adresse als Proxy" ON "Packetstream" "Vermiete deine IP-Adresse als Proxy" ON "Pawns.app" "Vermiete deine IP-Adresse als Proxy" ON "Traffmonetizer" "Vermiete deine IP-Adresse als Proxy" ON 3>&1 1>&2 2>&3)
if [ -z "$einzurichten" ]; then
	echo "Nichts wurde ausgewählt"
	exit
else
	for einrichtung in $einzurichten; do
		case $einrichtung in
		#########################
		# Honeygain Einrichtung #
		#########################
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
			###########################
			# Peer2Profit Einrichtung #
			###########################
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
			#######################
			# EarnApp Einrichtung #
			#######################
		EarnAPP)
			wget -qO- https://brightdata.com/static/earnapp/install.sh >/tmp/earnapp.sh && echo "yes" | sudo bash /tmp/earnapp.sh
			read -n1 -r -p "Drücke eine Taste, wenn du den Link im Browser geöffnet hast und das Gerät mit deinem Account verlinkt wurde..." key
			;;
			############################
			# PacketStream Einrichtung #
			############################
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
			#########################
			# Pawns.App Einrichtung #
			#########################
		"Pawns.app")
			pawnsmail=$(whiptail --title "IPRoyal Pawns.app E-Mail" --inputbox "Gebe deine IPRoyal Pawns.app E-Mail adresse an: " 20 70 3>&1 1>&2 2>&3)
			pawnspass=$(whiptail --title "IPRoyal Pawns.app Password" --passwordbox "Gebe dein IPRoyal Pawns.app Passwort ein: " 20 70 3>&1 1>&2 2>&3)
			if docker rm -f IPRoyal || true && docker run -d --name IPRoyal --restart=always iproyal/pawns-cli:latest -email="$pawnsmail" -password="$pawnspass" -device-name="$device_name" -accept-tos; then
				erfolg "IPRoyal (Pawns.app) wurde eingerichtet"
			else
				fehler "IPRoyal (Pawns.app) konnte nicht eingerichtet werden"
			fi
			;;
			##############################
			# TraffMonetizer Einrichtung #
			##############################
		Traffmonetizer)
			trafftoken=$(whiptail --title "TraffMonetizer Token" --inputbox "Gebe deinen TraffMonetizer Token an: " 20 70 3>&1 1>&2 2>&3)
			if docker rm -f traffmonetizer || true && docker run -d --name traffmonetizer --restart unless-stopped traffmonetizer/cli start accept --token "$trafftoken"; then
				erfolg "TraffMonetizer wurde eingerichtet"
			else
				fehler "TraffMonetizer konnte nicht eingerichtet werden"
			fi
			;;
			#########################
			# Ebesucher Einrichtung #
			#########################
		Ebesucher)
			messagebox "Hinweis:" "WARNUNG: Ebesucher benötigt einen Firefox und ca. 3GB Arbeitsspeicher!

Außerdem wird durch das aufrufen von webseiten relativ viel CPU verbraucht!

Ebesucher braucht leider etwas mehr Einrichtung. Aber keine Sorge, ich mach es dir relativ einfach.

Zunächst erstellen wir einen Firefox Container. 
Dieser soll im Hintergrund die Werbeseiten aufrufen."
			# Ebesucher Configuration if user = root
			if [ "$linux_user" == "root" ]; then
				# Check if ebesucher folder already exists
				if [ -d /root/ebesucher ]; then
					skip "Ordner ebesucher exestiert bereits"
					# check if config exists, if yes, ask to overwrite
					if [ -f ~/ebesucher/config.zip ]; then
						if whiptail --title "Alte config gefunden" --yesno "Es wurde bereits ein Firefox Profil angelegt, soll dieses gelöscht und überschrieben werden?" 20 100; then
							# remove old config
							rm -f /root/ebesucher/config.zip
							# download blank config
							wget -O /root/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
							# unpack config
							unzip -o /root/ebesucher/config.zip -d /root/ebesucher/
						else
							# unpack config
							unzip -o /root/ebesucher/config.zip -d /root/ebesucher/
						fi
					fi
				else
					# Create ebesucher folder
					if mkdir /root/ebesucher; then
						# download config
						wget -O /root/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
						# unpack config
						unzip -o /root/ebesucher/config.zip -d /root/ebesucher/
						erfolg "Ordner für ebesucher wurde erstellt"
					else
						fehler "Der Ordner für ebesucher konnte nicht angelegt werden"
					fi
				fi
				while true; do
					CPUSet=$(inputbox "CPU Begrenzung" "Das System hat $availablecores Kerne. Wieviele davon darf Ebesucher ausnutzen? 4 sind empfohlen")
					if [[ "$availablecores" -ge "CPUSet" ]]; then
						break
					fi
				done
				# Ebesucher docker creation function. Will be used in the next step
				ebesucher_docker() {
					if docker rm -f ebesucher || true && docker run -d --name=ebesucher -p 3000:5800 -m "$1" --cpus "$CPUSet" -v ~/ebesucher/config:/config:rw --shm-size 2g jlesage/firefox; then
						erfolg "Firefox-Ebesucher wurde eingerichtet"
						messagebox "Jetzt bist du gefragt!" "Öffne im browser deiner Wahl von einem anderen Gerät aus $(hostname -I | awk '{print $1}'):3000"
					else
						fehler "Firefox-Ebesucher konnte nicht eingerichtet werden"
					fi
				}
				# Check how much ram is available.
				ram_avail=$(bc <<<"scale=2;$(($(free | awk 'NR==2 {print $2}') / 1000000))")
				if [[ $ram_avail -ge "2" ]]; then
					# create ebesucher docker container with specific RAM available (around 1 GB less then available)
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
					if [ -f /root/ebesucher/config.zip ]; then
						# delete blank config.zip
						rm -f /root/ebesucher/config.zip
					fi
					echo 15
					docker stop ebesucher
					echo 20
					cd /root/ebesucher/ || exit
					echo 30
					# pack config folder into new config.zip
					sudo zip -r config.zip config/
					echo 40
					# download restart script
					wget -O /root/ebesucher/restart.sh https://raw.githubusercontent.com/Pakobbix/passive-income/master/restart.sh
					echo 60
					# make restart skript executable
					chmod +x /root/ebesucher/restart.sh
					echo 70
					# add username to restart skript
					sed -i "s/username=/&$nutzername/g" /root/ebesucher/restart.sh
					echo 80
					sed -i "s/CPUcores=/CPUcores=$CPUSet/g" /root/ebesucher/restart.sh
					echo 90
					bash /root/ebesucher/restart.sh
					echo 100
				} | whiptail --gauge "Erstelle Sicherung und Lade Restarter Skript herunter" 6 50 0
				# Export current crontab
				crontab -l >/tmp/ebesucher
				# check if restart script is already configured
				if ! grep -q "ebesucher/restart.sh" "/tmp/ebesucher"; then
					# add restart script, reboot and update to crontab
					echo "0 * * * * /bin/bash /root/ebesucher/restart.sh
@reboot /bin/bash /root/ebesucher/restart.sh
0 0 * * 0 reboot
0 4 * * * /bin/bash /root/update_system.sh" >>/tmp/ebesucher
					# Let cron reload the new configured crontab
					crontab /tmp/ebesucher
					# delete the export
					rm /tmp/ebesucher
				fi
			else
				# Ebesucher Configuration if user != root
				# Check if ebesucher folder already exists
				if [ -d /home/"$linux_user"/ebesucher ]; then
					skip "Ordner ebesucher exestiert bereits"
					# check if config exists, if yes, ask to overwrite
					if [ -f /home/"$linux_user"/ebesucher/config.zip ]; then
						if whiptail --title "Alte config gefunden" --yesno "Es wurde bereits ein Firefox Profil angelegt, soll dieses gelöscht und überschrieben werden?" 20 100; then
							# remove old config
							rm -f /home/"$linux_user"/ebesucher/config.zip
							# download blank config
							wget -O /home/"$linux_user"/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
							# unpack config
							unzip -o /home/"$linux_user"/ebesucher/config.zip -d /home/"$linux_user"/ebesucher/
						else
							# unpack config
							unzip -o /home/"$linux_user"/ebesucher/config.zip -d /home/"$linux_user"/ebesucher/
						fi
					fi
				else
					# Create ebesucher folder
					if [ -d /home/"$linux_user"/ebesucher ]; then
						# download config
						wget -O /home/"$linux_user"/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
						# unpack config
						unzip -o /home/"$linux_user"/ebesucher/config.zip -d /home/"$linux_user"/ebesucher/
					fi
					if mkdir /home/"$linux_user"/ebesucher; then
						# download config
						wget -O /home/"$linux_user"/ebesucher/config.zip https://github.com/Pakobbix/passive-income/raw/master/config.zip
						# unpack config
						unzip -o /home/"$linux_user"/ebesucher/config.zip -d /home/"$linux_user"/ebesucher/
						erfolg "Ordner für ebesucher konnte erstellt werden"
					else
						fehler "Der Ordner für ebesucher konnte nicht angelegt werden"
					fi
				fi
				while true; do
					CPUSet=$(inputbox "CPU Begrenzung" "Das System hat $availablecores Kerne. Wieviele davon darf Ebesucher ausnutzen? 4 sind empfohlen")
					if [[ "$availablecores" -ge "CPUSet" ]]; then
						break
					fi
				done
				# Ebesucher docker creation function. Will be used in the next step
				ebesucher_docker() {
					if docker rm -f ebesucher || true && docker run -d --name=ebesucher -p 3000:5800 -u $(awk -v user=$(whoami) -F':' '$0 ~ user {print $3}' /etc/passwd) -m "$1" --cpus "$2" -v ~/ebesucher/config:/config:rw --shm-size 2g jlesage/firefox; then
						erfolg "Firefox-Ebesucher wurde eingerichtet"
						messagebox "Jetzt bist du gefragt!" "Öffne im browser deiner Wahl von einem anderen Gerät aus $(hostname -I | awk '{print $1}'):3000"
					else
						fehler "Firefox-Ebesucher konnte nicht eingerichtet werden"
					fi
				}
				# Check how much ram is available.
				ram_avail=$(bc <<<"scale=2;$(($(free | awk 'NR==2 {print $2}') / 1000000))")
				if [[ $ram_avail -ge "2" ]]; then
					# create ebesucher docker container with specific RAM available (around 1 GB less then available)
					ebesucher_docker "1g" "$CPUSet"
				elif [[ $ram_avail -eq "4" ]]; then
					ebesucher_docker "3g" "$CPUSet"
				elif [[ $ram_avail -ge "5" ]]; then
					ebesucher_docker "4g" "$CPUSet"
				fi
				messagebox "" "Oben Rechts im Firefox Browser, öffne das Ebesucher addon.
Gebe in das Feld deinen Ebesucher Nutzernamen ein und mache einen Haken bei Privacy"
				nutzername=$(inputbox "Ebesucher Nutzername" "Gebe hier deinen Ebesucher Nutzernamen ein: ")
				messagebox 'Schließt nun alle Tabs im Browser und fahrt fort.'
				messagebox "Erstelle Sicherungen" "Damit die Einstellungen auch für immer gespeichert werden,
erstelle ich eine Sicherung der Firefox-Konfiguration"
				{
					echo 10
					if [ -f /home/"$linux_user"/ebesucher/config.zip ]; then
						# delete blank config.zip
						sudo rm -f /home/"$linux_user"/ebesucher/config.zip 2>/dev/null
					fi
					echo 15
					docker stop ebesucher
					echo 20
					cd /home/"$linux_user"/ebesucher/ || exit
					echo 30
					# pack config folder into new config.zip
					zip -r config.zip config/ 2>/dev/null
					echo 40
					# Give rights back to user
					sudo chown "$linux_user":"$linux_user" config.zip
					# download restart script
					wget -O /home/"$linux_user"/ebesucher/restart.sh https://raw.githubusercontent.com/Pakobbix/passive-income/master/restart.sh
					echo 50
					# add username to restart skript
					sed -i "s/username=/&$nutzername/g" /home/"$linux_user"/ebesucher/restart.sh
					echo 60
					# Add RAM and CPU Settings to restart script
					sed -i "s/CPUcores=/CPUcores=$CPUSet/g" /home/"$linux_user"/ebesucher/restart.sh
					# make restart skript executable
					chmod +x /home/"$linux_user"/ebesucher/restart.sh
					echo 80
					bash /home/"$linux_user"/ebesucher/restart.sh
					echo 100
				} | whiptail --gauge "Erstelle Sicherung und Lade Restarter Skript herunter" 6 50 0
				# Export current crontab
				crontab -l >/tmp/ebesucher
				# check if restart script is already configured
				if ! grep -q "ebesucher/restart.sh" "/tmp/ebesucher"; then
					# add restart script
					echo "0 * * * * /bin/bash /home/$linux_user/ebesucher/restart.sh
@reboot /bin/bash /home/$linux_user/ebesucher/restart.sh" >>/tmp/ebesucher
					# Let cron reload the new configured crontab
					crontab /tmp/ebesucher
					# delete the export
					rm /tmp/ebesucher
				fi
			fi

			;;
		esac
	done
fi

if [ "$linux_user" == "root" ]; then
	# configure update script
	echo -e "#!/bin/bash\n\nexport DEBIAN_FRONTEND=noninteractive\n\nsudo apt-get update\n\nsudo apt-get upgrade -y\n\nsudo apt-get autoremove -y" >/root/update_system.sh
	# make update script executable
	chmod +x /root/update_system.sh
else
	# configure update script
	echo -e "#!/bin/bash\n\nexport DEBIAN_FRONTEND=noninteractive\n\nsudo apt-get update\n\nsudo apt-get upgrade -y\n\nsudo apt-get autoremove -y" | sudo tee /root/update_system.sh
	# make update script executable
	sudo chmod +x /root/update_system.sh
	# export root crontab
	sudo crontab -l | sudo tee /tmp/rootcron
	# add update and reboot to root crontab
	if ! grep -q "update_system" "/tmp/rootcron"; then
		echo "0 0 * * 0 reboot
0 4 * * * /bin/bash /root/update_system.sh" | sudo tee -a /tmp/rootcron
	fi
	# import root crontab
	sudo crontab /tmp/rootcron
fi

if docker ps | grep -q "ebesucher\|traffmonetizer\|peer2profit\|IPRoyal\|packetstream\|honeygain"; then
	if docker ps -a | grep -i "containerr/watchtower"; then
		if docker run -d --name watchtower --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /etc/localtime:/etc/localtime:ro containrrr/watchtower --cleanup --interval 86400; then
			erfolg "Watchtower erfolgreich eingerichtet"
		else
			fehler "Watchtower konnte nicht eingerichtet werden"
		fi
	else
		skip "Watchtower ist bereits vorhanden."
	fi
fi

messagebox "FERTIG!" "Wir sind nun Fertig! Ich hoffe das alles geklappt hat, wenn nicht, erstelle ein Issue auf https://github.com/Pakobbix/passive-income/issues"
new_task "${green}$erfolgreich Erfolgreiche Operationen\n${red}$fehler Fehlerhafte Operationen\n${cyan}$skip Übersprungene Operationen${white}"
