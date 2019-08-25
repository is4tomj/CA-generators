YubiKey Cert Setup
================

The scripts in this repository are for generating key material using openssl
and loading the certs and private keys onto YubiKeys.


## Prereqs

Buy a Yubikey. I suggest a Yubikey FIPS.

```bash
# install ykman
$ sudo apt-add-repository ppa:yubico/stable
$ sudo apt update
$ sudo apt install yubikey-manager
$ sudo apt install libengine-pkcs11-openssl1.1
```

## Usage

Generate a Root CA and a Sub CA, then load the Sub CA onto a Yubikey. The
root key should be stored offline on an encrypted drive (I suggest having two
necrypted backups).

```bash
$ bash gen-root-and-sub-ca.sh
```

Generate an intermediate CA using the Sub CA on the Yubikey.

```bash
$ bash gen-ee-cert.sh
```

Generate an End-Entity Cert using the Yubikey with the private key material.

```bash
$ bash gen-ee-cert.sh
```


## Helpful sources

https://developers.yubico.com/PIV/Guides/Certificate_authority.html
https://developers.yubico.com/PIV/Introduction/Certificate_slots.html


## Cryptography Notice

This distribution includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software. BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted. See http://www.wassenaar.org/ for more information.

The U.S. Government Department of Commerce, Bureau of Industry and Security (BIS), has classified this software as Export Commodity Control Number (ECCN) 5D002.C.1, which includes information security software using or performing cryptographic functions with asymmetric algorithms. The form and manner of this distribution makes it eligible for export under the License Exception ENC Technology Software Unrestricted (TSU) exception (see the BIS Export Administration Regulations, Section 740.13) for both object code and source code.

## License

Copyright 2019 Tom Johnson

Licensed under MIT:

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
