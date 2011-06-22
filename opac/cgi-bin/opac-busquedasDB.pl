#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;
use JSON;

use C4::AR::Busquedas;
use Time::HiRes;

my $input = new CGI;

my $obj=$input->param('obj');


my ($template, $session, $t_params);

my %hash_temp = $input->Vars;
$obj = \%hash_temp;
$obj->{'tipoAccion'} = $input->param('tipoAccion');
$obj->{'string'} = Encode::decode_utf8($input->param('string'));
$obj->{'titulo'} = $input->param('titulo');
$obj->{'tipo'} = $input->param('tipo');    
$obj->{'only_available'} = $input->param('only_available') || 0;
$obj->{'from_suggested'} = $input->param('from_suggested');
$obj->{'tipo_nivel3_name'} = $input->param('tipo_nivel3_name');
$obj->{'tipoBusqueda'} = 'all';
$obj->{'token'} = $input->param('token');
my $ini = $obj->{'ini'} = $input->param('page') || 0;


my $start = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $suggested;
my $resultsarray;

$obj->{'type'} = 'OPAC';
$obj->{'session'}= $session;


# PAGINADOR
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'cantR'}= $obj->{'cantR'} || $cantR;

C4::AR::Validator::validateParams('U389',$obj,['tipoAccion']);

$obj->{'from_suggested'}= $obj->{'from_suggested'};


my $url;
my $url_todos;
my $token;

    ($template, $session, $t_params)= get_template_and_user({
                        template_name => "opac-main.tmpl",
                        query => $input,
                        type => "opac",
                        authnotrequired => 1,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                    });


if  ($obj->{'tipoAccion'} eq 'BUSQUEDA_AVANZADA'){


    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&titulo=".$obj->{'titulo'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'};
    
    C4::AR::Utilidades::addParamToUrl($url_todos,"titulo",$obj->{'titulo'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tipo_nivel3_name",$obj->{'tipo_nivel3_name'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tipoAccion",$obj->{'tipoAccion'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"isbn",$obj->{'isbn'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tema",$obj->{'tema'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"autor",$obj->{'autor'});
    

    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);

}   else {

    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'};
    
    ($cantidad, $resultsarray,$suggested)  = C4::AR::Busquedas::busquedaCombinada_newTemp($input->param('string'),$session,$obj);


} 


$t_params->{'partial_template'}         = "opac-busquedaResult.inc";
$t_params->{'content_title'}            = C4::AR::Filtros::i18n("Resultados de la b&uacute;squeda");
$t_params->{'suggested'}                = $suggested;
$t_params->{'tipoAccion'}               = $obj->{'tipoAccion'};
$t_params->{'url_todos'}                = $url_todos;
$t_params->{'only_available'}           = $obj->{'only_available'};
$t_params->{'paginador'}                = C4::AR::Utilidades::crearPaginadorOPAC($cantidad,$cantR, $pageNumber,$url,$t_params);
$t_params->{'combo_tipo_documento'}     = C4::AR::Utilidades::generarComboTipoNivel3();

#se arma el arreglo con la info para mostrar en el template

my $elapsed                             = Time::HiRes::tv_interval( $start );

$t_params->{'timeSeg'}                  = $elapsed;
$obj->{'nro_socio'}                     = $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}           = $resultsarray;

#se arma el string para mostrar en el cliente lo que a buscado, ademas escapa para evitar XSS
# $obj->{'keyword'} = Encode::decode_utf8($obj->{'string'});

$obj->{'keyword'}               = $obj->{'string'};
$t_params->{'keyword'}          = $obj->{'keyword'};
$t_params->{'buscoPor'}         = Encode::encode_utf8(C4::AR::Busquedas::armarBuscoPor($obj));

$t_params->{'cantidad'}         = $cantidad || 0;
$t_params->{'show_search_details'} = 1;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
