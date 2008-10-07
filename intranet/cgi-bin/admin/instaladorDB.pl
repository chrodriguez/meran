#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

use JSON;

my $input=new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{circulate=> 1},"intranet");

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion= $obj->{'accion'};


#***************************************************SIGUIENTE**********************************************
if($accion eq "SIGUIENTE"){
#logica necesaria al hacer click en siguiente
	my @infoRespuesta=();
	
 	$infoRespuesta[0]->{'info'}= "SIGUIENTE";
	
	my $infoRespuestaJSON = to_json \@infoRespuesta;
	print $input->header;
	print $infoRespuestaJSON;
}
#*************************************************************************************************************

#***************************************************ANTERIOR**********************************************
if($accion eq "ANTERIOR"){
#logica necesaria al hacer click en siguiente
	my @infoRespuesta=();
	
 	$infoRespuesta[0]->{'info'}= "ANTERIOR";
	
	my $infoRespuestaJSON = to_json \@infoRespuesta;
	print $input->header;
	print $infoRespuestaJSON;
}
#*************************************************************************************************************
