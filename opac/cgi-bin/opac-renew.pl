#!/usr/bin/perl
use strict;

use CGI;
use C4::Auth;
use JSON;

my $input = new CGI;

my ($userid, $session, $flags) = checkauth($input, 0,{borrow => 1});

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);
my %infoOperacion;
my $id3= $obj->{'id3'};;
my %params;

$params{'nro_socio'}= $userid;
$params{'id3'}= $id3;
$params{'loggedinuser'}= $userid;
$params{'tipo'}= 'OPAC';

my $dataItems= C4::AR::Nivel3::getDataNivel3($id3);
$params{'barcode'}= $dataItems->{'barcode'};

my ($msg_object) = C4::AR::Prestamos::t_renovar(\%params);

my $infoOperacionJSON = to_json $msg_object;

print $input->header;
print $infoOperacionJSON;
