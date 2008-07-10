#!/usr/bin/perl

# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)
#
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


# use HTML::Template;
use strict;
require Exporter;
# use C4::Context;
# use C4::Output;  # contains gettemplate
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

my $input=new CGI;

my $id1=$input->param('id1');
my $accion=$input->param('accion');

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ('busquedas/detalle.tmpl'),
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });



if($accion eq "borrarGrupo"){
	my $id2=$input->param('id2');
	&eliminarNivel2($id2);
}
elsif($accion eq "borrarN1"){
	&eliminarNivel1($id1);
}
elsif($accion eq "borrarEjemplar"){
	my $id3=$input->param('id3');
	&eliminarNivel3($id3);
}


my $nivel1=&buscarNivel1($id1); #C4::AR::Catalogacion;
my $cantItemN1=&cantidadItem(1,$id1);
my @autor= getautor($nivel1->{'autor'});
my @nivel1Loop= &detalleNivel1($id1, $nivel1,"intra");
my @nivel2Loop= &detalleNivel2($id1,"intra");

$template->param(
	loopnivel1 => \@nivel1Loop,
	loopnivel2 => \@nivel2Loop,
	titulo     => $nivel1->{'titulo'},
	id1	   => $id1,
	cantItemN1 => $cantItemN1,
	datosautor => \@autor,
);

output_html_with_http_headers $input, $cookie, $template->output;
