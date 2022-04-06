#!/bin/perl -W
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse glFTPd SITE UNDIRDUPE script [PERL] v1.0
#
# To use this script, add to glftpd.conf:
# site_cmd UNDIRDUPE     EXEC    /bin/apocundirdupe.pl
# custom-undirdupe       *
# Replace * with the desired glftpd option(s) (read glftpd.docs)
#
# Required libraries in /glftpd/lib:
# libcrypt.so.1 libdl.so.2 libm.so.6 libc.so.6 ld-linux.so.2
# There might be more, just use the handy tool "ldd" :)

# Where is the dupelog?
# (Relative to glftpd path)
# You probably don't need to change this...
# DO NOT INCLUDE A TRAILING BACKSLASH
$DUPELOGDIR = "/ftp-data/logs";

# What is the name of your dupelog?
# (Relative to glftpd path)
# You probably don't need to change this...
$DUPELOGFILE = "dupelog";

# Do you want to use file-based logging?
# y for yes, n for no
$USELOG = "y";

# Your log directory
# (Relative to glftpd path)
# Checked only if $USELOG is y
# DO NOT INCLUDE A TRAILING BACKSLASH
$LOGDIR = "/ftp-data/logs";

# Your Logname
# Checked only if $USELOG is y
$LOGNAME = "apocscripts.log";

# Do you want the advanced "log" cleaning feature enabled?
# It will auto-wipe "CDx, SAMPLE, COVER(S), VOBSUB, OGGDEC, TEST" from dupelog
# y for yes, n for no
$CLEANLOG = "y";

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

# Sanity check of $LOGDIR variable
if ( $LOGDIR =~ /\/$/ ) {
	log_proc("1","Error in configuration - \$LOGDIR cannot have a trailing backslash!");
}

# Sanity check of $DUPELOGDIR variable
if ( $DUPELOGDIR =~ /\/$/ ) {
	log_proc("1","Error in configuration - \$DUPELOGDIR cannot have a trailing backslash!");
}

# Check to see if we can write to dupelog
if ( ! -w "$DUPELOGDIR/$DUPELOGFILE" ) {
	log_proc("1","Unable to write to the dupelog");
}

# Check to see if we can write to dupelog dir
if ( ! -w "$DUPELOGDIR" ) {
	log_proc("1","Unable to write to the dupelog dir");
}

# This is the main routine

# Get the argument
my $undirdupe;

# If no arguments specified, print usage
if ( $#ARGV == -1 ) {
	error_proc("Usage\: SITE UNDIRDUPE dirname");
} else {
	$undirdupe = join(" ", @ARGV[ 0 .. $#ARGV ] );
	chomp $undirdupe;

	# Make sure we can't be h4x0r3d
        if ( "$undirdupe" !~ /^[[:alnum:][:blank:]\.\-\_]+$/ ) {
        	$undirdupe = quotemeta($undirdupe);
        	log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to hack us with \"$undirdupe\"");
        	error_proc("Sorry, invalid directory name");
        }
}

# Open up the files
open(DUPELOG, "$DUPELOGDIR/$DUPELOGFILE") || log_proc("1","Unable to open the dupelog");
open(TEMPLOG, ">>$DUPELOGDIR/$DUPELOGFILE.tmp.$$") || log_proc("1","Unable to create the temporary dupelog");

# This is the routine that searches through the dupelog for the request
# If LOGCLEAN is enabled, will clean up the log automatically
my $success = "0";
my $cleanup = "0";
my $string;
if ( "$CLEANLOG" eq "n" ) {
	while( $string = <DUPELOG> ) {
		if ( "$string" !~ /^.......$undirdupe$/i ) {
			print TEMPLOG "$string";
		} else {
			$success++;
		}
	}
} else {
	while( $string = <DUPELOG> ) {
		if ( "$string" !~ /^.......$undirdupe$/i ) {
			if ( "$string" !~ /^.......(cd|dis[ck])[-_]?([0-9]{1,2}|one|two|three|four|five|six|seven|eight|nine|ten)|sample|stats|vobsub|oggdec|test|cover/i ) {
				print TEMPLOG "$string";
				$cleanup++;
			}
		} else {
			$success++;
		}
	}
}

# Close the filehandles
close(DUPELOG);
close(TEMPLOG);

# Do the final preparation
if ( "$success" == "0" && "$cleanup" == "0" ) {
	# Delete the temporary file
	unlink "$DUPELOGDIR/$DUPELOGFILE.tmp.$$";

	log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to undirdupe \"$undirdupe\" \- failed");
	error_proc("Sorry, couldnt UnDirDupe \"$undirdupe\"");
} elsif ( "$success" == "0" && "$cleanup" > "0" ) {
	# Move the temporary file to the original, overwriting it
	rename "$DUPELOGDIR/$DUPELOGFILE.tmp.$$", "$DUPELOGDIR/$DUPELOGFILE";
	chown 0, 0, "$DUPELOGDIR/$DUPELOGFILE";
	chmod 0666, "$DUPELOGDIR/$DUPELOGFILE";

	log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to undirdupe \"$undirdupe\" \- failed");
	error_proc("Sorry, couldnt UnDirDupe \"$undirdupe\"");
} elsif ( "$success" > "0" && "$cleanup" > "0" ) {
	# Move the temporary file to the original, overwriting it
	rename "$DUPELOGDIR/$DUPELOGFILE.tmp.$$", "$DUPELOGDIR/$DUPELOGFILE";
	chown 0, 0, "$DUPELOGDIR/$DUPELOGFILE";
	chmod 0666, "$DUPELOGDIR/$DUPELOGFILE";

	if ( "$success" > "1" ) {
		log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to undirdupe \"$undirdupe\" \[$success records\] \- successful");
		print "Directory \"$undirdupe\" \[$success records\] is now UnDirDuped\n";
	} elsif ( "$success" == "1" ) {
		log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to undirdupe \"$undirdupe\" \- successful");
		print "Directory \"$undirdupe\" is now UnDirDuped\n";
	}
	exit 0;
}

# Procedures go here

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
			print LOG "\( $timestamp \| $date \| UnDirDupe \) ERROR \- $string\n";
			close(LOG);
			error_proc("$string");
		} else {
			print LOG "\( $timestamp \| $date \| UnDirDupe \) INFORMATION \- $string\n";
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