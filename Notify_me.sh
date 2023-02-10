#!/bin/bash

config="/opt/Passive-Income/NotificationHandler/config"

create_config() {
	messagehandler=$(
		whiptail --title "$(text_lang "058")" --menu "$(text_lang "059")" 20 100 9 \
			"1)" "Discord" \
			"2)" "Telegram" \
			"3)" "Apprise" \
			"4)" "NextcloudTalk" \
			"5)" "PushBullet" \
			"6)" "Email" \
			"7)" "Rocket.Chat" \
			"8)" "Abbrechen" 3>&2 2>&1 1>&3
	)
	case "$messagehandler" in
	Discord)
		dishook=$(whiptail --title "Discord Webhook URL" --inputbox "Gebe hier deine Discord Webhook URL ein" 16 100 3>&2 2>&1 1>&3)
		if [ -n "$dishook" ]; then
			sed -i "s/Discord_WebHookLink=.*/Discord_WebHookLink=\"$dishook\"/g" $config
		fi
		;;
	Telegram)
		T_UI=$(whiptail --title "Telegram USER ID" --inputbox "Gebe hier deine Telegram USERID ein" 16 100 3>&2 2>&1 1>&3)
		T_BotToken=$(whiptail --title "Telegram Bot Token" --inputbox "Gebe hier deinen Telegram Bot Token ein" 16 100 3>&2 2>&1 1>&3)
		if [ -n "$T_UI" ]; then
			sed -i "s/Telegram_UID=.*/Telegram_UID=\"$T_UI\"/g" $config
		fi
		if [ -n "$T_BotToken" ]; then
			sed -i "s/Telegram_BT=.*/Telegram_BT=\"$T_BotToken\"/g" $config
		fi
		;;
	Apprise)
		AppRise_URL=$(whiptail --title "AppRise URL" --inputbox "Gebe hier die AppRise URL ein" 16 100 3>&2 2>&1 1>&3)
		AppRise_URL_TAG=$(whiptail --title "AppRise Tag" --inputbox "Gebe hier einen AppRise Tag ein (Optional! Achtung, ohne Tag\nwerden alle Konfigurierten Methoden in Apprise genutzt)" 16 100 3>&2 2>&1 1>&3)
		if [ -n "$T_UI" ]; then
			sed -i "s/AppRiseURL=.*/AppRiseURL=\"$AppRise_URL\"/g" $config
		fi
		if [ -n "$T_BotToken" ]; then
			sed -i "s/AppRiseTAG=.*/AppRiseTAG=\"$AppRise_URL_TAG\"/g" $config
		fi
		;;
	NextcloudTalk)
		NextcloudDomain=$(whiptail --title "Nextcloud Domain" --inputbox "Gebe hier deine Nextcloud Domain/IP ein" 16 100 3>&2 2>&1 1>&3)
		NextcloudTalkToken=$(whiptail --title "Nextcloud Talk Token" --inputbox "Gebe hier deinen Nextcloud Talk Chatroom Token ein" 16 100 3>&2 2>&1 1>&3)
		NextcloudUser=$(whiptail --title "Nextcloud User" --inputbox "Gebe hier deinen Nextcloud User ein der die Nachricht schreiben soll" 16 100 3>&2 2>&1 1>&3)
		NextcloudPassword=$(whiptail --title "Nextcloud Password" --passwordbox "Gebe hier das Passwort von dem Nextcloud User ein" 16 100 3>&2 2>&1 1>&3)
		if [ -n "$NextcloudDomain" ]; then
			sed -i "s/NextcloudDomain=.*/NextcloudDomain=\"$NextcloudDomain\"/g" $config
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
			sed -i "s/PushBulletToken==.*/PushBulletToken==\"$PBToken\"/g" $config
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
			sed -i "s/RocketChatHook==.*/RocketChatHook==\"$RCHOOK\"/g" $config
		fi
		;;
	Abbrechen)
		exit 0
		;;
	esac
}

if ! [ -d "/opt/Passive-Income/NotificationHandler" ] || ! [ -f "$config" ] || ! source "$config" 2>/dev/null; then
	mkdir -p /opt/Passive-Income/NotificationHandler 2>/dev/null
	# wget blank CONFIG
	create_config
fi

source "$config"

if [ -z "$NotificationHandler" ]; then
	create_config
fi

ProcessID=$(pgrep -f "surfbar/$SurfbarName")

case $NotificationHandler in
Discord)
	if [ -z "$Discord_WebHookLink" ]; then
		echo "Fehler! Discord wurde ausgewählt, aber keine WebHook angegeben!"
		echo
		echo "Eine Anleitung für die Webhook findet ihr hier:"
		echo "https://hookdeck.com/webhooks/platforms/how-to-get-started-with-discord-webhooks#how-do-i-add-a-webhook-to-discord"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"Ebesucher ist Abgestürzt.\n$SurfbarName läuft nicht mehr\"}" "$Discord_WebHookLink" &>/dev/null
		else
			exit 1
		fi
	fi
	;;
