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
                        template_name => "opac-main.tmpl",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });


my $obj=$input->param('obj');

if($obj){
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
}else{
  my %hash_temp = {};
  $obj = \%hash_temp;
  $obj->{'tipoAccion'} = $input->param('tipoAccion');
  $obj->{'string'} = $input->param('string');
  $obj->{'tipoBusqueda'} = 'all';
}

my $ini= $obj->{'ini'};
my $start = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $resultsarray;
$obj->{'type'} = 'OPAC';
$obj->{'session'}= $session;

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'ini'}= $ini;
$obj->{'cantR'}= $obj->{'cantR'} || $cantR;

C4::AR::Validator::validateParams('U389',$obj,['tipoAccion']);

if($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_AUTOR'){

    $obj->{'autor'}= $obj->{'searchField'};
    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorAutor($obj,$session);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TITULO'){

    $obj->{'titulo'}= $obj->{'searchField'};
    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaSimplePorTitulo($obj,$session);

}elsif($obj->{'tipoAccion'} eq 'FILTRAR_POR_AUTOR'){

    ($cantidad, $resultsarray)= C4::AR::Busquedas::filtrarPorAutor($obj);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_SIMPLE_POR_TEMA'){

    $obj->{'tema'}= $obj->{'searchField'};
# FIXME falta implementar

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_COMBINABLE'){
    C4::AR::Debug::debug("ENTRA A COMBINABLE");
    if ($obj->{'tipoBusqueda'} eq 'all'){
        ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaCombinada_newTemp($obj->{'string'},$session,$obj);
    }else{
        ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);
    }
    $t_params->{'partial_template'}= "opac-busquedaResult.inc";
    $t_params->{'content_title'}= C4::AR::Filtros::i18n("Resultados de b&uacute;squeda para: ").$obj->{'string'};
    $t_params->{'search_string'}= $obj->{'string'};

}


$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'nro_socio'}= $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}= $resultsarray;
#se arma el string para mostrar en el cliente lo que a buscado, ademas escapa para evitar XSS
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}= $cantidad || 0;

my $elapsed = Time::HiRes::tv_interval( $start );
$t_params->{'timeSeg'}= $elapsed;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
