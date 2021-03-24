#!/bin/bash
clear
config="/etc/v2ray/config.json"
temp="/etc/v2ray/config.json"
#barra="==========================================="
barra="\033[03;32m=====================================================\033[0m"
numero='^[0-9]+$'

blanco(){
	[[ !  $2 = 0 ]] && {
		echo -e "\033[1;37m$1\033[0m"
	} || {
		echo -ne " \033[1;37m$1:\033[0m "
	}
}

col(){

	echo -e "	\033[0;92m$1 \033[0;31m>> \033[1;37m$2\033[0m"
}

col2(){

	echo -e " \033[1;91m$1\033[0m \033[1;37m$2\033[0m"
}

vacio(){

	blanco "\n no se puede ingresar campos vacios..."
}

#============================================
domain_check() {
	ssl_install_fun
    clear
    echo -e $barra
    echo -e "   \033[1;49;37mgenerador de certificado ssl/tls\033[0m"
    echo -e $barra
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
            echo -e $barra
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo -e $barra
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[1;49;32m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[1;49;32m${local_ip}\033[0m"
            echo -e $barra
            echo -e "      \033[1;49;32mComprovacion exitosa\033[0m"
            echo -e " \033[1;49;37mLa IP de su dominio coincide\n con la IP local, desea continuar?\033[0m"
            echo -e $barra
            echo -ne " \033[1;49;37msi o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n \033[3;49;31minstalacion cancelada...\033[0m" && sleep 2 && close=1 && break;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
            esac
        done
    else
        while :
        do
            clear
            echo -e $barra
            echo -e " \033[1;49;37mSu dominio: ${domain}\033[0m"
            echo -e $barra
            echo -e " \033[1;49;37mIP dominio:\033[0m  \033[3;49;31m${domain_ip}\033[0m"
            echo -e " \033[1;49;37mIP local:\033[0m    \033[3;49;31m${local_ip}\033[0m"
            echo -e $barra
            echo -e "      \033[3;49;31mComprovacion fallida\033[0m"
            echo -e " \033[4;49;97mLa IP de su dominio no coincide\033[0m\n         \033[4;49;97mcon la IP local\033[0m"
            echo -e $barra
            echo -e " \033[1;49;36m> Asegúrese que se agrego el registro"
            echo -e "   (A) correcto al nombre de dominio."
            echo -e " > Asegurece que su registro (A)"
            echo -e "   no posea algun tipo de seguridad"
            echo -e "   adiccional y que solo resuelva DNS."
            echo -e " > De lo contrario, V2ray no se puede"
            echo -e "   utilizar normalmente...\033[0m"
            echo -e $barra
            echo -e " \033[1;49;37mdesea continuar?"
            echo -ne " si o no [S/N]:\033[0m "
            read opcion
            case $opcion in
                [Yy]|[Ss]) break;;
                [Nn]) echo -e "\n \033[1;49;31minstalacion cancelada...\033[0m" && sleep 2 && close=1 && break;;
                *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
            esac
        done
    fi
    [[ $close = 1 ]] && port_exist_check
}

port_exist_check() {
    while :
    do
    clear
    echo -e $barra
    echo -e " \033[1;49;37mPara la compilacion del certificado"
    echo -e " se requiere que los siguientes puerto"
    echo -e " esten libres."
    echo -e "        '80' '443'"
    echo -e " este script intentara detener"
    echo -e " cualquier proseso que este"
    echo -e " usando estos puertos\033[0m"
    echo -e $barra
    echo -e " \033[1;49;37mdesea continuar?"
    echo -ne " [S/N]:\033[0m "
    read opcion

    case $opcion in
        [Ss]|[Yy])         
                    ports=('80' '443')
                    clear
                        echo -e $barra
                        echo -e "      \033[1;49;37mcomprovando puertos...\033[0m"
                        echo -e $barra
                        sleep 2
                        for i in ${ports[@]}; do
                            [[ 0 -eq $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -e "    \033[3;49;32m$i [OK]\033[0m" 
                            } || {
                                echo -e "    \033[3;49;31m$i [fail]\033[0m"
                            }
                        done
                        echo -e $barra
                        for i in ${ports[@]}; do
                            [[ 0 -ne $(lsof -i:$i | grep -i -c "listen") ]] && {
                                echo -ne "       \033[1;49;37mliberando puerto $i...\033[1;49;37m "
                                lsof -i:$i | awk '{print $2}' | grep -v "PID" | xargs kill -9
                                echo -e "\033[1;49;32m[OK]\033[0m"
                            }
                        done;;
        [Nn]) echo -e "\n \033[3;49;31minstalacion cancelada...\033[0m" && sleep 2 && close=1 && break;;
        *) echo -e "\n \033[1;49;37mselecione (S) para si o (N) para no!\033[0m" && sleep 2;;
    esac
    echo -e " \033[3;49;32mENTER continuar, CRTL+C para canselar...\033[0m"
    read foo
    break
    done
    [[ $close = 1 ]] && ssl_install
}