Telegram)
	if [ -z "$Telegram_UID" ] || [ -z "$Telegram_BT" ]; then
		echo "Fehler! Discord wurde ausgewählt, aber keine WebHook angegeben!"
		echo
		echo "Eine Anleitung für die Webhook findet ihr hier:"
		echo "https://hookdeck.com/webhooks/platforms/how-to-get-started-with-discord-webhooks#how-do-i-add-a-webhook-to-discord"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			curl -X POST -H 'Content-Type: application/json' -d '{"chat_id": "'"$Telegram_UID"'", "text": "This is a test from curl", "disable_notification": true}' https://api.telegram.org/bot$Telegram_BT/sendMessage
		else
			exit 1
		fi
	fi
	;;
Apprise)
	if [ -z "$AppRiseURL" ]; then
		echo "Fehler! AppRise wurde ausgewählt, aber keine URL angegeben!"
		echo
		echo "Eine Anleitung für AppRise findet ihr hier"
		echo "https://github.com/caronc/apprise/wiki/config"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			if [ -n "$AppRiseTAG" ]; then
				curl -d '{"body":"'"Ebesucher Container $SurfbarName ist down"'", "title":"Passive-Income Notification: Ebesucher ist Abgestürzt","tag":"'"$AppRiseTAG"'"}' -H "Content-Type: application/json" "$AppRiseURL" &>/dev/null
			else
				curl -d '{"body":"'"Ebesucher Container $SurfbarName ist down"'", "title":"Passive-Income Notification: Ebesucher ist Abgestürzt","tag":"all"}' -H "Content-Type: application/json" "$AppRiseURL" &>/dev/null
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
			curl -d '{"token":"'"$NextcloudTalkToken"'", "message":"'"Passive-Income Notification: Ebesucher ist Abgestürzt\nEbesucher Container $SurfbarName ist down"'"}' -H "Content-Type: application/json" -H "Accept:application/json" -H "OCS-APIRequest:true" -u "$NextcloudUser:$NextcloudPassword" "$NextcloudDomain"/ocs/v1.php/apps/spreed/api/v1/chat/tokenid &>/dev/null
		fi
	fi
	;;
PushBullet)
	if [ -z "$PushBulletToken" ]; then
		echo "Fehler! PushBullet wurde ausgewählt, aber kein Token angegeben!"
		echo
		echo "Eine Anleitung für PushBullet findet ihr hier"
		echo "https://www.pushbullet.com/"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			curl -u "$PushBulletToken": -X POST https://api.pushbullet.com/v2/pushes --header 'Content-Type: application/json' --data-binary '{"type": "note", "title": "Passive-Income Notification: Ebesucher ist Abgestürzt", "body": "Ebesucher Container '"$SurfbarName"' ist down"}'
		else
			exit 1
		fi
	fi
	;;
Mail)
	if [ -z "$smtpURL" ] || [ -z "$smtpPORT" ] || [ -z "$mailfrom" ] || [ -z "$mailrcpt" ] || [ -z "$mailuser" ] || [ -z "$mailpass" ]; then
		echo "Fehler! Mail wurde ausgewählt, aber eines oder mehrere Variablen leer gelassen!"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			echo "From: Passive-Income $mailfrom
To: $mailrcpt $mailrcpt
Subject: Passive-Income Notification: Ebesucher ist Abgestürzt

Hi $mailrcpt,
Your Ebesucher Container $SurfbarName ist abgestürzt und läuft nicht mehr.
Bye!" >/root/pain_watchmail
			curl "smtps://$smtpURL:$smtpPORT" --mail-from "$mailfrom" --mail-rcpt "$mailrcpt" -T /root/pain_watchmail -u "$mailuser:$mailpass" --ssl-reqd --insecure --show-error -s
		else
			exit 1
		fi
	fi
	;;
Rocket.Chat)
	if [ -z "$RocketChatHook" ]; then
		echo "Fehler! RocketChat wurde ausgewählt, aber keine WebHook angegeben!"
		echo
		echo "Eine Anleitung für die Webhook findet ihr hier:"
		echo "https://docs.rocket.chat/use-rocket.chat/rocket.chat-workspace-administration/integrations"
		exit 1
	else
		if [ -z "$ProcessID" ]; then
			curl -X POST -H 'Content-Type: application/json' --data '{"text":"Passive-Income Notification: Ebesucher ist Abgestürzt","attachments":[{"title":"Passive-Income Notification: Ebesucher ist Abgestürzt","text":"Ebesucher Container '"$SurfbarName"' ist down","color":"#764FA5"}]}' "$RocketChatHook"
		else
			exit 1
		fi
	fi
	;;
esac
