#!/bin/bash

file_data() {
    cat <<EOF
{
    "filename": "${file##*/}",
    "height": "${height:-0}",
    "width": "${width:-0}",
    "size": "${size:-onbekend}",
    "time": "${time:-0}",
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
        "time": { "type": "date" },
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
    height=`identify -format "%h" "$directory/$file"`
    width=`identify -format "%w" $directory/$file`
    size=`identify -format "%b" $directory/$file`
    time=`identify -format "%[EXIF:DateTime]" $directory/$file`
    camera=`identify -format "%[EXIF:Make] %[EXIF:Model]" $directory/$file`

    curl -H "Content-Type: application/json" -XPOST "${ELASTICSEARCH_HOST}fotoindex/_doc/$hash_" -d "$(file_data)"
    printf "\n"
  fi   
done < <(inotifywait -mr -e create -e moved_to $directory)