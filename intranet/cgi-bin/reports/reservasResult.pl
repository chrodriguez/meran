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
use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/reservasResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $branch=$obj->{'branch'};
my $orden = $obj->{'orden'} || 'cardnumber';
my $tipoReserva=$obj->{'tipoReserva'}; # Tipo de reserva
my $funcion=$obj->{'funcion'};
#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini=$obj->{'ini'};
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion


my ($cant,@resultsdata)= reservas($branch,$orden,$ini,$cantR,$tipoReserva);

C4::AR::Utilidades::crearPaginador($template, $cant,$cantR, $pageNumber,$funcion);

$template->param(
			resultsloop      => \@resultsdata,
			cantidad         => $cant,
		);

output_html_with_http_headers $input, $cookie, $template->output;
