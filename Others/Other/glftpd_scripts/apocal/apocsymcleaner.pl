#!/usr/bin/perl -W
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse SymLink Cleaner script [PERL] v1.0
#
# Required libraries in /lib:
# libcrypt.so.1 libdl.so.2 libm.so.6 libc.so.6 ld-linux.so.2
# There might be more, just use the handy tool "ldd" :)
#
# Installation:
#
# Chmod it +x
# Add it to crontab daily

# Where do we scan for symlinks?
# DO NOT INCLUDE A TRAILING BACKSLASH
$ROOT = "/glftpd/site";

# Do you want to use file-based logging?
# y for yes, n for no
$USELOG = "y";

# Your log directory
# Checked only if $USELOG is y
$LOGDIR = "/glftpd/ftp-data/logs";

# Your Logname
# Checked only if $USELOG is y
$LOGNAME = "apocscripts.log";

# DO not edit below unless you know what you're doing

# Setup our output flushing [ Auto-Flush ]
$| = 1;

# Check to see if we can write to the logfile
if ( "$USELOG" eq "y" ) {
	if ( ! -w "$LOGDIR" ) {
		error_proc("Unable to write to log dir or it is nonexistant");
	} else {
		if ( ! -w "$LOGDIR/$LOGNAME" ) {
			if ( ! -e "$LOGDIR/$LOGNAME" ) {
				open(LOG, ">$LOGDIR/$LOGNAME") || error_proc("Unable to create the log file");
				close LOG;
				chmod 0666, '$LOGDIR/$LOGNAME';
				chown "0", "0", "$LOGDIR/$LOGNAME";
				log_proc("2","The log $LOGDIR/$LOGNAME dosent exist, creating it");
			}
		}
	}
}

# Sanity check of $ROOT variable
if ( $ROOT =~ /\/$/ ) {
	log_proc("1","Error in configuration - \$ROOT cannot have a trailing backslash!");
}

# Variable Setup
my $totallinks = "0";
my $badlinks = "0";
my $info;
my $tmpdirpath;

# Execute the recursivelist function
RecurList( $ROOT );

# Print some statistic information
if ( $USELOG eq "y" ) {
	if ( $badlinks > 0 ) {
		log_proc("2","Found $totallinks Total SymLink\(s\), $badlinks BAD - REMOVED");
	} else {
		log_proc("2","Found $totallinks Total SymLink\(s\) - ALL GOOD!");
	}
} else {
	if ( $badlinks > 0 ) {
		print "Found $totallinks Total SymLink\(s\), $badlinks BAD - REMOVED\n";
	} else {
		print "Found $totallinks Total SymLink\(s\) - ALL GOOD!\n";
	}
}
exit 0;

# This is the function that recursively lists a directory
sub RecurList {
	my $dirpath = shift;

	# Fetch the directory info
	if ( ! opendir( DIRECTORY, $dirpath ) ) {
		log_proc("1","Couldnt open $dirpath while searching for symlinks.");
	}
	my @dirlist = readdir( DIRECTORY );
	closedir( DIRECTORY );

	# Remove the . and .. from the list
	shift( @dirlist ); shift( @dirlist );

	# Loop over the contents of the directory looking for match
	foreach my $name ( @dirlist ) {
		# Search for symlinks
		if ( -l "$dirpath/$name" ) {
			# Increment the symlink counter
			$totallinks++;

			# This is a symlink, check to see if it is valid
			$info = readlink( "$dirpath/$name" );
			if ( ! $info ) {
				# Unable to read info, delete this symlink
				remove_symlink( "$dirpath/$name" );
			} else {
				# Check to see if this is a lam0 rootdir link
				if ( $info =~ /^\// ) {
					# This is, adjust our dirpaths accordingly
					$ROOT =~ /^(.*)\//;
					$tmpdirpath = $1;
				} else {
					# Do some swapping around [ remove ../ entries ]
					$tmpdirpath = $dirpath;
					while ( $info =~ /^\.\.\/(.*)/ ) {
						$info = $1;
						$tmpdirpath =~ /^(.*)\//;
						$tmpdirpath = "$1";
					}
				}

				# Check if the file/dir it points to actually exists
				if ( ! -e "$tmpdirpath/$info" ) {
					# Delete this symlink
					remove_symlink( "$dirpath/$name" );
				}
			}
		} else {
			# Recurse over this directory?
			if ( -d "$dirpath/$name" ) {
				RecurList( "$dirpath/$name" );
			}
		}
	}
}

# This is the procedure that removes a bad symlink
sub remove_symlink {
	my $name = shift;
	# Increment the bad symlink counter
	$badlinks++;

	# Delete this symlink
	if ( ! unlink( "$name" ) ) {
		log_proc("1","Unable to remove symlink: $name");
	}
}

# This is the procedure that prints out the error and dies
sub error_proc {
	my $errorstring = shift;
	print "$errorstring\n";
	exit 2;
}

# This is the procedure that logs all errors/warnings/information to a logfile
# Code 1 = ERROR
# Code 2 = INFORMATION
sub log_proc {
	my $errcode = shift;
	my $string = shift;

	if ( "$USELOG" eq "y" ) {
		# Get the current time and month/day/year
		my ( $sec, $min, $hour, $day, $month, $year ) = localtime( time() );
		my $ampm = "AM";

		# Format the time
		if ( "$sec" < "10" ) {
			$sec = "0" . $sec;
		}
		if ( "$min" < "10" ) {
			$min = "0" . $min;
		}
		if ( "$hour" < "10" ) {
			$hour = "0" . $hour;
		} elsif ( "$hour" == "12" ) {
			$ampm = "PM";
		} elsif ( "$hour" > "12" ) {
			$hour -= 12;
			$ampm = "PM";
			if ( "$hour" < "10" ) {
				$hour = "0" . $hour;
			}
		}
		if ( "$day" < "10" ) {
			$day = "0" . $day;
		}
		$month++;
		$month = sprintf("%02d",$month);
		$year += 1900;

		# Create the final date/time string
		my $timestamp = "$hour\:$min.$sec $ampm";
		my $date = "$month/$day/$year";

		open( LOG, ">>$LOGDIR/$LOGNAME" ) || error_proc("Unable to open the log file $LOGDIR/$LOGNAME");

		# Print out the final strings
		if ( "$errcode" == "1" ) {
			print LOG "\( $timestamp \| $date \| SymCleaner \) ERROR \- $string\n";
			close(LOG);
			error_proc("$string");
		} else {
			print LOG "\( $timestamp \| $date \| SymCleaner \) INFORMATION \- $string\n";
			close(LOG);
			return 0;
		}
	} else {
		if ( "$errcode" == "1" ) {
			error_proc("$string");
		} else {
			return 0;
		}
	}
}