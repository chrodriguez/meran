#!/usr/bin/perl
use strict;

use CGI;
use C4::Auth;
use JSON;

my $input = new CGI;

my ($loggedinuser, $sessionID) = checkauth($input, 0,{borrow => 1});

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my %infoOperacion;
my $id3= $obj->{'id3'};;
my %params;


my $borrowernumber= C4::Auth::getborrowernumber($loggedinuser);
$params{'borrowernumber'}= $borrowernumber;
$params{'id3'}= $id3;
$params{'loggedinuser'}= $loggedinuser;
$params{'tipo'}= 'OPAC';

my $dataItems= C4::AR::Nivel3::getDataNivel3($id3);
$params{'barcode'}= $dataItems->{'barcode'};

my ($msg_object) = C4::AR::Prestamos::t_renovar(\%params);

my $infoOperacionJSON = to_json $msg_object;

print $input->header;
print $infoOperacionJSON;