ssl_install() {
    while :
    do

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        clear
        echo -e $barra
        echo -e " \033[1;49;37mya existen archivos de certificados"
        echo -e " en el directorio asignado.\033[0m"
        echo -e $barra
        echo -e " \033[1;49;37mENTER para canselar la instacion."
        echo -e " 'S' para eliminar y continuar\033[0m"
        echo -e $barra
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
        echo -e $barra
        echo -e " \033[1;49;37mya existe un almacer de certificado"
        echo -e " bajo este nombre de dominio\033[0m"
        echo -e $barra
        echo -e " \033[1;49;37m'ENTER' cansela la instalacion"
        echo -e " 'D' para eliminar y continuar"
        echo -e " 'R' para restaurar el almacen crt\033[0m"
        echo -e $barra
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
    echo -e " \033[1;49;37mEnter para continuar...\033[0m"
    read foo 
}

ssl_install_fun() {
    apt install socat netcat -y
    curl https://get.acme.sh | sh
}

acme() {
    clear
    echo -e $barra
    echo -e " \033[1;49;37mcreando nuevos certificado ssl/tls\033[0m"
    echo -e $barra
    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force --test; then
        echo -e "\n           \033[1;49;37mSSL La prueba del certificado\n se emite con éxito y comienza la emisión oficial\033[0m\n"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        sleep 2
    else
        echo -e "\n \033[4;49;31mError en la emisión de la prueba del certificado SSL\033[0m"
        echo -e $barra
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
    fi

    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "\n \033[1;49;37mSSL El certificado se genero con éxito\033[0m"
        echo -e $barra
        sleep 2
        [[ -d /data ]] && mkdir /data
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force; then
            echo -e $barra
            mv $config $temp
            echo "cat $temp | jq '.inbounds[].streamSettings.tlsSettings += {certificates:[{certificateFile:\"/data/v2ray.crt\",keyFile:\"/data/v2ray.key\"}]}' | jq '.inbounds[] += {domain:\"$domi\"}' >> $config" | bash
            chmod 777 $config
            rm $temp
            restart_v2r
            echo -e "\n \033[1;49;37mLa configuración del certificado es exitosa\033[0m"
            echo -e $barra
            echo -e "      /data/v2ray.crt"
            echo -e "      /data/v2ray.key"
            echo -e $barra
            sleep 2
        fi
    else
        echo -e "\n \033[4;49;31mError al generar el certificado SSL\033[0m"
        echo -e $barra
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
    fi
}

#============================================

restart_v2r(){
	v2ray restart
	#echo "reiniciando"
}

