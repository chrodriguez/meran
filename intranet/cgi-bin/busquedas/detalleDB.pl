#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;
use JSON;

my $input=new CGI;

my $obj;
my ($userid, $session, $flags) = checkauth($input, 0,{ catalogue => 1});


my %infoRespuesta;
#Cuando viene desde detalle, es un llamado ajax, que se hace con el AjaxHelper
$obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

my $id1=$obj->{'id1'};
my $accion=$obj->{'accion'};

my %params;

$params{'id1'}= $id1;
$params{'id2'}= $obj->{'id2'};
$params{'id3'}= $obj->{'id3'};
$params{'responsable'}= $userid;
	
if($accion eq "BORRAR_GRUPO"){

	my ($error, $codMsg, $message)= &C4::AR::Nivel2::t_deleteGrupo(\%params);
		
	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;
}elsif($accion eq "BORRAR_NIVEL1"){
		
	my ($error, $codMsg, $message)= &C4::AR::Nivel1::t_deleteNivel1(\%params);
		
	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;

}elsif($accion eq "BORRAR_NIVEL3"){

	my ($error, $codMsg, $message)= &C4::AR::Nivel3::t_deleteItem(\%params);

	$infoRespuesta{'error'}= $error;
	$infoRespuesta{'codMsg'}= $codMsg;
	$infoRespuesta{'message'}= $message;
}
	

#se convierte el arreglo de respuesta en JSON
my $infoRespuestaJSON = to_json \%infoRespuesta;
C4::Auth::print_header($session);

#se envia en JSON al cliente
print $infoRespuestaJSON;


