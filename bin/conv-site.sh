#!/bin/bash
# https://www.mediawiki.org/wiki/Convert_Socialtextwiki_to_Mediawiki#Copy_the_original_files_to_the_new_host


_mediawiki_url_base="https://wiki/"
_socialtext_path_base="/var/www/socialtext/"

echo -e "\nThis utility will allow you to migrate a SocialText wiki to your MediaWiki server:"

echo -e "Please enter the Base Path for SocialText files"
read -p "($_socialtext_path_base): " _socialtext_path
[ -z "$_socialtext_path" ] && _socialtext_path="$_socialtext_path_base"

echo -e "Please enter the Socialtext shortname"
read -p "(wiki): " _socialtext_short
[ -z "$_socialtext_short" ] && _socialtext_short="wiki"

echo -e "Please enter the Base URL for MediaWiki"
read -p "($_mediawiki_url_base): " _mediawiki_url
[ -z "$_mediawiki_url" ] && _mediawiki_url="$_mediawiki_url_base"

echo -e "Please enter the MediaWiki shortname"
read -p "(mediawiki): " _mediawiki_short
[ -z "$_mediawiki_short" ] && _mediawiki_short="mediawiki"

echo -e "Please enter the MediaWiki username"
read -p "($( id -un )): " _mediawiki_user
[ -z "$_mediawiki_user" ] && _mediawiki_user="$( id -un )"

echo -e "Please enter the MediaWiki password for ($_mediawiki_user)"
read -s _mediawiki_pass
echo


_mediawiki="${_mediawiki_url}${_mediawiki_short}/api.php"
_socialtext="${_socialtext_path}$_socialtext_short"




echo -e "\nAbout to migrate ($_socialtext) to ($_mediawiki):"
read -p 'Do you wish to continue? (Y/N) ' answer
answer=$( echo ${answer::1} | tr '[:upper:]' '[:lower:]' )

if [ "$answer" == "y" ]; then
    # wikiurl="http://NAME.OF.NEW.SERVER/mediawiki/api.php"
    # lgname="WikiSysop"
    # lgpassword="*************"

    # login
    login=$(wget -q -O - --no-check-certificate --save-cookies=/tmp/converter-cookies.txt \
                 --post-data "action=login&lgname=$_mediawiki_user&lgpassword=$_mediawiki_pass&format=json" \
                 $_mediawiki)
    # login=$(wget -q -O - --no-check-certificate --save-cookies=/tmp/converter-cookies.txt \
    #              --post-data "action=query&meta=tokens&type=login&lgname=$_mediawiki_user&lgpassword=$_mediawiki_pass&format=json" \
    #              $_mediawiki)



    echo $login 

    # # get edittoken
    # edittoken=$(wget -q -O - --no-check-certificate --save-cookies=/tmp/converter-cookies.txt \
    #              --post-data "action=query&prop=info|revisions&intoken=edit&titles=Main%20Page&format=json" \
    #              $_mediawiki)
    # echo $edittoken
    # token=$(echo $edittoken | sed -e 's/.*edittoken.:.\([^\"]*\)...\".*/\1/')
    # token="$token""%2B%5C"
    # echo $token


    exit 0



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
            editpage=$(wget -q -O - --no-check-certificate --load-cookies=/tmp/converter-cookies.txt --post-data $cmd $_mediawiki)
            #echo $editpage
        fi
    done
fi