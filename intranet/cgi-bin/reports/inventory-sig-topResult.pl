#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por signatura topografica



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use C4::AR::SxcGenerator;

my $input = new CGI;

my @results;
my $sigtop= $input->param('sigtop');
my $orden= $input->param('orden');

my $theme = $input->param('theme') || "default";
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventory-sig-topResult.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });


#Buscar
my @res;
if($sigtop ne ''){
	@res = C4::Circulation::Circ2::listitemsforinventorysigtop($sigtop,$orden);
}
#
# Generar Planilla
my $planilla=generar_planilla_inventario_sig_top(\@res,$loggedinuser);
#

foreach my $element (@res) {
        my %line;
	$line{'barcode'}=$element->{'barcode'};
	$line{'biblionumber'}=$element->{'biblionumber'};
	$line{'bulk'}=$element->{'bulk'};
	$line{'id'}=$element->{'id'};
	$line{'author'}=$element->{'author'}->{'completo'};
	$line{'title'}=$element->{'title'};
	$line{'unititle'}=$element->{'unititle'};
	$line{'publisher'}=$element->{'publisher'};
	$line{'publicationyear'}=$element->{'publicationyear'};
	$line{'number'}=$element->{'number'};
        push (@results, \%line);
}

my $cant=scalar(@results);

$template->param(
			results  => \@results,
			name     => $planilla,
			cantidad => $cant,
		);

output_html_with_http_headers $input, $cookie, $template->output;
