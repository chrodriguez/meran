#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;
use HTML::Template;

my $input = new CGI;
my $template;
my $loggedinuser;
my $cookie;

my $outside= $input->param('outside');
my $keyword= $input->param('keyword');
my $comboItemTypes= $input->param('comboItemTypes');
my $orden=$input->param('orden');#PARA EL ORDEN

my $search;
$search->{'keyword'}=$keyword;
$search->{'class'}=$comboItemTypes;

my $buscoPor="";


($template, $loggedinuser, $cookie)
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

my (@resultId1)= C4::AR::Busquedas::busquedaCombinada($search);

my @resultsarray;
my %result;
my $nivel1;
my @autor;
my $i=0;
foreach my $id1 (@resultId1) {
	$result{$i}->{'id1'}= $id1;
	$nivel1= &buscarNivel1($id1);
	$result{$i}->{'titulo'}= $nivel1->{'titulo'};
	@autor= C4::Search::getautor($nivel1->{'autor'});
	$result{$i}->{'idAutor'}=$autor[0]->{'id'};
	$result{$i}->{'nomCompleto'}= $autor[0]->{'completo'};
	my @ediciones=&obtenerEdiciones($id1, $comboItemTypes);
	$result{$i}->{'grupos'}=\@ediciones;
	my @disponibilidad=&obtenerDisponibilidadTotal($id1, $comboItemTypes);
	$result{$i}->{'disponibilidad'}=\@disponibilidad;
	$i++;
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


$template->param(SEARCH_RESULTS => \@resultsarray,
		 buscoPor=>	$buscoPor);

if($outside) {$template->param( HEADERS => 1);}


output_html_with_http_headers $input, $cookie, $template->output;
