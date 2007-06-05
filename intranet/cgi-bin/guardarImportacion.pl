#!/usr/bin/perl



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
#
#Este script , recibe el array desde el tmpl importacion con los datos de las descripciones
#a agregar a la tabla ISO2709, 
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::ImportacionIso;

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "importacion.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


#my $i=0;
#my $descripciones = $input->param('descripciones');#tomo el string de id's de los campos 
#my @datos=split(/,/,$descripciones); ##lo convierto a un array
#	foreach my  $a(@datos) { 
#		my $des =$input->param('descripcion'.$a); ##tomo el texto de la descripcion
#		/insertDescripcion($des,$a); ##inserto en la tabla ISO2709
#		$i=$i + 1;
#		}

#my @tablaskoha=mostrarTablas();

#Luciano
#my $inicializacion="";
#my $valor="";
#my $i= 0;
#foreach my $a(@tablaskoha) {
#	my @campos= mostrarCampos($a);
#       $inicializacion.= 'listaValues['.$i.'] = new Array();listaOptions['.$i.'] = new Array();';
#        my $j= 0;
#        foreach my $b(@campos) {
#                $valor.= 'listaValues['.$i.']['.$j.']=\''.$b.'\';listaOptions['.$i.']['.$j.']=\''.$b.'\';';
#                $j+=1;
#        }
#        $i+=1;
#}
##Luciano
#

my $id =$input->param('id');
my $campoIso=$input->param('campoIso');
my $subCampoIso=$input->param('subCampoIso');
my $descripcion=$input->param('descripcion');

my $campoKoha=$input->param('listaSecundaria');
my $tablaKoha=$input->param('listaPrincipal');
my $orden=$input->param('orden');
my $separador=$input->param('separador');
my $campoK=$input->param('campoK');

#my $combo= CGI::scrolling_list( -name     =>'listaPrincipal',
#                                -values   => \@tablaskoha,
#                                -size     => 1,
#				-onChange => 'cambiarListaDependiente(listaPrincipal,listaSecundaria)'
#                               );

insertNuevo($descripcion ,$tablaKoha , $campoIso, $subCampoIso, $campoKoha, $orden,$separador,$id,$campoK);

#if ($i>=1) {
$template->param(
                            ok          => \'ok',
#			    tablaskoha  => $combo,
			    descripcionI => $descripcion,
                	    subcampoiso => $subCampoIso,
			    campoiso    => $campoIso,
			    tablakoha  => $tablaKoha,
			    campoKoha  => $campoKoha,
#			    id          => $id,
#			    inicializaciones => $inicializacion,
#			    valores => $valor
		 );

#$template->param( 
#			    cantidad => $i,
#					);

#output_html_with_http_headers $input, $cookie, $template->output;
print $input->redirect('importacion.pl?campoiso='.$campoIso.'&subcampoiso='.$subCampoIso.'&ok=1&code='.$campoIso);
