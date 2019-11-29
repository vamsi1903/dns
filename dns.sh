#!/bin/bash
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils tree apache2 gpg rng-tools sudo

echo 'shuhari ALL=(ALL:ALL) ALL' >> /etc/sudoers.tmp

#Zone Creation

echo 'zone "shuhari.local" IN {
	type master;
	file "/etc/bind/db.forward";
	allow-update { none; };
};' >> /etc/bind/named.conf.local
echo 'zone "208.168.192.in-addr.arpa" IN {
	type master;
	file "/etc/bind/db.reverse";
	allow-update { none; };
};' >> /etc/bind/named.conf.local

#Forward Zone File

echo ';
; BIND  data file for local loopback interface
;
$TTL	604800
@	IN	SOA	shuhari.local. ser1.shuhari.local. (
				2	; Serial
			   604800	; Refresh
			    86400	; Retry
		          2419200	; Expire
			   604800 )	; Negative Cache TTL
;
@	IN	NS	ser1.shuhari.local.
ser1	IN	A	192.168.208.103
rootca	IN	A	192.168.208.101
subca	IN	A	192.168.208.102
www	IN	CNAME	ser1.shuhari.local.' >> /etc/bind/db.forward

#Reverse Zone File

echo ';
; BIND  data file for local loopback interface
;
$TTL    604800
@       IN      SOA     shuhari.local. ser1.shuhari.local. (
                                2       ; Serial
                           604800       ; Refresh
                            86400       ; Retry
                          2419200       ; Expire
                           604800 )     ; Negative Cache TTL
;
@       IN      NS      ser1.shuhari.local.
101	IN	PTR	rootca.shuhari.local.
102	IN	PTR	subca.shuhari.local.
103	IN	PTR	ser1.shuhari.local.' >> /etc/bind/db.reverse

#Changing Network Settings

sed -i 's/dhcp/static/g' /etc/network/interfaces

echo 'address	192.168.208.103
netmask	255.255.255.0
gateway	192.168.208.2
network	192.168.208.0
broadcast	192.168.208.255
dns-nameserver	192.168.208.103' >> /etc/network/interfaces

#Changing Hostname

cp /dev/null /etc/hostname
echo 'ser1.shuhari.local' >> /etc/hostname


#Changing Resolv.conf file

cp /dev/null /etc/resolv.conf

echo 'domain shuhari.local
search shuhari.local
nameserver 192.168.208.103' >> /etc/resolv.conf

#Restart Services
chattr +i /etc/resolv.conf
systemctl restart bind9
systemctl enable bind9
init 6
