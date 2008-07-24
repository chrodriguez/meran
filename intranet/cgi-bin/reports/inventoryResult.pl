#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::SxcGenerator;

my $input = new CGI;

my @results;
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $desde=$obj->{'desde'};
my $hasta=$obj->{'hasta'};
my $orden=$obj->{'orden'}||'barcode';

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/inventoryResult.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {reports => 1},
			     debug => 1,
			     });

#Buscar
my ($cant,@res) = C4::Circulation::Circ2::listitemsforinventory($desde,$hasta,"",1,"todos",$orden); #Hay que paginar
#

# Generar Planilla
my $planilla=generar_planilla_inventario(\@res,$loggedinuser);
#

foreach my $element (@res) {
                my %line;
		$line{'barcode'}=$element->{'barcode'};
		$line{'id1'}=$element->{'id1'};
		$line{'signatura_topografica'}=$element->{'signatura_topografica'};
		$line{'autor'}=$element->{'completo'};
		$line{'titulo'}=$element->{'titulo'};
		$line{'unititle'}=$element->{'unititle'};
		$line{'publisher'}=$element->{'publisher'};
		$line{'anio_publicacion'}=$element->{'anio_publicacion'};
		$line{'number'}=$element->{'number'};
	        push (@results, \%line);
}

# my $cant=scalar(@results);

$template->param( 
			results => \@results,
			name    => $planilla,
			cantidad    => $cant,
			desde   => $desde,
			hasta   => $hasta,
		);

output_html_with_http_headers $input, $cookie, $template->output;
