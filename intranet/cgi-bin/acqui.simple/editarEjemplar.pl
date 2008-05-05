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
use HTML::Template::Expr;
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my $id1=$input->param('id1');
my $id2=$input->param('id2');
my $id3=$input->param('id3');
my $itemtype=$input->param('itemtype');
my $accion=$input->param('accion');
my $todos=$input->param('todos')||0;
my $json=$input->param('json');

my @niveles3;
my $cant=0;
my $nivel3Comp;
if($id3 ne ""){
	($cant,$nivel3Comp)=&buscarNivel3Completo($id3);
}
else{
	$todos=1;
	@niveles3=&buscarNivel3PorId2($id2);
}

if(!$json){
	my ($template, $loggedinuser, $cookie)
    		= get_templateexpr_and_user({template_name => "acqui.simple/editarEjemplar.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

	my $nivel1=&buscarNivel1($id1);
	my $titulo=$nivel1->{'titulo'};
	my @autor=&C4::Search::getautor($nivel1->{'autor'});
	my $cant=0;

	if($accion eq "modNivel3"){
		my $respuesta=$input->param('respuesta');
		my $objetosResp;
		if($respuesta ne ""){
			$objetosResp= &C4::AR::Utilidades::from_json_ISO($respuesta);
		}
		if($todos){
			my @ids3=split(/#/,$id3);
			foreach my $idN3 (@ids3){
				&modificarNivel3Completo($idN3,$objetosResp,$todos);
			}
		}
		else{
			&modificarNivel3Completo($id3,$objetosResp,$todos);
		}
	}

	$template->param(
		itemloop	=> \@niveles3,
		nivel		=> 3,
		itemtype	=> $itemtype,
		id1		=> $id1,
		id2		=> $id2,
		id3		=> $id3,
		titulo		=> $titulo,
		datosautor	=> \@autor,
		todos  		=> $todos,
	);
	output_html_with_http_headers $input, $cookie, $template->output;
}
else{

	
	my %results = &buscarCamposModificadosYObligatorios(3,$itemtype);
	my ($cantIdsModN3,@resultsdata)=&crearCatalogo(0,$nivel3Comp,$cant,$itemtype,%results);

	my $resultadoJSON = to_json \@resultsdata;

	#Para que no valla a un tmpl
	print $input->header;
	print $resultadoJSON;
}





