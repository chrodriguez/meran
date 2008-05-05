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
use C4::AR::Catalogacion;
use JSON;

my $input = new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

my $paso=$input->param('paso');
my $itemtype=$input->param('itemtype');
my $accion=$input->param('accion');
my $id1=$input->param('id1');

#BUSQUEDA de campos modificados que se generan dinamicamente para mostrar en el tmpl
my $modificar;
my $cant=0;
if($accion eq "modificarN1"){
	($cant,$modificar)=&buscarNivel1Completo($id1);
}

my %results = &buscarCamposModificadosYObligatorios($paso,$itemtype);
my ($cantIds,@resultsdata)=&crearCatalogo(0,$modificar,$cant,$itemtype,%results);

my @resultsdata2;
if($paso >= 2){
	my %results2=&buscarCamposModificadosYObligatorios(3,$itemtype);
	($cantIds,@resultsdata2)=&crearCatalogo($cantIds,$modificar,$cant,$itemtype,%results2);
	push(@resultsdata,@resultsdata2);
}


# my $resultadoJSON = encode_json \@resultsdata;
my $resultadoJSON = to_json \@resultsdata;#PARA QUE MUESTRE BIEN LOS ACENTOS.

#Para que no valla a un tmpl
print $input->header;
print $resultadoJSON;
