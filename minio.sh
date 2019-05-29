#!/bin/bash

# usage: ./minio-upload my-bucket my-file.zip

bucket=$1
file=$2

host=localhost:9000
s3_key='fotostam'
s3_secret='secretsecret'

resource="/${bucket}/${file}"
content_type="application/octet-stream"
date=`date -R`
_signature="GET\n\n${content_type}\n${date}\n${resource}"
signature=`echo -en ${_signature} | openssl sha1 -hmac ${s3_secret} -binary | base64`

curl -v -X GET -H "Host: $host" \
          -H "Date: ${date}" \
          -H "Content-Type: ${content_type}" \
          -H "Authorization: AWS ${s3_key}:${signature}" \
          http://$host${resource}
