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

my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0,{ editcatalogue => 1});

my $nivel=$input->param('nivel');
my $itemtype=$input->param('itemtype');
my $cant=$input->param('cant');

my $objeto=$input->param('objeto');
my $objetoResp;
if($objeto ne ""){
	$objetoResp = &C4::AR::Utilidades::from_json_ISO($objeto);
}

my $ok=&guardarCampoTemporal($objetoResp,$nivel,$itemtype);
$objetoResp->{'ok'}=$ok;
my $tabla=$objetoResp->{'tabla'};
my $tipoInput=$objetoResp->{'tipo'};
my $campos=$objetoResp->{'campos'};
my $orden=$objetoResp->{'orden'};
if($tabla != -1 && $tipoInput eq "combo"){
	my $ident=&C4::AR::Utilidades::obtenerIdentTablaRef($tabla);
	my $opciones=&C4::AR::Utilidades::obtenerValoresTablaRef($tabla,$ident,$campos,$orden);
	$objetoResp->{'opciones'}=$opciones
}

my $resultadoJSON = to_json $objetoResp;

#Para que no valla a un tmpl
print $input->header;
print $resultadoJSON;
