#!/usr/bin/perl

# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)
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

use HTML::Template;
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => ('busquedas/MARCDetalle.tmpl'),
	query           => $input,
	type            => "intranet",
	authnotrequired => 0,
	flagsrequired   => {catalogue => 1},
    });

my $idNivel3=$input->param('id3');

my @nivel2Loop= &MARCDetail($idNivel3);

$template->param(
 	loopnivel2 => \@nivel2Loop,
);


output_html_with_http_headers $input, $cookie, $template->output;
