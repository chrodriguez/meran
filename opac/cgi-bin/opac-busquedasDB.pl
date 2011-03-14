#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;

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
my $ini;

if($obj){
    
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
    $obj->{'ini'}=0;

}   else    {

    my %hash_temp = {};
    $obj = \%hash_temp;
    $obj->{'tipoAccion'} = $input->param('tipoAccion');
    $obj->{'string'} = Encode::decode_utf8($input->param('string'));
#     $obj->{'string'} = $input->param('string');
    $obj->{'titulo'} = $input->param('titulo');
    $obj->{'tipo'} = $input->param('tipo');    
    $obj->{'only_available'} = $input->param('only_available') || 0;
    $obj->{'from_suggested'} = $input->param('from_suggested');
    $obj->{'tipo_nivel3_name'} = $input->param('tipo_nivel3_name');
    $obj->{'tipoBusqueda'} = 'all';
    $obj->{'ini'} = $input->param('page') || 0;

}

#  C4::AR::Debug::debug("opac-busquedas.pl => string => ".$obj->{'string'});
# my $url = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&string=".Encode::encode_utf8($obj->{'string'})."&tipoAccion=".$obj->{'tipoAccion'};


my $start = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $suggested;
my $resultsarray;
$obj->{'type'} = 'OPAC';
$obj->{'session'}= $session;

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$obj->{'cantR'}= $obj->{'cantR'} || $cantR;

C4::AR::Validator::validateParams('U389',$obj,['tipoAccion']);
$obj->{'from_suggested'}= $obj->{'from_suggested'};

my $url;
my $url_todos;

if($obj->{'tipoAccion'} eq 'BUSQUEDA_AVANZADA'){

    $obj->{'autor'}= $obj->{'searchField'};
    
    $url = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&titulo=".$obj->{'titulo'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&titulo=".$obj->{'titulo'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'};

    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);

}elsif($obj->{'tipoAccion'} eq 'BUSQUEDA_COMBINABLE'){
    
    my $string_buscado;

    if ($input->param('string')){
          $string_buscado= $input->param('string');      
    } else{
          $string_buscado= $obj->{'string'};
    }

    $url = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&string=".$string_buscado."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
    $url_todos = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&string=".$string_buscado."&tipoAccion=".$obj->{'tipoAccion'};
    
    ($cantidad, $resultsarray,$suggested)  = C4::AR::Busquedas::busquedaCombinada_newTemp($string_buscado,$session,$obj);

}

$t_params->{'partial_template'}         = "opac-busquedaResult.inc";
$t_params->{'content_title'}            = C4::AR::Filtros::i18n("Resultados de la b&uacute;squeda");
$t_params->{'suggested'}                = $suggested;
$t_params->{'tipoAccion'}               = $obj->{'tipoAccion'};
$t_params->{'url_todos'}                = $url_todos;
$t_params->{'only_available'}           = $obj->{'only_available'};

$t_params->{'paginador'}                = C4::AR::Utilidades::crearPaginadorOPAC($cantidad,$cantR, $pageNumber,$url,$t_params);

#se arma el arreglo con la info para mostrar en el template

my $elapsed                             = Time::HiRes::tv_interval( $start );

$t_params->{'timeSeg'}                  = $elapsed;
$obj->{'nro_socio'}                     = $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}           = $resultsarray;

#se arma el string para mostrar en el cliente lo que a buscado, ademas escapa para evitar XSS
# $obj->{'keyword'} = Encode::decode_utf8($obj->{'string'});

$obj->{'keyword'}               = $obj->{'string'};
$t_params->{'keyword'}          = $obj->{'keyword'};

# $t_params->{'buscoPor'}         = C4::AR::Utilidades::verificarValor($obj->{'string'});#C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'buscoPor'}         = C4::AR::Busquedas::armarBuscoPor($obj);

# $t_params->{'buscoPor'}         = Encode::encode('utf8' , C4::AR::Busquedas::armarBuscoPor($obj));

$t_params->{'cantidad'}         = $cantidad || 0;
# $t_params->{'search_string'}    = $obj->{'string'};

$t_params->{'show_search_details'} = 1;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
