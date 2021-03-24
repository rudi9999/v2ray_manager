#!/bin/bash
BARRA="\033[03;32m=====================================================\033[0m"

install_ini () {
clear
echo -e "$BARRA"
echo -e "\033[92m        -- INSTALANDO PAQUETES NECESARIOS -- "
echo -e "$BARRA"
#netcat
[[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] || apt-get install netcat -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m  # apt-get install netcat............... $ESTATUS "
#socat
[[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] || apt-get install socat -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m  # apt-get install socat................ $ESTATUS "
#jq
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || apt-get install jq -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
[[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
echo -e "\033[97m  # apt-get install jq................... $ESTATUS "
echo -e "$BARRA"
echo -e "\033[92m La instalacion de paquetes necesarios a finalizado"
echo -e "$BARRA"
echo -e "\033[97m Si la instalacion de paquetes tiene fallas"
echo -ne "\033[97m Puede intentar de nuevo [s/n]: "
read inst
[[ $inst = @(s|S|y|Y) ]] && install_ini
}

ofus () {
	unset server
	server=$(echo ${txt_ofuscatw}|cut -d':' -f1)
	unset txtofus
	number=$(expr length $1)
	for((i=1; i<$number+1; i++)); do
		txt[$i]=$(echo "$1" | cut -b $i)
		case ${txt[$i]} in
			".")txt[$i]="*";;
			"*")txt[$i]=".";;
			"1")txt[$i]="@";;
			"@")txt[$i]="1";;
			"2")txt[$i]="?";;
			"?")txt[$i]="2";;
			"4")txt[$i]="%";;
			"%")txt[$i]="4";;
			"-")txt[$i]="K";;
			"K")txt[$i]="-";;
		esac
		txtofus+="${txt[$i]}"
	done
	echo "$txtofus" | rev
}

invalid_key () {
echo -e $BARRA && echo -e "\033[1;91m#¡Key Invalida#! " && echo -e $BARRA
rm -rf /usr/bin/v2r.sh
rm -rf /usr/bin/v2r
exit 1
}

meu_ip () {
MIP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MIP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MIP" != "$MIP2" ]] && IP="$MIP2" || IP="$MIP"
echo "$IP" > /usr/bin/vendor_code
}

install_ini
meu_ip

rm -rf /usr/bin/v2r.sh
rm -rf /usr/bin/v2r

clear
echo -e $BARRA
echo -e "	   Instalador V2ray Manager"
echo -e $BARRA

while [[ ! $Key ]]; do
echo -e $BARRA && echo -ne "\033[1;91m# DIGITE LA KEY #:\033[0m " && read Key
tput cuu1 && tput dl1
done
echo -ne "\033[1;91m# Verificando Key # :\033[0m "
cd $HOME
wget -O /usr/bin/v2r.sh $(ofus "$Key")/$IP > /dev/null 2>&1 && echo -e "\033[1;32m Key Completa" || {
   echo -e "\033[1;91m Key Incompleta"
   invalid_key
   exit
}

if [[ -e /usr/bin/v2r.sh ]] && [[ ! $(cat /usr/bin/v2r.sh|grep "KEY INVALIDA!") ]]; then
	chmod +x /usr/bin/v2r.sh
	ln -s /usr/bin/v2r.sh /usr/bin/v2r
	clear
	echo -e $BARRA
	echo -e "	     \033[1;49;37mV2ray manager"
	echo -e "	  instalcion completa\033[0m"
	echo -e $BARRA
	echo -e "	\033[1;49;37mpara ejecutar el script..."
	echo -e "	   type\033[0m \033[1;49;36mv2r\033[0m \033[1;49;37mo\033[0m \033[1;49;36mv2r.sh\033[0m"
	echo -e $BARRA

 else
    invalid_key
fi
