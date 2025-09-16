#!/bin/bash

#!/bin/bash
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
echo "[+] Hunting subdomains with assetfinder . . ."
assetfinder --subs-only $url >> $url/recon/sub-domains.txt
echo "[+] $(cat $url/recon/sub-domains.txt | wc -l) subdomains were found."

# Finding alive domains
echo "[+] Finding alive subdomains . . ."
cat $url/recon/sub-domains.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/alive-domains.txt
echo "[+] $(cat $url/recon/alive-domains.txt | wc -l) alive subdomains were found."