<?php
##################
#
# TV Series sorter
# since it's an php script, it requires php, not in jail but installed on the system.
# read the settings carefully and run it in DEBUG-mode first!
# if you find bugs etc open an issue or cry in #glhelp
# ofc this will work with other languages aswell, but then you got to know your release-rules and write regex'es for it
# now have fun ;)
#
# made by fawkes
##################

#
# Settings
#
# DEBUG = TRUE --> DO NOTHING
$DEBUG = FALSE;
# DEBUG_DIR_COUNT --> DEBUG it for X directories
# for 1000 dirs this would be an immense output so thats an easy way to shape it :)
# NOTE: we already set an offset of 2 for ".." and "."
$DEBUG_DIR_COUNT = 300;

# Directories
# Define site rootdir
$DIR['ROOT']		=	"/jail/glftpd/site/";
# Define your incoming directory - if you have more than one dir, you may generate multiple sorter.php
$DIR['INCOMING']	=	$DIR['ROOT'] . "iNCOMiNG/";
# Sorted directories - they have to have the same key-name ( DE-HD, DE-SD ) like the regex for them
$DIR['RET-DE-HD']	= 	$DIR['ROOT'] . "RETAiL-HD/";
$DIR['RET-DE-SD']	=	$DIR['ROOT'] . "RETAiL-SD/";
$DIR['DE-HD']		=	$DIR['ROOT'] . "SORTED-HD/";
$DIR['DE-SD']		=	$DIR['ROOT'] . "SORTED-SD/";
#$DIR['RET-EN-HD']	=	$DIR['ROOT'] . "RETAiL-HD-EN/";
#$DIR['RET-EN-SD']	=	$DIR['ROOT'] . "RETAiL-SD-EN/";
$DIR['EN-HD']		=	$DIR['ROOT'] . "SORTED-HD-EN/";
$DIR['EN-SD']		=	$DIR['ROOT'] . "SORTED-SD-EN/";

# Regex for release names. The most specific regex at first. The least specific at last
# Regex should include the definition for season and episodes and ofc for the title
# Yes, they all are not made with /i aka ignore case, but this gives us more flexibility
# German
$REGEX['RET-DE-HD']	=	
"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+[Gg][Ee][Rr][Mm][Aa][Nn]\.(UNCUT\.)?(([DdAaFf][LlCcTtSs][3Ss]{0,1}\.){0,4}?)[17][02][80][0]{0,1}[pP]\.[Bb][Ll][Uu][Rr][Aa][Yy](\.[Ff][Ii][Xx])?(\.[Rr][Ee][Pp][Aa][Cc][Kk])?(\.[Rr][Ee][Aa][Dd]\.[Nn][Ff][Oo])?(\.[Ii][Nn][Tt][Ee][Rr][Nn][Aa][Ll])?\.([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?[Xx]264(\.[Rr][Ee][Pp][Aa][Cc][Kk])?\-.+/";
$REGEX['DE-HD'] 	=	"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+[Gg][Ee][Rr][Mm][Aa][Nn].+[17][02][80][0]{0,1}[pP].+\.([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?x264(\.[Rr][Ee][Pp][Aa][Cc][Kk])?\-.+/";
$REGEX['RET-DE-SD']	=	
"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+[Gg][Ee][Rr][Mm][Aa][Nn]\.(UNCUT\.)?([0-9]{4}\.)?([Aa][Nn][Ii][Mm][Ee]\.)?(([WwFfDd][SsLl]\.){0,2}?)([Rr][Ee][Pp][Aa][Cc][Kk]\.)?[BbDd][DdVv][Dd]?[Rr][Ii][Pp]\.([Rr][Ee][Aa][Dd]\.[Nn][Ff][Oo]\.)?([Pp][Rr][Oo][Pp][Ee][Rr](\.|\-))?([Rr][Ee][Pp][Aa][Cc][Kk]\.)?([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?[Xx][Vv2][Ii6][Dd4](\.[Ii][Nn][Tt][Ee][Rr][Nn][Aa][Ll])?(\.[Rr][Ee][RrPp][IiAa][PpCc][Kk]?)?(\.[Pp][Rr][Oo][Pp][Ee][Rr])?\-.+/";
$REGEX['DE-SD'] 	=	
"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+[Gg][Ee][Rr][Mm][Aa][Nn].+\.([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?[Xx][Vv2][Ii6][Dd4](\.[Rr][Ee][Pp][Aa][Cc][Kk])?(\.[Rr][Ee][Pp][Aa][Cc][Kk])?(\.[Rr][Ee][Aa][Dd]\.[Nn][Ff][Oo])?\-.+/";
# English
$REGEX['EN-HD'] 	=	"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+[17][02][80][0]{0,1}[pP].+\.([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?[Xx]264(\.[Rr][Ee][Pp][Aa][Cc][Kk])?\-.+/";
$REGEX['EN-SD'] 	=	"/(?P<title>.+)\.((?P<season>S\d{1,2})?)E(?P<episode>\d{1,3}).+\.([Rr][Ee][Aa][Dd][Nn][Ff][Oo]\.)?[Xx][Vv2][Ii6][Dd4](\.[Rr][Ee][Pp][Aa][Cc][Kk])?\-.+/";


