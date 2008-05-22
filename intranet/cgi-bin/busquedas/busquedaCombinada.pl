#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;

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


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "busquedas/busquedaResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

if($keyword ne ""){
	$buscoPor.="Busqueda combinada: ".$keyword."&";
}


if($comboItemTypes != -1 && $comboItemTypes ne ""){
	$comboItemTypes=&verificarValor($comboItemTypes);
	my $itemtype=C4::AR::Busquedas::ItemType($comboItemTypes);
	$buscoPor.="Tipo de documento: ".$itemtype."&";
}

my $ini= $obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad, @resultId1)= C4::AR::Busquedas::busquedaCombinada($search,$ini,$cantR);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion);

my @resultsarray;
my %result;
my $nivel1;
my @autor;
my $i=0;

if($cantidad > 0){
#si busquedaCombianda devuelve algo se busca la info siguiente
	foreach my $id1 (@resultId1) {
	
		$result{$i}->{'id1'}= $id1;
		$nivel1= &C4::AR::Catalogacion::buscarNivel1($id1);
		$result{$i}->{'titulo'}= $nivel1->{'titulo'};
		@autor= C4::Search::getautor($nivel1->{'autor'});
		$result{$i}->{'idAutor'}=$autor[0]->{'id'};
		$result{$i}->{'nomCompleto'}= $autor[0]->{'completo'};
		my @ediciones=&C4::AR::Busquedas::obtenerEdiciones($id1, $comboItemTypes);
		$result{$i}->{'grupos'}=\@ediciones;
		my @disponibilidad=&C4::AR::Busquedas::obtenerDisponibilidadTotal($id1, $comboItemTypes);
		$result{$i}->{'disponibilidad'}=\@disponibilidad;
	
		$i++;
	}
}

#PARA EL ORDEN VER SI QUEDA, PUEDE SER CAMBIADO POR JQUERY!!!!!!!!!!!!!!!
my @keys=keys %result;
@keys= sort{$result{$a}->{$orden} cmp $result{$b}->{$orden}} @keys;
foreach my $row (@keys){
	push (@resultsarray, $result{$row});
}

my @busqueda=split(/&/,$buscoPor);
$buscoPor="";

foreach my $str (@busqueda){
	$buscoPor.=", ".$str;
}

$buscoPor= substr($buscoPor,2,length($buscoPor));


$template->param(	SEARCH_RESULTS => \@resultsarray,
		 	buscoPor=>	$buscoPor,
			cantidad=>	$cantidad
		);

if($outside) {$template->param( HEADERS => 1);}


output_html_with_http_headers $input, $cookie, $template->output;
