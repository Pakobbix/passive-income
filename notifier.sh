#!/bin/bash

red='\033[0;31m'    # ${red}
white='\033[0;37m'  # ${white}
yellow='\033[0;33m' # ${yellow}
lblue='\033[1;34m'  # ${lblue}
cyan='\033[0;36m'   # ${cyan}
purple='\033[0;35m' # ${purple}

Help() {
	# Display Help
	echo
	echo -e "${purple}Benachrichtigungs Skript für Passive-Income (pain).${white}"
	echo
	echo "Ausführung: ./notifier.sh"
	echo
	echo "Für erneute Configuration: ./notifier.sh -c"
	echo
	echo "Argumente:"
	echo -e "${yellow} -c${white}     ${lblue}Starte die Konfiguration erneut"
	echo -e "${yellow} -h${white}     ${lblue}Zeige diese Hilfe"
	echo
}

fehler() {
	echo -e "${red}$1${white}"
}

Hinweis() {
	echo -e "${yellow}$1${white}"

}

URLlink() {
	echo -e "${cyan}$1${white}"
}

config="/opt/Passive-Income/NotificationHandler/config"

setup_config() {
	while true; do
		messagehandler=$(
			whiptail --title "Wähle den Notifier" --menu "Nehme hier die Art der Benachrichtung die du haben willst." 20 100 9 \
				"SurfbarName" "" \
				"Discord" "" \
				"Telegram" "" \
				"Apprise" "" \
				"NextcloudTalk" "" \
				"PushBullet" "" \
				"Email" "" \
				"Rocket.Chat" "" \
				"CronErstellen" "" \
				"Beenden" "" 3>&2 2>&1 1>&3
		)
		case "$messagehandler" in
		SurfbarName)
			surflink=$(whiptail --title "Surfbar Link" --inputbox "Gebe hier den Namen deiner Surfbar ein\nBeispiel:\nHttps://www.ebesucher.de/surfbar/MeinSurfLink\nName ist hierbei: MeinSurfLink\nEs können auch mehrere eingegeben werden." 16 100 3>&2 2>&1 1>&3)
			if [ -n "$surflink" ]; then
				sed -i "s/SurfbarName=.*/SurfbarName=\"$surflink\"/g" $config
			fi
			;;
		Discord)
			dishook=$(whiptail --title "Discord Webhook URL" --inputbox "Gebe hier deine Discord Webhook URL ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$dishook" ]; then
				sed -i "s|Discord_WebHookLink=.*|Discord_WebHookLink=\"$dishook\"|g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"Discord\"/g" $config
			fi
			;;
		Telegram)
			T_UI=$(whiptail --title "Telegram USER ID" --inputbox "Gebe hier deine Telegram USERID ein" 16 100 3>&2 2>&1 1>&3)
			T_BotToken=$(whiptail --title "Telegram Bot Token" --inputbox "Gebe hier deinen Telegram Bot Token ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$T_UI" ]; then
				sed -i "s/Telegram_UID=.*/Telegram_UID=\"$T_UI\"/g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"Telegram\"/g" $config
			fi
			if [ -n "$T_BotToken" ]; then
				sed -i "s/Telegram_BT=.*/Telegram_BT=\"$T_BotToken\"/g" $config
			fi
			;;
		Apprise)
			AppRise_URL=$(whiptail --title "AppRise URL" --inputbox "Gebe hier die AppRise URL ein\nNötig ist hier die IP:Port. Beispiel:\n192.168.5.21:8000" 16 100 3>&2 2>&1 1>&3)
			AppRise_URL_TAG=$(whiptail --title "AppRise Tag" --inputbox "Gebe hier einen AppRise Tag ein (Optional! Achtung, ohne Tag\nwerden alle Konfigurierten Methoden in Apprise genutzt)" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$AppRise_URL" ]; then
				sed -i "s|AppRiseURL=.*|AppRiseURL=\"$AppRise_URL/notify/apprise\"|g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"Apprise\"/g" $config
			fi
			if [ -n "$AppRise_URL_TAG" ]; then
				sed -i "s/AppRiseTAG=.*/AppRiseTAG=\"$AppRise_URL_TAG\"/g" $config
			fi
			;;
		NextcloudTalk)
			NextcloudDomain=$(whiptail --title "Nextcloud Domain" --inputbox "Gebe hier deine Nextcloud Domain/IP:Port ein\nBeispiel: 10.0.0.4:85 oder\nhttps://cloud.zephyre.one" 16 100 3>&2 2>&1 1>&3)
			NextcloudTalkToken=$(whiptail --title "Nextcloud Talk Token" --inputbox "Gebe hier deinen Nextcloud Talk Chatroom Token ein\nhttps://cloud.zephyre.one/call/9gp9y99i\n9gp9y99i ist der benötigte Token" 16 100 3>&2 2>&1 1>&3)
			NextcloudUser=$(whiptail --title "Nextcloud User" --inputbox "Gebe hier deinen Nextcloud User ein der die Nachricht schreiben soll.\nDer User muss dem Chatroom hinzugefügt werden!" 16 100 3>&2 2>&1 1>&3)
			NextcloudPassword=$(whiptail --title "Nextcloud Password" --passwordbox "Gebe hier das Passwort von dem Nextcloud User ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$NextcloudDomain" ]; then
				sed -i "s|NextcloudDomain=.*|NextcloudDomain=\"$NextcloudDomain\"|g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"NextCloud\"/g" $config
			fi
			if [ -n "$NextcloudTalkToken" ]; then
				sed -i "s/NextcloudTalkToken=.*/NextcloudTalkToken=\"$NextcloudTalkToken\"/g" $config
			fi
			if [ -n "$NextcloudUser" ]; then
				sed -i "s/NextcloudUser=.*/NextcloudUser=\"$NextcloudUser\"/g" $config
			fi
			if [ -n "$NextcloudPassword" ]; then
				sed -i "s/NextcloudPassword=.*/NextcloudPassword=\"$NextcloudPassword\"/g" $config
			fi
			;;
		PushBullet)
			PBToken=$(whiptail --title "Pushbullet Token" --inputbox "Gebe hier deinen Pushbullet Token ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$PBToken" ]; then
				sed -i "s/PushBulletToken=.*/PushBulletToken=\"$PBToken\"/g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"PushBullet\"/g" $config
			fi
			;;
		Email)
			smtpURL=$(whiptail --title "Nextcloud Domain" --inputbox "Gebe hier die SMTP Domain ein" 16 100 3>&2 2>&1 1>&3)
			smtpPORT=$(whiptail --title "Nextcloud Talk Token" --inputbox "Gebe hier den SMTP Port an" 16 100 3>&2 2>&1 1>&3)
			mailfrom=$(whiptail --title "Nextcloud User" --inputbox "Gebe hier die E-Mail an, die die Nachricht verschicken soll" 16 100 3>&2 2>&1 1>&3)
			mailrcpt=$(whiptail --title "Nextcloud Password" --inputbox "Gebe hier die E-Mail an, die die Nachricht erhalten soll" 16 100 3>&2 2>&1 1>&3)
			mailuser=$(whiptail --title "Nextcloud User" --inputbox "Gebe hier den User für die E-Mail an" 16 100 3>&2 2>&1 1>&3)
			mailpass=$(whiptail --title "Nextcloud Password" --passwordbox "Gebe das Passwort des Users ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$smtpURL" ]; then
				sed -i "s/smtpURL=.*/smtpURL=\"$smtpURL\"/g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"Email\"/g" $config
			fi
			if [ -n "$smtpPORT" ]; then
				sed -i "s/smtpPORT=.*/smtpPORT=\"$smtpPORT\"/g" $config
			fi
			if [ -n "$mailfrom" ]; then
				sed -i "s/mailfrom=.*/mailfrom=\"$mailfrom\"/g" $config
			fi
			if [ -n "$mailrcpt" ]; then
				sed -i "s/mailrcpt=.*/mailrcpt=\"$mailrcpt\"/g" $config
			fi
			if [ -n "$mailuser" ]; then
				sed -i "s/mailuser=.*/mailuser=\"$mailuser\"/g" $config
			fi
			if [ -n "$mailpass" ]; then
				sed -i "s/mailpass=.*/mailpass=\"$mailpass\"/g" $config
			fi
			;;
		Rocket.Chat)
			RCHOOK=$(whiptail --title "Rocket Chat Webhook" --inputbox "Gebe hier deine Rocket.Chat Webhook ein" 16 100 3>&2 2>&1 1>&3)
			if [ -n "$RCHOOK" ]; then
				sed -i "s/RocketChatHook=.*/RocketChatHook=\"$RCHOOK\"/g" $config
				sed -i "s/NotificationHandler=.*/NotificationHandler=\"Rocket.Chat\"/g" $config
			fi
			;;
		CronErstellen)
			cronloc="/tmp/crontab"
			curr_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
			scriptname=$(echo "$0" | sed 's/\.\///g')
			crontab -l "$cronloc"
			if grep -q "notifier.sh" $cronloc; then
				if whiptail --title "Eintrag bereits vorhanden" --yesno "Es ist bereits ein eintrag für den notifier vorhanden, möchtest du diesen überschreiben?" 20 100; then
					sed -i "s|.*notifier.sh.*|10,20,30,40,50 * * * * /bin/bash $curr_dir/$scriptname|g" "$cronloc"
					crontab "$cronloc"
				fi
			else
				echo "10,20,30,40,50 * * * * /bin/bash $curr_dir/$scriptname|g" >>"$cronloc"
				crontab "$cronloc"
			fi
			;;
		Beenden)
			break
			exit 0
			;;
		esac
		break
		exit
	done
}