# Filter for symlinks (NoNFO, incomplete, NoSample, etc.)
$FILTER['REGEX'][]	=	"/\(no\-nfo\)\-.+/";
$FILTER['REGEX'][]	=	"/\(incomplete\)\-.+/";
$FILTER['REGEX'][]	=	"/.+[Ss][Uu][Bb][Bb][Ee][Dd].+/";
# Static filter for files and directory names
$FILTER['STATIC']	=	array(".", "..", ".releaseinfo");

# Complete regex - regex for the directory inside the release which tells if its finished, or not
$COMPLETE			= 	"/\[(?P<SN>\w+)\].+\-.+\( (?P<size>\w+)M (?P<files>\w+)F.+\-.+COMPLETE.+\).+\-.+\[.+\]/";

# Fix regex - regex for release-fix directories aka sub, nfo and dir fix
$RELEASEFIX			=	"/.+\.[SsDdNn][UuIiFf][BbRrOo][Ff][Ii][Xx].+/";

# Use title subdir like sorted/some.nice.series/* ?
$SUBDIR['TITLE']	= TRUE;
# Use season subdir like sorted/some.nice.series/S01/some.nice.series.release.x264-group ?
# Depends on $SUBDIR['TITLE'] already
$SUBDIR['SEASON']	= TRUE;


# The time to wait after finishing the upload - if somebody wants to trade from that dir
# Time in Minutes - default 5 Minutes
$WAITTIME		= 5;

$OWNERUID=0;
$OWNERGID=0;
$FILERIGHTS=777;

### End of Settings ###

$STATS['RET-DE-HD'] = 0;
$STATS['RET-DE-SD'] = 0;
$STATS['DE-HD'] = 0;
$STATS['DE-SD'] = 0;
$STATS['EN-HD'] = 0;
$STATS['EN-SD'] = 0;

