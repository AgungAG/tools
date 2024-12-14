#!/bin/bash

sudo apt install figlet -y
sudo apt install tor -y
subfinder -up
httpx -up
nuclei -up
nuclei -ut
echo "tools already update"

cd ~/LUcek/
bash requirement-linux.sh
echo "lucek ready"

cd ~/NucleiFuzzer/
sudo cp NucleiFuzzer.sh /usr/local/bin/nf
sudo chmod +x /usr/local/bin/nf
echo "nf ready"

cd ~/UniqueSubdomainFinder
sudo cp find.sh /usr/local/bin/fn
sudo chmod +x /usr/local/bin/fn
echo "fn ready"

cd ~/NucleiScanHelper/
sudo cp scan.sh /usr/local/bin/ns
sudo chmod +x /usr/local/bin/ns
echo "ns ready"

cd ~/urldedupe/
sudo cp urldedupe /usr/bin/
echo "urldedupe ready"

cd ~/rootbakar/
sudo cp gas.sh /usr/local/bin/gas
sudo chmod +x /usr/local/bin/gas
echo "gas ready"

sudo cp cekip.sh /usr/local/bin/ip
sudo chmod +x /usr/local/bin/ip

sudo cp torrc /etc/tor/torrc
sudo service tor restart
echo "All successfully!"
