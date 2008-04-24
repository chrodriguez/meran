#!/usr/bin/perl

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
# use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;

my $query=new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
     template_name   => 'circ/receipt.tmpl',
     query           => $query,
     type            => "intranet",
     authnotrequired => 0,
     flagsrequired   => { circulate => 1 },
    });

my %env;
my %args = {};

$args{'borrowerName'} = $query->param('borrowerName');
$args{'borrowerNumber'} = $query->param('borrowerNumber');
$args{'documentType'} = $query->param('documentType');
$args{'documentNumber'} = $query->param('documentNumber');
$args{'author'} = $query->param('author');
$args{'bookTitle'} = $query->param('bookTitle');
$args{'inventory'} = $query->param('inventory');
$args{'topoSign'} = $query->param('topoSign');
$args{'barcode'} = $query->param('barcode');
$args{'volume'} = $query->param('volume');
$args{'borrowDate'} = $query->param('borrowDate');
$args{'returnDate'} = $query->param('returnDate');
$args{'librarian'} = $query->param('librarian');
$args{'librarianNumber'} = $query->param('librarianNumber');
$args{'issuedescription'} = $query->param('issuedescription');

$template->param (%args);
output_html_with_http_headers $query, $cookie, $template->output;
