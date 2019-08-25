#!/bin/bash

echo ""
echo "#############################"
echo "### Create the Root CA"
echo "#############################"
echo ""
echo "Please enter Company Name (use 0-9a-zA-Z and spaces)"
echo "    e.g. Company Name, Inc."
read companyName

CN=$(echo ${companyName//[^0-9a-zA-Z]/-})

echo "Please provide email address"
read email

echo "Generating root key"
openssl genrsa -out $CN-Root-CA-key.pem 4096

cat>$CN-Root-CA.conf<<EOF
[ req ]
x509_extensions = v3_ca
distinguished_name = req_distinguished_name
prompt = yes
[ req_distinguished_name ]
countryName = Country Name (2-letter code)
countryName_default = US
organizationName = Organization Name
organizationName_default = $companyName
organizationalUnitName = Org Unit
organizationalUnitName_default = Operations
commonName = Common Name
commonName_default = $companyName Root CA
[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign, digitalSignature, keyEncipherment
EOF

echo "Generating Root CA and initializing serial number counter"
ret=$(openssl req -new -sha256 -x509 -set_serial 1 -days 1000000 -config $CN-Root-CA.conf -key $CN-Root-CA-key.pem -out $CN-Root-CA-crt.pem)

echo 01 > $CN-Root-CA-crt.srl

echo "You may inspect the newly generated root CA with:"
echo "   $ openssl x509 -text < $CN-Root-Root-CA-crt.pem"
echo ""
echo "#############################"
echo "### Prepare a Sub-CA"
echo "#############################"
echo ""
echo "Pick a name for the Sub-CA (0-9a-zA-z, no spaces)"
read user

echo "Generating managment key, pin, and puk for $user"

key=$(export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -d '[:lower:]' | tr -cd '[:xdigit:]' | fold -w48 | head -1)
echo $key > $CN-$user-CA-key.txt
pin=$(export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w6 | head -1)
echo $pin > $CN-$user-CA-pin.txt
puk=$(export LC_CTYPE=C; dd if=/dev/urandom 2>/dev/null | tr -cd '[:digit:]' | fold -w8 | head -1)
echo $puk > $CN-$user-CA-puk.txt

echo "Go ahead and choose 'y' to reset the piv data on the Yubikey"
ykman piv reset
ykman piv change-management-key --protect --pin 123456 --management-key 010203040506070801020304050607080102030405060708 --new-management-key $key
ykman piv change-pin --pin 123456 --new-pin $pin
ykman piv change-puk --puk 12345678 --new-puk $puk
echo "Done setting management key, pin, and puk"
echo ""
echo "#############################"
echo "### Create Sub-CA"
echo "#############################"
echo ""

### Generate private key
echo "Generating Root Sub-ca key"
openssl genrsa -out $CN-$user-CA-key.pem 2048

### Generate the Sub-CA cert request
cat>$CN-$user-CA-csr.conf<<EOF
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
openssl req -sha256 -new -config $CN-$user-CA-csr.conf -key $CN-$user-CA-key.pem -nodes -out $CN-$user-CA-csr.pem

### Generate the Sub-CA certificate
echo "Generate Sub-CA cert"
cat>$CN-$user-CA-crt.conf<<EOF
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign, digitalSignature, keyEncipherment
EOF
openssl x509 -sha256 -CA $CN-Root-CA-crt.pem -CAkey $CN-Root-CA-key.pem -req -in $CN-$user-CA-csr.pem -extfile $CN-$user-CA-crt.conf -out $CN-$user-CA-crt.pem
echo 01 > $CN-$user-CA-crt.srl

echo ""
echo "#############################"
echo "### Import Sub-CA key and cert to Yubikey"
echo "#############################"
echo ""

ykman piv import-key --pin $pin --pin-policy ALWAYS --touch-policy ALWAYS 9c $CN-$user-CA-key.pem
ykman piv import-certificate --pin $pin --verify 9c $CN-$user-CA-crt.pem



