#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Search;
use HTML::Template;
use C4::Interface::CGI::Output;
use C4::Date;

my $query = new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-userdetails.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });


my $dateformat = C4::Date::get_date_format();
# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);

$borr->{'dateenrolled'} = format_date($borr->{'dateenrolled'},$dateformat);
$borr->{'expiry'}       = format_date($borr->{'expiry'},$dateformat);
$borr->{'dateofbirth'}  = format_date($borr->{'dateofbirth'},$dateformat);
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'},$dateformat);


$template->param($borr,
			     LibraryName => C4::Context->preference("LibraryName"),
			     pagetitle => "Detalles del usuario",
);

output_html_with_http_headers $query, $cookie, $template->output;

