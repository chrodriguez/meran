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
use C4::Interface::CGI::Output;
use CGI;

my $input=new CGI;

my ($template, $session, $t_params)= get_template_and_user({
								template_name => "opac-HistorialPrestamos.tmpl",
								query => $input,
								type => "opac",
								authnotrequired => 0,
                                flagsrequired => {borrow => 1},
								debug => 1,
			});

my $bornum= getSessionLoggedUser($session);

my $obj=$input->param('obj');
$obj= &C4::AR::Utilidades::from_json_ISO($obj);

my $funcion= $obj->{'funcion'};
my $orden=$obj->{'orden'}||'date_due';
my $ini= $obj->{'ini'}||'';

my ($ini,$pageNumber,$cantR)= &C4::AR::Utilidades::InitPaginador($ini);
my ($cantidad,$issues)=C4::AR::Issues::historialPrestamos(C4::Auth::getSessionBorrowerNumber($session),$ini,$cantR,$orden);

$t_params->{'paginador'}= &C4::AR::Utilidades::crearPaginador($cantidad, $cantR, $pageNumber,$funcion,$t_params);
$t_params->{'loop_reading'}= $issues;
$t_params->{'cantidad'}= $cantidad;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
