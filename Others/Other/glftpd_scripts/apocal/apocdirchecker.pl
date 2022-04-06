#!/bin/perl -W
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse glFTPd Dupechecker for Directories script [PERL] v1.0
#
# To use this script, add to glftpd.conf:
# pre_dir_check  /bin/apocdirchecker.pl
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

# Check to see if we can read from dupelog
if ( ! -r "$DUPELOGDIR/$DUPELOGFILE" ) {
	log_proc("1","Unable to read from the dupelog");
}

# This is the main routine

# Get the argument
my $dirname;

# If no arguments specified, print error
if ( $#ARGV == -1 ) {
	log_proc("1","Did not receive any arguments");
} else {
	$dirname = $ARGV[0];
	chomp $dirname;

	# Make sure we can't be h4x0r3d
	if ( "$dirname" !~ /^[[:alnum:][:blank:]\.\-\_]+$/ ) {
		$dirname = quotemeta($dirname);
		log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to hack us with \"$dirname\"");
		error_proc("Sorry, invalid directory name");
	}
}

# Check for llama CD1, cD1 in same dir
if ( opendir(DIRSTRUCT, $ARGV[1]) ) {
	foreach my $dirstruct ( readdir( DIRSTRUCT ) ) {
		if ( $dirstruct =~ /$dirname/i ) {
			log_proc("2","CaPs DUPE: $ENV{USER}\@$ENV{GROUP} tried to create directory \"$dirname\" in \"$ARGV[1]\"");
			error_proc("A directory with the same name already exists in \"$ARGV[1]\"");
		}
	}
} else {
	error_proc("Unable to verify directory structure");
}

# If the directory request is a common directory, allow it
if ( "$dirname" =~ /^(cd|dis[ck])[-_]?([0-9]{1,2}|one|two|three|four|five|six|seven|eight|nine|ten)|sample|stats|vobsub|oggdec|test$/i ) {
	accept_proc();
}

# Open up the dupelog
open( DUPELOG, "$DUPELOGDIR/$DUPELOGFILE" ) || log_proc("1","Unable to open the dupelog");

# This is the routine that searches through the dupelog for the requested directory
my $success = "0";
my @hit;
my $string;
while( $string = <DUPELOG> ) {
	if ( "$string" =~ /$dirname/i ) {
		if ( "$success" < "1" ) {
			@hit = split( /\s+/, $string );
			$hit[0] =~ /(..)(..)(..)/;
			$hit[0] = join( "/", $1, $2, $3 );
		}
		$success++;
	}
}

# Close the filehandle
close(DUPELOG);

# Do the final preparation
if ( $success == "0" ) {
	accept_proc();
} else {
	log_proc("2","$ENV{USER}\@$ENV{GROUP} tried to create a directory named \"$dirname\" \[ created on $hit[0] \] \- failure");
	error_proc("Sorry, the directory \"$dirname\" already exists \- created on $hit[0]");
}

# Procedures go here

# This is the procedure that displays successful creation of directory
sub accept_proc {
	print "Directory \"$dirname\" passed the dupe test\n";
	exit 0;
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
			print LOG "\( $timestamp \| $date \| DirChecker \) ERROR \- $string\n";
			close(LOG);
			error_proc("$string");
		} else {
			print LOG "\( $timestamp \| $date \| DirChecker \) INFORMATION \- $string\n";
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