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

%infoOperacion = (	error => $error,
        		message => $message,
		);

push @infoOperacionArray, \%infoOperacion;

my $infoOperacionJSON = to_json \@infoOperacionArray;

print $input->header;
print $infoOperacionJSON;
