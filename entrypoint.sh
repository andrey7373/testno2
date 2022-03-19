#!/bin/bash

#Шаг 2 — Создание центра сертификации
	mkdir -p ~/pki/{cacerts,certs,private}
	chmod 700 ~/pki

#Сгенерировать ключ root. Это будет 4096-битный ключ RSA, который будет использоваться для подписи корневого центра сертификации.
	ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/ca-key.pem
#созданию корневого центра сертификации, используя ключ для подписания сертификата root:	
	ipsec pki --self --flag serverAuth --in ~/pki/private/ca-key.pem --type rsa --digest sha256 --dn "C=US, O=Example Company, CN=alpatski.asuscomm.com" --outform pem  --ca --lifetime 3653 > ~/pki/cacerts/ca-cert.pem

#Шаг 3 — Генерирование сертификата для сервера VPN
#создадим сертификат и ключ для сервера VPN. Этот сертификат позволит клиентам проверять подлинность сервера, используя только что сгенерированный нами сертификат CA.
	
#Вначале создайте закрытый ключ сервера VPN с помощью следующей команды:
	ipsec pki --gen --type rsa --size 4096 --outform pem > ~/pki/private/server-key.pem
	ipsec pki --pub --in ~/pki/private/server-key.pem --type rsa > ~/pki/private/server-key.csr
	
#Затем создайте и подпишите сертификат сервера VPN, используя ключ центра сертификации, созданный на предыдущем шаге:
	ipsec pki --issue --cacert ~/pki/cacerts/ca-cert.pem --cakey ~/pki/private/ca-key.pem --digest sha256 --dn "C=US, O=Example Company, CN=alpatski.asuscomm.com" --san "alpatski.asuscomm.com" --flag serverAuth --outform pem < ~/pki/private/server-key.csr > ~/pki/certs/server-cert.pem
	openssl rsa -in ~/pki/private/server-key.pem -out ~/pki/private/server-key.der -outform DER

#Теперь мы сгенерировали все файлы TLS/SSL, необходимые StrongSwan, и можем переместить их в каталог /etc/ipsec.d следующим образом:	
	cp -r ~/pki/* /etc/ipsec.d/
