#!/bin/bash

if [ "x$1" == "xlain" ]; then
    
    ##### auth
    curl -i -X POST \
      --url http://kong:8001/consumers/ \
      --data "username=myuser"
     
    ID=$(curl -X POST --url http://kong:8001/consumers/myuser/jwt -H "Content-Type: application/x-www-form-urlencoded" | jq '.id' | perl -ne '/"(.+)"/ && print $1')
     
    SECRET=$(curl -X GET http://kong:8001/consumers/myuser/jwt/$ID | jq '.secret' | perl -ne '/"(.+)"/ && print $1')
    KEY=$(curl -X GET http://kong:8001/consumers/myuser/jwt/$ID | jq '.key' | perl -ne '/"(.+)"/ && print $1')
    
    ##### /lain
    curl -i -X POST \
      --url http://kong:8001/services/ \
      --data 'name=lain' \
      --data 'url=http://lain:8080/'

    curl -i -X POST \
      --url http://kong:8001/services/lain/routes \
      --data 'paths=/'    
     
    curl -i -X POST \
      --url http://kong:8001/services/lain/plugins/ \
      --data 'name=jwt'
    
    #### cookie
    curl -i -X POST \
      --url http://kong:8001/services/ \
      --data 'name=plain' \
      --data 'url=http://lain:8080/base.html'
     
    curl -i -X POST \
      --url http://kong:8001/services/plain/routes \
      --data 'paths=/base.html'

    PLUGIN=$(curl -X GET http://kong:8001/plugins/ | jq '.data[] | select(.name == "jwt") | .id' | perl -ne '/"(.+)"/ && print $1')
    curl -X PATCH http://kong:8001/plugins/$PLUGIN --data "config.cookie_names[]=Authorization"

    
    HEADER=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl base64 -e -A)
    PAYLOAD=$(echo -n "{\"iss\":\"$KEY\"}" | openssl base64 -e -A)
    SIGNATURE=$(echo -n "$HEADER.$PAYLOAD" | openssl dgst -sha256 -hmac $SECRET -binary | openssl base64 -e -A  | sed s/\+/-/ | sed -E s/=+$// | sed -e's/\//_/g')
    JWT="$HEADER.$PAYLOAD.$SIGNATURE"
    
    echo ""
    echo ""
    echo "##############################################################"
    echo $JWT
else
    exec $@
fi