dell_user(){
	while :
	do
	clear
	users=$(cat $config | jq .inbounds[].settings.clients[] | jq .email)

	echo -e $barra
	blanco "	ELIMINAR USUARIO V2RAY"
	echo -e $barra
	n=0
	for i in $users
	do
		[[ $i = null ]] && {
			i="default"
			a='*'
			col "$a)" "$i"
		} || {
			col "$n)" "$i"
		}
		let n++
	done
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NUMERO DE USUARIO A ELIMINAR" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && continue
	[[ $opcion = 0 ]] && break

	[[ ! $opcion =~ $numero ]] && {
		blanco " solo numeros apartir de 1"
		sleep 2
	} || {
		let n--
		[[ $opcion>=${n} ]] && {
			blanco "solo numero entre 1 y $n"
			sleep 2
		} || {
			mv $config $temp
			echo jq \'del\(.inbounds[].settings.clients[$opcion]\)\' $temp \> $config | bash
			chmod 777 $config
			rm $temp
			clear
			echo -e $barra
			blanco "	Usuario eliminado"
			echo -e $barra
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
	users=$(cat $config | jq .inbounds[].settings.clients[].email)

	echo -e "$barra"
	blanco "	CREAR USUARIO V2RAY"
	echo -e $barra
	n=0
	for i in $users
	do
		[[ $i = null ]] && {
			i="default"
			a='*'
			col "$a)" "$i"
		} || {
			col "$n)" "$i"
		}
		let n++
	done
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NOMBRE DEL NUEVO USUARIO" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && continue

	[[ $opcion = 0 ]] && break

	espacios=$(echo "$opcion" | tr -d '[[:space:]]')
	opcion=$espacios

	mv $config $temp
	num=$(jq '.inbounds[].settings.clients | length' $temp)
	new=".inbounds[].settings.clients[$num]"
	new_id="id:\"$(uuidgen)\""
	new_mail="email:\"$opcion\""
	aid=$(jq '.inbounds[].settings.clients[0].alterId' $temp)
	echo jq \'$new += \{alterId:${aid},"$new_id","$new_mail"\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "	Usuario creado con exito"
	echo -e $barra
	restart_v2r
	sleep 2
    done
}

view_user(){
	while :
	do

		clear
		users=$(cat $config | jq .inbounds[].settings.clients[] | jq .email)

		echo -e $barra
		blanco "	VER USUARIO V2RAY"
		echo -e $barra

		n=1
		for i in $users
		do
			[[ $i = null ]] && i="default"
			col "$n)" "$i"
			let n++
		done

		echo -e $barra
		col "0)" "VOLVER"
		echo -e $barra
		blanco "VER DATOS DEL USUARIO" 0
		read opcion

		[[ -z $opcion ]] && vacio && sleep 3 && continue
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
		echo -e $barra
		blanco " Usuario: $ps"
		echo -e $barra
		col2 "Remarks:" "$ps"
		col2 "Address:" "$add"
		col2 "Port:" "$port"
		col2 "id:" "$id"
		col2 "alterId:" "$aid"
		col2 "security:" "none"
		col2 "network:""$net"
		col2 "Head Type:" "none"
		[[ ! $host = '' ]] && col2 "Host/SNI:" "$host"
		[[ ! $path = '' ]] && col2 "Path:" "$path"
		col2 "TLS:" "$tls"
		blanco $barra
		blanco "              VMMES LINK"
		blanco $barra
		vmess
		blanco $barra
		blanco " Enter para continuar..."
		read foo
	done
}

vmess() {

	echo -e "\033[3;32mvmess://$(echo {\"add\":$add\,\"aid\":\"$aid\"\,\"host\":$host\,\"id\":$id\,\"net\":$net\,\"path\":$path\,\"port\":\"$port\"\,\"ps\":$ps\,\"tls\":$tls\,\"type\":\"none\"\,\"v\":\"2\"} | base64 -w 0)\033[3;32m"
}

alterid(){
	while :
	do
		aid=$(jq '.inbounds[].settings.clients[0].alterId' $config)
	clear
	echo -e $barra
	blanco "        configuracion alterId"
	echo -e $barra
	col2 "	alterid:" "$aid"
	echo -e $barra
	col "x)" "VOLVER"
	echo -e $barra
	blanco "NUEVO VALOR" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = x ]] && break

	mv $config $temp
	new=".inbounds[].settings.clients[0]"
	echo jq \'$new += \{alterId:${opcion}\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "Nuevo alterId fijado"
	echo -e $barra
	restart_v2r
	sleep 2
	done
}

port(){
	while :
	do
	port=$(jq '.inbounds[].port' $config)
	clear
	echo -e $barra
	blanco "       configuracion de puerto"
	echo -e $barra
	col2 "puerto:" "$port"
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NUEVO PUERTO" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = 0 ]] && break

	mv $config $temp
	new=".inbounds[]"
	echo jq \'$new += \{port:${opcion}\}\' $temp \> $config | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "	Nuevo alterId fijado"
	echo -e $barra
	sleep 2
	restart_v2r
	done
}

