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
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::AR::StatGraphs;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params)
    = get_template_and_user({template_name => "reports/levels.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


my  $ui= $input->param('ui_name') || C4::Context->preference("defaultUI");

my %params;
$params{'onChange'}= 'hacerSubmit()';
my $ComboUI=C4::AR::Utilidades::generarComboUI(\%params);

my ($cantidad,@resultsdata)= levelsReport($ui); 
my $torta=&levelsPie($ui,$cantidad, @resultsdata);
my $barras=&levelsHBars($ui,$cantidad, @resultsdata);

$t_params->{'resultsloop'}=\@resultsdata;
$t_params->{'unidades'}= $ComboUI;
$t_params->{'cantidad'}=$cantidad;
$t_params->{'ui'}= $ui;
$t_params->{'barras'}=$barras;
$t_params->{'torta'}=$torta;

C4::Auth::output_html_with_http_headers($input, $template, $t_params,$session);
