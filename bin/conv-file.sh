#!/bin/bash
# https://www.mediawiki.org/wiki/Convert_Socialtextwiki_to_Mediawiki#Copy_the_original_files_to_the_new_host

find plugin -path 'plugin/zsi*/attachments/*.txt' | sort |
while read f; do
    if [[ "`grep -q 'Control: Deleted' $f; echo $?`" != "0" ]]; then
        d=${f/.txt}
        filenameNew=$(egrep '^Subject:' $f | sed -e 's/Subject: \(.*\)/\1/')
        filenameOrig=$(ls -1 $d | head -n 1)
        version=$(egrep '^Date: ' $f | sed -e 's/Date: \(.*\)/\1/')
        #echo "---------------------------"
        #echo $filenameOrig
        #echo "$filenameNew"
        rm upload/*
        cp $d/$filenameOrig "upload/$filenameNew"
        # prepare upload
        echo -e ">$filenameNew\n$filenameNew\n$version\n(autoconverted from socialtext wiki)" > upload/files.txt
        # upload
        ./upload.pl upload
    fi
done