while getopts ":hc" option; do
	case $option in
	h) # display Help
		Help
		exit
		;;
	c) # Starte eine erneute Konfiguration
		if ! [ -f "$config" ]; then
			mkdir -p /opt/Passive-Income/NotificationHandler 2>/dev/null
			wget -qO "$config" https://raw.githubusercontent.com/Pakobbix/passive-income/NotificationHandler/NotificationHandler/config
		fi
		setup_config
		exit
		;;
	\?) # Invalid option
		echo "Fehler: Ungültige Eingabe"
		Help
		exit
		;;
	esac
done

if ! [ -d "/opt/Passive-Income/NotificationHandler" ] || ! [ -f "$config" ]; then
	mkdir -p /opt/Passive-Income/NotificationHandler 2>/dev/null
	wget -qO "$config" https://raw.githubusercontent.com/Pakobbix/passive-income/NotificationHandler/NotificationHandler/config
	setup_config
fi

source "$config"

if [ -z "$NotificationHandler" ]; then
	setup_config
fi

if [ -z "$SurfbarName" ]; then
	fehler "SurfbarName ist nicht gesetzt!"
	Hinweis "Wenn du weiter drückst, wird die Konfiguration nochmal aufgerufen. Wähle hier dann SurfbarName um diesen zu Konfigurieren"
	read -rp "Drücke eine beliebige Taste zum fortfahren"
	setup_config
