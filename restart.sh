#!/bin/bash

# Variablen für Benennung und Ebesucher Nutzernamen
username=
containername=ebesucher

# Variable für die Maximale Nutzung von CPU Cores
CPUcores=

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
docker_run(){
  if [ -z "$username" ]; then
    # Funktion zum starten des Containers, falls username nicht gesetzt
    docker run -d --name="$containername" -p 3000:5800 -u $(awk -v user=$(whoami) -F':' '$0 ~ user {print $3}' /etc/passwd) -v "$git_dir"/config:/config:rw -m "$1" --cpus "$CPUcores" --shm-size 2g jlesage/firefox
    else
    # Funktion zum starten von Firefox immer mit der Surfbar (Verhindert dass bei Updates Firefox ein "neue Features" Tab über der Surfbar öffnet)
    docker run -d --name="$containername" -p 3000:5800 -u $(awk -v user=$(whoami) -F':' '$0 ~ user {print $3}' /etc/passwd) -e FF_OPEN_URL="https://ebesucher.com/surfbar/$username" -m "$1" --cpus "$CPUcores" -v "$git_dir"/config:/config:rw --shm-size 2g jlesage/firefox
  fi
}

# Überprüfe wieviel Arbeitsspeicher vorhanden ist, um bei Geräten mit weniger als 4 GB 1 GB als Sicherungs zu haben.
ram_avail=$(bc <<<"scale=2;$(($(free | awk 'NR==2 {print $2}') / 1000000))")
if [[ $ram_avail -ge "2" ]]; then
  docker_run "1g" "$CPUcores"
elif [[ $ram_avail -eq "4" ]]; then
  docker_run "3g" "$CPUcores"
elif [[ $ram_avail -ge "5" ]]; then
  docker_run "4g" "$CPUcores"
fi
