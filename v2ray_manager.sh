#!/bin/bash
clear
config="/etc/v2ray/config.json"
temp="/etc/v2ray/temp.json"
barra="==========================================="
numero='^[0-9]+$'

#============================================
domain_check() {
	ssl_install_fun
    clear
    echo $barra
    echo -e "   \033[1;49;37mgenerador de certificado ssl/tls\033[0m"
    echo $barra
    echo -e " \033[1;49;37mingrese su dominio (ej: midominio.com.ar)\033[0m"
    echo -ne ' \033[3;49;31m>>>\033[0m '
    read domain

    echo -e "\n \033[1;49;36mOteniendo resolucion dns de su dominio...\033[0m"
    domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')

    echo -e "\n \033[1;49;36mOteniendo IP local...\033[0m"
    local_ip=$(wget -qO- ipv4.icanhazip.com)
    sleep 2

    if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
        while :
        do
            clear
            echo $barra
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo $barra
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[1;49;32m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[1;49;32m${local_ip}\033[0m"
            echo $barra
            echo -e "      \033[1;49;32mComprovacion exitosa\033[0m"
            echo -e " \033[1;49;37mLa IP de su dominio coincide\n con la IP local, desea continuar?\033[0m"
            echo $barra
            echo -ne " \033[1;49;37msi o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n \033[3;49;31minstalacion cancelada...\033[0m" && sleep 2 && exit;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
            esac
        done
    else
        while :
        do
            clear
            echo $barra
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo $barra
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[3;49;31m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[3;49;31m${local_ip}\033[0m"
            echo $barra
            echo -e "      \033[3;49;31mComprovacion fallida\033[0m"
            echo -e " \033[4;49;97mLa IP de su dominio no coincide\033[0m\n         \033[4;49;97mcon la IP local\033[0m"
            echo $barra
            echo -e " \033[1;49;36m> Asegúrese que se agrego el registro"
            echo -e "   (A) correcto al nombre de dominio."
            echo -e " > Asegurece que su registro (A)"
            echo -e "   no posea algun tipo de seguridad"
            echo -e "   adiccional y que solo resuelva DNS."
            echo -e " > De lo contrario, V2ray no se puede"
            echo -e "   utilizar normalmente...\033[0m"
            echo $barra
            echo -e " \033[1;49;37mdesea continuar?"
            echo -ne " si o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n \033[1;49;31minstalacion cancelada...\033[0m" && sleep 2 && exit;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
            esac
        done
    fi
}

port_exist_check() {
    while :
    do
    clear
    echo $barra
    echo -e " \033[1;49;37mPara la compilacion del certificado"
    echo -e " se requiere que los siguientes puerto"
    echo -e " esten libres."
    echo -e "        '80' '443'"
    echo -e " este script intentara detener"
    echo -e " cualquier proseso que este"
    echo -e " usando estos puertos\033[0m"
    echo $barra
    echo -e " \033[1;49;37mdesea continuar?"
    echo -ne " [S/N]:\033[0m "
    read opcion

    case $opcion in
        [Ss]|[Yy])         
                    ports=('80' '443')
                    clear
                        echo $barra
                        echo -e "      \033[1;49;37mcomprovando puertos...\033[0m"
                        echo $barra
                        sleep 2
                        for i in ${ports[@]}; do
                            [[ 0 -eq $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -e "    \033[3;49;32m$i [OK]\033[0m" 
                            } || {
                                echo -e "    \033[3;49;31m$i [fail]\033[0m"
                            }
                        done
                        echo $barra
                        for i in ${ports[@]}; do
                            [[ 0 -ne $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -ne "       \033[1;49;37mliberando puerto $i...\033[1;49;37m "
                                lsof -i:$i | awk '{print $2}' | grep -v "PID" | xargs kill -9
                                echo -e "\033[1;49;32m[OK]\033[0m"
                            }
                        done;;
        [Nn]) echo -e "\n \033[3;49;31minstalacion cancelada...\033[0m" && sleep 2 && exit;;
        *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
    esac
    echo -e " \033[3;49;32mENTER continuar, CRTL+C para canselar...\033[0m"
    read foo
    break
    done
}

ssl_install() {
    while :
    do

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        clear
        echo $barra
        echo -e " \033[1;49;37mya existen archivos de certificados"
        echo -e " en el directorio asignado.\033[0m"
        echo $barra
        echo -e " \033[1;49;37mENTER para canselar la instacion."
        echo -e " 'S' para eliminar y continuar\033[0m"
        echo $barra
        echo -ne " opcion: "
        read ssl_delete
        case $ssl_delete in
        [Ss]|[Yy])
                    rm -rf /data/*
                    echo -e " \033[3;49;32marchivos removidos..!\033[0m"
                    sleep 2
                    ;;
        *) break;;
        esac
    fi

    if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" || -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
        echo $barra
        echo -e " \033[1;49;37mya existe un almacer de certificado"
        echo -e " bajo este nombre de dominio\033[0m"
        echo $barra
        echo -e " \033[1;49;37m'ENTER' cansela la instalacion"
        echo -e " 'D' para eliminar y continuar"
        echo -e " 'R' para restaurar el almacen crt\033[0m"
        echo $barra
        echo -ne " opcion: "
        read opcion
        case $opcion in
            [Dd])
                        echo -e " \033[1;49;92meliminando almacen cert...\033[0m"
                        sleep 2
                        rm -rf $HOME/.acme.sh/${domain}_ecc
                        ;;
            [Rr])
                        echo -e " \033[1;49;92mrestaurando certificados...\033[0m"
                        sleep 2
                        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
                        echo -e " \033[1;49;37mrestauracion completa...\033[0m\033[1;49;92m[ok]\033[0m"
                        break
                        ;;
            *) break;;
        esac
    fi
    acme
    break
    done
}

ssl_install_fun() {
    apt install socat netcat -y
    curl https://get.acme.sh | sh
}

acme() {
    clear
    echo $barra
    echo -e " \033[1;49;37mcreando nuevos certificado ssl/tls\033[0m"
    echo $barra
    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force --test; then
        echo -e "\n           \033[1;49;37mSSL La prueba del certificado\n se emite con éxito y comienza la emisión oficial\033[0m\n"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        sleep 2
    else
        echo -e "\n \033[4;49;31mError en la emisión de la prueba del certificado SSL\033[0m"
        echo $barra
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi

    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "\n \033[1;49;37mSSL El certificado se genero con éxito\033[0m"
        echo $barra
        sleep 2
        [[ -d /data ]] && mkdir /data
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force; then
            echo $barra
            mv $config $temp
            echo "cat $temp | jq '.inbounds[].streamSettings.tlsSettings += {certificates:[{certificateFile:\"/data/v2ray.crt\",keyFile:\"/data/v2ray.key\"}]}' | jq '.inbounds[] += {domain:\"$domi\"}' >> $config" | bash
            chmod 777 $config
            rm $temp
            restart_v2r
            echo -e "\n \033[1;49;37mLa configuración del certificado es exitosa\033[0m"
            echo $barra
            echo -e "      /data/v2ray.crt"
            echo -e "      /data/v2ray.key"
            echo $barra
            sleep 2
        fi
    else
        echo -e "\n \033[4;49;31mError al generar el certificado SSL\033[0m"
        echo $barra
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi
}

crt_ssl(){
	domain_check
	port_exist_check
	ssl_install
}

#============================================

restart_v2r(){
	#v2ray restart
	echo "reiniciando"
}

dell_user(){
	while :
	do
	clear
	users=$(cat $config | jq .inbounds[].settings.clients[] | jq .email)

	echo $barra
	echo "	ELIMINAR USUARIO V2RAY"
	echo $barra
	n=0
	for i in $users
	do
		[[ $i = null ]] && {
			i="default"
			a='*'
			echo " $a) $i"
		} || {
			echo " $n) $i"
		}
		let n++
	done
	echo $barra
	echo "	0) VOLVER"
	echo $barra
	read -p "NUMERO DE USUARIO A ELIMINAR: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break

	[[ ! $opcion =~ $numero ]] && {
		echo " solo numeros apartir de 1"
		sleep 2
	} || {
		let n--
		[[ $opcion>=${n} ]] && {
			echo "solo numero entre 1 y $n"
			sleep 2
		} || {
			mv $config $temp
			echo jq \'del\(.inbounds[].settings.clients[$opcion]\)\' $temp \> $config | bash
			chmod 777 $config
			rm $temp
			clear
			echo $barra
			echo "	Usuario eliminado"
			echo $barra
			restart_v2r
			sleep 2
		}
	}
	done
}

add_user(){
	while :
	do
	clear
	users=$(cat $config | jq .inbounds[].settings.clients[] | jq .email)

	echo $barra
	echo "	CREAR USUARIO V2RAY"
	echo $barra
	n=0
	for i in $users
	do
		[[ $i = null ]] && {
			i="default"
			a='*'
			echo " $a) $i"
		} || {
			echo " $n) $i"
		}
		let n++
	done
	echo $barra
	echo "	0) VOLVER"
	echo $barra
	read -p "NOMBRE DEL NUEVO USUARIO: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break

	espacios=$(echo "$opcion" | tr -d '[[:space:]]')
	opcion=$espacios

	mv $config $temp
	num=$(jq '.inbounds[].settings.clients | length' $temp)
	new=".inbounds[].settings.clients[$num]"
	new_id="id:\"$(uuidgen)\""
	#new_mail="email:\"$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')@mail.com\""
	new_mail="email:\"$opcion\""
	aid=$(jq '.inbounds[].settings.clients[0].alterId' $temp)
	echo jq \'$new += \{alterId:${aid},"$new_id","$new_mail"\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo $barra
	echo "	Usuario creado con exito"
	echo $barra
	restart_v2r
	sleep 2
    done
}

view_user(){
	while :
	do

		clear
		users=$(cat $config | jq .inbounds[].settings.clients[] | jq .email)

		echo $barra
		echo "	VER USUARIO V2RAY"
		echo $barra

		n=1
		for i in $users
		do
			[[ $i = null ]] && i="default"
			echo " $n) $i"
			let n++
		done

		echo $barra
		echo "	0) VOLVER"
		echo $barra
		read -p "VER DATOS DEL USUARIO: " opcion

		[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
		[[ $opcion = 0 ]] && break

		let opcion--

		ps=$(jq .inbounds[].settings.clients[$opcion].email $config) && [[ $ps = null ]] && ps="default"
		id=$(jq .inbounds[].settings.clients[$opcion].id $config)
		aid=$(jq .inbounds[].settings.clients[$opcion].alterId $config)
		add=$(jq '.inbounds[].domain' $config) && [[ $add = null ]] && add=$(wget -qO- ipv4.icanhazip.com)
		host=$(jq '.inbounds[].streamSettings.wsSettings.headers.Host' $config) && [[ $host = null ]] && host=''
		net=$(jq '.inbounds[].streamSettings.network' $config)
		path=$(jq '.inbounds[].streamSettings.wsSettings.path' $config) && [[ $path = null ]] && path=''
		port=$(jq '.inbounds[].port' $config)
		tls=$(jq '.inbounds[].streamSettings.security' $config)

		clear
		echo $barra
		echo " Usuario: $ps"
		echo $barra
		echo "Remarks: $ps"
		echo "Address: $add"
		echo "Port: $port"
		echo "id: $id"
		echo "alterId: $aid"
		echo "security: none"
		echo "network: $net"
		echo "Head Type: none"
		[[ ! $host = '' ]] && echo "Host/SNI: $host"
		[[ ! $path = '' ]] && echo "path: $path"
		echo "TLS: $tls"
		echo $barra
		echo "              VMMES LINK"
		echo $barra
		vmess
		echo $barra
		echo "enter para continuar..."
		read foo
	done
}

vmess() {

	echo vmess://$(echo {\"add\":$add\,\"aid\":\"$aid\"\,\"host\":$host\,\"id\":$id\,\"net\":$net\,\"path\":$path\,\"port\":\"$port\"\,\"ps\":$ps\,\"tls\":$tls\,\"type\":\"none\"\,\"v\":\"2\"} | base64 -w 0)
}

alterid(){
	while :
	do
		aid=$(jq '.inbounds[].settings.clients[0].alterId' $config)
	clear
	echo $barra
	echo "        configuracion alterId"
	echo $barra
	echo "	alterid: $aid"
	echo $barra
	echo "	x) VOLVER"
	echo $barra
	read -p " NUEVO VALOR: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = x ]] && break

	mv $config $temp
	new=".inbounds[].settings.clients[0]"
	echo jq \'$new += \{alterId:${opcion}\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo $barra
	echo "	Nuevo alterId fijado"
	echo $barra
	restart_v2r
	sleep 2
	done
}

port(){
	while :
	do
	port=$(jq '.inbounds[].port' $config)
	clear
	echo $barra
	echo "       configuracion de puerto"
	echo $barra
	echo "	puerto: $port"
	echo $barra
	echo "	0) VOLVER"
	echo $barra
	read -p " NUEVO PUERTO: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break

	mv $config $temp
	new=".inbounds[]"
	echo jq \'$new += \{port:${opcion}\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo $barra
	echo "	Nuevo alterId fijado"
	echo $barra
	sleep 2
	restart_v2r
	done
}

crt_man(){
	while :
	do
		clear
		echo $barra
		echo " configuracion de certificado manual"
		echo $barra

		chek=$(jq '.inbounds[].streamSettings.tlsSettings' $config)
		[[ ! $chek = {} ]] && {
			crt=$(jq '.inbounds[].streamSettings.tlsSettings.certificates[].certificateFile' $config)
			key=$(jq '.inbounds[].streamSettings.tlsSettings.certificates[].keyFile' $config)
			dom=$(jq '.inbounds[].domain' $config)
			echo -e "		\033[4;49minstalado\033[0m"
			echo "	crt: $crt"
			echo "	key: $key"
			echo "	dominio: $dom"
		} || {
			echo -e "	\033[4;49mcertificado no instalado\033[0m"
		}

		echo $barra
		echo "	1) ingresar nuevo crt"
		echo $barra
		echo "	0) VOLVER"
		echo $barra
		read -p " opcion : " opcion

		[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
		[[ $opcion = 0 ]] && break

		clear
		echo $barra
		echo -e " ingrese su archivo de certificado\n ej: /root/crt/certif.crt"
		echo $barra
		read -p "crt: " crts

		clear
		echo $barra
		echo "	nuevo certificado"
		echo $barra
		echo "	$crts"
		echo $barra
		echo -e " ingrese su archivo key\n ej: /root/crt/certif.key"
		echo $barra
		read -p "key: " keys

		clear
		echo $barra
		echo "	nuevo certificado"
		echo $barra
		echo "	$crts"
		echo "	$keys"
		echo $barra
		echo -e " ingrese su dominio\n ej: netfree.xyz"
		echo $barra
		read -p " dominio: " domi

		clear
		echo $barra
		echo " verifique sus datos sean correctos!"
		echo $barra
		echo "	$crts"
		echo "	$keys"
		echo "	$domi"
		echo $barra
		read foo

		mv $config $temp
		echo "cat $temp | jq '.inbounds[].streamSettings.tlsSettings += {certificates:[{certificateFile:\"$crts\",keyFile:\"$keys\"}]}' | jq '.inbounds[] += {domain:\"$domi\"}' >> $config" | bash
		chmod 777 $config
		rm $temp
		clear
		echo $barra
		echo " nuevo certificado agregado"
		echo $barra
		restart_v2r
		sleep 2
	done
}

address(){
	while :
	do
	add=$(jq '.inbounds[].domain' $config) && [[ $add = null ]] && add=$(wget -qO- ipv4.icanhazip.com)
	clear
	echo $barra
	echo "       configuracion address"
	echo $barra
	echo "	address: $add"
	echo $barra
	echo "	0) VOLVER"
	echo $barra
	read -p " NUEVO ADDRESS: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break

	mv $config $temp
	echo "cat $temp | jq '.inbounds[] += {domain:\"$opcion\"}' >> $config" | bash
	chmod 777 $config
	rm $temp
	clear
	echo $barra
	echo "	Nuevo address fijado"
	echo $barra
	restart_v2r
	sleep 2
	done
}

host(){
	while :
	do
	host=$(jq '.inbounds[].streamSettings.wsSettings.headers.Host' $config) && [[ $host = null ]] && host='sin host'
	clear
	echo $barra
	echo "       configuracion Host"
	echo $barra
	echo "	Host: $host"
	echo $barra
	echo "	0) VOLVER"
	echo $barra
	read -p " NUEVO HOST: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break
	mv $config $temp
	echo "cat $temp | jq '.inbounds[].streamSettings.wsSettings.headers += {Host:\"$opcion\"}' >> $config" | bash
	chmod 777 $config
	rm $temp
	clear
	echo $barra
	echo "	Nuevo Host fijado"
	echo $barra
	restart_v2r
	sleep 2
	done
}

install(){
	clear
	echo $barra
	echo "	Esta por intalar v2ray!"
	echo $barra
	echo -e " La instalacion puede tener\n alguna fallas!\n por favor observe atentamente\n el log de intalacion,\n este podria contener informacion\n sobre algunos errores!\n estos deveras ser corregidos de\n forma manual antes de continual\n usando el script"
	echo $barra
	echo " enter para continuar..."
	read foo
	#source <(curl -sL https://multi.netlify.app/v2ray.sh)
	echo $barra
	echo " instalcion finalizada"
	echo " Por favor verifique el log"
	echo $barra
	echo " enter para continuar..."
	read foo
	clear

	mv $config $temp
	echo "cat $temp | jq 'del(.inbounds[].streamSettings.kcpSettings[])' >> $config" | bash
	chmod 777 $config
	rm $temp
	restart_v2r
}

settings(){
	while :
	do
	clear
	echo $barra
	echo " Ajustes e instalacion v2ray"
	echo $barra
	echo " 1) instalar v2ray"
	echo $barra
	echo " 2) alterId"
	echo " 3) puerto"
	echo " 4) address"
	echo " 5) Host"
	echo $barra
	echo " 6) certif ssl/tls (script)"
	echo " 7) certif menu nativo"
	echo " 8) certif ingreso manual"
	echo $barra
	echo " 9) protocolo menu nativo"
	echo " 10) conf v2ray menu nativo"
	echo $barra
	echo " 0) Volver"
	echo $barra
	read -p "opcion: " opcion

	[[ -z $opcion ]] && echo " no se puede ingresar campos vacios.." && sleep 3 && break
	[[ $opcion = 0 ]] && break

	case $opcion in
		1)install;;
		2)alterid;;
		3)port;;
		4)address;;
		5)host;;
		6)crt_ssl;;
		7)v2ray tls;;
		8)crt_man;;
		9)v2ray stream;;
		10)v2ray;;
		*) echo " solo numeros de 0 a 10" && sleep 2;;
	esac
    done
}

main(){
	while [[ -e $config ]]; do
		clear
		echo $barra
		echo "            MENU V2RAY"
		echo $barra
		echo "	1) CREAR USUARIO"
		echo "	2) REMOVER USUARIO"
		echo "	3) VER USUARIOS"
		echo "	4) CONFIGURAR V2RAY"
		echo $barra
		echo "	0) SALIR"
		echo $barra
		read -p "opcion: " opcion

		case $opcion in
			1)add_user;;
			2)dell_user;;
			3)view_user;;
			4)settings;;
			0) break;;
			*) echo -e "\n selecione una opcion del 0 al 4" && sleep 2;;
		esac
	done
}

main