fi

for SurfbarLinks in $SurfbarName; do

	ProcessID=$(pgrep -f "surfbar/$SurfbarLinks")

	case $NotificationHandler in
	Discord)
		if [ -z "$Discord_WebHookLink" ]; then
			fehler "Fehler! Discord wurde ausgewählt, aber keine WebHook angegeben!"
			echo
			Hinweis "Eine Anleitung für die Webhook findet ihr hier:"
			URLlink "https://hookdeck.com/webhooks/platforms/how-to-get-started-with-discord-webhooks#how-do-i-add-a-webhook-to-discord"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"Ebesucher ist Abgestürzt.\n$SurfbarLinks läuft nicht mehr\"}" "$Discord_WebHookLink" &>/dev/null
			else
				exit 1
			fi
		fi
		;;
	Telegram)
		if [ -z "$Telegram_UID" ] || [ -z "$Telegram_BT" ]; then
			fehler "Fehler! Discord wurde ausgewählt, aber keine WebHook angegeben!"
			echo
			Hinweis "Eine Anleitung für die Webhook findet ihr hier:"
			URLlink "https://hookdeck.com/webhooks/platforms/how-to-get-started-with-discord-webhooks#how-do-i-add-a-webhook-to-discord"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$Telegram_UID"'", "text": "'"Ebesucher auf $surflink"'", "disable_notification": true}' https://api.telegram.org/bot$Telegram_BT/sendMessage
			else
				exit 1
			fi
		fi
		;;
	Apprise)
		if [ -z "$AppRiseURL" ]; then
			fehler "Fehler! AppRise wurde ausgewählt, aber keine URL angegeben!"
			echo
			Hinweis "Eine Anleitung für AppRise findet ihr hier"
			URLlink "https://github.com/caronc/apprise/wiki/config"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				if [ -n "$AppRiseTAG" ]; then
					curl -d '{"body":"'"Ebesucher Container $SurfbarLinks ist down"'", "title":"Passive-Income Notification: Ebesucher ist Abgestürzt","tag":"'"$AppRiseTAG"'"}' -H "Content-Type: application/json" "$AppRiseURL" &>/dev/null
				else
					curl -d '{"body":"'"Ebesucher Container $SurfbarLinks ist down"'", "title":"Passive-Income Notification: Ebesucher ist Abgestürzt","tag":"all"}' -H "Content-Type: application/json" "$AppRiseURL" &>/dev/null
				fi
			else
				exit 1
			fi
		fi
		;;
	NextCloud)
		if [ -z "$NextcloudUser" ] || [ -z "$NextcloudPassword" ] || [ -z "$NextcloudDomain" ] || [ -z "$NextcloudTalkToken" ]; then
			echo "Eine oder mehrere Variablen (NextcloudUser, NextcloudPassword, NextcloudDomain, und/oder NextcloudTalkToken) wurden nicht angegeben. Beende NotificationHandler!."
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				curl -d '{"token":"'"$NextcloudTalkToken"'", "message":"'"Passive-Income Notification: Ebesucher ist Abgestürzt\nEbesucher Container $SurfbarLinks ist down"'"}' -H "Content-Type: application/json" -H "Accept:application/json" -H "OCS-APIRequest:true" -u "$NextcloudUser:$NextcloudPassword" "$NextcloudDomain"/ocs/v1.php/apps/spreed/api/v1/chat/tokenid &>/dev/null
			fi
		fi
		;;
	PushBullet)
		if [ -z "$PushBulletToken" ]; then
			fehler "Fehler! PushBullet wurde ausgewählt, aber kein Token angegeben!"
			echo
			Hinweis "Eine Anleitung für PushBullet findet ihr hier"
			URLlink "https://www.pushbullet.com/"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$Telegram_UID"'", "text": "'"Ebesucher auf $surflink"'", "disable_notification": true}' https://api.telegram.org/bot$Telegram_BT/sendMessage
				curl -u "$PushBulletToken": -X POST https://api.pushbullet.com/v2/pushes --header 'Content-Type: application/json' --data-binary '{"type": "note", "title": "Passive-Income Notification: Ebesucher ist Abgestürzt", "body": "Ebesucher Container '"$SurfbarLinks"' ist down"}'
			else
				exit 1
			fi
		fi
		;;
	Email)
		if [ -z "$smtpURL" ] || [ -z "$smtpPORT" ] || [ -z "$mailfrom" ] || [ -z "$mailrcpt" ] || [ -z "$mailuser" ] || [ -z "$mailpass" ]; then
			echo "Fehler! Mail wurde ausgewählt, aber eines oder mehrere Variablen leer gelassen!"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				echo "From: Passive-Income $mailfrom
