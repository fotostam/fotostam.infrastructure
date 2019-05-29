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
        "filename": { "type": "text" },
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

directory=/data/bucket

while read path action file
do
  printf "Test: $file"
  if file "$directory/$file" |grep -qE 'image|bitmap'; then
    hash=$(sha1sum $directory/$file)
    printf "Indexing $directory/$file with index $hash \n"
    
    #image data
    height=`identify -quite -format "%h" "$directory/$file"`
    width=`identify -quite -format "%w" $directory/$file`
    size=`identify -quite -format "%b" $directory/$file`
    camera=`identify -quite -format "%[EXIF:Make] %[EXIF:Model]" $directory/$file`

    curl -H "Content-Type: application/json" -XPOST "${ELASTICSEARCH_HOST}fotoindex/_doc/$hash_" -d "$(file_data)"
    printf "\n"
  fi   
done < <(inotifywait -mr -e create -e moved_to $directory)