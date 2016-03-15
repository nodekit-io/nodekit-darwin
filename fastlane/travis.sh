#!/bin/bash

# generate your private key, put the public key on the server you will be connecting to
ssh-keygen -t rsa -N "" -C travis  -f ./travis_key

# generate the password/secret you will store encrypted in the .travis.yml and use to encrypt your private key
cat /dev/urandom | head -c 10000 | openssl sha1 > ./secret

# encrypt your private key using your secret password
openssl aes-256-cbc -pass "file:./secret" -in ./travis_key -out ./travis_key.enc -a

# download your Travis-CI public key via the API. eg: https://api.travis-ci.org/repos/travis-ci/travis-ci/key
# replace 'RSA PUBLIC KEY' with 'PUBLIC KEY' in it
# save it as a file id_travis.pub

# now encrypt your secure environment variable and secret password 
# travis encrypt SSH_SECRET=replacewithcontentsof.secret --add

# insert your secure environment variable in your .travis.yml like so
# env:
#   - secure: "ENCODEDSECUREVAR"
# make sure you add the .my_key.enc to your repository

# to decode your encrypted private key in Travis, use the following line and it will output a decrypted my_key file
# openssl aes-256-cbc -pass "pass:$SSH_SECRET" -in ./my_key.enc -out ./my_key -d -a
