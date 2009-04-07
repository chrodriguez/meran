#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
my $input = new CGI;

my $obj=$input->param('obj');

if($obj ne ""){
	$obj= C4::AR::Utilidades::from_json_ISO($obj);
}

my $outside= $input->param('outside');

my $keyword= $obj->{'keyword'};
my $comboItemTypes= $obj->{'comboItemTypes'};
my $orden= $obj->{'orden'};#PARA EL ORDEN
my $funcion= $obj->{'funcion'};

my $search;
$search->{'keyword'}= $keyword;
$search->{'class'}= $comboItemTypes;

my $buscoPor="";


my ($template, $session, $t_params) = get_template_and_user ({
                                                        template_name	=> 'busquedas/busquedaResult.tmpl',
                                                        query		=> $input,
                                                        type		=> "intranet",
                                                        authnotrequired	=> 0,
                                                        flagsrequired	=> { circulate => 1 },
    					});

if($keyword ne ""){
	$buscoPor.="Busqueda combinada: ".$keyword."&";
}


if($comboItemTypes != -1 && $comboItemTypes ne ""){
	$comboItemTypes=&verificarValor($comboItemTypes);
	my $itemtype=C4::AR::Busquedas::getItemType($comboItemTypes);
	$buscoPor.="Tipo de documento: ".$itemtype."&";
}

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, @resultId1)= C4::AR::Busquedas::busquedaCombinada_newTemp($ini,$cantR,$search->{'keyword'});

$t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

my $resultsarray = C4::AR::Busquedas::armarInfoNivel1($cantidad,$comboItemTypes,$orden,@resultId1);

my @busqueda=split(/&/,$buscoPor);
$buscoPor="";

foreach my $str (@busqueda){
	$buscoPor.=", ".$str;
}

$buscoPor= substr($buscoPor,2,length($buscoPor));


$t_params->{'SEARCH_RESULTS'}= $resultsarray;
$t_params->{'buscoPor'}=$buscoPor;
$t_params->{'cantidad'}=$cantidad;

if($outside) {
    $t_params->{'HEADERS'}= 1;
}

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
