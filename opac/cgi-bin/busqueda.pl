#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "busquedaResult.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => {borrow => 1},
			     });


my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

# my $keyword= $obj->{'keyword'};
my $comboTipoDocumento= $obj->{'tipo_nivel3_name'};
my $orden= $obj->{'orden'};#PARA EL ORDEN
my $funcion= $obj->{'funcion'};

my $search;
# $search->{'keyword'}= $keyword;
$search->{'class'}= $comboTipoDocumento;

my $buscoPor="";

# if($keyword ne ""){
# 	$buscoPor.="Busqueda combinada: ".$keyword."&";
# }

if($comboTipoDocumento != -1 && $comboTipoDocumento ne ""){
	my $itemtype=C4::AR::Busquedas::getItemType($comboTipoDocumento);
	$buscoPor.="Tipo de documento: ".$comboTipoDocumento."&";
}

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, @resultId1)= C4::AR::Busquedas::busquedaAvanzada_newTemp($ini,$cantR,$obj);

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

#se arma el arreglo con la info para mostrar en el template
$obj->{'cantidad'}= $cantidad;
$obj->{'loggedinuser'}= $session->{'loggedinuser'};
my $resultsarray = C4::AR::Busquedas::armarInfoNivel1($obj,@resultId1);
#se loguea la busqueda
C4::AR::Busquedas::logBusqueda($obj, $session);

my @busqueda=split(/&/,$buscoPor);
$buscoPor="";

foreach my $str (@busqueda){
	$buscoPor.=", ".$str;
}

$buscoPor= substr($buscoPor,2,length($buscoPor));

$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'buscoPor'}= $buscoPor;
$t_params->{'cantidad'}= $cantidad;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
