#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

#written 8/5/2002 by Finlay
#script to execute issuing of books

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
use C4::Koha;
use HTML::Template;
use C4::Date;
use C4::AR::Issues;
use Date::Manip;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/detallePrestamos.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrnumber'};

my $issueslist = prestamosPorUsuario($borrnumber);
my @issues;
my $dateformat = C4::Date::get_date_format();

foreach my $it (keys %$issueslist) {
	my $book= $issueslist->{$it};
	$book->{'date_due'} = format_date($book->{'date_due'},$dateformat);
# 	my $err= "Error con la fecha";
# 	my $hoy=C4::Date::format_date_in_iso(ParseDate("today"),$dateformat);
# 	my $close = ParseDate(C4::Context->preference("close"));
# 	if (Date::Manip::Date_Cmp($close,ParseDate("today"))<0){#Se paso la hora de cierre
# 		$hoy=C4::Date::format_date_in_iso(DateCalc($hoy,"+ 1 day",\$err),$dateformat);
# 	} NO SE USA!!!!!!

	my ($vencido,$df)= &C4::AR::Issues::estaVencido($book->{'id3'},$book->{'issuecode'});
	$book->{'date_fin'} = format_date($df,$dateformat);
	if ($vencido){$book->{'color'} ='red';}

# 	$book->{'renew'} = &sepuederenovar($borrnumber, $book->{'id3'});
	$book->{'issuetype'}=$book->{'issuetype'};
	if ($book->{'autor'} eq ''){$book->{'autor'}=' ';}

	push @issues,$book
}

my $cantIssues=scalar(@issues);

$template->param(
	issues     	=> \@issues,
	cantIssues 	=> $cantIssues,
	borrowernumber  => $borrnumber
);

output_html_with_http_headers $input, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
