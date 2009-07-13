#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use Time::HiRes;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                        template_name => "opac-busquedaResult.tmpl",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });


my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

my $ini= $obj->{'ini'};
my $start = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $resultsarray;
$obj->{'type'} = 'OPAC';
$obj->{'session'}= $session;

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'ini'}= $ini;
$obj->{'cantR'}= $cantR;

if($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_AUTOR'){

    $obj->{'autor'}= $obj->{'searchinc'};
    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorAutor($obj,$session);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TITULO'){

    $obj->{'titulo'}= $obj->{'searchinc'};
    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorTitulo($obj,$session);

}elsif($obj->{'tipoAccion'} eq 'FILTRAR_POR_AUTOR'){

    ($cantidad, $resultsarray)= C4::AR::Busquedas::filtrarPorAutor($obj);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TEMA'){

    $obj->{'tema'}= $obj->{'searchinc'};
# FIXME falta implementar

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_COMBINABLE'){

    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);
}


$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'nro_socio'}= $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}= $resultsarray;
#se arma el string para mostrar en el cliente lo que a buscado, ademas escapa para evitar XSS
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}= $cantidad;

my $elapsed = Time::HiRes::tv_interval( $start );
$t_params->{'timeSeg'}= $elapsed;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
