#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario



use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::SxcGenerator;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                template_name => "reports/inventory.tmpl",
                                                query => $input,
                                                type => "intranet",
                                                authnotrequired => 0,
                                                flagsrequired => {borrowers => 1},
                                                debug => 1,
			    });

#Por los branches
my $branch=$input->param('branch');
( $branch || ($branch=C4::AR::Preferencias->getValorPreferencia("defaultbranch")) );
#

my $MIN=C4::Circulation::Circ2::getMinBarcode($branch);
my $MAX=C4::Circulation::Circ2::getMaxBarcode($branch);

my @barcodePorTipo=C4::Circulation::Circ2::barcodesPorTipo($branch);

$t_params->{'MAX'}= $MAX;
$t_params->{'MIN'}= $MIN;
$t_params->{'barcodePorTipo'}=\@barcodePorTipo;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
