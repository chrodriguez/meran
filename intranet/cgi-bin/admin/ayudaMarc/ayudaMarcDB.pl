#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Utilidades;
use JSON;
use C4::AR::AyudaMarc;

my $input           = new CGI;
my $obj             = $input->param('obj');

$obj                = C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion      = $obj->{'tipoAccion'} || "";

my $authnotrequired = 0;

if($tipoAccion eq "AGREGAR_VISUALIZACION"){

    my ($user, $session, $flags)= checkauth(  $input, 
                                              $authnotrequired, 
                                              {   ui                => 'ANY', 
                                                  tipo_documento    => 'ANY', 
                                                  accion            => 'CONSULTA', 
                                                  entorno           => 'datos_nivel1'}, 
                                              'intranet'
                                  );

    my ($Message_arrayref)  = C4::AR::AyudaMarc::agregarAyudaMarc($obj);
    my $infoOperacionJSON   = to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
}    