#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user ({
	template_name	=> 'circ/detalleUsuario.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);
my $borrnumber= $obj->{'borrowernumber'};

my @resultBorrower;
$resultBorrower[0]=C4::AR::Usuarios::getBorrowerInfo($borrnumber);

$template->param(
	borrower => \@resultBorrower,
);

output_html_with_http_headers $input, $cookie, $template->output;

