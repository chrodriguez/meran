#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;
use JSON;
use C4::AR::Busquedas;
use Time::HiRes;
use Encode;
use URI::Escape;
use HTML::StripTags qw(strip_tags);

my $input                   = new CGI;
my $obj                     = $input->param('obj');
my %hash_temp               = $input->Vars;
$obj                        = \%hash_temp;
#Se usa $params_hash para guardar los originales y hacer la URL del paginador, sino pasa que se hace encode de encode y rompe
my $params_hash             = $input->Vars;
my $string                  = $input->param('string') || "";
my ($template, $session, $t_params);

$obj->{'tipoAccion'}        = $input->param('tipoAccion');
#solucion a la busqueda con acentos, se hace uri_escape para pasar el parametro por la url
#en Busquedas.pm se decodea utf8 y sacan acentos para sphinx
$obj->{'string'}            = uri_escape($string);
$obj->{'titulo'}            = Encode::decode_utf8($input->param('titulo'));
$obj->{'autor'}             = Encode::decode_utf8($input->param('autor'));
$obj->{'isbn'}              = Encode::decode_utf8($input->param('isbn'));
$obj->{'estantes'}          = Encode::decode_utf8($input->param('estantes'));
$obj->{'estantes_grupo'}    = Encode::decode_utf8($input->param('estantes_grupo'));
$obj->{'tema'}              = Encode::decode_utf8($input->param('tema'));
$obj->{'tipo'}              = $input->param('tipo');    

#la primera vez que ingresa a opac-busquedasDB only_available no existe
#por lo tanto no puedo hacer strip_tags
$obj->{'only_available'}    = $input->param('only_available') || 0;
if($obj->{'only_available'}){
    #escapamos todos los tabs html para evitar XSS
    $obj->{'only_available'}    = strip_tags($input->param('only_available'));
}

$obj->{'from_suggested'}    = $input->param('from_suggested');
$obj->{'tipo_nivel3_name'}  = $input->param('tipo_nivel3_name');
$obj->{'tipoBusqueda'}      = 'all';
$obj->{'token'}             = $input->param('token');

#se corta el parametro page en 6 numeros nada mas, sino rompe error 500
my $ini                     = $obj->{'ini'} = substr($input->param('page'),0,5);
C4::AR::Debug::debug("pageeeeeeee : ".$ini);
my $start                   = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $suggested;
my $resultsarray;

$obj->{'type'}              = 'OPAC';
$obj->{'session'}           = $session;

# PAGINADOR
my ($ini,$pageNumber,$cantR) = C4::AR::Utilidades::InitPaginador($ini);
#actualizamos el ini del $obj para que pagine correctamente
$obj->{'ini'}               = $ini;
$obj->{'cantR'}             = $cantR;

C4::AR::Validator::validateParams('U389',$obj,['tipoAccion']);

$obj->{'from_suggested'}    = $obj->{'from_suggested'};

my $url;
my $url_todos;
my $token;

    ($template, $session, $t_params)    = get_template_and_user({
                        template_name   => "opac-main.tmpl",
                        query           => $input,
                        type            => "opac",
                        authnotrequired => 1,
                        flagsrequired   => {  ui            => 'ANY', 
                                            tipo_documento  => 'ANY', 
                                            accion          => 'CONSULTA', 
                                            entorno         => 'undefined'},
                    });


if  ($obj->{'tipoAccion'} eq 'BUSQUEDA_AVANZADA'){

if ($obj->{'estantes'}){
  #Busqueda por Estante Virtual
    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&estantes=".$obj->{'estantes'}."&tipoAccion=".$obj->{'tipoAccion'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&estantes=".$obj->{'estantes'}."&tipoAccion=".$obj->{'tipoAccion'};
    C4::AR::Utilidades::addParamToUrl($url_todos,"estantes",$obj->{'estantes'});

    ($cantidad, $resultsarray)   = C4::AR::Busquedas::busquedaPorEstante($obj->{'estantes'}, $session, $obj);

    #Sino queda en el buscoPor
    $obj->{'tipo_nivel3_name'} = -1; 
  }
else{
if($obj->{'estantes_grupo'}){

  #Busqueda por Estante Virtual
    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&estantes_grupo=".$obj->{'estantes_grupo'}."&tipoAccion=".$obj->{'tipoAccion'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&estantes_grupo=".$obj->{'estantes_grupo'}."&tipoAccion=".$obj->{'tipoAccion'};
    C4::AR::Utilidades::addParamToUrl($url_todos,"estantes_grupo",$obj->{'estantes_grupo'});

    ($cantidad, $resultsarray)   = C4::AR::Busquedas::busquedaEstanteDeGrupo($obj->{'estantes_grupo'}, $session, $obj);

    #Sino queda en el buscoPor
    $obj->{'tipo_nivel3_name'} = -1; 

 }
  else {

    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&titulo=".$obj->{'titulo'}."&autor=".$obj->{'autor'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&titulo=".$obj->{'titulo'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'};
    
    C4::AR::Utilidades::addParamToUrl($url_todos,"titulo",$obj->{'titulo'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tipo_nivel3_name",$obj->{'tipo_nivel3_name'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tipoAccion",$obj->{'tipoAccion'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"isbn",$obj->{'isbn'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"tema",$obj->{'tema'});
    C4::AR::Utilidades::addParamToUrl($url_todos,"autor",$obj->{'autor'});
    
    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);
  }
}
}   else {
    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'};
    
    ($cantidad, $resultsarray,$suggested)  = C4::AR::Busquedas::busquedaCombinada_newTemp($string,$session,$obj);
} 

if ($obj->{'estantes'}||$obj->{'estantes_grupo'}){
  $t_params->{'partial_template'}         = "opac-busquedaEstantes.inc";
}
else{
  $t_params->{'partial_template'}         = "opac-busquedaResult.inc";
}

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
#primero se unescapea por la url, arriba se escapo
$obj->{'keyword'}                       = uri_unescape($obj->{'string'});
$t_params->{'keyword'}                  = $obj->{'keyword'};
$t_params->{'buscoPor'}                 = C4::AR::Busquedas::armarBuscoPor($obj);

$t_params->{'cantidad'}                 = $cantidad || 0;
$t_params->{'show_search_details'}      = 1;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