To: $mailrcpt $mailrcpt
Subject: Passive-Income Notification: Ebesucher ist Abgestürzt

Hi $mailrcpt,
Your Ebesucher Container $SurfbarLinks ist abgestürzt und läuft nicht mehr.
Bye!" >/root/pain_watchmail
				curl "smtps://$smtpURL:$smtpPORT" --mail-from "$mailfrom" --mail-rcpt "$mailrcpt" -T /root/pain_watchmail -u "$mailuser:$mailpass" --ssl-reqd --insecure --show-error -s
			else
				exit 1
			fi
		fi
		;;
	Rocket.Chat)
		if [ -z "$RocketChatHook" ]; then
			fehler "Fehler! RocketChat wurde ausgewählt, aber keine WebHook angegeben!"
			echo
			Hinweis "Eine Anleitung für die Webhook findet ihr hier:"
			URLlink "https://docs.rocket.chat/use-rocket.chat/rocket.chat-workspace-administration/integrations"
			exit 1
		else
			if [ -z "$ProcessID" ]; then
				curl -X POST -H 'Content-Type: application/json' --data '{"text":"Passive-Income Notification: Ebesucher ist Abgestürzt","attachments":[{"title":"Passive-Income Notification: Ebesucher ist Abgestürzt","text":"Ebesucher Container '"$SurfbarLinks"' ist down","color":"#764FA5"}]}' "$RocketChatHook"
			else
				exit 1
			fi
		fi
		;;
	esac
done
