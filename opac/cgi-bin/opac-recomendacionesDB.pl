#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;
use JSON;
use C4::AR::Nivel2;

my $input = new CGI;

my $obj=$input->param('obj');

my ($template, $session, $t_params);

if($obj){
    
    $obj= C4::AR::Utilidades::from_json_ISO($obj);

}

if ($obj->{'tipoAccion'} eq 'BUSQUEDA_RECOMENDACION') {

    my $idNivel1=  $obj->{'idCatalogoSearch'};

    my $combo_ediciones= C4::AR::Utilidades::generarComboNivel2($idNivel1);

    ($template, $session, $t_params)= get_template_and_user({
                        template_name => "/includes/opac-combo_ediciones.inc",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });

    $t_params->{'combo_ediciones'} = $combo_ediciones;

   
}   elsif ($obj->{'tipoAccion'} eq 'CARGAR_DATOS_EDICION')   {

    my $idNivel2=  $obj->{'edicion'};

    my $idNivel1= $obj->{'idCatalogoSearch'};

    C4::AR::Debug::debug($idNivel1);

    my $datos_edicion= C4::AR::Nivel2::getNivel2FromId2($idNivel2);
  
    C4::AR::Utilidades::printHASH($datos_edicion);
    my $datos_nivel1= C4::AR::Nivel1::getNivel1FromId1($idNivel1);

    ($template, $session, $t_params)= get_template_and_user({
                        template_name => "/includes/opac-datos_edicion.inc",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });


    $t_params->{'datos_edicion'} = $datos_edicion;
    $t_params->{'datos_nivel1'} = $datos_nivel1;
}
 
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);