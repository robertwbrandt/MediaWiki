#!/bin/bash

DocumentRoot="/var/www/html"
owner="www-data:www-data"
templatedb="mediawiki"
template="/var/www/html/$templatedb"

wgDBserver=$( sed -n 's|^\$wgDBserver\s*=\s*"\(.*\)";.*|\1|p' "$template/LocalSettings.php" )
wgDBuser=$( sed -n 's|^\$wgDBuser\s*=\s*"\(.*\)";.*|\1|p' "$template/LocalSettings.php" )
wgDBpassword=$( sed -n 's|^\$wgDBpassword\s*=\s*"\(.*\)";.*|\1|p' "$template/LocalSettings.php" )

echo -e "\nThis utility will allow you to clone the Template Wiki($templatedb) to another Wiki:"
echo -e "Wiki shortname can only contain alphanumeric characheters and underscores."
read -p 'Wiki Shortname: ' shortname
shortname=$( echo ${shortname//[[:blank:]]/} | tr '[:upper:]' '[:lower:]' | sed 's|[^0-9a-z]|_|g' )
read -p 'Wiki Title: ' title

echo -e "\nAbout to create a wiki with the following attributes:"
echo -e "        Title: $title"
echo -e "Database Name: $shortname"
echo -e "Document Root: $DocumentRoot/$shortname\n"
read -p 'Do you with to continue? (Y/N) ' answer
answer=$( echo ${answer::1} | tr '[:upper:]' '[:lower:]' )

if [ "$answer" == "y" ]; then

	wiki="/var/www/html/$shortname"

	if [ -d "$wiki" ]; then
		echo "The directory ($wiki) already exists!" >&2
		exit 1
	fi

	echo -e "[client]" > /tmp/clonewiki.cnf
	echo -e "host     = $wgDBserver" >> /tmp/clonewiki.cnf
	echo -e "user     = $wgDBuser" >> /tmp/clonewiki.cnf
	echo -e "password = $wgDBpassword" >> /tmp/clonewiki.cnf

	if mysql --defaults-file=/tmp/clonewiki.cnf -e "SHOW DATABASES;" | grep "$shortname"
	then
		echo "The database ($shortname) already exists!" >&2
		exit 2
	fi

	echo -e "\nCreating the directory ($wiki)"
	cp -a "$template" "$wiki"

	# mkdir -p "$wiki"
	# ln -s $template/* $wiki/
	# rm "$wiki/LocalSettings.php"
	# cp -a "$template/LocalSettings.php" "$wiki/LocalSettings.php"
	# rm "$wiki/images"
	# cp -a "$template/images" "$wiki/images"

	# rm "$wiki/includes"
	# mkdir -p "$wiki/includes"
	# ln -s $template/includes/* $wiki/includes/
	# rm "$wiki/includes/config"
	# cp -a "$template/includes/config" "$wiki/includes/config"
	# # cp -a "$template/includes" "$wiki/includes"

	echo -e "\nModifying $wiki/LocalSettings.php file"
	sed -i "s|\$wgScriptPath\s*=\s*\".*\";.*|\$wgScriptPath = \"/$shortname\";|" "$wiki/LocalSettings.php"
	
	sed -i "s|\$wgSitename\s*=\s*\".*\";.*|\$wgSitename = \"$title\";|" "$wiki/LocalSettings.php"
	title=$( echo $title | tr ' ' '_' )
	sed -i "s|\$wgMetaNamespace\s*=\s*\".*\";.*|\$wgMetaNamespace = \"$title\";|" "$wiki/LocalSettings.php"

	sed -i "s|\$wgDBname\s*=\s*\".*\";.*|\$wgDBname = \"$shortname\";|" "$wiki/LocalSettings.php"
	sed -i "s|\$wgDebugLogFile\s*=\s*\".*\";.*|\$wgDebugLogFile = \"/var/log/apache2/${shortname}.log\";|" "$wiki/LocalSettings.php"

	echo -e "\nCreating the Database ($shortname) on $wgDBserver"
	mysqldbcopy --source=$wgDBuser:$wgDBpassword@$wgDBserver --destination=$wgDBuser:$wgDBpassword@$wgDBserver $templatedb:$shortname
	mysql --defaults-file=/tmp/clonewiki.cnf -e "SHOW DATABASES;"
	rm /tmp/clonewiki.cnf

	echo -e "\nChanging the owner of $wiki back to $owner"
	chown -R $owner "$wiki"

	echo -e "\nRunning MediaWiki update script"

	pushd "$wiki"
	php maintenance/update.php
	popd
fi

exit 0
