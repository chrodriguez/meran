#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
# use C4::Koha;
# use HTML::Template;

my $input=new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
     template_name   => 'circ/receipt.tmpl',
     query           => $input,
     type            => "intranet",
     authnotrequired => 0,
     flagsrequired   => { circulate => 1 },
    });

my %env;
my %args = {};
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
$args{'borrowerName'} = $obj->{'borrowerName'};
$args{'borrowerNumber'} = $obj->{'borrowerNumber'};
$args{'documentType'} = $obj->{'documentType'};
$args{'documentNumber'} = $obj->{'documentNumber'};
$args{'author'} = $obj->{'autor'};
$args{'bookTitle'} = $obj->{'titulo'};
$args{'inventory'} = $obj->{'inventory'};
$args{'topoSign'} = $obj->{'topoSign'};
$args{'barcode'} = $obj->{'barcode'};
$args{'volume'} = $obj->{'volume'};
$args{'borrowDate'} = $obj->{'borrowDate'};
$args{'returnDate'} = $obj->{'returnDate'};
$args{'librarian'} = $obj->{'librarian'};
$args{'librarianNumber'} = $obj->{'librarianNumber'};
$args{'issuedescription'} = $obj->{'issuedescription'};

$template->param (%args);
output_html_with_http_headers $input, $cookie, $template->output;
