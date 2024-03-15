#!/bin/bash

odl () {
	d=$( echo "(($3 - $1) * ($3 - $1) + ($4 - $2) * ($4 - $2))" | bc)
	echo "scale=4;sqrt($d)" | bc -l
}

KtoraStacja () {
mini=$( odl 53.1275 23.1470 $1 $2)
id=12295
d=$( odl 49.8221 19.0448 $1 $2)
if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12600
 fi
d=$(odl 53.6952 17.5614 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12235
 fi
d=$(odl 52.4082 16.9335 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12330
fi
d=$(odl 50.6668 17.9236 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12530
fi
d=$(odl 50.4337 16.6422 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12520
fi
d=$(odl 51.1263 16.9781 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12424
fi
d=$(odl 49.2757 19.9692 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12625
fi
d=$(odl 51.8436 16.5744 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12418
fi
d=$(odl 50.7359 15.7397 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12510
fi
d=$(odl 52.2337 21.0714 $1 $2)
 if (( $(echo "$d < $mini" | bc -l) )); then
 mini=$d
 id=12375
fi
}

debug () {
  if [ "$debug_mode" -eq 1 ]; then
  	echo "$1"
  fi
}

pomoc () {
	echo "./projekt.sh --city <miasto> [--debug|--verbose]"
	echo "	--city <miasto>		Wybranie miasta"
	echo "	--debug|--verbose	Tryb debugowania"
	echo "	--help			Wyświetla pomoc"
	exit 0
}

debug_mode=0

konfiguracja () {
	file="$1"
	source "$file"
}

display () {
	echo "$(jq '.stacja' $tempF | sed 's/\"//g')" "[""$(jq '.id_stacji' $tempF | sed 's/\"//g')""]" "/" "$(jq '.data_pomiaru' $tempF | sed 's/\"//g')" "$(jq '.godzina_pomiaru' $tempF | sed 's/\"//g')"":""00"
	echo ""
	echo -e "Temperatura:""\t""\t""$(jq '.temperatura' $tempF | sed 's/\"//g')" "°C"
	echo -e "Prędkość wiatru:""\t""$(jq '.predkosc_wiatru' $tempF | sed 's/\"//g')" "m/s"
	echo -e "Kierunek wiatru:""\t""$(jq '.kierunek_wiatru' $tempF | sed 's/\"//g')" "°"
	echo -e "Wilgotność wzg.:""\t""$(jq '.temperatura' $tempF | sed 's/\"//g')" "%"
	echo -e "Suma opadu:""\t""\t""$(jq '.temperatura' $tempF | sed 's/\"//g')" "mm"
	echo -e "Ciśnienie:""\t""\t""$(jq '.temperatura' $tempF | sed 's/\"//g')" "hPa"	
}

konfiguracja "./pogoda.rc"

cd "cache/"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --city)
      shift
      city="$1"
      ;;
    --debug|--verbose)
      debug_mode=1
      debug "Tryb debugowania został włączony"
      ;;
    --help|--h)
      pomoc
      ;;
    *)
      echo "Nieznany parametr!"
      echo "Aby uzyskać pomoc wpisz: ./projekt.sh --help/-h"
      exit 1
      ;;
  esac
  shift
done

debug "Sprawdzanie pamięci podręcznej"
if [ -f $city ];then
	debug "Odczytywanie pamięci podręcznej"
	x=$(jq .[0].lat $city|sed 's/\"//g')
	y=$(jq .[0].lon $city|sed 's/\"//g')
	debug "Obliczanie odległości między stacjami"
	KtoraStacja $x $y
	tempF=$(mktemp)
else
	debug "Oczekiwanie na odpytanie API"
	sleep 2
	debug "Pobieranie danych..."
	wget -q "https://nominatim.openstreetmap.org/search?q=$city&format=jsonv2&limit=1"
	mv "search?q=$city&format=jsonv2&limit=1" "$city"
	x=$(jq .[0].lat $city|sed 's/\"//g')
	y=$(jq .[0].lon $city|sed 's/\"//g')
	debug "Obliczanie odległości między stacjami"
	KtoraStacja $x $y
	tempF=$(mktemp)
fi
sleep 2
debug "Pobieranie danych..."
wget -q -O $tempF "https://danepubliczne.imgw.pl/api/data/synop/id/$id"
display
rm $tempF








