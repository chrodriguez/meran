#!/usr/bin/perl


use strict;
use CGI;
use C4::AR::Auth;

use C4::AR::Utilidades;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my $obj = $input->param('obj');
$obj = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion = $obj->{'tipoAccion'} || "";

my $ini = $obj->{'ini'};
my ($ini, $pageNumber, $cantR) = C4::AR::Utilidades::InitPaginador($ini);
my $authnotrequired = 0;


if($tipoAccion eq "MOSTRAR_DATOS_NIVEL_REPETIBLE"){

my ($template, $session, $t_params)  = get_template_and_user({
              template_name   => ('herramientas/mostrarDatosNivelRepetible.tmpl'),
              query           => $input,
              type            => "intranet",
              authnotrequired => $authnotrequired,
              flagsrequired   => {  ui => 'ANY', 
                                    tipo_documento => 'ANY', 
                                    accion => 'CONSULTA', 
                                    entorno => 'datos_nivel1' },
});

$t_params->{'ini'} = $obj->{'ini'} = $ini;
$t_params->{'cantR'} = $obj->{'cantR'} = $cantR;


my ($cant, @nivel_repetible_array_ref) = C4::AR::Catalogacion::getImportacionSinEstructura($obj);
$t_params->{'datos_nivel_repetible_array'} = \@nivel_repetible_array_ref;
$t_params->{'cantidad'} = $cant;
$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cant, $obj->{'cantR'}, $pageNumber, $obj->{'funcion'}, $t_params);

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}

elsif($tipoAccion eq "ELIMINAR_NIVEL_REPETIBLE"){

     my ($user, $session, $flags) = checkauth(  $input, 
                                                $authnotrequired, 
                                                {   ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'}, 
                                                'intranet'
                                    );

    
    #elimina un nivel repetible, segun el nivel y el rep_id pasado por parametro
    my ($Message_arrayref) = C4::AR::Catalogacion::t_eliminarNivelRepetible($obj);
    
    my $infoOperacionJSON = to_json $Message_arrayref;
    
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
}