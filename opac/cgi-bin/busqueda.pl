#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Utilidades;
use C4::AR::Catalogacion;

my $query = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
								template_name => "busquedaResult.tmpl",
								query => $query,
								type => "opac",
								authnotrequired => 1,
								flagsrequired => {borrow => 1},
					#  			     debug => 1,
			     });


my $obj=$query->param('obj');

if($obj ne ""){
	$obj=from_json_ISO($obj);
}

## FIXME estos parametros que vienen del servidor hay q verificarlos todos y escapar cualquier basura antes de usarlos
my $signatura= $obj->{'signatura'};
my $isbn = $obj->{'isbn'};
my $codBarra= $obj->{'codBarra'};
my $autor= $obj->{'autor'};
my $titulo= $obj->{'titulo'};
my $tipo= $obj->{'tipo'};
my $idTema= $obj->{'idTema'};
my $tema= $obj->{'tema'};
my $comboItemTypes= $obj->{'comboItemTypes'};
my $idAutor= $obj->{'idAutor'};#Viene por get desde un link de autor
my $orden= $obj->{'orden'}||'titulo';#PARA EL ORDEN
my $funcion= $obj->{'funcion'};

my $valorOPAC= C4::Context->preference("logSearchOPAC");
my $valorINTRA= C4::Context->preference("logSearchINTRA");
my $search;
my @search_array;
# esto creo q no es necessario
my $env; 


#busqueda desde el top
my $criteria= $obj->{'criteria'};
my $searchinc= $obj->{'searchinc'};

if($criteria ne ''){

	if($criteria eq 'autor'){$autor= $searchinc;}
	if($criteria eq 'titulo'){$titulo= $searchinc;}
}
####

#*********************************Busqueda Avanzada********************************************************
my $nivel1="";
my $nivel2="";
my $nivel3="";
my $nivel1rep="";
my $nivel2rep="";
my $nivel3rep="";
my $buscoPor="";

## FIXME si se le ingresa algo como esto se rompe!!!!!!!!!!!!!!!
# "><script>alert('hola')</script>
if($idAutor > 0 ){
	$nivel1="autor=".&verificarValor($idAutor);
}

if($signatura ne ""){
## FIXME todas estas entradas se concatenan y no son verificadas y enviadas al cliente, MALLLL
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

	if( ($valorOPAC == 1) ){
		my $search;
		$search->{'barcode'}= $codBarra;
		push @search_array, $search;
	}
}

if($autor ne ""){
	$buscoPor.="Autor: ".$autor."&";
	my @autores=C4::AR::Utilidades::obtenerAutores(&verificarValor($autor));
	my $niv1="";
	foreach my $aut (@autores){
		$niv1.= "OR autor = ".$aut->{'id'}." ";
	}
	$niv1=substr($niv1,2,length($niv1));
	if(scalar(@autores)){
		$nivel1.="(".$niv1.")#";
	}


	if( ($valorOPAC == 1) ){
		my $search;
		$search->{'autor'}= $autor;
# 		loguearBusqueda($loggedinuser,$env,'opac',$search);
		push @search_array, $search;
	}
}

if($titulo ne ""){
	$buscoPor.="Titulo: ".$titulo."&";
	if($tipo eq 'normal'){
		$nivel1.= "titulo like '%".&verificarValor($titulo)."%'#";
	}
	else{
		$nivel1.="titulo='".&verificarValor($titulo)."'#";
	}

	if( ($valorOPAC == 1) ){
		my $search;
		$search->{'titulo'}= $titulo;
# 		loguearBusqueda($loggedinuser,$env,'opac',$search);
		push @search_array, $search;
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

	if( ($valorOPAC == 1) ){
		my $search;
		$search->{'tipo_documento'}= $comboItemTypes;
# 		loguearBusqueda($loggedinuser,$env,'opac',$search);
		push @search_array, $search;
	}
}

my ($error, $codMsg, $message)= C4::AR::Busquedas::t_loguearBusqueda($t_params->{'loggedinuser'},$env,'opac',\@search_array);

my $ini= ($obj->{'ini'}||'');
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$resultId1)= &C4::AR::Busquedas::busquedaAvanzada($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,"AND",$ini,$cantR);

&C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

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
	$autor=C4::AR::Busquedas::getautor($nivel1->{'autor'});
	$result{$i}->{'idAutor'}=$autor->{'id'};
	$result{$i}->{'nomCompleto'}= $autor->{'completo'};
	my $ediciones=&obtenerGrupos($id1, $comboItemTypes,"OPAC");
	$result{$i}->{'grupos'}=$ediciones;
	my @disponibilidad=&obtenerDisponibilidadTotal($id1, $comboItemTypes);
	$result{$i}->{'disponibilidad'}=\@disponibilidad;

}

#*****************************Fin****Busqueda Avanzada********************************************************

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

$t_params->{'SEARCH_RESULTS'}= \@resultsarray;
## FIXME hay que tener mucho cuidado con este tipo de cosas, entradas desde el cliente que pasan por el servidor sin controlar
# y son devueltas al cliente
$t_params->{'buscoPor'}= &verificarValor($buscoPor);
$t_params->{'cantidad'}= $cantidad;


C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session, $cookie);
