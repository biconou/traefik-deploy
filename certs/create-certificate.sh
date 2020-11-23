#!/bin/bash

DOMAIN=localhost

#Create the certificate key
openssl genrsa -out ${DOMAIN}.key 2048

cat /etc/ssl/openssl.cnf > custom.cnf
echo "" >> custom.cnf
echo "[ SAN ]" >> custom.cnf
echo "subjectAltName=DNS:nextcloud.local" >> custom.cnf

#Create the signing (csr)
openssl req -new -sha256 \
    -key ${DOMAIN}.key \
    -subj "/C=FR/O=Remi Cocula/CN=${DOMAIN}" \
    -reqexts SAN \
    -config custom.cnf \
    -out ${DOMAIN}.csr

#Verify the csr's content
openssl req -in ${DOMAIN}.csr -noout -text

#Generate the certificate using the mydomain csr and key along with the CA Root key
openssl x509 -req -in ${DOMAIN}.csr \
    -CA remi.cocula-ca.crt -CAkey remi.cocula-ca.key -CAcreateserial \
    -out ${DOMAIN}.crt \
    -extensions SAN \
    -extfile custom.cnf \
    -days 500 -sha256

#Verify the certificate's content
openssl x509 -in ${DOMAIN}.crt -text -noout