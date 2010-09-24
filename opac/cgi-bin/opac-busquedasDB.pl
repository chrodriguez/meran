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


#verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada
C4::AR::Busquedas::sphinx_start();

my $obj = $input->param('obj');

if($obj){
    $obj= C4::AR::Utilidades::from_json_ISO($obj);
}else{
  my %hash_temp = {};
  $obj = \%hash_temp;
  $obj->{'tipoAccion'} = $input->param('tipoAccion');
#   $obj->{'string'} = Encode::decode_utf8($input->param('string'));
  $obj->{'string'} = $input->param('string');
  $obj->{'from_suggested'} = $input->param('from_suggested');
  $obj->{'tipoBusqueda'} = 'all';
  $obj->{'ini'} = $input->param('page') || 0;
}

# C4::AR::Debug::debug("opac-busquedas.pl => string => ".$obj->{'string'});

# my $url = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&string=".Encode::encode_utf8($obj->{'string'})."&tipoAccion=".$obj->{'tipoAccion'};

my $url = "/cgi-bin/koha/opac-busquedasDB.pl?token=".$input->param('token')."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'};


my $ini= $obj->{'ini'};
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
    
    if ($obj->{'tipoBusqueda'} eq 'all'){
#         ($cantidad, $resultsarray)  = C4::AR::Busquedas::busquedaCombinada_newTemp(Encode::decode_utf8($input->param('string')),$session,$obj);
        ($cantidad, $resultsarray,$suggested)  = C4::AR::Busquedas::busquedaCombinada_newTemp($input->param('string'),$session,$obj);
    }else{
        ($cantidad, $resultsarray)  = C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);
    }

    $t_params->{'partial_template'}         = "opac-busquedaResult.inc";
    $t_params->{'content_title'}            = C4::AR::Filtros::i18n("Resultados de la b&uacute;squeda");
}


$t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginadorOPAC($cantidad,$cantR, $pageNumber,$url,$t_params);
$t_params->{'suggested'}        = $suggested;
$t_params->{'tipoAccion'}       = $obj->{'tipoAccion'};
#se arma el arreglo con la info para mostrar en el template
my $elapsed                     = Time::HiRes::tv_interval( $start );
$t_params->{'timeSeg'}          = $elapsed;
$obj->{'nro_socio'}             = $session->param('nro_socio');
$t_params->{'SEARCH_RESULTS'}   = $resultsarray;
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

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