crt_man(){
	while :
	do
		clear
		echo -e $barra
		blanco "configuracion de certificado manual"
		echo -e $barra

		chek=$(jq '.inbounds[].streamSettings.tlsSettings' $config)
		[[ ! $chek = {} ]] && {
			crt=$(jq '.inbounds[].streamSettings.tlsSettings.certificates[].certificateFile' $config)
			key=$(jq '.inbounds[].streamSettings.tlsSettings.certificates[].keyFile' $config)
			dom=$(jq '.inbounds[].domain' $config)
			echo -e "		\033[4;49minstalado\033[0m"
			col2 "crt:" "$crt"
			col2 "key:" "$key"
			col2 "dominio:" "$dom"
		} || {
			blanco "	certificado no instalado"
		}

		echo -e $barra
		col "1)" "ingresar nuevo crt"
		echo -e $barra
		col "0)" "VOLVER"
		echo -e $barra
		blanco "opcion" 0
		read opcion

		[[ -z $opcion ]] && vacio && sleep 3 && break
		[[ $opcion = 0 ]] && break

		clear
		echo -e $barra
		blanco "ingrese su archivo de certificado\n ej: /root/crt/certif.crt"
		echo -e $barra
		blanco "crt" 0
		read crts

		clear
		echo -e $barra
		blanco "	nuevo certificado"
		echo -e $barra
		blanco "	$crts"
		echo -e $barra
		blanco "ingrese su archivo key\n ej: /root/crt/certif.key"
		echo -e $barra
		blanco "key" 0
		read keys

		clear
		echo -e $barra
		blanco "	nuevo certificado"
		echo -e $barra
		blanco "	$crts"
		blanco "	$keys"
		echo -e $barra
		blanco "ingrese su dominio\n ej: netfree.xyz"
		echo -e $barra
		blanco "dominio" 0
		read domi

		clear
		echo -e $barra
		blanco "verifique sus datos sean correctos!"
		echo -e $barra
		blanco "	$crts"
		blanco "	$keys"
		blanco "	$domi"
		echo -e $barra
		read foo

		mv $config $temp
		echo "cat $temp | jq '.inbounds[].streamSettings.tlsSettings += {certificates:[{certificateFile:\"$crts\",keyFile:\"$keys\"}]}' | jq '.inbounds[] += {domain:\"$domi\"}' >> $config" | bash
		chmod 777 $config
		rm $temp
		clear
		echo -e $barra
		blanco "nuevo certificado agregado"
		echo -e $barra
		restart_v2r
		sleep 2
	done
}

address(){
	while :
	do
	add=$(jq '.inbounds[].domain' $config) && [[ $add = null ]] && add=$(wget -qO- ipv4.icanhazip.com)
	clear
	echo -e $barra
	blanco "       configuracion address"
	echo -e $barra
	col2 "address:" "$add"
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NUEVO ADDRESS" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = 0 ]] && break

	mv $config $temp
	echo "cat $temp | jq '.inbounds[] += {domain:\"$opcion\"}' >> $config" | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "Nuevo address fijado"
	echo -e $barra
	restart_v2r
	sleep 2
	done
}

host(){
	while :
	do
	host=$(jq '.inbounds[].streamSettings.wsSettings.headers.Host' $config) && [[ $host = null ]] && host='sin host'
	clear
	echo -e $barra
	blanco "       configuracion Host"
	echo -e $barra
	col2 "Host:" "$host"
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NUEVO HOST" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = 0 ]] && break
	mv $config $temp
	echo "cat $temp | jq '.inbounds[].streamSettings.wsSettings.headers += {Host:\"$opcion\"}' >> $config" | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "Nuevo Host fijado"
	echo -e $barra
	restart_v2r
	sleep 2
	done
}

