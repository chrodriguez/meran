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

my $signatura= $input->param('signatura');
my $isbn = $input->param('isbn');
my $codBarra= $input->param('codBarra');
my $autor= $input->param('autor');
my $titulo= $input->param('titulo');
my $tipo= $input->param('tipo');
my $idTema= $input->param('idTema');
my $tema= $input->param('tema');
my $comboItemTypes= $input->param('comboItemTypes');
my $idAutor=$input->param('idAutor');#Viene por get desde un link de autor
my $orden=$input->param('orden')||'titulo';#PARA EL ORDEN

my $nivel1="";
my $nivel2="";
my $nivel3="";
my $nivel1rep="";
my $nivel2rep="";
my $nivel3rep="";
my $buscoPor="";


($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "busquedas/busquedaResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

if($idAutor > 0 ){
	$nivel1="autor=".&verificarValor($idAutor);
}

if($signatura ne ""){
	$buscoPor.="Signatura topagrafica: ".$signatura."&";
	$nivel3.= "signatura_topografica like '".&verificarValor($signatura)."%'#";
}

if($isbn ne ""){
	$buscoPor.="ISBN: ".$isbn."&";
	$nivel2rep.= "(n2r.campo='020' AND n2r.subcampo='a'AND n2r.dato='".&verificarValor($isbn)."')#";
}

if($codBarra ne ""){
	$buscoPor.="Codigo de barra: ".$codBarra."&";
	$nivel3.= "barcode='".&verificarValor($codBarra)."'#";
}

if($autor ne ""){
	$buscoPor.="Autor: ".$autor."&";
	my @autores=C4::AR::Utilidades::obtenerAutores(&verificarValor($autor));
	my $niv1="";
	foreach my $aut (@autores){
		$niv1.= "OR autor = ".$aut->{'id'}." ";
	}
	$niv1=substr($niv1,2,length($niv1));
	$nivel1.="(".$niv1.")#";
}

if($titulo ne ""){
	$buscoPor.="Titulo: ".$titulo."&";
	if($tipo eq 'normal'){
		$nivel1.= "titulo like '%".&verificarValor($titulo)."%'#";
	}
	else{
		$nivel1.="titulo='".&verificarValor($titulo)."'#";
	}
}

if($idTema ne "" ){
	$buscoPor.="Tema: ".$tema."&";
	$nivel1rep.= "(n1r.campo='650' AND n1r.subcampo='a'AND n1r.dato='".&verificarValor($idTema)."')#";
}


if($comboItemTypes != -1 && $comboItemTypes ne ""){
	$comboItemTypes=&verificarValor($comboItemTypes);
	my $itemtype=C4::AR::Busquedas::getItemType($comboItemTypes);
	$buscoPor.="Tipo de documento: ".$itemtype."&";
	$nivel2.= "tipo_documento='".$comboItemTypes."'#";
}

my $ini= ($input->param('ini'));
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$resultId1)= &busquedaAvanzada($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,"AND",$ini,$cantR);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,"buscar");

my @resultsarray;
my %result;
my $nivel1;
my @autor;
my $id1;
for (my $i=0;$i<scalar(@$resultId1);$i++){
	$id1=$resultId1->[$i];
	$result{$i}->{'id1'}= $id1;
	$nivel1= &buscarNivel1($id1);
	$result{$i}->{'titulo'}= $nivel1->{'titulo'};
	@autor= C4::Search::getautor($nivel1->{'autor'});
	$result{$i}->{'idAutor'}=$autor[0]->{'id'};
	$result{$i}->{'nomCompleto'}= $autor[0]->{'completo'};
	my @ediciones=&obtenerGrupos($id1, $comboItemTypes);
	$result{$i}->{'grupos'}=\@ediciones;
	my @disponibilidad=&obtenerDisponibilidadTotal($id1, $comboItemTypes);
	$result{$i}->{'disponibilidad'}=\@disponibilidad;
}

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
# #se hace la busqueda
# open(INFO, ">/tmp/debug.txt");
# print INFO "Se imprime el result \n";
# # my @aux= split(/&/,$nivel1);
# for (my $i=0;$i<scalar(@$resultId1);$i++){
# 	print INFO "id1: $resultId1->[$i] \n";
# }
# close(INFO);

$template->param(
		SEARCH_RESULTS => \@resultsarray,
		buscoPor=>	$buscoPor
		);


output_html_with_http_headers $input, $cookie, $template->output;
