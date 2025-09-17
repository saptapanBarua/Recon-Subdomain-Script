#!/bin/bash

# This is an updated version of Zisan Vaiya, CEO of ByteCapsuleIt
# Author: Saptapan Barua

BYELLOW="\e[1;33m"
BWHITE="\e[1;32m"
YELLOWUNDERLINE="\e[0;33m"
RESET="\e[0m"

url=$1

# Directory creating...
if [ ! -d "$url" ]
then
	mkdir $url
fi

# SubDirectory creating...
if [ ! -d "$url/recon" ]
then
	mkdir $url/recon
fi

# Waybackurls SubDirectory creating...
if [ ! -d "$url/recon/waybackurls" ]
then
	mkdir $url/recon/waybackurls
fi

# Waybackurls SubDirectory extensions folder creating...
if [ ! -d "$url/recon/waybackurls/extensions" ]
then
	mkdir $url/recon/waybackurls/extensions
fi

# Hunting start
echo -e "${BYELLOW}[+]${RESET} Hunting subdomains with assetfinder . . ."
assetfinder --subs-only $url >> $url/recon/sub-domains1.txt
grep $1 "$url/recon/sub-domains1.txt" >> "$url/recon/sub-domains.txt"
echo -e "${BYELLOW}[+]${RESET} $(cat $url/recon/sub-domains.txt | wc -l) subdomains were found."

# Gather potential takeovers
echo -e "${BYELLOW}[+]${RESET} Scanning with subjack . . ."
subjack -w $url/recon/sub-domains.txt -t 100 -timeout 30 -ssl -v 3 >> $url/recon/subjack-output.txt
echo "$(grep -c "^Vulnerable" $url/recon/subjack-output.txt) vulnerable subdomains were found." # '^' is used to check start with specific character and '$' is used to check end with specific character 

# Finding alive domains
echo -e "${BYELLOW}[+]${RESET} Finding alive subdomains . . ."
cat $url/recon/sub-domains.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/alive-domains.txt
echo -e "${BYELLOW}[+]${RESET} $(cat $url/recon/alive-domains.txt | wc -l) alive subdomains were found."

# Port scanning of alive domains
echo -e "${BYELLOW}[+]${RESET} Port scannning . . .\n"
nmap -iL $url/recon/alive-domains.txt -T4 -oA $url/recon/nmap-results.txt

# Scrapping waybackurl data
echo -e "${BYELLOW}[+]${RESET} Scraping waybackdata . . ."
cat $url/recon/sub-domains.txt | waybackurls >> $url/recon/waybackurls/wayback-output.txt
sort -u $url/recon/waybackurls/wayback-output.txt -o $url/recon/waybackurls/wayback-output.txt

# Pulling and compiling all possible params found in wayback data
echo -e "${BYELLOW}[+]${RESET} Pulling and compiling all possible params found in wayback data . . ."
cat $url/recon/waybackurls/wayback-output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/waybackurls/wayback-params.txt
for line in $(cat $url/recon/waybackurls/wayback-params.txt)
	do echo $line'='
done

# Pulling and compiling js/php/aspx/jsp/json files from wayback output...
echo -e "${BYELLOW}[+]${RESET} Pulling and compiling ${YELLOWUNDERLINE}js/php/aspx/jsp/json${RESET} files from wayback output . . ."
for line in $(cat $url/recon/waybackurls/wayback-output.txt)
do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]]; then
		echo $line >> $url/recon/waybackurls/extensions/js1.txt
		sort -u $url/recon/waybackurls/extensions/js1.txt >> $url/recon/waybackurls/extensions/js.txt
	fi
	if [[ "$ext" == "html" ]];then
		echo $line >> $url/recon/waybackurls/extensions/jsp1.txt
		sort -u $url/recon/waybackurls/extensions/jsp1.txt >> $url/recon/waybackurls/extensions/jsp.txt
	fi
	if [[ "$ext" == "json" ]];then
		echo $line >> $url/recon/waybackurls/extensions/json1.txt
		sort -u $url/recon/waybackurls/extensions/json1.txt >> $url/recon/waybackurls/extensions/json.txt
	fi
	if [[ "$ext" == "php" ]];then
		echo $line >> $url/recon/waybackurls/extensions/php1.txt
		sort -u $url/recon/waybackurls/extensions/php1.txt >> $url/recon/waybackurls/extensions/php.txt
	fi
	if [[ "$ext" == "aspx" ]];then
		echo $line >> $url/recon/waybackurls/extensions/aspx1.txt
		sort -u $url/recon/waybackurls/extensions/aspx1.txt >> $url/recon/waybackurls/extensions/aspx.txt
	fi
done

# Deleting unnecessary
rm -f $url/recon/sub-domains1.txt
rm -f $url/recon/waybackurls/extensions/js1.txt
rm -f $url/recon/waybackurls/extensions/jsp1.txt
rm -f $url/recon/waybackurls/extensions/json1.txt
rm -f $url/recon/waybackurls/extensions/php1.txt
rm -f $url/recon/waybackurls/extensions/aspx1.txt

echo -e "\n\t${BWHITE}Recon complete.${RESET}"