$DIR_COUNT = -2;
# Open directory -- incoming
if ( $HANDLE['INCOMING'] = opendir( $DIR['INCOMING'] ) ) {
	# Read files/directories from incoming
	while( ( $FILE['INCOMING'] = readdir( $HANDLE['INCOMING'] ) ) != FALSE ) {
		$DIR_COUNT++;
		# Check for static filters
		debmsg ( "Found Dir " . $FILE['INCOMING'] );
		if ( ! in_array( $FILE['INCOMING'], $FILTER['STATIC'] ) ) {
			debmsg ( "	Passed Static Filter" );
			# Loop trough regex filters
			foreach ( $FILTER['REGEX'] as $PATTERN ) {
				# If filter applies, continue with next $FILE
				#echo $FILE['INCOMING'];
				if ( preg_match( $PATTERN, $FILE['INCOMING'] ) ) {
					debmsg ( "	matched " . $PATTERN . " Continueing" );
					continue 2;
				}
			}
			debmsg ( "	Passed Regex Filter" );
			$DIR['CURRENT_RELEASE'] = $DIR['INCOMING'] . $FILE['INCOMING'];
			# If release is not a fix go on.
			if ( !preg_match( $RELEASEFIX, $FILE['INCOMING'] ) ) {
				debmsg ( "	Passed Releasefix Filter " );
				# Open directory -- current release
				if ( $HANDLE['RELEASE'] = opendir( $DIR['CURRENT_RELEASE'] ) ) {
					# Read files/directories from current release
					while ( ( $FILE['RELEASE'] = readdir ( $HANDLE['RELEASE'] ) ) != FALSE ) {
						# Check if it matches the complete-regex
						if( ! in_array($FILE['RELEASE'], $FILTER['STATIC'])) {
							# Check if WAITTIME is over already
							$FinishTime = filemtime($DIR['CURRENT_RELEASE']."/".$FILE['RELEASE']);
							$Now = time();
							if ( preg_match( $COMPLETE, $FILE['RELEASE'] ) && ($FinishTime + ($WAITTIME*60)) < $Now) {
								debmsg ( "	Found Complete DIR... trying to move" );
								# try to move it
								try_move( $FILE['INCOMING'] );
							}
						}
					}
					closedir( $HANDLE['RELEASE'] );
				}
			}
			else {
				debmsg ( "	Release fix detected, continueing" );
			}
		}
		else {
			debmsg ( "	Failed @ Static Filter" );
		}
		# If debug is activated, only loop through $DEBUG_DIR_COUNT directories
		if ( $DEBUG and $DIR_COUNT == $DEBUG_DIR_COUNT ) {
			exit;
		}
	}
	closedir( $HANDLE['INCOMING'] );
}

function try_move( $RELEASE_DIR ) {
	# Get settings
	global $DEBUG, $REGEX, $DIR, $SUBDIR, $STATS, $OWNERGID, $OWNERUID, $FILERIGHTS;
	# Test for each regex
	foreach ( $REGEX as $TYPE => $PATTERN ) {
		# Match current regex
		if ( preg_match ( $PATTERN, $RELEASE_DIR, $MATCH ) ) {
			debmsg ( "	Found Release Type(" . $TYPE . ")" );
			# Get target-directory to the matching regex
			$TARGET_DIR = $DIR[$TYPE];
			$STATS[$TYPE]++;
			# Set full source-dir
			$SOURCE_DIR = $DIR['INCOMING'] . $RELEASE_DIR;
			# If title sub-directory is activated and a title is known ....
			if ( $SUBDIR['TITLE'] and $MATCH['title'] != "" ) {
				debmsg ( "	Subdir for Title(" . $MATCH['title'] . ") is set" );
				# Add that to the target-directory
				$TARGET_DIR = $TARGET_DIR . $MATCH['title'] . "/";
				$CHMOD_ROOT = $TARGET_DIR;
				# If season sub-directory is activated and the season number is known ....
				if ( $SUBDIR['SEASON'] and $MATCH['season'] != "" ) {
					debmsg ( "	Subdir for Season(" . $MATCH['season'] . ") is set" );
					# Add that to the target-directory
					$TARGET_DIR = $TARGET_DIR . $MATCH['season'] . "/";
				}
			}
			# If debug is set, only echo info, !!!!!do nothing!!!!!
			if ( $DEBUG ) {
				debmsg ( "	would move " . $SOURCE_DIR . " to " . $TARGET_DIR );
			}
			else {
				@mkdir( $TARGET_DIR, $FILERIGHTS, TRUE );
				shell_exec ( "mv " . $SOURCE_DIR . " " . $TARGET_DIR );
				shell_exec ( "chmod -R " . $FILERIGHTS . " " . $CHMOD_ROOT );
				shell_exec ( "chown -R " . $OWNERUID. "." . $OWNERGID . " " . $CHMOD_ROOT );

			}
			return;
		}
	}
}

function debmsg ( $msg  ) {
	global $DEBUG;
	if ( $DEBUG ) {
		echo $msg."\r\n";
	}
}




?>
