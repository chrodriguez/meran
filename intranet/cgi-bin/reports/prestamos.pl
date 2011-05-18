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
#

use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::SxcGenerator;
use C4::AR::Busquedas;

my $input = new CGI;

my $msg = $input->param('msg') || "";

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/prestamos.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
			    });
#Por los branches
my @branches;
my @select_branch;
my %select_branches;
my $branches=C4::AR::Busquedas::getBranches();
foreach my $branch (keys %$branches) {
        push @select_branch, $branch;
        $select_branches{$branch} = $branches->{$branch}->{'branchname'};
}

my $branch= C4::AR::Preferencias::getValorPreferencia('defaultUI');

my $CGIbranch=C4::AR::Utilidades::generarComboUI();
#Fin: Por los branches

$t_params->{'unidades'}= $CGIbranch;
$t_params->{'msg'}= $msg;

$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Prestamos no devueltos");


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);



