#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use C4::AR::SxcGenerator;

my $input = new CGI;

my @results;
my  $from=$input->param('from');
my $to=$input->param('to');

my $theme = $input->param('theme') || "default";
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventory.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });

#Buscar
my ($cant,@res) = C4::Circulation::Circ2::listitemsforinventory($from,$to,"",1,"todos"); #Hay que paginar
#

# Generar Planilla
my $planilla=generar_planilla_inventario(\@res,$loggedinuser);
#

my $class='par';       
foreach my $element (@res) {
                my %line;
		$line{'clase'}= $class;
		if($class eq 'par'){$class='impar'}else{$class='par'}; 
                
		$line{'barcode'}=$element->{'barcode'};
		$line{'biblionumber'}=$element->{'biblionumber'};
		$line{'bulk'}=$element->{'bulk'};
		$line{'author'}=$element->{'completo'};
		$line{'title'}=$element->{'title'};
		$line{'unititle'}=$element->{'unititle'};
		$line{'publisher'}=$element->{'publisher'};
		$line{'publicationyear'}=$element->{'publicationyear'};
		$line{'number'}=$element->{'number'};
	        push (@results, \%line);
}

my $cant=scalar(@results);

#Por los branches
                my $branch=$input->param('branch');
                ($branch ||($branch=C4::Context->preference("defaultbranch")));
#


my $MIN=C4::Circulation::Circ2::getminbarcode($branch);
my $MAX=C4::Circulation::Circ2::getmaxbarcode($branch);

$template->param( 
			results => \@results,
			name => $planilla,
			cant =>$cant,
			from => $from,
			to => $to,
			MAX => $MAX,
			MIN => $MIN
		);

output_html_with_http_headers $input, $cookie, $template->output;
