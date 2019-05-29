#!/bin/bash

file_data() {
    cat <<EOF
{
    "filename": "${file##*/}",
    "height": "${height:-0}",
    "width": "${width:-0}",
    "size": "${size:-onbekend}",
    "camera": "${camera:-onbekend}"
}
EOF
}

generate_mapping() {
    cat <<EOF
{
  "mappings": {
    "_doc": {
      "properties": {
        "filename": { "type": "keyword" },
        "height": { "type": "integer" },
        "width": { "type": "integer" },
        "size": { "type": "keyword" },
        "camera": { "type": "keyword" }
      }
    }
  }
}
EOF
}

DIRECTORY=/data/bucket/

printf "Deleting index \n"
curl -H "Content-Type: application/json" -XDELETE "${ELASTICSEARCH_HOST}fotoindex" 
printf "Creating index \n";
curl -H "Content-Type: application/json" -XPUT "${ELASTICSEARCH_HOST}fotoindex?include_type_name=true" -d "$(generate_mapping)"
printf "\n"
printf "Starting index \n"
for file in ${DIRECTORY}*
do
    if file "$file" |grep -qE 'image|bitmap'; then
        hash=$(sha1sum $file)
        printf "Indexing $file with index $hash \n"
        
        #image data
        height=`identify -quiet -format "%h" $file`
        width=`identify -quiet -format "%w" $file`
        size=`identify -quiet -format "%b" $file`
        camera=`identify -quiet -format "%[EXIF:Make] %[EXIF:Model]" $file`

        curl -H "Content-Type: application/json" -XPOST "${ELASTICSEARCH_HOST}fotoindex/_doc/$hash_" -d "$(file_data)"
        printf "\n"
    fi
done