install(){
	clear
	echo -e $barra
	blanco "	Esta por intalar v2ray!"
	echo -e $barra
	blanco " La instalacion puede tener\n alguna fallas!\n por favor observe atentamente\n el log de intalacion,\n este podria contener informacion\n sobre algunos errores!\n estos deveras ser corregidos de\n forma manual antes de continual\n usando el script"
	echo -e $barra
	blanco "Enter para continuar..."
	read foo
	source <(curl -sL https://multi.netlify.app/v2ray.sh)
	echo -e $barra
	blanco "instalcion finalizada"
	blanco "Por favor verifique el log"
	echo -e $barra
	blanco "Enter para continuar..."
	read foo
	clear

	mv $config $temp
	echo "cat $temp | jq 'del(.inbounds[].streamSettings.kcpSettings[])' >> $config" | bash
	chmod 777 $config
	rm $temp
	restart_v2r
}

v2ray_tls(){
	clear
	echo -e $barra
	blanco "		certificado tls v2ray"
	echo -e $barra
	v2ray tls
	echo -e $barra
	blanco "Enter para continuar..."
	read foo
}

v2ray_stream(){
	clear
	echo -e $barra
	blanco "	instalacion de protocolos v2ray"
	echo -e $barra
	v2ray stream
	echo -e $barra
	blanco "Enter para continuar..."
	read foo
}

v2ray_menu(){
	clear
	echo -e $barra
	blanco "		MENU V2RAY"
	echo -e $barra
	v2ray
}

path(){
	while :
	do
	path=$(jq '.inbounds[].streamSettings.wsSettings.path' $config) && [[ $path = null ]] && path=''
	clear
	echo -e $barra
	blanco "       configuracion Path"
	echo -e $barra
	col2 "path:" "$path"
	echo -e $barra
	col "0)" "VOLVER"
	echo -e $barra
	blanco "NUEVO Path" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = 0 ]] && break

	mv $config $temp
	echo "cat $temp | jq '.inbounds[].streamSettings.wsSettings += {path:\"$opcion\"}' >> $config" | bash
	chmod 777 $config
	rm $temp
	clear
	echo -e $barra
	blanco "Nuevo path fijado"
	echo -e $barra
	sleep 2
	restart_v2r
	done
}

settings(){
	while :
	do
	clear
	echo -e $barra
	blanco "	  Ajustes e instalacion v2ray"
	echo -e $barra
	col "1)" "instalar v2ray"
	echo -e $barra
	col "2)" "alterId"
	col "3)" "puerto"
	col "4)" "address"
	col "5)" "Host"
	col "6)" "Path"
	echo -e $barra
	col "7)" "certif ssl/tls (script)"
	col "8)" "certif menu nativo"
	col "9)" "certif ingreso manual"
	echo -e $barra
	col "10)" "protocolo menu nativo"
	col "11)" "conf v2ray menu nativo"
	echo -e $barra
	col "0)" "Volver"
	echo -e $barra
	blanco "opcion" 0
	read opcion

	[[ -z $opcion ]] && vacio && sleep 3 && break
	[[ $opcion = 0 ]] && break

	case $opcion in
		1)install;;
		2)alterid;;
		3)port;;
		4)address;;
		5)host;;
		6)path;;
		7)domain_check && clear ;;
		8)v2ray_tls;;
		9)crt_man;;
		10)v2ray_stream;;
		11)v2ray_menu;;
		*) blanco " solo numeros de 0 a 10" && sleep 2;;
	esac
    done
}

main(){
	[[ ! -e $config ]] && {
		clear
		echo -e $barra
		blanco " No se encontro ningun archovo de configracion v2ray"
		echo -e $barra
		blanco "	  No instalo v2ray o esta usando\n	     una vercion diferente!!!"
		echo -e $barra
		echo -e "		\033[4;31mNOTA importante\033[0m"
		echo -e " \033[0;31mSi esta usando una vercion v2ray diferente"
		echo -e " y opta por cuntinuar usando este script."
		echo -e " Este puede; no funcionar correctamente"
		echo -e " y causar problemas en futuras instalaciones.\033[0m"
		echo -e $barra
		blanco " Enter para cuntinuar..."
		read foo
	}
	while :
	do
		clear
		echo -e $barra
		blanco "            MENU V2RAY"
		echo -e $barra
		col "1)" "CREAR USUARIO"
		col "2)" "REMOVER USUARIO"
		col "3)" "VER USUARIOS"
		col "4)" "CONFIGURAR V2RAY"
		echo -e $barra
		col "0)" "SALIR"
		echo -e $barra
		blanco "opcion" 0
		read opcion

		case $opcion in
			1)add_user;;
			2)dell_user;;
			3)view_user;;
			4)settings;;
			0) break;;
			*) blanco "\n selecione una opcion del 0 al 4" && sleep 2;;
		esac
	done
}

main
