#!/usr/bin/perl

#script to administer the systempref table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)
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
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::AR::Preferencias;
use C4::AR::Utilidades;


my $input = new CGI;
my $obj=&from_json_ISO($input->param('obj'));
my $json=$obj->{'json'};
my $tabla=$obj->{'tabla'};
if($json ne ""){
	my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ parameters => 1});

	my $guardar=$obj->{'guardar'};
	my $tipo=$obj->{'tipo'};
	if($guardar){
		my $modificar=$obj->{'modificar'};
		my $variable=$obj->{'variable'};
		my $valor=$obj->{'valor'};
		my $expl=&UTF8toISO($obj->{'explicacion'});
		my $opciones="";
		if($tipo eq "combo"){$opciones=$tabla."|".$obj->{'campo'};}
		if($tipo eq "valAuto"){
			my $categ=$obj->{'categoria'};
			$opciones="authorised_values|".$categ;
		}
		my $error=0;
		if($modificar eq "1"){&modificarVariable($variable,$valor,$expl);}
		else{$error=&guardarVariable($variable,$valor,$expl,$tipo,$opciones);}
		print $input->header;
		print $error;
	}
	else{
		my $strjson="";
		if($tipo eq "combo"){
			if($tabla){
			my @campos=&obtenerCampos($tabla);
			foreach my $campo(@campos){
				$strjson.=",{'clave':'".$campo->{'campo'}."','valor':'".$campo->{'campo'}."'}";
			}
			}
			else{
			my %tablas=&buscarTablasdeReferencias();
			foreach my $tabla(keys(%tablas)){
				$strjson.=",{'clave':'".$tabla."','valor':'".$tabla."'}";
			}
			}
		}
		else{
			my $valAuto=&obtenerValoresAutorizados();
			foreach my $val(@$valAuto){
				$strjson.=",{'clave':'".$val->{'category'}."','valor':'".$val->{'category'}."'}";
			}
		}
		$strjson=substr($strjson,1,length($strjson));
		$strjson="[".$strjson."]";
		print $input->header;
		print $strjson;
	}
}
else{
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/preferenciasResults.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });


my $buscar=$obj->{'buscar'};
my $agregar=$obj->{'agregar'};
if($agregar){
	my $modificar=$obj->{'modificar'};
	my $infoVar;
	my $valor="";
	my $op="";
	if($modificar){
		my $variable=$obj->{'variable'};
		$infoVar=&buscarPreferencia($variable);
		$valor=$infoVar->{'value'};
		$op=$infoVar->{'options'};
		my $tipo=$infoVar->{'type'};
		my @array;
		if($op ne ""){
			@array=split(/\|/,$op);
			$op=$array[1];
		}
		if($tipo eq "combo"){$tabla=$array[0];}
		$template->param(
			variable    => $variable,
			explicacion => $infoVar->{'explanation'},
			modificar   => $modificar,
			tabla	    => $tabla,
			categoria   => $op,
			campo	    => $op,
		);
	}
		my $opcion=$obj->{'opcion'}||$infoVar->{'type'};
		my $compo;
		my %labels;
		my @values;
		if($opcion eq "bool"){
			push(@values,1);
			push(@values,0);
			$labels{1}="Si";
			$labels{0}="No";
			$compo=&crearComponentes("radio","valor",\@values,\%labels,$valor);
		}
		elsif($opcion eq "texta"){
			$compo=&crearComponentes("texta","valor",60,4,$valor);
		}
		elsif($opcion eq "valAuto"){
			my $categoria=$obj->{'categoria'}||$op;
			%labels=&obtenerDatosValorAutorizado($categoria);
			@values=keys(%labels);
			$compo=&crearComponentes("combo","valor",\@values,\%labels,"");
		}
		elsif($opcion eq "combo"){
			my $campo=$obj->{'campo'}||$op;
			my $id=&obtenerIdentTablaRef($tabla);
			my ($js,$valores)=&obtenerValoresTablaRef($tabla,$id,$campo,$campo);
			@values=keys %$valores;
			foreach my $val(@values){
				$labels{$val}=$valores->{$val};
			}
			$compo=&crearComponentes("combo","valor",\@values,\%labels,$valor);
		}
		else{
			$compo=&crearComponentes("text","valor",60,\%labels,$valor);
		}
		$template->param(valor=>$compo);
}
else{
	
	my $loop=&buscarPreferencias($buscar);
	$template->param(loop => $loop);
}

$template->param(agregar=>$agregar);
output_html_with_http_headers $input, $cookie, $template->output;
}
