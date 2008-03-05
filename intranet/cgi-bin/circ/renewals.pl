#!/usr/bin/perl
#written 11/3/2002 by Finlay
#script to execute returns of books

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
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
use C4::Print;
use C4::AR::Issues;
use C4::AR::Reserves;
use C4::AR::Sanctions;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Koha;
use Date::Manip;

my $query=new CGI;
#getting the template
my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => "circ/renewals.tmpl",
			query => $query,
			type => "intranet",
			authnotrequired => 0,
			flagsrequired => {circulate => 1},
			});

my $okMensaje;
my $hasdebts=0;
my $sanction=0;
my $enddate;
my $badbarcode=0;
my %env;
my $barcode = $query->param('barcode');
# actually return book and prepare item table.....
if ($barcode) {
    # decode cuecat
    $barcode = cuecatbarcodedecode($barcode);
    my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
    my ($returned) = devolver($iteminformation->{'itemnumber'},$iteminformation->{'borrowernumber'},$borrowernumber);
    if ($returned) {
	    $okMensaje= 'El libro fue devuelto';
    } else {
	# El codigo de barras no es valido
	    $badbarcode = 1;
    }
}

$template->param(       
		okMensaje => $okMensaje,
		hasdebts => $hasdebts,
		sanction => $sanction,
		enddate => $enddate,
		badbarcode => $badbarcode,
		barcode => $barcode,
);

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;

sub cuecatbarcodedecode {
	my ($barcode) = @_;
	chomp($barcode);
	my @fields = split(/\./,$barcode);
	my @results = map(decode($_), @fields[1..$#fields]);
	if ($#results == 2){
		return $results[2];
	} else {
		return $barcode;
	}
}

# Local Variables:
# tab-width: 4
# End:
