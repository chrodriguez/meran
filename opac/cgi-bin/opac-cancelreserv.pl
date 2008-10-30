#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::AR::Utilidades;
use JSON;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{borrow => 1});

my $objJSON=$input->param('obj');
my $obj=from_json_ISO($objJSON);

my $borrowernumber=getborrowernumber($loggedinuser);
my %params;
$params{'reservenumber'}=$obj->{'reserveNumber'};
$params{'borrowernumber'}=$borrowernumber;
$params{'loggedinuser'}=$borrowernumber;
$params{'tipo'}="OPAC";

# my ($error,$codMsg,$message);
my $msg_object;

if($obj->{'accion'} eq 'CANCELAR'){

	($msg_object)=C4::AR::Reservas::t_cancelar_reserva(\%params);
}

if($obj->{'accion'} eq 'CANCELAR_Y_RESERVAR'){
	#parametros necesarios para cancelar y reservar
	$params{'id1'}=$obj->{'id1Nuevo'};
	$params{'id2'}=$obj->{'id2Nuevo'};

	($msg_object)=C4::AR::Reservas::t_cancelar_y_reservar(\%params);
}

my $infoOperacionJSON = to_json $msg_object;	

print $input->header;
print $infoOperacionJSON;



