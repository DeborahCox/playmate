#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

netplan_config() {
  echo
  echo -e "$yellow Enter$red ip$yellow address$1.$none"
  read -r ip
  echo
  echo -e "$yellow Enter$red gateway$yellow address$1.$none"
  read -r gateway
  echo
  echo -e "$yellow Enter$red DNS$yellow address$1.$none"
  read -r dns
  echo
  echo "-------------------------------------------------------"
  echo -e "$magenta Set IP to $red$ip.$none"
  echo
  echo -e "$magenta Set Gateway to $red$gateway.$none"
  echo
  echo -e "$magenta Set DNS to $red$dns.$none"
  echo
  read -p "$(echo -e "${magenta}Confirm?$none") " confirm
  if [ -z "$confirm" ] || [ "$confirm" != n ]; then
    netdir=$(egrep -lir --include=*.yaml "(ens18)" /etc/netplan/)
    echo
    echo -e "${magenta}found netplan config here: $netdir.$none"
    echo "
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      addresses:
        - $ip/24
      gateway4: $gateway
      nameservers:
        addresses: [$dns]" >$netdir
  else
    echo
    echo -e "${yellow}Not Changing"
    echo "------------------------------------------------------"
    echo
  fi
}

docker_repo() {
  read -p "$(echo -e "${yellow}Change docker repository: [${magenta}Y/N]$none") " docker
  if [[ -z "$docker" ]] || [[ "$docker" == [Yy] ]]; then
    dir=$(egrep -lir --include=*.list "(download.docker.com)" /etc/apt/)
    echo
    echo -e "${yellow}Found docker official repo here: $magenta$dir.$none"
    echo "----------------------------------------------------------------"
    echo
    sed -i.bak "s#https://download.docker.com/linux/#https://mirrors.aliyun.com/docker-ce/linux/#g" $dir
  elif [[ "$docker" == [Nn] ]]; then
    echo "----------------------------------------------------------------"
    echo
  else
    echo -e "$red exit now$none"
  fi
}
docker_mirror() {
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://khz2v3ve.mirror.aliyuncs.com"],
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
EOF
}

echo -e "${yellow}1.Change netplan config."
echo -e "2.Change docker repo."
echo -e "3.Change docker mirrors and turn on metrics.$none"
echo
read -r num
if [ $num -eq 1 ]; then
  netplan_config
elif [ $num -eq 2 ]; then
  docker_repo
elif [ $num  -eq 3 ]; then
  docker_mirror
else
  echo
  echo -e "exit"
  exit
fi
