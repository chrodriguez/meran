#!/usr/bin/perl
#written 5/7/2005 by Luciano Iglesias
#script to manage sanctions to borrowers

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
use C4::AR::Auth;


my $input = new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
            template_name   => 'circ/sancionesResult.tmpl',
            query       => $input,
            type        => "intranet",
            authnotrequired => 0,
            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
    });

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $orden=$obj->{'orden'}||'persona.apellido';

my $sanciones= C4::AR::Sanciones::sanciones($orden);
$t_params->{'CANT_SANCIONES'}=scalar(@$sanciones);
$t_params->{'SANCIONES'}= $sanciones;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);