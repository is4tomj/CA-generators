#!/bin/bash

echo "Please enter Company Name (use 0-9a-zA-Z and spaces)"
echo "    e.g. Company Name, Inc."
read companyName
CN=$(echo ${companyName//[^0-9a-zA-Z]/-})

echo "Please enter Sub-CA name (e.g., Global)"
read host

echo "Please provide user"
read user

echo ""
echo "##########################"
echo "### Generate new privacy key and cert request"
echo "##########################"
echo ""
openssl genrsa -out $CN-$user-Intermediate-CA-key.pem 2048
cat>$CN-$user-Intermediate-CA-csr.conf<<EOF
[ req ]
distinguished_name = req_distinguished_name
prompt = yes
[ req_distinguished_name ]
countryName = Country Name (2-letter code)
countryName_default = US
organizationName = Organization Name
organizationName_default = $companyName
organizationalUnitName = Org Unit
organizationalUnitName_default = Operations
commonName = CN
commonName_default = $companyName $user CA
EOF
openssl req -sha256 -new -config $CN-$user-Intermediate-CA-csr.conf -key $CN-$user-Intermediate-CA-key.pem -nodes -out $CN-$user-Intermediate-CA-csr.pem

echo ""
echo "##########################"
echo "### Sign the certificate"
echo "##########################"
echo ""

echo "Enter pathlen (default 1)"
read pathlen

cat>$CN-$user-Intermediate-CA-crt.conf<<EOF
basicConstraints = critical,CA:true,pathlen:$pathlen
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = critical, serverAuth
EOF


# /usr/lib/engines/engine_pkcs11.so is the wrong lib. That is for old versions of openssl. The current version is 1.1.1, so need to (1) install libengine-pkcs11-openssl1.1, and (2) use the following path /usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so

pin=`cat $CN-$host-CA-pin.txt`
echo "*************** pin: $pin ***************"
openssl << EOF
engine dynamic -pre SO_PATH:/usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so -pre VERBOSE
x509 -engine pkcs11 -CAkeyform engine -CAkey 'pkcs11:manufacturer=piv_II;id=%02' -sha256 -CA $CN-$host-CA-crt.pem -req -passin pass:$pin -in $CN-$user-Intermediate-CA-csr.pem -extfile $CN-$user-Intermediate-CA-crt.conf -out $CN-$user-Intermediate-CA-crt.pem
EOF


echo "Done. You may inspect the newly generated Intermediate CA cert with this command:"
echo "  $ openssl x509 -text < $CN-$user-Intermediate-CA-crt.pem"
echo ""

