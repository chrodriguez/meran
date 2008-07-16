#!/usr/bin/perl

# $Id: addbiblio.pl,v 1.32.2.7 2004/03/19 08:21:01 tipaul Exp $

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use C4::Koha;
use HTML::Template;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

=item
armarCondicion
Arma la condicion para la busqueda. Si la condicion es un like agrega el % dependiende de la condicion y concatena el valor; si es cualquiera otra condicion solo concatena el valor a esa condicion.
Tambien verifica que el valor de busqueda se valido.
=cut
sub armarCondicion(){
	my ($cond,$valor)=@_;
	$valor=&C4::AR::Utilidades::verificarValor($valor);
	if($cond eq "Empieza"){
		$cond=" like '".$valor."%' ";
	}
	elsif($cond eq "Contiene"){
		$cond=" like '%".$valor."%' ";
	}
	elsif($cond eq "Finaliza"){
		$cond=" like '%".$valor."' ";
	}
	else{
		$cond=$cond."'".$valor."'";
	}
	return $cond;
}

sub armarCondicionAutor(){
	my ($cond,$valor)=@_;
	$valor=&C4::AR::Utilidades::verificarValor($valor);
	if($cond eq "Empieza"){
		$cond=" like '".$valor."%' ";
	}
	elsif($cond eq "Contiene"){
		$cond=" like '%".$valor."%' ";
	}
	elsif($cond eq "Finaliza"){
		$cond=" like '%".$valor."' ";
	}
	else{
		$cond=$cond."'".$valor."'";
	}
	my @autores=&buscarAutorPorCond($cond);
	my $str="";
	foreach my $aut (@autores){
		$str.= "OR autor = ".$aut->{'id'}." ";
	}
	$str=substr($str,2,length($str));
	return "(".$str.")";
}

=item
parsearString
Esta funcion parsea los string que viene desde el tmpl armando asi el string para hacer las consultas y verificado que el dato sea correcto previniendo el sql injection.
=cut
sub parsearString(){
	my ($str,$rep)=@_;
	my @arrayCampos;
	my @arrayVal;
	my $string="";
	my $valor;
	my $cond;
	if($str ne ""){
		my @arrayCampos=split(/#/,$str);
		foreach my $cons (@arrayCampos){
			@arrayVal=split(/\//,$cons);
			if($rep){
				$cond=&armarCondicion($arrayVal[2],$arrayVal[3]);
				$string.="(".$rep.".campo=".$arrayVal[0]." AND ".$rep.".subcampo='".$arrayVal[1]."' AND ".$rep.".dato".$cond.")#";
			}
			else{
				if($arrayVal[0] eq "autor"){
					$string.=&armarCondicionAutor($arrayVal[1],$arrayVal[2])."#";
				}
				else{
					$cond=&armarCondicion($arrayVal[1],$arrayVal[2]);
					$string.=$arrayVal[0].$cond."#";
				}
				
			}
		}
	}
	return $string;
}

my $input = new CGI;
my $accion= $input->param('accion');

if($accion eq "buscar"){
	my ($template, $loggedinuser, $cookie)
    		= get_template_and_user({template_name => "busquedas/busquedaResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

	my $nivel1=&parsearString($input->param('nivel1'),0);
	my $nivel2=&parsearString($input->param('nivel2'),0);
	my $nivel3=&parsearString($input->param('nivel3'),0);
	my $nivel1rep=&parsearString($input->param('nivel1rep'),"n1r");
	my $nivel2rep=&parsearString($input->param('nivel2rep'),"n2r");
	my $nivel3rep=&parsearString($input->param('nivel3rep'),"n3r");
	my $operador=$input->param('operador');

	my ($cantidad,$resultId1)= &busquedaAvanzada($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,$operador);

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
	my @ediciones=&obtenerEdiciones($id1, 'ALL');
	$result{$i}->{'grupos'}=\@ediciones;
	my @disponibilidad=&obtenerDisponibilidadTotal($id1, 'ALL');
	$result{$i}->{'disponibilidad'}=\@disponibilidad;
}

my @keys=keys %result;
foreach my $row (@keys){
	push (@resultsarray, $result{$row});
}


$template->param(
		SEARCH_RESULTS => \@resultsarray,
		);


output_html_with_http_headers $input, $cookie, $template->output;

}
else{
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ catalogue => 1});

	my $campoX= $input->param('campoX');
	my $campo= $input->param('campo');

	my $string="";

	if($accion eq "seleccionCampoX"){
		my @campos=&C4::AR::Busquedas::buscarCamposMARC($campoX);
		for(my $i=0; $i < scalar(@campos); $i++){
			$string .= $campos[$i]."#";
		}
	}
	elsif($accion eq "seleccionCampo"){
		my @arrCampos=split("/",$campo);
		my @subcampos=&C4::AR::Busquedas::buscarSubCamposMARC($arrCampos[1]);
		for(my $i=0; $i < scalar(@subcampos); $i++){
			$string .= $subcampos[$i]."#";
		}
	}
	else{#accion = busquedaReferencia
		my $mapeo= $input->param('mapeo');
		my $campo= (split(/#/,$mapeo))[1];
		my $tipo='combo';
		my @valuesMapeo;
		my %labelsMapeo;
		my $labels="";
		my $value;
		if($campo eq "nivel_bibliografico"){
			%labelsMapeo=&C4::Busquedas::getLevels();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "lenguaje"){
			%labelsMapeo=&C4::Busquedas::getLanguages();
			my @keys= keys %labelsMapeo;
			@keys= sort{$labelsMapeo{$a} cmp $labelsMapeo{$b}} @keys;
			foreach my $key (@keys){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "pais_publicacion"){
			%labelsMapeo=&C4::Busquedas::getCountryTypes();
			my @keys= keys %labelsMapeo;
			@keys= sort{$labelsMapeo{$a} cmp $labelsMapeo{$b}} @keys;
			foreach my $key (@keys){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "wthdrawn"){
			%labelsMapeo=&C4::Search::getavails();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "holdingbranch" || $campo eq "homebranch" ){
			my $labels=&C4::Koha::getbranches();
			foreach my $key (keys %$labels){
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=%$labels->{$key}->{'branchname'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "tipo_documento"){
			my($i,@labels)=&C4::AR::Busquedas::getItemTypes();
			my $key;
			foreach my $itemtype (@labels){
				$key=$itemtype->{'itemtype'};
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=$itemtype->{'description'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "notforloan"){
			my @labels=&C4::AR::Issues::IssuesType();
			my $key;
			foreach my $issuetype (@labels){
				$key=$issuetype->{'issuecode'};
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=$issuetype->{'description'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "soporte"){
			%labelsMapeo=&C4::Busquedas::getSupportTypes();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		else{
			$tipo='text';
		}
		$string= &C4::AR::Utilidades::crearComponentes( $tipo,'valor1',\@valuesMapeo,$labels,'');
	}
	print $input->header;
	print $string;
}