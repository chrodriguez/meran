#!/usr/bin/perl

#script para administrar las tablas de referencia de lugares
#escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Koha;
use C4::Date;
use C4::Search;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "place.tmpl",
                                query => $query,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });


#Paises -> provincias -> localidades -> ciudades
my $mod = $query->param("modificando");

my $pais =( $query->param("paises"));
my $prov =( $query->param("provincias"));
my $depto_partido =( $query->param("localidades"));
my $ciudad =( $query->param("ciudades"));

#inicializo las listas
my $lista_Paises='';
my $lista_Provincias='';
my $lista_Loc='';
my $lista_Ciudad='';




if(($pais eq 0)||($pais eq '')){
	#Paises
	my %paises=mostrarPaises();
	my @codigos;

	foreach my $pais ( sort { $paises{$a} cmp $paises{$b} } keys(%paises)){
         push @codigos, $pais;
       } 


	 $lista_Paises=CGI::scrolling_list(      
					-name      => 'paises',
                                        -values    => \@codigos,
                                        -defaults  => $codigos[0],
					-labels    => \%paises,
					-size	   => 1,
					-onChange  => 'hacerSubmit()',
                                 );

	$template->param( lista_Paises        => $lista_Paises);
	}
else{
 if(($prov eq 0)||($prov eq '')){	
	#Paises->Provincias
	my @codigos;
	my $provincias;
	my %provincias;
	if ($pais != 0){
         %provincias=mostrarProvincias($pais);}
	foreach my $prov ( sort { $provincias{$a} cmp $provincias{$b} } keys(%provincias)){
         push @codigos, $prov;
       }

	foreach my $prov (keys %provincias) {
         push @codigos, $prov;
	}

	 $lista_Provincias=CGI::scrolling_list(
                                        -name      => 'provincias',
                                        -values    => \@codigos,
                                        -defaults  => $codigos[0],
                                        -labels    => \%provincias,
                                        -size      => 1,
                                        -onChange  => 'hacerSubmit()',
                                 );

	$template->param(
                   pais        => darPais($pais),
		   codpais        => $pais,
                   lista_Provincias        => $lista_Provincias);

	}
  else{
if (($depto_partido eq 0)||($depto_partido eq '')){

#Provincias->Localidades
my %local;
if ($prov != 0 ){
         %local=mostrarDepartamentos($prov);
}
my @codigos;
foreach my $ciudad ( sort { $local{$a} cmp $local{$b} } keys(%local)){
         push @codigos, $ciudad;
       }


 $lista_Loc=CGI::scrolling_list(
                                        -name      => 'localidades',
                                        -values    => \@codigos,
                                        -defaults  => $codigos[0],
                                        -labels    =>\%local,
                                        -size      => 1,
                                        -onChange  =>'hacerSubmit()',
                                 );

	 $template->param(
                   pais        => darPais($pais),
                   codpais        => $pais,
		   prov 	=> darProvincia($prov),
		   codprov	=> $prov,
                   lista_Loc       => $lista_Loc 	);

	}
	else{
	
#Localidades->Ciudades
my %ciudades;
if ($depto_partido != 0){
         %ciudades=mostrarCiudades($depto_partido);}

my @codigos;
foreach my $ciudad ( sort { $ciudades{$a} cmp $ciudades{$b} } keys(%ciudades)){
         push @codigos, $ciudad;
       }


my $lista_Ciudad=CGI::scrolling_list(
                                        -name      => 'ciudades',
                                        -values    => \@codigos,
                                        -defaults   =>$codigos[0],
                                        -labels    =>\%ciudades,
                                        -size      => 1,
                                        -onChange  => 'hacerSubmit()',
                                 );

         $template->param(
                   pais        	=> darPais($pais),
                   codpais      => $pais,
                   prov         => darProvincia($prov),
                   codprov      => $prov,
                   localidad       =>  darDepartamento($depto_partido),
		   codloc	=> $depto_partido,
		   lista_Ciudad => $lista_Ciudad    
		);

}}}
#Fin?
$template->param(modificando => $mod);

output_html_with_http_headers $query, $cookie, $template->output;
