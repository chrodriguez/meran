#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                                        template_name	=> 'busquedas/busquedaResult.tmpl',
                                                        query		=> $input,
                                                        type		=> "intranet",
                                                        authnotrequired	=> 0,
                                                        flagsrequired	=> { circulate => 1 },
    					});

my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

my $outside= $input->param('outside');
my $keyword= $obj->{'keyword'};
my $tipo_documento= $obj->{'tipo_nivel3_name'};
my $orden= $obj->{'orden'};#PARA EL ORDEN
my $funcion= $obj->{'funcion'};

my $search;
$search->{'keyword'}= $keyword;
$search->{'class'}= $tipo_documento;

# my $buscoPor="";
# 
# if($keyword ne ""){
# 	$buscoPor.="Busqueda combinada: ".$keyword."&";
# }
# 
# if($tipo_documento != -1 && $tipo_documento ne ""){
# 	my $itemtype=C4::AR::Busquedas::getItemType($tipo_documento);
# 	$buscoPor.="Tipo de documento: ".$itemtype."&";
# }

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, @resultId1)= C4::AR::Busquedas::busquedaCombinada_newTemp($ini,$cantR,$search->{'keyword'});

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'loggedinuser'}= $session->{'loggedinuser'};
my $resultsarray = C4::AR::Busquedas::armarInfoNivel1($obj,@resultId1);
#se loguea la busqueda
C4::AR::Busquedas::logBusqueda($obj, $session);

# my @busqueda=split(/&/,$buscoPor);
# $buscoPor="";
# 
# foreach my $str (@busqueda){
# 	$buscoPor.=", ".$str;
# }
# 
# $buscoPor= substr($buscoPor,2,length($buscoPor));

$t_params->{'SEARCH_RESULTS'}= $resultsarray;
# $t_params->{'buscoPor'}=$buscoPor;
$t_params->{'buscoPor'}= C4::AR::Busquedas::armarBuscoPor($obj);
$t_params->{'cantidad'}=$cantidad;

if($outside) {
    $t_params->{'HEADERS'}= 1;
}

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
