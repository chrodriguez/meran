#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $input = new CGI;

my $obj=$input->param('obj');

if($obj ne ""){
	$obj=from_json_ISO($obj);
}

my $signatura= $obj->{'signatura'};
my $isbn = $obj->{'isbn'};
my $codBarra= $obj->{'codBarra'};
my $autor= $obj->{'autor'};
my $titulo= $obj->{'titulo'};
my $tipo= $obj->{'tipo'};
my $idTema= $obj->{'idTema'};
my $tema= $obj->{'tema'};
my $comboItemTypes= $obj->{'comboItemTypes'};
my $idAutor= $obj->{'idAutor'};
my $orden= $obj->{'orden'}||'titulo';#PARA EL ORDEN
my $funcion= $obj->{'funcion'};


my $nivel1="";
my $nivel2="";
my $nivel3="";
my $nivel1rep="";
my $nivel2rep="";
my $nivel3rep="";
my $buscoPor="";


my ($template, $session, $t_params) = get_template_and_user ({
                                                            template_name	=> 'busquedas/busquedaResult.tmpl',
                                                            query		=> $input,
                                                            type		=> "intranet",
                                                            authnotrequired	=> 0,
                                                            flagsrequired	=> { circulate => 1 },
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

my $ini= ($obj->{'ini'}||'');
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$resultId1)= C4::AR::Busquedas::busquedaAvanzada($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,"AND",$ini,$cantR);

C4::AR::Utilidades::crearPaginador($template, $cantidad,$cantR, $pageNumber,$funcion,$t_params);

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
	$autor= getautor($nivel1->{'autor'});
	$result{$i}->{'idAutor'}=$autor->{'id'};
	$result{$i}->{'nomCompleto'}= $autor->{'completo'};
	my $ediciones=&obtenerGrupos($id1, $comboItemTypes,"INTRA");
	$result{$i}->{'grupos'}=$ediciones;
	my @disponibilidad=&obtenerDisponibilidadTotal($id1, $comboItemTypes);
	$result{$i}->{'disponibilidad'}=\@disponibilidad;
	
	#Busco si existe alguna imagen de Amazon de alguno de los niveles 2
	my $url=&C4::AR::Amazon::getImageForId1($id1,"small");
	if ($url) {$result{$i}->{'amazon_cover'}="amazon_covers/".$url;}
	#
}

my @keys=keys %result;
@keys= sort{$result{$a}->{$orden} cmp $result{$b}->{$orden}} @keys; #PARA EL ORDEN
foreach my $row (@keys){
	push (@resultsarray, $result{$row});
}

my @busqueda=split(/&/,$buscoPor);
$buscoPor="";
foreach my $str (@busqueda){
	$buscoPor.=", ".$str;
}

$buscoPor= substr($buscoPor,2,length($buscoPor));

$t_params->{'SEARCH_RESULTS'}= \@resultsarray;
$t_params->{'buscoPor'}=$buscoPor;
$t_params->{'cantidad'}=$cantidad;


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
