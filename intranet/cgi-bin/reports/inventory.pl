#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario



use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::SxcGenerator;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventory.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });

#Por los branches
my $branch=$input->param('branch');
($branch ||($branch=C4::Context->preference("defaultbranch")));
#

my $MIN=C4::Circulation::Circ2::getminbarcode($branch);
my $MAX=C4::Circulation::Circ2::getmaxbarcode($branch);

my @barcodePorTipo=C4::Circulation::Circ2::barcodesbytype($branch);

$template->param(
			MAX => $MAX,
			MIN => $MIN,
			barcodePorTipo=>\@barcodePorTipo,
		);

output_html_with_http_headers $input, $cookie, $template->output;
