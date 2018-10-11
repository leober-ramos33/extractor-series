#!/bin/bash

###### Information #######
# Script for Bash, for extracting links of series from pelisplus.co
# By @yonaikerlol



####### CONFIG #########

# Episodes
seasonEpisodes[1]=$2
seasonEpisodes[2]=$3
seasonEpisodes[3]=$4
seasonEpisodes[4]=$5
seasonEpisodes[5]=$6
seasonEpisodes[6]=$7
seasonEpisodes[7]=$8
seasonEpisodes[8]=$9
seasonEpisodes[9]="${10}"
seasonEpisodes[10]="${11}"
seasonEpisodes[11]="${12}"
seasonEpisodes[12]="${13}"
seasonEpisodes[13]="${14}"
seasonEpisodes[14]="${15}"
seasonEpisodes[15]="${16}"

####### END CONFIG ##########


green="\e[32m"
normal="\e[0m"
underlined="\e[4m"
bold="\e[1m"
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

#####  ###### #      #  ####  #####  #      #    #  ####
#    # #      #      # #      #    # #      #    # #
#    # #####  #      #  ####  #    # #      #    #  ####
#####  #      #      #      # #####  #      #    #      #
#      #      #      # #    # #      #      #    # #    #
#      ###### ###### #  ####  #      ######  ####   ####

"
if [ -z "${1}" ] || [ -z "${2}" ]; then
	echo -e "Usage: ${0} <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>\nExample: ${0} mr-robot 10 12 10"
	exit 0
fi

serie=$(echo "${1}" | sed 's/-/ /g' | sed -e "s/\b\(.\)/\u\1/g")
seasonTotal=$(curl -Ls "http://pelisplus.co/serie/${1}" | grep item-season-title | seq $(wc -l))

echo -e "Extracting ${underlined}${serie}${normal}... ( http://pelisplus.co/serie/${1} )"

for s in $seasonTotal; do
	echo "${serie} - ${s}:" > ".${1}.${s}.txt"
	echo "# ${serie} - ${s}:" > ".${1}.${s}.min.txt"
	seasonEnd="${seasonEpisodes[s]}"
	echo -e "\n${bold}Season ${s} (1-${seasonEnd}):${normal}"

	for (( e=1; e <= seasonEnd; e++ )); do
		if [ "${e}" -lt 10 ]; then
			echo -n "${s}x0${e}... (http://pelisplus.co/serie/${1}/temporada-${s}/capitulo-${e})"
		else
			echo -n "${s}x${e}... (http://pelisplus.co/serie/${1}/temporada-${s}/capitulo-${e})"
		fi

		req=$(curl -Ls "http://pelisplus.co/serie/${1}/temporada-${s}/capitulo-${e}")
		
		if echo "${req}" | grep -o 'https://openload.co/embed/...........' &> /dev/null; then
			link=$(echo "${req}" | grep -o 'https://openload.co/embed/...........' | head -n 1)
		elif echo "${req}" | grep -o 'https://streamango.com/embed/................' &> /dev/null; then
			link=$(echo "${req}" | grep -o 'https://streamango.com/embed/................' | head -n 1)
		else
			if [ "${e}" -lt 10 ]; then
				echo "${s}x0${e}:" >> ".${1}.${s}.txt"
				echo "#" >> ".${1}.${s}.min.txt"
			else
				echo "${s}x${e}:" >> ".${1}.${s}.txt"
				echo "#" >> ".${1}.${s}.min.txt"
			fi
			echo -e "${red}NOK!${normal}"
			continue
		fi
		
		if [ "${e}" -lt 10 ]; then
			echo "${s}x0${e}: ${link}" >> ".${1}.${s}.txt"
			echo "${link}" >> ".${1}.${s}.min.txt"
		else
			echo "${s}x${e}: ${link}" >> ".${1}.${s}.txt"
			echo "${link}" >> ".${1}.${s}.min.txt"
		fi
		echo -e "\t${green}OK!${normal} ( ${link} )"
	done

	sed 's/$'"/`echo \\\r`/" ".${1}.${s}.txt" > "${1}.${s}.txt"
	sed 's/$'"/`echo \\\r`/" ".${1}.${s}.min.txt" > "${1}.${s}.min.txt"

	zip "${1}.${s}.zip" "${1}.${s}.txt" "${1}.${s}.min.txt" &> /dev/null

	rm ".${1}.${s}.txt" &> /dev/null
	rm ".${1}.${s}.min.txt" &> /dev/null
	rm "${1}.${s}.txt" &> /dev/null
	rm "${1}.${s}.min.txt" &> /dev/null
done
