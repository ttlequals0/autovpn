#!/bin/bash
# OpenVPN  automated installer for Debian, Ubuntu and CentOS

# This script will work on Debian, Ubuntu, CentOS and probably other distros
# of the same families. This is a completely automated install no user input necessary..
# The script will use pre-defined values that can be changed manually in script.
# This script also assume server is behind NAT.

if [[ "$USER" != 'root' ]]; then
	echo "This requiers root privileges"
	exit
fi


if [[ ! -e /dev/net/tun ]]; then
	echo "TUN/TAP is not available"
	exit
fi


if grep -qs "CentOS release 5" "/etc/redhat-release"; then
	echo "CentOS 5 not supported"
	exit
fi

if [[ -e /etc/debian_version ]]; then
	OS=debian
	RCLOCAL='/etc/rc.local'
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
	OS=centos
	RCLOCAL='/etc/rc.d/rc.local'
	# Needed for CentOS 7
	chmod +x /etc/rc.d/rc.local
else
	echo "OS is not supported please run on Debian, Ubuntu or CentOS"
	exit
fi

newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-common.txt ~/$1.ovpn
	echo "<ca>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/$1.ovpn
	echo "</ca>" >> ~/$1.ovpn
	echo "<cert>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> ~/$1.ovpn
	echo "</cert>" >> ~/$1.ovpn
	echo "<key>" >> ~/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> ~/$1.ovpn
	echo "</key>" >> ~/$1.ovpn
}


# Get external IP assumed behind NAT
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -qO- ipv4.icanhazip.com)
fi
PORT=1194
CLIENT=client1

	if [[ "$OS" = 'debian' ]]; then
		apt-get update
		apt-get install openvpn iptables openssl -y
	else
		# Else, the distro is CentOS
		yum install epel-release -y
		yum install openvpn iptables openssl wget -y
	fi
	# An old version of easy-rsa was available by default in some openvpn packages
	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi
	# Get easy-rsa
	wget --no-check-certificate -O ~/EasyRSA-3.0.0.tgz https://github.com/OpenVPN/easy-rsa/releases/download/3.0.0/EasyRSA-3.0.0.tgz
	tar xzf ~/EasyRSA-3.0.0.tgz -C ~/
	mv ~/EasyRSA-3.0.0/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.0/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.0.tgz
	cd /etc/openvpn/easy-rsa/ || exit
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $CLIENT nopass
	./easyrsa gen-crl
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn
	# Generate server.conf
	echo "port $PORT
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" > /etc/openvpn/server.conf
	echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server.conf
	echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
	echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf

	echo "keepalive 10 120
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify /etc/openvpn/easy-rsa/pki/crl.pem" >> /etc/openvpn/server.conf
	# Enable net.ipv4.ip_forward for the system
	if [[ "$OS" = 'debian' ]]; then
		sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	else
		# CentOS 5 and 6
		sed -i 's|net.ipv4.ip_forward = 0|net.ipv4.ip_forward = 1|' /etc/sysctl.conf
		# CentOS 7
		if ! grep -q "net.ipv4.ip_forward=1" "/etc/sysctl.conf"; then
			echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
		fi
	fi
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set NAT for the VPN subnet
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to "$IP"
	sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
	if pgrep firewalld; then
		# We don't use --add-service=openvpn because that would only work with
		# the default port. Using both permanent and not permanent rules to
		# avoid a firewalld reload.
		firewall-cmd --zone=public --add-port=$PORT/udp
		firewall-cmd --zone=trusted --add-source=10.8.0.0/24
		firewall-cmd --permanent --zone=public --add-port=$PORT/udp
		firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	fi
	if iptables -L | grep -q REJECT; then
		# If iptables has at least one REJECT rule, we asume this is needed.
		# Not the best approach but I can't think of other and this shouldn't
		# cause problems.
		iptables -I INPUT -p udp --dport $PORT -j ACCEPT
		iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
		iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
		sed -i "1 a\iptables -I INPUT -p udp --dport $PORT -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
		sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
	fi
	# restart OpenVPN
	if [[ "$OS" = 'debian' ]]; then
		# check for systemd
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
		else
			/etc/init.d/openvpn restart
		fi
	else
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
			systemctl enable openvpn@server.service
		else
			service openvpn restart
			chkconfig openvpn on
		fi
	fi
IP=$(wget -qO- ipv4.icanhazip.com)
	# client-common.txt is created so we have a template to add further users later
	echo "client
dev tun
proto udp
remote $IP $PORT
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
comp-lzo
verb 3" > /etc/openvpn/client-common.txt
	# Generates the custom client.ovpn
	newclient "$CLIENT"
	echo ""
	echo "Finished!"
	echo ""
	echo "Client config is available at ~/$CLIENT.ovpn"
	echo "If you want to add more clients, simply re-run this script again"
