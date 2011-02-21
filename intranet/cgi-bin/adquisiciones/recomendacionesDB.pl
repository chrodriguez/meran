#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion  = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "ACTUALIZAR_CANTIDAD_RECOMENDACION"){

    my $recomendacion_detalle   = C4::AR::Recomendaciones::editarCantidadEjemplares($obj);
}
