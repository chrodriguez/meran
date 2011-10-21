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
use C4::AR::PdfGenerator;

my $input          = new CGI;
my $string         = ($input->param('string')) || "";
my $to_pdf         = $input->param('export') || 0;



my ($template, $session, $t_params);

#se escapea algun tag html si existe, evita XSS 
#Guardo los parametros q vienen por URL
my $obj; 
$obj->{'string'}            = $string;
$obj->{'tipoAccion'}        = CGI::escapeHTML($input->param('tipoAccion'));
$obj->{'titulo'}            = ($input->param('titulo'));
$obj->{'autor'}             = ($input->param('autor'));
$obj->{'isbn'}              = ($input->param('isbn'));
$obj->{'estantes'}          = ($input->param('estantes'));
$obj->{'estantes_grupo'}    = CGI::escapeHTML($input->param('estantes_grupo'));
$obj->{'tema'}              = ($input->param('tema'));
$obj->{'tipo'}              = ($input->param('tipo'));    
$obj->{'only_available'}    = CGI::escapeHTML($input->param('only_available')) || 0;
$obj->{'from_suggested'}    = CGI::escapeHTML($input->param('from_suggested'));
$obj->{'tipo_nivel3_name'}  = ($input->param('tipo_nivel3_name'));
$obj->{'tipoBusqueda'}      = 'all';
$obj->{'token'}             = CGI::escapeHTML($input->param('token'));


C4::AR::Validator::validateParams('U389',$obj,['tipoAccion']);

#se corta el parametro page en 6 numeros nada mas, sino rompe error 500
my $page                    = ($input->param('page'));
my $ini                     = $obj->{'ini'} = substr($page,0,5);

my $start                   = [ Time::HiRes::gettimeofday() ]; #se toma el tiempo de inicio de la búsqueda

my $cantidad;
my $suggested;
my $resultsarray;

$obj->{'type'}              = 'OPAC';
$obj->{'session'}           = $session;

my ($ini,$pageNumber,$cantR) = C4::AR::Utilidades::InitPaginador($ini);

#actualizamos el ini del $obj para que pagine correctamente
$obj->{'ini'}               = $ini;
$obj->{'cantR'}             = $cantR;


my $url;
my $url_todos;
my $token;

