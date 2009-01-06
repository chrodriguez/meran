#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use CGI;
use C4::Context;

my $query=new CGI;
# PAARECCE Q NO SE USA MAS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
open(A,">>/tmp/debug");
print A "logout: \n";

# my $sessionID=$query->cookie('sessionID');
my $session = CGI::Session->load();# or die CGI::Session->errstr();
my $sessionID = $session->param('sessionID');

my $sessions;
open (S, "/tmp/sessions");
while (my ($sid, $u, $lasttime) = split(/:/, <S>)) {
    chomp $lasttime;
    (next) unless ($sid);
    (next) if ($sid eq $sessionID);
    $sessions->{$sid}->{'userid'}=$u;
    $sessions->{$sid}->{'lasttime'}=$lasttime;
}
open (S, ">/tmp/sessions");
foreach (keys %$sessions) {
    my $userid=$sessions->{$_}->{'userid'};
    my $lasttime=$sessions->{$_}->{'lasttime'};
    print S "$_:$userid:$lasttime\n";
}

my $dbh = C4::Context->dbh;

# Check that this is the ip that created the session before deleting it

my $sth=$dbh->prepare("select userid,ip from sist_sesion where sessionID=?");
$sth->execute($sessionID);
my ($userid, $ip);
if ($sth->rows) {
    ($userid,$ip) = $sth->fetchrow;
    if ($ip ne $ENV{'REMOTE_ADDR'}) {
       # attempt to logout from a different ip than cookie was created at
       exit;
    }
}

$sth=$dbh->prepare("delete from sist_sesion where sessionID=?");
$sth->execute($sessionID);
open L, ">>/tmp/sessionlog";
my $time=localtime(time());
printf L "%20s from %16s logged out at %30s (manual log out).\n", $userid, $ip, $time;
close L;

## FIXME para que hace esto
=item
my $cookie=$query->cookie(-name => 'sessionID',
			  -value => '',
			  -expires => '+1y');
=cut
# Should redirect to intranet home page after logging out

print A "desde logout antes de borrar la session: \n";
print A "session->userid: ".$session->param('userid')."\n";
print A "session->password: ".$session->param('password')."\n";
print A "session->nroRandom: ".$session->param('nroRandom')."\n";
print A "session->sessionID: ".$session->param('sessionID')."\n";
print A "sessionID: ".$sessionID."\n";

$session->clear();
if ( $session->is_expired ) {
	print A "la session EXPIRO\n";
}

if ( $session->is_empty ) {
      print A "la session esta EMPTY\n";
}

print A "session->userid: ".$session->param('userid')."\n";
print A "session->password: ".$session->param('password')."\n";
print A "session->nroRandom: ".$session->param('nroRandom')."\n";
print A "session->sessionID: ".$session->param('sessionID')."\n";
print A "sessionID: ".$sessionID."\n";

print $query->redirect("userpage.pl");
exit;


