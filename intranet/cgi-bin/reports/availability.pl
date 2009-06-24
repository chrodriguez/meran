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
use C4::AR::Utilidades;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
								template_name => "reports/availability.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			    });

my  $ui= $input->param('ui') || C4::AR::Preferencias->getValorPreferencia("defaultUI");

my $ComboUI=C4::AR::Utilidades::generarComboUI();
my $ComboDisponibilidad=C4::AR::Utilidades::generarComboDeDisponibilidad();

$t_params->{'disponibilidades'}= $ComboDisponibilidad;
$t_params->{'unidades'}= $ComboUI;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
