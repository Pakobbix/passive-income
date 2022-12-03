### Skript um Passive Einkommensmöglichkeiten auf einem Ubuntu-Server zu installieren.
Dieses Skript hilft einem dabei, einen Ubuntu Server oder Mini PC mit Ubuntu so einzurichten, dass via Docker-Container ein Passives einkommen generiert werden kann.\
Es gilt jedoch zu beachten, dass es immer nur 1 mal pro IP auch was bringt. Wenn ihr mehrere Mini PC's oder Server zuhause hinstellen wollt, bringt es nichts, das diese Sachen überall zu installieren, da die Anbieter immer nur eine Public-IP erlauben.\
Habt ihr also "nur" einen Internet Vertrag, geht auch nur ein Server/Mini PC um damit Passiv zu verdienen.\

Pro IP könnt ihr so mindestens ~20€ bis maximal ~50€ machen, je nach Standort und Internet Auslastung/Stabilität.
## Benutzung
Für die Einrichtung, benötigt ihr:

 - einen Server/Mini PC.
 - ein Ethernet/Lan Kabel mit Internet Zugang
 - einen USB Stick
 - einen Laptop oder PC
 - ein Bildschirm/Fernseher + Verbindungskabel zum Server/Mini PC
 - Tastatur

Die Installation von Ubuntu Server:
 - Ladet euch [Ubuntu Server 22.04](https://ubuntu.com/download/server) herunter.
 - Erstellt einen Boot Stick mit [Ventoy](https://www.ventoy.net/en/download.html) (Empfohlen), [Rufus](https://rufus.ie/de/) oder [balenaEtcher](https://www.balena.io/etcher/)
 - Schließt den USB Stick an den Server/Mini PC, und startet vom USB Stick.
 - Installiert nun Ubuntu Server, sobald ihr gefragt werdet, aktiviert OpenSSH ohne import. (TIP: Falls das installieren schiefgehen sollte, und ihr ein Problem haben wie vg-ubuntu-lvm not found, dann müsst ihr leider nochmal installieren. Entfernt aber die Option ein LVM bei den Festplatten zu erstellen)
   - (TIP: Wenn ihr den PC woanders aufstellen wollt, als an dem Ort, wo Ihr den einrichtet, stellt keine Statische IP ein. Bleibt auf DHCP)
 - Ihr werdet gefragt, ob ihr zusätzliche Anwendungen installieren wollt, verneint diese bzw. überspringt den Punkt
 - Nach der Installation werdet ihr gebeten, neuzustarten. Entfernt danach den USB Stick und fahrt den Server/Mini PC wieder hoch.
 - Nun solltet der PC neustarten. Wir brauchen nun nur noch die IP Adresse.
 - Wenn ihr diese schon kennt, überspringt die weiteren Punkte
 - Falls der Login nicht angezeigt wird, drückt einmal Enter
 - Gebt euren bei der Installation gewählten Login Namen ein, und bestätigt die Eingabe mit Enter.
 - Gebt dann euer gewähltes Passwort ein und bestätigt erneut mit Enter.
 - Damit nachher der Befehl des Helperskripts funktioniert, gebt folgendes ein:
 - `apt install -y curl`
 - Gebt nun folgenden Befehl ein, dann wird euch die Momentane IP-Adresse angezeigt:

`hostname -I`
## Skript ausführen
Um das Skript auszuführen, solltet ihr euch per SSH verbinden. Dadurch könnt ihr dann auch Kopieren und einfügen.\
Ab hier ist es nicht mehr nötigt, Bildschirm und Tastatur angeschlossen zu lassen.\
**Nach der Einrichtung per Skript, braucht der Server/Mini PC nur noch Strom und Internet um zu funktionieren.**\
\
Öffnet dazu das Windows Terminal.\
gebt nun folgendes ein: (Ändert username in den Benutzernamen den ihr bei der Installation angelegt habt und 123.456.789.0 in die IP-Adresse vom Server/Mini PC

`ssh username@123.456.789.0`

Tippt `yes` ein um zu bestätigen, dass ihr der Verbindung zu dem PC vertraut.\
Gebt nun das Passwort ein, dass ihr bei der Installation von Ubuntu Server eingegeben habt.\
Ihr solltet nun mit dem Server/Mini PC verbunden sein. Sehen solltet ihr das an der veränderten Eingabe.\
Falls ihr euch unschlüssig seid, gebt `whoami` ein. Sollte da nicht der Nutzername angezeigt werden, ist etwas schief gegangen.\
Solltet ihr aber verbunden sein, könnt ihr nun das Skript starten.\
Dies macht ihr, in dem ihr folgenden Befehl kopiert, in das Terminal einfügt und mit Enter bestätigt:

`bash <(curl -fsSL https://raw.githubusercontent.com/Pakobbix/passive-income/master/gui_start.sh)`

Folgt nun den Schritten aus dem Skript.\

Die Anbieter sind mit Ref-Links versehen, falls ihr euch erst noch anmelden müsst, und um mich zu unterstützen.
## Unterstützte Anbieter:
- [ebesucher](http://www.ebesucher.de/?ref=Pakobbix)
- [honeygain](https://r.honeygain.me/PAKOB7875D)
- [Peer2Profit](https://p2pr.me/1664028004632f0d64483e3)
- [EarnAPP](https://earnapp.com/i/VF8ygUXG)
- [packetstream](https://packetstream.io/?psr=4HUh)
- [IPRoyal Pawn.app](https://pawns.app?r=905162)
- [TraffMonetizer](https://traffmonetizer.com/?aff=607897)
