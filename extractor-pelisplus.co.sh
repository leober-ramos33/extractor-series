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
season_episodes[9]="${10}"
season_episodes[10]="${11}"
season_episodes[11]="${12}"
season_episodes[12]="${13}"
season_episodes[13]="${14}"
season_episodes[14]="${15}"
season_episodes[15]="${16}"

####### END CONFIG ##########


green="\e[32m"
normal="\e[0m"
underlined="\e[4m"
red="\e[31m"

clear
echo "
#######
#       #    # ##### #####    ##    ####  #####  ####  #####
#        #  #    #   #    #  #  #  #    #   #   #    # #    #
#####     ##     #   #    # #    # #        #   #    # #    #
#         ##     #   #####  ###### #        #   #    # #####
#        #  #    #   #   #  #    # #    #   #   #    # #   #
####### #    #   #   #    # #    #  ####    #    ####  #    #

"
if [ -z "${1}" ] || [ -z "${2}" ]; then
	echo -e "Usage: ${0} <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>\nExample: ${0} mr-robot 10 12 10"
	exit 0
fi

serie="${1}"
serieName=$(echo "${serie}" | sed 's/-/ /g' | sed -e "s/\b\(.\)/\u\1/g")
information=$(curl -Ls "http://pelisplus.co/serie/${serie}")
season_end=$(echo "${information}" | grep item-season-title | seq $(wc -l))

echo -e "Extracting ${underlined}${serieName}${normal}... ( http://pelisplus.co/serie/${serie} )"

for season in $season_end; do
	echo "${serieName} - ${season}:" > .linux-$serie.$season.txt
	echo "# ${serieName} - ${season}:" > .linux-$serie.$season.min.txt
	end="${season_episodes[season]}"
	echo -e "\n${underlined}Season ${season} (1-${end}):${normal}"

	for (( f=1; f <= $end; f++ )); do
		echo -n "${season}x${f}... "
		html=$(curl -Ls "http://pelisplus.co/serie/${serie}/temporada-${season}/capitulo-${f}")
		
		if echo "${html}" | grep -o 'https://openload.co/embed/...........' &> /dev/null; then
			link=$(echo "${html}" | grep -o 'https://openload.co/embed/...........' | head -n 1)
		elif echo "${html}" | grep -o 'https://streamango.com/embed/................' &> /dev/null; then
			link=$(echo "${html}" | grep -o 'https://streamango.com/embed/................' | head -n 1)
		else
			echo "${season}x${f}: " >> .linux-$serie.$season.txt
			echo "#" >> .linux-$serie.$season.min.txt
			echo -e "${red}NOK!${normal}"
			continue
		fi
		
		echo "${season}x${f}: ${link}" >> .linux-$serie.$season.txt
		echo "${link}" >> .linux-$serie.$season.min.txt
		echo -e "${green}OK!${normal} ( ${link} )"
	done

	sed 's/$'"/`echo \\\r`/" .linux-$serie.$season.txt > $serie.$season.txt
	sed 's/$'"/`echo \\\r`/" .linux-$serie.$season.min.txt > $serie.$season.min.txt

	zip $serie.$season.zip $serie.$season.txt $serie.$season.min.txt &> /dev/null

	rm .linux-* &> /dev/null
	rm $serie.$season.txt &> /dev/null
	rm $serie.$season.min.txt &> /dev/null
done