if ($to_pdf){
    $obj->{'ini'}               = 0;
    $obj->{'cantR'}             = "";
    ($template, $session, $t_params) = get_template_and_user({
                            template_name => "includes/opac-busquedaResult_XLS.inc",
                            query => $input,
                            type => "opac",
                            authnotrequired => 1,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
         
     });


    ($cantidad, $resultsarray)=C4::AR::Busquedas::busquedaSinPaginar($session, $obj);


    $t_params->{'SEARCH_RESULTS'}       = $resultsarray;
    $t_params->{'cantidad'}             = $cantidad;
    $t_params->{'exported'}             = 1;
    my $out= C4::AR::Auth::get_html_content($template, $t_params);
    my $filename= C4::AR::PdfGenerator::pdfFromHTML($out);

    print C4::AR::PdfGenerator::pdfHeader();

    C4::AR::PdfGenerator::printPDF($filename);


} else {
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

            $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'};

            $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"estantes",$obj->{'estantes'});
            $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"tipoAccion",$obj->{'tipoAccion'});

            ($cantidad, $resultsarray)   = C4::AR::Busquedas::busquedaPorEstante($obj->{'estantes'}, $session, $obj);

            #Sino queda en el buscoPor
            $obj->{'tipo_nivel3_name'} = -1; 
          } else {
                if($obj->{'estantes_grupo'}){
                    #Busqueda por Estante Virtual
                    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&estantes_grupo=".$obj->{'estantes_grupo'}."&tipoAccion=".$obj->{'tipoAccion'};
                    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'};
                
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"estantes_grupo",$obj->{'estantes_grupo'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"tipoAccion",$obj->{'tipoAccion'});
                
                    ($cantidad, $resultsarray)   = C4::AR::Busquedas::busquedaEstanteDeGrupo($obj->{'estantes_grupo'}, $session, $obj);
                
                    #Sino queda en el buscoPor
                    $obj->{'tipo_nivel3_name'} = -1; 
                
                } else {
            
                    $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&titulo=".$obj->{'titulo'}."&autor=".$obj->{'autor'}."&tipo=".$obj->{'tipo'}."&tipo_nivel3_name=".$obj->{'tipo_nivel3_name'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
                    $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'};
                    

                    $url = C4::AR::Utilidades::addParamToUrl($url,"titulo",$obj->{'titulo'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"tipo_nivel3_name",$obj->{'tipo_nivel3_name'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"tipoAccion",$obj->{'tipoAccion'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"isbn",$obj->{'isbn'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"tema",$obj->{'tema'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"autor",$obj->{'autor'});
                    $url = C4::AR::Utilidades::addParamToUrl($url,"only_available",$obj->{'only_available'});

                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"titulo",$obj->{'titulo'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"tipo_nivel3_name",$obj->{'tipo_nivel3_name'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"tipoAccion",$obj->{'tipoAccion'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"isbn",$obj->{'isbn'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"tema",$obj->{'tema'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"autor",$obj->{'autor'});
                    $url_todos = C4::AR::Utilidades::addParamToUrl($url_todos,"only_available",0);
                    
                    ($cantidad, $resultsarray)= C4::AR::Busquedas::busquedaAvanzada_newTemp($obj,$session);
                }
        }      
    }  else {

        $url = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'}."&only_available=".$obj->{'only_available'};
        $url_todos = C4::AR::Utilidades::getUrlPrefix()."/opac-busquedasDB.pl?token=".$obj->{'token'}."&string=".$obj->{'string'}."&tipoAccion=".$obj->{'tipoAccion'};

        ($cantidad, $resultsarray,$suggested)  = C4::AR::Busquedas::busquedaCombinada_newTemp($string,$session,$obj);   

    } 

        if ($obj->{'estantes'}||$obj->{'estantes_grupo'}){
        
            $t_params->{'partial_template'}     = "opac-busquedaEstantes.inc";

        }else{
                
            $t_params->{'partial_template'}     = "opac-busquedaResult.inc";
        }

        $t_params->{'content_title'}            = C4::AR::Filtros::i18n("Resultados de la b&uacute;squeda");
        $t_params->{'suggested'}                = $suggested;
        $t_params->{'tipoAccion'}               = $obj->{'tipoAccion'};
        $t_params->{'url_todos'}                = $url_todos;
        $t_params->{'only_available'}           = $obj->{'only_available'};
        $t_params->{'paginador'}                = C4::AR::Utilidades::crearPaginadorOPAC($cantidad,$cantR, $pageNumber,$url,$t_params);

        $t_params->{'combo_tipo_documento'}     = C4::AR::Utilidades::generarComboTipoNivel3();

        my $elapsed                             = Time::HiRes::tv_interval( $start );

        $t_params->{'timeSeg'}                  = $elapsed;
        $obj->{'nro_socio'}                     = $session->param('nro_socio');
        $t_params->{'SEARCH_RESULTS'}           = $resultsarray;
        $obj->{'keyword'}                       = $obj->{'string'};
        $t_params->{'keyword'}                  = $obj->{'string'};
        $t_params->{'buscoPor'}                 = C4::AR::Busquedas::armarBuscoPor($obj);
        $t_params->{'cantidad'}                 = $cantidad || 0;
        $t_params->{'show_search_details'}      = 1;

        #pdf
        $t_params->{'pdf_titulo'}             = $obj->{'titulo'};
        $t_params->{'pdf_autor'}              = $obj->{'autor'};
        $t_params->{'pdf_isbn'}               = $obj->{'isbn'};
        $t_params->{'pdf_estantes'}           = $obj->{'estantes'};
        $t_params->{'pdf_estantes_grupo'}     = $obj->{'estantes_grupo'};
        $t_params->{'pdf_tipo'}               = $obj->{'tipo'};
        $t_params->{'pdf_onlyAvailable'}      = $obj->{'only_available'};
        $t_params->{'pdf_tipo_nivel3_name'}   = $obj->{'tipo_nivel3_name'};
        $t_params->{'pdf_token'}              = $obj->{'token'};

                                $t_params->{'external_search'}          = C4::AR::Preferencias::getValorPreferencia('external_search') || 0;
        my $cant_servidores =   $t_params->{'cant_external_servers'}    = C4::AR::Busquedas::cantServidoresExternos();

        if ($cant_servidores){
        	$t_params->{'external_servers'} = C4::AR::Busquedas::getServidoresExternos();
        }
        
        $t_params->{'show_search_details'}      = 1;

        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}