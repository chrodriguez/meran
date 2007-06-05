#!/usr/bin/perl
#script para administrar las tablas de referencia
#escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Inform�tica, UNLP
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
use C4::Context;
use C4::Output;
use C4::Search;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/referencies.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $tabla=$input->param('editandotabla');
my $valores=buscarTabladeReferencia($tabla);
my $env;
my @campos=obtenerCampos($tabla);
my $ind=$input->param('editandoind');
($ind||($ind=0)); 
my $cant=$input->param('editandocant');
($cant||($cant=20)); 
my $orden=$input->param('editandoorden');
($orden||($orden=$valores->{'orden'})); 


my ($total,@loop)= listadoTabla($tabla,$ind,$cant,$valores->{'camporeferencia'},$orden);
$template->param(camposloop =>\@campos,
		loop =>\@loop,
		editandoind=>$ind,
		editandocant=> $cant,
		editandoorden=> $orden,
		editandotabla=> $tabla,
		editandoidentificador=> $valores->{'nomcamporeferencia'},
		editandototal=> $total);


output_html_with_http_headers $input, $cookie, $template->output;

