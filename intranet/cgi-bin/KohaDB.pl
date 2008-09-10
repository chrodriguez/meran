#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});
my $borrowernumber=getborrowernumber($loggedinuser);

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $tipo= $obj->{'tipo'};

my $dbh = C4::Context->dbh;

if($tipo eq "USUARIOS_CONECTADOS"){

	my $query=" 	SELECT count(*) as cantUsers
			FROM sessions
			WHERE (? +  60  > lasttime) AND (? -  60 < lasttime)
			ORDER BY lasttime DESC ";

	my $sth=$dbh->prepare($query);
        $sth->execute(time(), time());

	print $input->header;
	print $sth->fetchrow;
}

