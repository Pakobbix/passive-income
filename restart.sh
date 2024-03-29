#!/bin/bash

# Variablen für Benennung und Ebesucher Nutzernamen
username=
containername=ebesucher

# Variable für die Maximale Nutzung von CPU Cores
CPUcores=

# Überprüfe ob bereits ein restart läuft
if [ -f /tmp/ebesucher_restart.lock ]; then
  exit
fi

# Erstelle Lockfile
echo $$ >/tmp/ebesucher_restart.lock

# Ordner des Skripts
git_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# Wechsel in den Ordner
cd "$git_dir" || exit

# Stoppe alten Container
docker stop "$containername"
# Lösche alten Container
docker rm "$containername"
# Lösche altes Firefox Profil
rm -rf config/
# Stelle Firefox Profil Sicherung wieder her
unzip -qqo config.zip
# Warte 60s um die 120s Wartezeit von Ebesucher zu umgehen
sleep 60s
# Starte Ebesucher Firefox
docker_run() {
  docker run -d --name="$containername" -p 3000:5800 -v "$git_dir"/config:/config:rw -m "$1" --cpus "$CPUcores" --shm-size 2g jlesage/firefox
}

# Überprüfe wieviel Arbeitsspeicher vorhanden ist, um bei Geräten mit weniger als 4 GB 1 GB als Sicherungs zu haben.
ram_avail=$(bc <<<"scale=2;$(($(free | awk 'NR==2 {print $2}') / 1000000))")
if ((ram_avail >= 3 && ram_avail <= 4)); then
  docker_run "3g" "$CPUSet"
elif [[ $ram_avail -ge "5" ]]; then
  docker_run "4g" "$CPUSet"
fi

rm -f /tmp/ebesucher_restart.lock
