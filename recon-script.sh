#!/bin/bash

BGREEN="\033[1;32m"
RESET="\033[0m"

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

# Hunting start
echo "[${{BGREEN}}+${RESET}] Hunting subdomains with assetfinder . . ."
assetfinder --subs-only $url >> $url/recon/sub-domains.txt
echo "${BGREEN}+${RESET}] $(cat $url/recon/sub-domains.txt | wc -l) subdomains were found."

# Finding alive domains
echo "${BGREEN}+${RESET}] Finding alive subdomains . . ."
cat $url/recon/sub-domains.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/alive-domains.txt
echo "${BGREEN}+${RESET}] $(cat $url/recon/alive-domains.txt | wc -l) alive subdomains were found."