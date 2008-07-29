#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

#PARA LOS CAMPOS TEMPORALES!!!!

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $nivel=$obj->{'nivel'};
my $itemtype=$obj->{'itemtype'};
my $cant=$obj->{'cant'};

my $objetoResp=$obj->{'objeto'};

my $ok=guardarCampoTemporal($objetoResp,$nivel,$itemtype);
$objetoResp->{'ok'}=$ok;
my $tabla=$objetoResp->{'tabla'};
my $tipoInput=$objetoResp->{'tipo'};
my $campos=$objetoResp->{'campos'};
my $orden=$objetoResp->{'orden'};
if($tabla != -1 && $tipoInput eq "combo"){
	my $ident=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
	my $opciones=&C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$ident,$campos,$orden);
	$objetoResp->{'opciones'}=$opciones
}

my $resultadoJSON = to_json $objetoResp;

#Para que no valla a un tmpl
print $input->header;
print $resultadoJSON;
