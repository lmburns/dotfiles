#!/bin/bash
if [[ $# -eq 0 ]] ; then
  echo " Usage: $0 https://archive.4plebs.org/adv/thread/19296689/"
  exit 0
fi
if ! [ -x "$(command -v wget)" ]; then
  echo ' Error: wget not installed.' >&2
  exit 1
fi
if ! [ -x "$(command -v jq)" ]; then
  echo ' Error: jq not installed.' >&2
  exit 1
fi
proto="$(echo $1 | grep :// | sed -e's,^\(.*://\).*,\1,g')"
url="$(echo ${1/$proto/})"
host="$(echo ${url} | cut -d/ -f1)"
path="$(echo $url | grep / | cut -d/ -f2-)"
board="$(echo ${path} | cut -d/ -f1)"
num="$(echo ${path} | cut -d/ -f3)"
threadjson=$(wget ${proto}${host}/_/api/chan/thread?board=${board}\&num=${num} -O-)
filepath="./${host}/${board}/${num}"
mkdir -p ${filepath}
mediaurl=$(echo ${threadjson} | jq -r '.[].op.media?.media_link?')
if [ ! -n "${mediaurl}" ] || [ "${mediaurl}" == "null" ]
then
  mediaurl=$(echo ${threadjson} | jq -r '.[].op.media?.remote_media_link?')
fi
newfilename="${filepath}/$(echo ${threadjson} | jq -r '.[].op.media?.media_id?')_$(echo ${threadjson} | jq -r '.[].op.media?.media_filename?')"
origfilename="${filepath}/$(echo ${threadjson} | jq -r '.[].op.media?.media_filename?')"
if [ -n "${mediaurl}" ] && [ "${mediaurl}" != "null" ]
then
  if grep -q ${mediaurl} "${filepath}/downloaded.txt"; then
    echo "${mediaurl} already downloaded. Skipping"
  else
    if [ -f "${origfilename}" ]; then
      if [ -f "${newfilename}" ]; then
        echo "'${newfilename}' exists. Skipping"
      else
        echo "'${origfilename}' exists. Saving as '${newfilename}'"
        wget ${mediaurl} -O "${newfilename}"
        echo ${mediaurl} >> "${filepath}/downloaded.txt"
      fi
    else
      wget ${mediaurl} -O "${origfilename}"
      echo ${mediaurl} >> "${filepath}/downloaded.txt"
    fi
  fi
fi
echo ${threadjson} | jq -c '.[].posts? | .[]? | .media? | del(.exif)' |\
while read media
do
  if [ -n "${media}" ]
  then
    mediaurl=$(echo ${media} | jq -r '.media_link')
    if [ ! -n "${mediaurl}" ] || [ "${mediaurl}" == "null" ]
    then
      mediaurl=$(echo ${media} | jq -r '.remote_media_link')
    fi
    newfilename="${filepath}/$(echo ${media} | jq -r '.media_id')_$(echo ${media} | jq -r '.media_filename')"
    origfilename="${filepath}/$(echo ${media} | jq -r '.media_filename')"
    if [ -n "${mediaurl}" ] && [ "${mediaurl}" != "null" ]
    then
      if grep -q ${mediaurl} "${filepath}/downloaded.txt"; then
        echo "${mediaurl} already downloaded. Skipping"
      else
        if [ -f "${origfilename}" ]; then
          if [ -f "${newfilename}" ]; then
            echo "'${newfilename}' exists. Skipping"
          else
            echo "'${origfilename}' exists. Saving as '${newfilename}'"
            wget ${mediaurl} -O "${newfilename}"
            echo ${mediaurl} >> "${filepath}/downloaded.txt"
          fi
        else
          wget ${mediaurl} -O "${origfilename}"
          echo ${mediaurl} >> "${filepath}/downloaded.txt"
        fi
      fi
    fi
  fi
done
