#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;


my ($template, $session, $params) =  get_template_and_user ({
			template_name	=> 'circ/receipt.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> { circulate => 1 },
    });

my %env;
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
$params{'borrowerName'} = $obj->{'borrowerName'};
$params{'borrowerNumber'} = $obj->{'borrowerNumber'};
$params{'documentType'} = $obj->{'documentType'};
$params{'documentNumber'} = $obj->{'documentNumber'};
$params{'author'} = $obj->{'autor'};
$params{'bookTitle'} = $obj->{'titulo'};
$params{'inventory'} = $obj->{'inventory'};
$params{'topoSign'} = $obj->{'topoSign'};
$params{'barcode'} = $obj->{'barcode'};
$params{'volume'} = $obj->{'volume'};
$params{'borrowDate'} = $obj->{'borrowDate'};
$params{'returnDate'} = $obj->{'returnDate'};
$params{'librarian'} = $obj->{'librarian'};
$params{'librarianNumber'} = $obj->{'librarianNumber'};
$params{'issuedescription'} = $obj->{'issuedescription'};


C4::Auth::output_html_with_http_headers($input, $template, $params);
