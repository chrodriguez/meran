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
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Koha;
use C4::Search;

my $input = new CGI;

my $orden=$input->param('orden')||'surname';

my @sanctionsarray= C4::AR::Sanctions::sanciones($orden); #Se cambio para que la consulta no este en el .pl
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({	template_name => "circ/sanctions.tmpl",
				query => $input,
                            	type => "intranet",
                            	authnotrequired => 0,
                            	flagsrequired => {circulate => 1},
                           });

	
# El usuario logueado es superlibrarian????????
if ($borrowernumber eq 0){#es el kohaadmin
	$template->param(superlibrarian => 1);
}
else{
	my $data=borrdata('',$borrowernumber);
	my $dbh = C4::Context->dbh;
	my $flags= &getuserflags($data->{'cardnumber'} ,$dbh);
	$template->param(superlibrarian => $flags->{'superlibrarian'});
}
#


$template->param(	
			sanctionsloop => \@sanctionsarray
		);
output_html_with_http_headers $input, $cookie, $template->output;
