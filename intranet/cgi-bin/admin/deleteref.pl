#!/usr/bin/perl
#script para administrar el borrado de elementos de las tablas de referencia
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
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/deleteref.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $tabla=$input->param('editandotabla');
my $codigo=$input->param('editandocodigo');
my $camporeferencia=$input->param('editandoidentificador');
my @campos=obtenerCampos($tabla);
my @loop= valoresTabla($tabla,$camporeferencia,$codigo);
my @valoresSimilares = valoresSimilares($tabla,$camporeferencia,$codigo);
my $ind=$input->param('editandoind');
($ind||($ind=0)); 
my $cant=$input->param('editandocant');
($cant||($cant=20)); 
my $orden=$input->param('editandoorden');
my @loopRelacionados= tablasRelacionadas($tabla,$camporeferencia,$codigo);


#para agregar la clase y que se vea la zebra
my $num= 1;
foreach my $res (@loop) {
	((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    	$num++;
}

#para agregar la clase y que se vea la zebra
my $num= 1;
foreach my $res (@valoresSimilares) {
	((($num % 2) && ($res->{'clase'} = 'par' ))|| ($res->{'clase'}='impar'));
    	$num++;
}

$template->param(camposloop => \@campos,
		loop => \@loop,
		loopRelacionados =>\@loopRelacionados,
		editandoSimilares=>\@valoresSimilares,
		editandoind=>$ind,
		editandocant => $cant,
		editandotabla=>$tabla,
		editandoidentificador=>$camporeferencia,
		editandocodigo=>$codigo,
		editandoorden=>$orden);
	




output_html_with_http_headers $input, $cookie, $template->output;

