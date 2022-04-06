#!/usr/bin/perl
##########################################################
# Script name: foo-pre configurator 0.01
# Author: [Jedi] (jedi_il@hotmail.com)
# Description:
# this prog is to help newbies to configure their pre.cfg (foo-pre's config files) and to help
# both newbies and non-newbies easyly add/delete new/old groups :)
# it got fairly simple interface, c0ns0le hehe, maybe on future versions ill add curses menus..
# Copyright: This program is under the The GNU General Public License (aka GNU GPL)
# URL: http://jedi.says.no/
###########################################################

$VER="0.01";


if (-f $ARGV[0]) { $path=$ARGV[0]; }
else {	
	do {
		print "Open pre.cfg file, enter path: ";
		$path=<STDIN>; chomp $path;
		if (!( -f $path)) { print "Not a valid file !\n"; }
	} until (-f $path);
}

&loadfile;

do {
system("clear");
print qq~
,--------------------------------------------------------,
| Welcome to foo-pre configurator by [Jedi]              |
+--------------------------------------------------------+
|               ..:: Main Menu ::..                      |
|       1 - Add Group           4 - Add Section          |
|       2 - Del Group           5 - Del Section          |
|       3 - List Groups         6 - List Sections        |
|       x - eXit                                         |
`-------------------------------------[ v$VER BETA ]-----'
 Loaded file [ $path ]
What will it be? ~;
$inkey=lc <STDIN>; chomp $inkey;
if ($inkey eq "1") { &addgroup; &loadfile; <STDIN>; }
elsif ($inkey eq "2") { &delgroup; &loadfile; <STDIN>; }
elsif ($inkey eq "3") { &listgroups; <STDIN>; }
elsif ($inkey eq "4") { &addsection; &loadfile; <STDIN>; }
elsif ($inkey eq "5") { &delsection; &loadfile; <STDIN>; }
elsif ($inkey eq "6") { &listsections; <STDIN>; }  
} until ($inkey eq "x");

exit;

sub delsection {
	do {
		print "Name of section to delete (?=section list):";
		 $delme = <STDIN> ; chomp $delme ;
		if ($delme eq "?") { &listsections; }
	} until ($delme ne "?");
	&itemdel('section',$delme);
	print "Section $delme was successfully deleted";
}

sub delgroup {
	do {
		print "Name of group to delete (?=group list):";
		$delme = <STDIN> ; chomp $delme ;
		if ($delme eq "?") { &listgroups; }
	} until ($delme ne "?");
	&itemdel('group',$delme);
	print "Group $delme was successfully deleted";
}

sub itemdel {
	my $test = $_[0] . "." . $_[1];
	open(PRE,"<$path");
	@con=<PRE>;
	close PRE;
	open(PREOUT,">$path");
	foreach $k (@con) {
		$o=$k;
		chomp $k;
		my ($l) = $k =~ /^([^#]*)/;
		trim (\$k); 
		if ($k !~ /^$test/) {
			print PREOUT $o;
		}
	}
	close PREOUT;
}
			
		
sub parsefile {
	my @pre = @_;
	for ($i=0;$i<(scalar @pre);$i++) {
		chomp $pre[$i];
		my ($l) = $pre[$i] =~ /^([^#]*)/;
		trim (\$l);	# trim
		if ($l ne "") {	
			my ($var,$set) = split(/=/,$l);
			my (@table) = split(/\./,$var);
			if ($table[0] eq 'group') {
				my $grpname = $table[1];
				my $oper = $table[2];
				$groups{$grpname}->{$oper}=$set;
			}
			if ($table[0] eq 'section') {
				my $secname = $table[1];
				my $oper = $table[2];
				$sections{$secname}->{$oper}=$set;
			}
		}
	}
}

sub loadfile {
	undef %groups;
	undef %sections;
        open(PRE,"<$path");
        @con=<PRE>;
        close PRE;
        &parsefile(@con); 
}

sub add2file {
	open(PREOUT,">>$path");
	print PREOUT @_;
	close(PREOUT);
}

sub listgroups {
	print " ,--------------------------------------------------------------------->\n";
	print "| Group        | Allow        | Dir \n";
        print "|---------------------------------------------------------------------->\n";
	foreach $key (keys %groups) {
        	printf("| %-12s | %-12s | %s\n",$key, $groups{$key}->{allow}, $groups{$key}->{dir});
	}
	print " `--------------------------------------------------------------------->\n";
}

sub listsections {
	print " ,--------------------------------------------------------------------->\n";
        print "| Section  | Name     | gl_*  | Dir \n";
        print "|---------------------------------------------------------------------->\n";
        foreach $key (keys %sections) {
                printf("| %-8s | %-8s | %-5s | %s\n",
			  $key, $sections{$key}->{name},
		$sections{$key}->{gl_credit_section} . ',' . $sections{$key}->{gl_stat_section},
			  $sections{$key}->{dir});
        }
        print " `--------------------------------------------------------------------->\n";
}
sub addgroup {
	print "Group name: ";
	$grpname = <STDIN>; chomp $grpname;
	do {
		print "$grpname" . "'s allow sections (?=list sections): ";
		$grpallow = <STDIN>; chomp $grpallow;
		if ($grpallow eq '?') { &listsections; }
	} until ($grpallow ne '?');
	print "$grpname" . "'s directory(ies): ";
	$grpdirs = <STDIN>; chomp $grpdirs;
	$grpout=sprintf("group.%s.allow=%s\ngroup.%s.dir=%s\n",
			$grpname,$grpallow,
			$grpname,$grpdirs);
	&add2file($grpout);
	print "The output would be: \n$grpout";
}

sub addsection {
        do {
                print "Section name (?=list sections): ";
                $secname = <STDIN>; chomp $secname;
                if ($secname eq '?') { &listsections; } 
        } until ($secname ne '?');
        print "$secname" . "'s directory: ";
        $secdir = <STDIN>; chomp $secdir; 	
	print "INFO: If you dont use sections, or if you'r unsure, you just put both gl_* (next two questions) to 0" .
	      "(meaning first section). otherwise you haveto know what you're doing :.)\n";
	print "$secname" . "'s gl_credit_section - glftpd section to give credits in (numeric):";
	$glcred = <STDIN>; chomp $glcred; int $glcred;
	print "$secname" . "'s gl_stat_section - glftpd section to give stats in (numeric):";
	$glstat = <STDIN>; chomp $glstat; int $glstat;
        $secout=sprintf("section.%s.name=%s\nsection.%s.dir=%s\nsection.%s.gl_credit_section=%d\nsection.%s.gl_stat_section=%d\n",
                        $secname,$secname,
                        $secname,$secdir,
			$secname,$glcred,
			$secname,$glstat);
	&add2file($secout);
        print "The output would be \n$secout";
}       
sub trim {
	my $k = shift;
	for (${$k}) {
	    s/^\s+//;
	    s/\s+$//;
	}
}
