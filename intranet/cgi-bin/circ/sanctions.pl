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
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Sanctions;

my $input = new CGI;

my ($template, $session, $params) =  get_template_and_user ({
            template_name   => 'circ/sanctions.tmpl',
            query       => $input,
            type        => "intranet",
            authnotrequired => 0,
            flagsrequired   => { circulate => 1 },
    });

my $orden=$input->param('orden')||'surname';
my @sanctionsarray= &sanciones($orden); #Se cambio para que la consulta no este en el .pl	
my $borrowernumber = $session->param('borrowernumber');
# El usuario logueado es superlibrarian????????
# if ($borrowernumber eq 0){#es el kohaadmin
# 	$params->{'superlibrarian'}=1;
# }
# else{ #es superlibrarian o puede actualizar sanciones??
# 	my $data=C4::AR::Usuarios::getBorrower($borrowernumber);
# 	my $dbh = C4::Context->dbh;
# 	my $flags= &getuserflags($data->{'cardnumber'} ,$dbh);
# 	$params->{'superlibrarian'}= $flags->{'superlibrarian'}||$flags->{'updatesanctions'};
# }
#


$params->{'sanctionsloop'}= \@sanctionsarray;
$params->{'responsable'}= $borrowernumber;

C4::Auth::output_html_with_http_headers($input, $template, $params);
