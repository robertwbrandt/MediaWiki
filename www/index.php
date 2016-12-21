<?php
$templateDir    = "mediawiki";
$localSettings  = "LocalSettings.php";
?>

<html dir="ltr" class="client-js" lang="en"><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<meta charset="UTF-8">
<title>OPW - Wiki Central</title>
<link rel="stylesheet" href="/load.css">
<link rel="shortcut icon" href="/favicon.ico">
<link rel="copyright" href="https://www.gnu.org/copyleft/fdl.html">
</head>
<body class="mediawiki ltr sitedir-ltr ns-0 ns-subject page-Main_Page rootpage-Main_Page skin-vector action-view">

<div id="mw-page-base" class="noprint"></div>
<div id="mw-head-base" class="noprint"></div>

<div id="content" class="mw-body" role="main">
	<a id="top"></a>

	<div class="mw-indicators"></div>

	<h1 id="firstHeading" class="firstHeading" lang="en">The Office of Public Works - Wiki Central</h1>
	<div id="bodyContent" class="mw-body-content">
		<div id="siteSub">From Office of Public Works</div>
		<div id="contentSub"></div>
												
		<div id="mw-content-text" dir="ltr" class="mw-content-ltr" lang="en">
			<p>Consult the <a rel="nofollow" class="external text" href="https://meta.wikimedia.org/wiki/Help:Contents">User's Guide</a> for information on using the wiki software.</p>			<h2><span class="mw-headline" id="Getting_started">Available Wikis</span></h2>
			<ul>
<?php
if ($handle = opendir('.')) {
    $blacklist = array('.', '..', '.snapshot',$templateDir);
    while (false !== ($dir = readdir($handle))) {
        if (!in_array($dir, $blacklist) and is_dir($dir) and file_exists($file = ($dir . DIRECTORY_SEPARATOR . $localSettings))) {
			$lines = file($file);
			$count = count($lines) - 1;
			$i = 0;
			$title = '';
			while ($i < $count)
				if ( substr( trim($lines[++$i]), 0, 11 ) === '$wgSitename' ) {
					$title = trim(substr( trim($lines[$i]), 11 ), " \t\n\r\0\x0B=;\"");
					break;
				}
			if (strlen($title) > 1)
	            echo "<li><a href=\"/$dir\" title=\"$title\">$title</a></li>\n";
       }
    }
    closedir($handle);
}
?>
			</ul>
			<br/>
			<ul><li><small><a href="/<?=$templateDir?>" title="Template">Template</a></small></li></ul>
		</div>
	</div>
</div>

<div id="mw-navigation">
	<h2>Navigation menu</h2>
	<div id="mw-head">
		<div id="p-personal" role="navigation" class="" aria-labelledby="p-personal-label"></div>
		<div id="left-navigation">
			<div id="p-namespaces" role="navigation" class="vectorTabs" aria-labelledby="p-namespaces-label">
				<h3 id="p-namespaces-label">Namespaces</h3>
				<ul><li id="ca-nstab-main" class="selected"><span><a href="" title="View the content page [Alt+Shift+c]" accesskey="c">Main page</a></span></li></ul>
			</div>
			<div id="p-variants" role="navigation" class="vectorMenu emptyPortlet" aria-labelledby="p-variants-label">
				<h3 id="p-variants-label" tabindex="0"><span>Variants</span><a href="#" tabindex="-1"></a></h3>
				<div class="menu">
					<ul></ul>
				</div>
			</div>
		</div>
		<div id="right-navigation"></div>
	</div>
	<div id="mw-panel">
		<div id="p-logo" role="banner"><a class="mw-wiki-logo" href="/<?=$templateDir?>/index.php/Main_Page" title="Visit the main page"></a></div>
		<div class="portal" role="navigation" id="p-navigation" aria-labelledby="p-navigation-label">
			<h3 id="p-navigation-label">Navigation</h3>
		</div>
	</div>
</div>

<div id="footer" role="contentinfo">
	<ul id="footer-info">
		<li id="footer-info-copyright">Content is available under <a class="external" rel="nofollow" href="https://www.gnu.org/copyleft/fdl.html">GNU Free Documentation License 1.3 or later</a> unless otherwise noted.</li>
	</ul>
	<ul id="footer-places">
		<li id="footer-places-privacy"><a href="/<?=$templateDir?>/index.php/Office_of_Public_Works:Privacy_policy" title="Office of Public Works:Privacy policy">Privacy policy</a></li>
		<li id="footer-places-about"><a href="/<?=$templateDir?>/index.php/Office_of_Public_Works:About" title="Office of Public Works:About">About Office of Public Works</a></li>
		<li id="footer-places-disclaimer"><a href="/<?=$templateDir?>/index.php/Office_of_Public_Works:General_disclaimer" title="Office of Public Works:General disclaimer">Disclaimers</a></li>
	</ul>
	<ul id="footer-icons" class="noprint">
		<li id="footer-copyrightico"><a href="https://www.gnu.org/copyleft/fdl.html"><img src="/<?=$templateDir?>/resources/assets/licenses/gnu-fdl.png" alt="GNU Free Documentation License 1.3 or later" width="88" height="31"></a></li>
		<li id="footer-poweredbyico"><a href="https://www.mediawiki.org/"><img src="/<?=$templateDir?>/resources/assets/poweredby_mediawiki_88x31.png" alt="Powered by MediaWiki" srcset="/<?=$templateDir?>/resources/assets/poweredby_mediawiki_132x47.png 1.5x, /<?=$templateDir?>/resources/assets/poweredby_mediawiki_176x62.png 2x" width="88" height="31"></a></li>
	</ul>
	<div style="clear:both"></div>
</div>

</body></html>
