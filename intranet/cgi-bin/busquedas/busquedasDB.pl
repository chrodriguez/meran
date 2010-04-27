#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use Time::HiRes;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                            template_name   => 'busquedas/busquedaResult.tmpl',
                            query       => $input,
                            type        => "intranet",
                            authnotrequired => 0,
                            flagsrequired   =>  { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        });

my $authnotrequired= 0;
my $obj=$input->param('obj');


$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $start = [ Time::HiRes::gettimeofday( ) ]; #se toma el tiempo de inicio de la búsqueda
my $tipoAccion= $obj->{'tipoAccion'}||"";
my $dateformat = C4::Date::get_date_format();
my $ini= $obj->{'ini'};

#verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada    
C4::AR::Busquedas::sphinx_start();

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

$t_params->{'ini'} = $obj->{'ini'} = $ini;
$t_params->{'cantR'} = $obj->{'cantR'} = $cantR;
$obj->{'type'} = 'INTRA';

=item
Aca se maneja el cambio de la password para el usuario
=cut
if (C4::AR::Utilidades::validateString($tipoAccion)){
    if($tipoAccion eq "BUSQUEDA_POR_AUTOR"){

#       $t_params->{'com'}            = $obj->{'completo'};
      $t_params->{'session'}            = $session;
      my ($cantidad, $resultId1)        = C4::AR::Busquedas::filtrarPorAutor($obj, $session);
      $t_params->{'paginador'}          = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
      $t_params->{'cantidad'}           = $cantidad;  
      $t_params->{'SEARCH_RESULTS'}     = $resultId1;

    }elsif($tipoAccion eq "BUSQUEDA_COMBINADA"){
    
	    my $outside                     = $input->param('outside');
	    my $keyword                     = $obj->{'keyword'};
	    my $tipo_documento              = $obj->{'tipo_nivel3_name'};
	    
	    my $search;
	    $search->{'keyword'}            = $keyword;
	    $search->{'class'}              = $tipo_documento;
	    
	    my ($cantidad, $resultId1, $suggested)      = C4::AR::Busquedas::busquedaCombinada_newTemp($search->{'keyword'}, $session, $obj);
	    $t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginador($cantidad, $cantR, $pageNumber, $obj->{'funcion'}, $t_params);
        $t_params->{'suggested'}        = $suggested;
	    $obj->{'cantidad'}              = $cantidad;  #????????
	    $t_params->{'SEARCH_RESULTS'}   = $resultId1;
        $t_params->{'cantidad'}         = $cantidad;

	    if($outside) {
            $t_params->{'HEADERS'}      = 1;
	    }
	    
    }elsif($tipoAccion eq "BUSQUEDA_AVANZADA"){
	    my $funcion                     = $obj->{'funcion'};
	    my $ini                         = ($obj->{'ini'}||'');
	    
	    my ($cantidad, $array_nivel1)   = C4::AR::Busquedas::busquedaAvanzada_newTemp($obj, $session);
	    
	    $obj->{'cantidad'}              = $cantidad;
	    $obj->{'loggedinuser'}          = $session->param('nro_socio');
	    $t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
	    $t_params->{'SEARCH_RESULTS'}   = $array_nivel1;
        $t_params->{'cantidad'}         = $cantidad;

    }elsif($tipoAccion eq "BUSQUEDA_POR_BARCODE"){
        my $funcion                     = $obj->{'funcion'};
        my $ini                         = ($obj->{'ini'}||'');
        
        my ($cantidad, $array_nivel1)   = C4::AR::Busquedas::busquedaPorBarcode($obj->{'codBarra'}, $session, $obj);
        
        $obj->{'cantidad'}              = $cantidad;
        $obj->{'loggedinuser'}          = $session->param('nro_socio');
        $t_params->{'paginador'}        = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
        $t_params->{'SEARCH_RESULTS'}   = $array_nivel1;
        $t_params->{'cantidad'}         = $cantidad;

    }

    #se arma el string para mostrar en el cliente lo que a buscado, ademas escapa para evitar XSS
#     $t_params->{'buscoPor'} = Encode::encode('utf8' , C4::AR::Busquedas::armarBuscoPor($obj));
    $t_params->{'buscoPor'} = Encode::encode('utf8' ,C4::AR::Busquedas::armarBuscoPor($obj));
    my $elapsed             = Time::HiRes::tv_interval( $start );
    $t_params->{'timeSeg'}  = $elapsed;
    C4::AR::Busquedas::logBusqueda($t_params, $session);
    
    C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}

