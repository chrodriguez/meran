#!/usr/bin/perl
use strict;

# written 04-09-2005 by Luciano Iglesias (li@info.unlp.edu.ar)
# script to renew items from the web

use C4::AR::Issues;
use CGI;
use C4::Auth;
use C4::AR::Mensajes;
use JSON;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});

open(A, ">>/tmp/debug.txt");
print A "desde opac-renew \n";

=item
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
=cut

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my %infoOperacion;
my $error;
my $codMsg;
my $id3= $obj->{'id3'};
my @infoOperacionArray;
my $paraMens;
my %params;


my $borrowernumber=getborrowernumber($loggedinuser);
$params{'borrowernumber'}= $borrowernumber;
$params{'id3'}= $id3;
$params{'loggedinuser'}= $loggedinuser;
$params{'tipo'}= 'OPAC';

my $dataItems= C4::Circulation::Circ2::getDataItems($id3);
$params{'barcode'}= $dataItems->{'barcode'};

my ($error,$codMsg, $message) = C4::AR::Issues::t_renovar(\%params);

# print A "barcode: ".$dataItems->{'barcode'}."\n";
print A "error: $error\n";
print A "codMsg $codMsg \n";
print A "mensaje $message\n";


%infoOperacion = (	error => $error,
        		message => $message,
		);
close(A);

push @infoOperacionArray, \%infoOperacion;

my $infoOperacionJSON = to_json \@infoOperacionArray;
# my $infoOperacionJSON;

print $input->header;
print $infoOperacionJSON;
