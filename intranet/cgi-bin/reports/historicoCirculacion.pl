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
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "reports/historicoCirculacion.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                    debug => 1,
                            });



$t_params->{'selectusuarios'}= C4::AR::Utilidades::generarComboDeSocios();
$t_params->{'selectTipoPrestamos'}= C4::AR::Utilidades::generarComboTipoPrestamo();
$t_params->{'selectTipoOperacion'}= C4::AR::Utilidades::generarComboTipoDeOperacion();
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Historico de Circulacion");


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
