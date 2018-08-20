#!/bin/bash

###### Information #######
# Script for Bash, for extrancting links of series from pelisplus.co
# By @yonaikerlol



####### CONFIG #########

# Episodes
season_episodes[1]=$2
season_episodes[2]=$3
season_episodes[3]=$4
season_episodes[4]=$5
season_episodes[5]=$6
season_episodes[6]=$7
season_episodes[7]=$8
season_episodes[8]=$9

####### END CONFIG ##########


green="\e[32m"
normal="\e[0m"
underlined="\e[4m"
red="\e[31m"

clear
echo "
 _______  __   __  _______  ______    _______  _______  _______  _______  ______
|       ||  |_|  ||       ||    _ |  |   _   ||       ||       ||       ||    _ |
|    ___||       ||_     _||   | ||  |  |_|  ||       ||_     _||   _   ||   | ||
|   |___ |       |  |   |  |   |_||_ |       ||       |  |   |  |  | |  ||   |_||_
|    ___| |     |   |   |  |    __  ||       ||      _|  |   |  |  |_|  ||    __  |
|   |___ |   _   |  |   |  |   |  | ||   _   ||     |_   |   |  |       ||   |  | |
|_______||__| |__|  |___|  |___|  |_||__| |__||_______|  |___|  |_______||___|  |_|
"

if [ -z "${1}" ] || [ -z "${2}" ]; then
	echo -e "Usage: ${0} {serie} {episodes of 1 season} {episodes of 2 season}...{episodes of 8 season}\nExample: ${0} mr-robot 10 12 10"
	exit 0
fi

serie="${1}"
serieName=$(echo "${serie}" | sed 's/-/ /g' | sed -e "s/\b\(.\)/\u\1/g")
information=$(curl -Ls "http://pelisplus.co/serie/${serie}")
season_end=$(echo "${information}" | grep item-season-title | seq $(wc -l));

echo -e "Extracting ${underlined}${serieName}${normal}... ( http://pelisplus.co/serie/${serie} )"

for season in $season_end; do
	echo "${serieName} - ${season}:" > .linux-$serie.$season.txt
	echo "# ${serieName} - ${season}:" > .linux-$serie.$season.min.txt
	end="${season_episodes[season]}"
	echo -e "\n${underlined}Season ${season} (1-${end}):${normal}"

	for (( f=1; f <= $end; f++ )); do
		echo -n "${season}x${f}... "
		html=$(curl -Ls "http://pelisplus.co/serie/${serie}/temporada-${season}/capitulo-${f}")
		
		if echo "${html}" | grep 'https://openload.co/embed/...........' &> /dev/null; then
			link=$(echo "${html}" | grep 'https://openload.co/embed/...........' | sed 's/.*="//g' | sed 's/"//g')
		elif echo "${html}" | grep 'https://streamango.com/embed/................' &> /dev/null; then
			link=$(echo "${html}" | grep 'https://streamango.com/embed/................' | sed 's/.*="//g' | sed 's/"//g')
		else
			echo "${season}x${f}: " >> .linux-$serie.$season.txt
			echo "#" >> .linux-$serie.$season.min.txt
			echo -e "${red}NOK!${normal}"
			continue
		fi
		
		if [ $(echo "${link}" | wc -l) -eq 2 ]; then
			link=$(echo "${link}" | sed -e "2d")
		elif [ $(echo "${link}" | wc -l) -eq 3 ]; then
			link=$(echo "${link}" | sed -e "2,3d")
		fi

		echo "${season}x${f}: ${link}" >> .linux-$serie.$season.txt
		echo "${link}" >> .linux-$serie.$season.min.txt
		echo -e "${green}OK!${normal} ( ${link} )"
	done

	sed 's/$'"/`echo \\\r`/" .linux-$serie.$season.txt > windows-$serie.$season.txt
	sed 's/$'"/`echo \\\r`/" .linux-$serie.$season.min.txt > windows-$serie.$season.min.txt

	mv .linux-$serie.$season.txt linux-$serie.$season.txt &> /dev/null
	mv .linux-$serie.$season.min.txt linux-$serie.$season.min.txt &> /dev/null
	zip $serie.$season.zip linux-$serie.$season.txt linux-$serie.$season.min.txt windows-$serie.$season.txt windows-$serie.$season.min.txt &> /dev/null

	rm linux-* &> /dev/null
	rm windows-* &> /dev/null
done
