#!/bin/sh
# https://www.mediawiki.org/wiki/Convert_Socialtextwiki_to_Mediawiki#Copy_the_original_files_to_the_new_host

wikiurl="http://NAME.OF.NEW.SERVER/mediawiki/api.php"
lgname="WikiSysop"
lgpassword="*************"

# login
login=$(wget -q -O - --no-check-certificate --save-cookies=/tmp/converter-cookies.txt \
             --post-data "action=login&lgname=$lgname&lgpassword=$lgpassword&format=json" \
             $wikiurl)
#echo $login 

# get edittoken
edittoken=$(wget -q -O - --no-check-certificate --save-cookies=/tmp/converter-cookies.txt \
             --post-data "action=query&prop=info|revisions&intoken=edit&titles=Main%20Page&format=json" \
             $wikiurl)
#echo $edittoken
token=$(echo $edittoken | sed -e 's/.*edittoken.:.\([^\"]*\)...\".*/\1/')
token="$token""%2B%5C"
#echo $token

# test editing with a test page
#cmd="action=edit&title=test1&summary=autoconverted&format=json&text=test1&token=$token&recreate=1&notminor=1&bot=1"
#editpage=$(wget -q -O - --no-check-certificate --load-cookies=/tmp/converter-cookies.txt --post-data $cmd $wikiurl)
#echo $editpage
#exit

# loop over all pages except for dirs in the list of excludes
find data -not -path "data/help*" -type f -and -not -name ".*" | sort |
while read n; do
    pagedir=$(echo $n | sed -e 's/.*\/\(.*\)\/index.txt/\1/')
    if [[ "`grep -q $pagedir excludes; echo $?`" == "0" ]]; then
        echo "omitting  $pagedir"
    else
        echo "parsing   $pagedir"
        workspace=$(echo $n | sed -e 's/.*\/\(.*\)\/[^\/]\+\/index.txt/\1/')
        pagename=$(egrep '^Subject:' $n | head -n 1 | sed -e 's/^Subject: \(.*\)/\1/')
        pagedate=$(egrep '^Date:' $n | head -n 1 | sed -e 's/^Date: \(.*\)/\1/')
        echo "$workspace $pagedir -------------- $pagename";
        text=$(./conv.py $n)
        text1=$(php -r 'print urlencode($argv[1]);' "$text")
        pagename1=$(php -r 'print urlencode($argv[1]);' "$pagename")
        pagedate1=$(php -r 'print urlencode($argv[1]);' "$pagedate")
        cmd="action=edit&title=$pagename1&summary=$pagedate1+autoconverted+from+socialtextwiki&format=json&text=$text1&token=$token&recreate=1&notminor=1&bot=1"
        editpage=$(wget -q -O - --no-check-certificate --load-cookies=/tmp/converter-cookies.txt --post-data $cmd $wikiurl)
        #echo $editpage
    fi
done
