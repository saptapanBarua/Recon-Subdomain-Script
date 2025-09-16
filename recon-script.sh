#!/bin/bash

BYELLOW="\033[1;33m"
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
echo -e "[${BYELLOW}+${RESET}] Hunting subdomains with assetfinder . . ."
assetfinder --subs-only $url >> $url/recon/sub-domains.txt
echo -e "[${BYELLOW}+${RESET}] $(cat $url/recon/sub-domains.txt | wc -l) subdomains were found."

# Finding alive domains
echo -e "[${BYELLOW}+${RESET}] Finding alive subdomains . . ."
cat $url/recon/sub-domains.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/alive-domains.txt
echo -e "[${BYELLOW}+${RESET}] $(cat $url/recon/alive-domains.txt | wc -l) alive subdomains were found."