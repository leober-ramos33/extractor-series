#!/bin/bash

###### Information #######
# Script for Bash, for extracting links of series (TV) from www.seriesgato.tv
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
                                                                
 ####  ###### #####  # ######  ####   ####    ##   #####  ####  
#      #      #    # # #      #      #    #  #  #    #   #    # 
 ####  #####  #    # # #####   ####  #      #    #   #   #    # 
     # #      #####  # #           # #  ### ######   #   #    # 
#    # #      #   #  # #      #    # #    # #    #   #   #    # 
 ####  ###### #    # # ######  ####   ####  #    #   #    ####  
   
"
if [ -z "${1}" ] || [ -z "${2}" ]; then
	echo -e "Usage: ${0} <id of serie> <episodes of 1 season> <episodes of 2 season>...<episodes of 15 season>"
	echo -e "Example: ${0} 18-5-mr-robot-289590.html 10 12 10"
	echo -e "${red}WARNING:${normal} It doesn't work with series that contain numbers on their name"
	exit 0
fi

if ! command -v pup &> /dev/null; then
	PATH=$PATH:$(pwd)
	if ! command -v pup &> /dev/null; then
		echo -e "Not find ${underlined}pup${normal} is ${red}required${normal}"
		exit 0
	fi
fi

echo -e "${red}WARNING:${normal} It doesn't work with series that contain numbers on their name"

serieName=$(echo "${1}" | sed 's/18\-5\-//g' | sed 's/\-/ /g' | sed 's/\.html//g' | sed -e 's/\b\(.\)/\u\1/g')
serieCode=$(echo "${serieName}" | sed 's/^[^1-9]*//g')
serie=$(echo "${serieName}" | sed 's/[1-9].*//g' | sed 's/ /-/g' | sed -e 's/\b\(.\)/\l\1/g')
seasons=$(curl -Ls "http://www.seriesgato.tv/serie/${1}" | grep 'Wdgt AABox' | seq $(wc -l))

echo -e "Extracting ${underlined}${serieName}${normal}... ( ${underlined}https://www.seriesgato.tv/serie/${1}${normal} )"

for s in $seasons; do
	echo "${serieName} - ${s}:" > ".${serie}.${s}.txt"
	echo "# ${serieName} - ${s}:" > ".${serie}.${s}.min.txt"
	episodesEnd="${seasonEpisodes[s]}"
	echo -e "\n${bold}Season ${s} (1-${episodesEnd}):${normal}"

	for (( i=1; i <= episodesEnd; i++ )); do
		if [ "${i}" -lt 10 ]; then
			echo -n "${s}x0${i}... ( https://www.seriesgato.tv/capitulo/18-5-${serie}${s}x0${i}-${serieCode}.html )"
			req=$(curl -Ls "https://www.seriesgato.tv/capitulo/18-5-${serie}${s}x0${i}-${serieCode}.html")
		else
			echo -n "${s}x${i}... ( https://www.seriesgato.tv/capitulo/18-5-${serie}${s}x${i}-${serieCode}.html )"
			req=$(curl -Ls "https://www.seriesgato.tv/capitulo/18-5-${serie}${s}x${i}-${serieCode}.html")
		fi

		totalOptions=$(echo "${req}" | pup 'tbody > tr > td[style="width:auto;text-align:center;"]' | sed 's/^[^1-9]*//g' | sed '/^$/d' | seq $(wc -l))

		if [ -z "${totalOptions}" ]; then
			if [ "${i}" -lt 10 ]; then
				echo "${s}x0${i}" >> ".${serie}.${s}.txt"
			else	
				echo "${s}x${i}:" >> ".${serie}.${s}.txt"
			fi
			echo "#" >> ".${serie}.${s}.min.txt"
			echo -e "\t${red}NOK!${normal}"
			continue
		fi

		for f in $totalOptions; do
			link=$(echo "${req}" | pup 'tbody > tr > td[style="text-align:center;"]:nth-child(2) > a.Button.STPb attr{href}' | sed -n -e "${f}p" | sed 's/.*l\///g' | base64 -d | base64 -d)
			language=$(echo "${req}" | pup 'tbody > tr > td[style="text-align:center;"]:nth-child(3) > span text{}' | sed -n -e "${f}p")
			quality=$(echo "${req}" | pup 'tbody > tr > td[style="text-align:center;"]:nth-child(4) > span text{}' | sed -n -e "${f}p")

			if [ "${f}" -eq 1 ]; then
				links="${link}"
				options="\n\t${f}. ${language}\t${quality}"
			else
				links="${links}\n${link}"
				options="${options}\n\t${f}. ${language}\t${quality}"
			fi
		done

		echo -e "\n\tOptions: ${options}"
		echo -e "\t${bold}NOTE:${normal} Inglés = English\tLatino = Spanish (America)\tCastellano = Spanish (Europe)\tSub. Esp. = English with spanish subtitles"
		echo -e "\t${red}WARNING:${normal} You have 10 seconds to answer, if you do not answer, option 1 will be chosen by default."
		echo -en "\tSelect an option (a number): "
		
		if ! read -t 10 -r optionSelected; then
			optionSelected=1
		fi

		if [ "${optionSelected}" -eq 0 ]; then
			if [ "${i}" -lt 10 ]; then
				echo "${s}x0${i}" >> ".${serie}.${s}.txt"
			else	
				echo "${s}x${i}:" >> ".${serie}.${s}.txt"
			fi
			echo "#" >> ".${serie}.${s}.min.txt"
			echo -e "\t${red}NOK!${normal}"
			continue
		fi
		
		link=$(echo "${links}" | sed 's/\\n/\n/g' | sed -n -e "${optionSelected}p")
		
		if [ "${i}" -lt 10 ]; then
			echo "${s}x0${i}: ${link}" >> ".${serie}.${s}.txt"
		else	
			echo "${s}x${i}: ${link}" >> ".${serie}.${s}.txt"
		fi
		echo "${link}" >> ".${serie}.${s}.min.txt"
		echo -e "\n\t${green}OK!${normal} ( ${bold}${link}${normal} )"
	done

	sed 's/$'"/`echo \\\r`/" ".${serie}.${s}.txt" > "${serie}.${s}.txt"
	sed 's/$'"/`echo \\\r`/" ".${serie}.${s}.min.txt" > "${serie}.${s}.min.txt"

	zip "${serie}.${s}.zip" "${serie}.${s}.txt" "${serie}.${s}.min.txt" &> /dev/null

	rm ".${serie}.${s}.txt" &> /dev/null
	rm ".${serie}.${s}.min.txt" &> /dev/null
	rm "${serie}.${s}.txt" &> /dev/null
	rm "${serie}.${s}.min.txt" &> /dev/null
done
