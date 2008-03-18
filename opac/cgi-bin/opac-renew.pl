#!/usr/bin/perl
use strict;

# written 04-09-2005 by Luciano Iglesias (li@info.unlp.edu.ar)
# script to renew items from the web

use C4::AR::Issues;
use CGI;

my $query = new CGI;
my $itemnumber = $query->param('item');
my $borrowernumber = $query->param("bornum");
my $url="/cgi-bin/koha/opac-user.pl";
my ($borr, $flags) = C4::Circulation::Circ2::getpatroninformation(undef, $borrowernumber);
###CURSO DE USUARIO###
if ((C4::Context->preference("usercourse"))&&($borr->{'usercourse'} == "NULL" )) {
	#el usuario no hizo el curso!!!
	$url="/cgi-bin/koha/opac-user.pl?no_user_course=1";
} 
else { #No esta seteado lo del curso  o ya lo hizo
	my $status = renovar($borrowernumber,$itemnumber,$borrowernumber);
}

print $query->redirect($url);