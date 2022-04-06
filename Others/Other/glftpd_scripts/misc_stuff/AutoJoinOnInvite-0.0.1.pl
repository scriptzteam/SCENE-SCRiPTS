package Xchat::b0at::AutoJoinOnInvite; 
use strict; 
use warnings; 
my $NAME    = 'Auto Join On Invite (no list)'; 
my $VERSION = '001-nolist'; 
my $PREFIX  = "\02Join on Invite\02"; 
Xchat::register($NAME, $VERSION, "Joins a channel you're invited to."); 
Xchat::print("\02$NAME $VERSION\02 by b0at"); 
Xchat::hook_print('Invited', sub { 
   my @args = @{ $_[0] }; 
   my $chan = lc shift @args; 
   Xchat::print("$PREFIX Auto-joining $chan..."); 
   Xchat::command("join $chan"); 
   return Xchat::EAT_NONE; 
}); 