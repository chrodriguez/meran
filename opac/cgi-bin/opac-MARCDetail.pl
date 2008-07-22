#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;
use C4::AR::Busquedas;

my $input=new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-MARCdetail.tmpl",
			     query => $input,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $idNivel3=$input->param('id3');

my @nivel2Loop= C4::AR::Busquedas::MARCDetail($idNivel3);

$template->param(
 	loopnivel2 => \@nivel2Loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
