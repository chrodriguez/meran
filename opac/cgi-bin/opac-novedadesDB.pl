#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use JSON;
use C4::AR::Auth;
use C4::AR::Novedades;
use C4::AR::Utilidades;

my $input               = new CGI;
my $authnotrequired     = 0;
my $obj                 = $input->param('obj');
$obj                    = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion          = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "DELETE_NOVEDAD"){

    my ($loggedinuser, $session, $flags) = checkauth( 
                                               $input, 
                                               $authnotrequired,
                                               {   ui               => 'ANY', 
                                                   tipo_documento   => 'ANY', 
                                                   accion           => 'CONSULTA', 
                                                   entorno          => 'undefined'},   
                                                   "opac"
                                );   
                                
    my $id_novedad          = $obj->{'tipoAccion'}||"";                                 

    my ($Message_arrayref)  = C4::AR::Novedades::noMostrarNovedad($obj);   
  
    my $infoOperacionJSON   = to_json $Message_arrayref;
        
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

}
