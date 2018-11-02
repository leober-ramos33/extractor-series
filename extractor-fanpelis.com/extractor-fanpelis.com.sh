#!/bin/bash

###### Information #######
# Script for Bash, for extracting links of series (TV) from fanpelis.com
# By @yonaikerlol


####### CONFIG #########

# Episodes
seasonEpisodes[1]="${2}"
seasonEpisodes[2]="${3}"
seasonEpisodes[3]="${4}"
seasonEpisodes[4]="${5}"
seasonEpisodes[5]="${6}"
seasonEpisodes[6]="${7}"
seasonEpisodes[7]="${8}"
seasonEpisodes[8]="${9}"
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
                                                   
######   ##   #    # #####  ###### #      #  ####  
#       #  #  ##   # #    # #      #      # #      
#####  #    # # #  # #    # #####  #      #  ####  
#      ###### #  # # #####  #      #      #      # 
#      #    # #   ## #      #      #      # #    # 
#      #    # #    # #      ###### ###### #  ####  
                                                   
"

if [ -z "${1}" ] || [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [ "${1}" = "--version" ] || [ -z "${2}" ]; then
	echo "Usage: $(basename "${0}") <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>"
	echo "Example: ${0} el-joven-sheldon 22"
	exit 0
fi

if ! command -v pup &> /dev/null; then
	PATH=$PATH:$(cd ..; pwd)
	if ! command -v pup &> /dev/null; then
		echo -e "Not find ${underlined}pup${normal} is ${red}required${normal}"
		exit 0
	fi
fi

serie=$(echo "${1}" | sed 's/\-/ /g' | sed -e 's/\b\(.\)/\u\1/g')
seasons=$(curl -Ls "https://fanpelis.com/series/${1}" | grep 'item-season' | seq $(wc -l))

echo -e "Extracting ${bold}${serie}${normal}... ( ${underlined}https://fanpelis.com/series/${1}${normal} )"

for s in $seasons; do
	echo "${serie} - ${s}:" > ".${1}.${s}.txt"
	echo "# ${serie} - ${s}:" > ".${1}.${s}.min.txt"
	episodesEnd="${seasonEpisodes[s]}"
	echo -e "\n${bold}Season ${s} (1-${episodesEnd}):${normal}"

	for (( i=1; i <= episodesEnd; i++ )); do
		if [ "${i}" -lt 10 ]; then
			echo -n "${s}x0${i}... ( http://fanpelis.com/episode/${1}-temporada-${s}-episodio-${i} )"
			req=$(curl -Ls "http://fanpelis.com/episode/${1}-temporada-${s}-episodio-${i}")
		else
			echo -n "${s}x${i}... ( ${underlined}http://fanpelis.com/episode/${1}-temporada-${s}-episodio-${i}${normal} )"
			req=$(curl -Ls "http://fanpelis.com/episode/${1}-temporada-${s}-episodio-${i}")
		fi

		totalOptions=$(echo "${req}" | pup 'div[class="btn-group btn-group-justified embed-selector"] > a attr{href}' | seq $(wc -l))

		if [ -z "${totalOptions}" ]; then
			if [ "${i}" -lt 10 ]; then
				echo "${s}x0${i}" >> ".${1}.${s}.txt"
			else	
				echo "${s}x${i}:" >> ".${1}.${s}.txt"
			fi
			echo "#" >> ".${1}.${s}.min.txt"
			echo -e "\t${red}NOK!${normal}"
			continue
		fi

		for f in $totalOptions; do
			link=$(echo "${req}" | pup 'div[class="btn-group btn-group-justified embed-selector"] > a attr{href}' | sed -n -e "${f}p" | sed 's/\&amp;/\&/g' | sed 's/^/http:\/\/fanpelis\.com/g')
			quality=$(echo "${req}" | pup 'div[class="btn-group btn-group-justified embed-selector"] > a > span:nth-child(3) text{}' | sed -n -e "${f}p")
			reqLink=$(curl -Ls "${link}")

			if echo "${reqLink}" | grep -o 'https://openload.co/f/...........' &> /dev/null; then
				link=$(echo "${reqLink}" | grep -o 'https://openload.co/f/...........' | sed 's/\/f\//\/embed\//g')
			elif echo "${reqLink}" | grep -o 'https://www.rapidvideo.com/d/..........' &> /dev/null; then
				link=$(echo "${reqLink}" | grep -o 'https://www.rapidvideo.com/d/..........')
			fi

			if [ "${f}" -eq 1 ]; then
				links="${link}"
				options="\n\t${f}. ${quality}"
			else
				links="${links}\n${link}"
				options="${options}\n\t${f}. ${quality}"
			fi
		done

		echo -e "\n\tOptions: ${options}"
		echo -e "\t${red}WARNING:${normal} You have 10 seconds to answer, if you do not answer, option 1 will be chosen by default."
		echo -en "\tSelect an option (a number): "
		
		if ! read -t 10 -r optionSelected; then
			optionSelected=1
			echo ""
		fi

		if [ "${optionSelected}" -eq 0 ] || ! [[ "${optionSelected}" =~ ^[0-9]+$ ]]; then
			if [ "${i}" -lt 10 ]; then
				echo "${s}x0${i}:" >> ".${1}.${s}.txt"
			else	
				echo "${s}x${i}:" >> ".${1}.${s}.txt"
			fi
			echo "#" >> ".${1}.${s}.min.txt"
			echo -e "\t${red}NOK!${normal}"
			continue
		fi
		
		link=$(echo "${links}" | sed 's/\\n/\n/g' | sed -n -e "${optionSelected}p")
		
		if [ "${i}" -lt 10 ]; then
			echo "${s}x0${i}: ${link}" >> ".${1}.${s}.txt"
		else	
			echo "${s}x${i}: ${link}" >> ".${1}.${s}.txt"
		fi
		echo "${link}" >> ".${1}.${s}.min.txt"
		echo -e "\t${green}OK!${normal} ( ${bold}${link}${normal} )"
	done

	sed 's/$'"/`echo \\\r`/" ".${1}.${s}.txt" > "${1}.${s}.txt"
	sed 's/$'"/`echo \\\r`/" ".${1}.${s}.min.txt" > "${1}.${s}.min.txt"

	zip "${1}.${s}.zip" "${1}.${s}.txt" "${1}.${s}.min.txt" &> /dev/null

	rm ".${1}.${s}.txt" &> /dev/null
	rm ".${1}.${s}.min.txt" &> /dev/null
	rm "${1}.${s}.txt" &> /dev/null
	rm "${1}.${s}.min.txt" &> /dev/null
done
