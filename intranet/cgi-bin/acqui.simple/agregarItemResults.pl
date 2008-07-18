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
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use C4::AR::Mensajes;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_templateexpr_and_user({template_name => "acqui.simple/agregarItemResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $nivel=$input->param('nivel');
my $itemtype=$input->param('itemtype')||'ALL';
my $id1=$input->param('id1') || -1;
my $id2=$input->param('id2') || -1;
my $accion=$input->param('accion2')||$input->param('accion')||-1;
#busca la primera vez la descripcion del itemtype y despues lo toma de la pagina.
my $descripcion=$input->param('descripcion') || C4::AR::Busquedas::getItemType($itemtype);


if($accion eq "borrar"){
	&eliminarNivel1($id1);
	$nivel=1;
}
elsif($accion eq "borrarN2"){
	&eliminarNivel2($id2);
	$nivel=2;
}
elsif($accion eq "modificarN1" && $nivel == 1){
	my $nivel1 =&buscarNivel1($id1);
	my $idAutor=$nivel1->{'autor'};
	my $autor=C4::AR::Busquedas::getautor($idAutor);
	$autor=$autor->{'completo'};
	$nivel=1;
	$template->param(accion  => $accion,
			 autor 	 => $autor,
			 idAutor => $idAutor);
}

#GUARDADO de los items
my $paso;
if($nivel == 3){
	$paso=$input->param('paso')||$nivel-1;
}
else{
	$paso=$input->param('paso')||$nivel;
}

my @nivel1o2;
my @nivel3;
my $respuesta= $input->param('respuesta');
if($respuesta ne ""){
	my $objetosResp= &C4::AR::Utilidades::from_json_ISO($respuesta);
	foreach my $obj(@$objetosResp){
		if($obj->{'nivel'} < 3){
			push(@nivel1o2,$obj);
		}
		else{
			push(@nivel3,$obj);
		}
	}
}

my $idAutor=$input->param('idAutor');
my $cantItems=$input->param('cantitems'); #recupero la cantidad de items del nivel 3 a insertar
my $barcode=$input->param('codbarra'); #recupero el codigo de barra para el o los items del nivel 3

my $error=0;
my $codMsg;
my $mensaje="";
my $paraMens;
if($paso > 1 && ($accion ne "modificarN1" && $accion ne "agregarN2" && $accion ne "borrarN2" && $accion ne "modificarN2")){
	if(($paso-1)==1){
		($id1,$error,$codMsg)= guardarNivel1($idAutor,\@nivel1o2);
		if($error){
			$mensaje= C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
			$paso=1;
		}
	}
	elsif(($paso-1)==2 && (!$error)){
		my ($id2,$tipoDocN2,$error,$codMsg)=guardarNivel2($id1,\@nivel1o2);
		if($error){
			$mensaje= C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
			$paso=2;
		}
		else{
			($error,$codMsg)=guardarNivel3($id1,$id2,$barcode,$cantItems,$tipoDocN2,\@nivel3);
# 			if($error){
				$mensaje=C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
# 			}
# 			else{
# 				$mensaje=&C4::AR::Mensajes::getMensaje($codMsg,"INTRA",$paraMens);
# 			}
			$paso=2;
		}
	}
}
#FIN del guardado
elsif($accion eq "modificarN1" && $paso==2){
	&modificarNivel1Completo($id1,$idAutor,\@nivel1o2);
	$accion="";
	$template->param(
			accion	  => $accion,
			)
}

#BUSQUEDA de los datos ingresados en el nivel 1 y nivel 2 para mostrar en la pagina del paso 2
if($paso > 1 && $id1 != -1){
	my $itemNivel1=&buscarNivel1($id1);
	my $autor=C4::AR::Busquedas::getautor($itemNivel1->{'autor'});
	$autor=$autor->{'completo'};
	my $titulo=$itemNivel1->{'titulo'};
	my @itemNivel2=&buscarNivel2PorId1($id1);
	$template->param(
			id1	=> $id1,
			titulo	=> $titulo,
			autor	=> $autor,
			resultsGrupos => \@itemNivel2
			);
}
#FIN busqueda


$template->param(
 			nivel		  => $nivel,
 			paso		  => $paso,
 			itemtype	  => $itemtype,
 			descripcion	  => $descripcion,
 			id1		  => $id1,
 			error		  => $error,
			mensaje		  => $mensaje,
		);

output_html_with_http_headers $input, $cookie, $template->output;
