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

my $theme = $input->param('theme') || "default";
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventory-sig-top.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });


#Buscar
my @res;
if($sigtop ne ''){
	@res = C4::Circulation::Circ2::listitemsforinventorysigtop($sigtop);
}
#
my $class='par';       
foreach my $element (@res) {
                my %line;
		$line{'clase'}= $class;
		if($class eq 'par'){$class='impar'}else{$class='par'}; 
                
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

#
my $planilla=generar_planilla_inventario_sig_top(\@results,$loggedinuser);
#

my $cant=scalar(@results);

#Por los branches
                my $branch=$input->param('branch');
                ($branch ||($branch=C4::Context->preference("defaultbranch")));
#

$template->param( 
			results => \@results,
			name => $planilla,
			cant =>$cant,
			sigtop => $sigtop,
		);

output_html_with_http_headers $input, $cookie, $template->output;
