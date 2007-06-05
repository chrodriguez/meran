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
#Este script , le pide a la modulo ImportacionIso, los datos de la tabla ISO2709 
#y se encarga de armar el arreglo para enviarlo al template import.
#

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::ImportacionIso;
use C4::Koha;

my $input = new CGI;

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || "1"; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "importacion.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

my $ok = $input->param('ok');
my $campoiso = $input->param('campoiso');
my $subcampoiso = $input->param('subcampoiso');

#Si se hizo una insercion, muestro sobre que campo y subcampo ingreso una nueva descripcion
$template->param( 
			ok 		=> $ok,
			campoiso	=> $campoiso,
			subcampoiso 	=> $subcampoiso,	
		);
my @tablaskoha =mostrarTablas(); #Tomo todas las tablas de koha para que elegir a que tabla pertenece ese campo 
#y subcampo

#Luciano
my $inicializacion="";
my $valor="";
my $i= 0;
foreach my $a(@tablaskoha) {
	my @campos= mostrarCampos($a);
        $inicializacion.= 'listaValues['.$i.'] = new Array();listaOptions['.$i.'] = new Array();';
        my $j= 0;
        foreach my $b(@campos) {
                 $valor.= 'listaValues['.$i.']['.$j.']=\''.$b.'\';listaOptions['.$i.']['.$j.']=\''.$b.'\';';
                 $j+=1;
         }
	 $i+=1;
 }
#Luciano

my @indices =listadoDeCodigosDeCampo();
my @ordenes;
push(@ordenes,"");
for($i=1;$i<=9;$i++){
        my  $algo='k'.'0'.$i;
        push(@ordenes,$algo);
}

for($i=10;$i<=60;$i++){#para los campos k interfazWeb
  	my  $algo='k'.$i;
	push(@ordenes,$algo);
}

my $campos=CGI::scrolling_list(  -name     =>'campoK',
                                 -values   => \@ordenes,
                                 -size     => 1,
                               );


my $combo= CGI::scrolling_list(  -name     =>'listaPrincipal',
                                 -values   => \@tablaskoha,
                                 -size     => 1,
                                 -onChange => 'cambiarListaDependiente(listaPrincipal,listaSecundaria)'
                               );

my @orden=("1","2","3","4","5","6","7","8","9","10");
my $orden1= CGI::scrolling_list(  -name     =>'orden',
                                  -values   => \@orden,
                                  -size     => 1,
                               );

#Por los braches
my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

#Miguel - 03-04-07 - Le agrego una opcion para que le indique al usuario que no se ha seleccionado nada aùn, ver si queda
push @select_branch,'SIN SELECCIONAR';

#agregado por Einar para que quede el branch por defecto
my $branch=$input->param('branch');
unless ($branch) {$branch=(split("_",(split(";",$cookie))[0]))[1];}
#hasta aca y la linea adentro del pasaje por parametros a la CGIbranch

my $CGIbranch=CGI::scrolling_list( 	-name      => 'branch',
		                        -id        => 'branch',
        		                -values    => \@select_branch,
        	                	-defaults  => $branch,
	        	       	        -labels    => \%select_branches,
        	        	        -size      => 1,
	                        	-multiple  => 0,
					-onChange  => 'cambioUnidadDeInformacion()',
					default    =>'SIN SELECCIONAR'
				 );
#Fin: Por los branches

my @resultsdata=datosCompletos($campoIso,$branch);

$template->param( 
			resultsloop      => \@resultsdata,
			tablaskoha       => $combo,
			indices		 => \@indices,
			inicializaciones => $inicializacion, #agregado del guardoImpo..
			valores          => $valor,    #idem anterior
			CGIbranch 	 => $CGIbranch,
			code 		 => $campoIso,
			branch           => $branch,
			ordenSelect      => $orden1,
			camposK          => $campos,
		);

output_html_with_http_headers $input, $cookie, $template->output;

