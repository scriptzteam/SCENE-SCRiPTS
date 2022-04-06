#! /bin/gawk -f
# LISTIDLE2 by tittof
#
# List users that haven't logged in for a given number of days
#
# This AWK Program is a clean room implementation of
# Jehsom's listidle v1.0 shell script.
#
# we want gawk so maybe
#
# sudo apt-get install gawk
# cp /usr/bin/gawk $GLROOT/bin/
#
# You can use it as a site_cmd this way:
# site_cmd LISTIDLE       EXEC             /bin/listidle.awk
# custom-listidle         1
#
BEGIN { 
#
# Where are the userfiles (chrooted)?
USERFILESPATH="/ftp-data/users/"
#
# you can modify the output of the program
#
# Do not show Users in the following groups (space seperated)
# Example BG="HiDDENGROUP ANOTHERHiDDENGROUP"
#
BG=""
#
# Do not show Users with following usernames (space seperated) 
# Example UB="sitebot default.user"
#
UB="default.user sitebot"
#
# Do not show Users with following flags (NO SEPERATION)
# Example BF="16"
#
BF="6"
#
# DO NOT EDIT BELOW THIS LINE!
#
#
# Save the DAYS Variable from getting overwritten
if ( ARGC == 2 ) DAYS=ARGV[1];
 else {
	if ( ARGC == 1 ) {
		DAYS=0;
		show_error("No Parameter? Assuming 0! ");
	}
	 else {
		show_error("Only one parameter please!");
		exit 0;
	}
}
# DAYS has to be positive numeric up to 10000
if ( DAYS ~ /^[0-9]+$/ ) {
	if ( DAYS > 10000 ) DAYS=0
} else {
	show_error("Give a valid number!      "); 
	exit 0;
}
#
# retrieve the list of files we want to process
#
OLDRS=RS
RS = "/"
cmd = "cd \""USERFILESPATH"\" && printf '%s/' *"
while (cmd | getline > 0) if ($0) files[n++] = $0
close(cmd)
i=1
for (f in files) {
	#printf(USERFILESPATH"%s\n", files[f]);
	ARGV[i]=sprintf(USERFILESPATH"%s", files[f]);
	i++
}
ARGC=i;
RS=OLDRS
#
# Now we have all the filenames
#
split(BG,BGA," ");
split(UB,UBA," ");
split(BF,BFA,"");
B=0;
IDLE=0;
BN="";
print "USER@GROUP DAYS"

}

function show_error(error_text) {
        print ".-=--------------------------------------------=-."
        print "| "error_text"                     |"
        print "|                                                |"
        print "| site listidle [days of idle]                   |"
        print "| where [days of idle] is 0..10000               |"
        print ".-=--------------------------------------------=-."
}

$1 ~ "^TIME$|^GROUP$|^FLAGS$" {

	if ($1=="FLAGS") {
		for ( FLAGSB in BFA ) {
			if (index($2,BFA[FLAGSB]) !=0) nextfile;
		}
	}

        if ($1=="TIME") {

                # Show Users that are not BANNED from showing
                # and have not logged in since DAYS

		if (BN != "") {
			for ( USERB in UBA ) {
				if (UBA[USERB] == BN) {
					B=1;
				}
			}
		}

                if (B==0 && BN != "" && IDLE >= DAYS) {
                        GL != "" ? BNGL=BN"@"GL : BNGL=BN;
                        printf BNGL" "IDLE"\n"
                }
                
                # extract basename of FILENAME and store that to BN
                BN=FILENAME;
                sub(/^.*\//, "", BN);
                
                # determine idle days of user
                IDLE=int((strftime("%s") - $3 )/86400);
                                
                # init variables to default values
                GL="";
                B=0;
        }

        if ($1=="GROUP") {
                for (BGROUP in BGA) {
                        if (BGA[BGROUP] == $2) {
                                B=1;
                                break;
                        }                                                         
                }
                GL=="" ? GL=$2 : GL=GL","$2;
        }                                                                         
}
