#!/usr/bin/perl

use strict;
require Exporter;
use C4::AR::Auth;
use CGI;

my $query 	= new CGI;

my $obj 	= $query->param('obj') || 0;

my ($template, $session, $t_params) = C4::AR::Auth::get_template_and_user({
                                    template_name   => "reports/circulacion.tmpl",
                                    query           => $query,
                                    type            => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired   => {  ui            => 'ANY', 
                                                        tipo_documento  => 'ANY', 
                                                        accion          => 'CONSULTA', 
                                                        entorno         => 'undefined' },
});

if (!$obj) {

    $obj 					= $query->Vars;
    $obj->{'ui'} 			= $obj->{'tipo_prestamo_name'};
    $obj->{'item_type'} 	= $obj->{'categoria_socio_id'};
    $obj->{'nivel_biblio'} 	= $obj->{'name_nivel_bibliografico'};
    
} else {

    $obj 					= C4::AR::Utilidades::from_json_ISO($obj);

}

$obj->{'fecha_ini'} 		=  C4::AR::Filtros::i18n($obj->{'fecha_ini'});
$obj->{'fecha_fin'} 		=  C4::AR::Filtros::i18n($obj->{'fecha_fin'});

$t_params->{'comboDeCategorias'}    = C4::AR::Utilidades::generarComboCategoriasDeSocio();
$t_params->{'comboDeTipoDoc'}       = C4::AR::Utilidades::generarComboTipoDeDocConValuesIds();
$t_params->{'comboDeTipoPrestamos'} = C4::AR::Utilidades::generarComboTipoPrestamo();

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);