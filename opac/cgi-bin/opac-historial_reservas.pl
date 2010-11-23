#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record
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
use C4::Auth;

use CGI;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									query => $input,
									type => "opac",
									authnotrequired => 0,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
									debug => 1,
			});

my $nro_socio= C4::Auth::getSessionNroSocio($session);

my $ini = $input->param('page') || 0;
my $url = "/cgi-bin/koha/opac-historial_reservas.pl?token=".$input->param('token');
my $orden = 'titulo';
my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

my ($cantidad,$reservas_hashref)=&C4::AR::Estadisticas::historialReservas($nro_socio,$ini,$cantR);

$t_params->{'paginador'}= &C4::AR::Utilidades::crearPaginadorOPAC($cantidad,$cantR, $pageNumber,$url,$t_params);
$t_params->{'cantidad'}= $cantidad;
$t_params->{'loop_reservas'}= $reservas_hashref;
$t_params->{'content_title'}= C4::AR::Filtros::i18n("Historial de reservas");
$t_params->{'partial_template'}= "opac-historial_reservas.inc";
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
