#!/usr/bin/perl

# $Id: addbiblio-nomarc.pl,v 1.2 2003/05/09 23:47:22 rangi Exp $

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
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

# $Log: addbiblio-nomarc.pl,v $
# Revision 1.2  2003/05/09 23:47:22  rangi
# This script is now templated
# 3 more to go i think
#

use CGI;
use strict;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui.simple/addbiblio-nomarc.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);


my %tiposColaboradores=obtenerTiposDeColaboradores();

#Habria que agregar un valor SIN SELECCIONAR por defecto
#Se arma el Select de Funcion
$tiposColaboradores{0}='--Seleccione uno--';
my @colabtypes;
foreach my $aux  ( sort { $tiposColaboradores{$a} cmp $tiposColaboradores{$b} } keys(%tiposColaboradores))
{ push(@colabtypes,$aux);}
my $referenciaColaboradores=CGI::scrolling_list(-name     =>'referenciaColaboradores',
                                 		-defaults => 0,
				 		-values => \@colabtypes,
						-labels    => \%tiposColaboradores,
                                 		-size     => 1,
				 		-id =>"referenciaColaboradores",
				 		-onChange=>"cambiarTipo();",
                               			);

my $error = $input->param('error');

$template->param(
    resp => C4::Context->preference("responsability"),  # Esta habilitada la mencion de resp.?
    ERROR => $error,
    referenciaColaboradores=> $referenciaColaboradores
);

output_html_with_http_headers $input, $cookie, $template->output;
