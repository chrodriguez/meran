#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por signatura topografica



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;
use C4::Koha;
use C4::BookShelves;
use OpenOffice::OOCBuilder;

my $input = new CGI;

my @results;
my $sigtop= $input->param('sigtop');

#Genero la hoja de calculo Openoffice
# - start sxc document
my $sheet=new OpenOffice::OOCBuilder();

# - Set Meta.xml data
$sheet->set_title ('Reporte de Inventario');
$sheet->set_author ('KOHA');

# - Set name of first sheet
$sheet->set_sheet_name ('Reporte',1);
# - Set some data
# columns can be in numbers or letters
$sheet->set_bold (1);
my $pos=1;
$sheet->set_fontsize(11);
$sheet->set_data_xy (1, $pos, "Ministerio de Educación
Universidad Nacional de La Plata
Biblioteca de la Facultad de Ciencias Económicas");

$sheet->set_fontsize(10);
$pos++;
$sheet->set_data_xy (1, $pos, 'Fecha');
$sheet->set_colwidth (1, 2000);
$sheet->set_data_xy (2, $pos, 'Nro. Inventario');
$sheet->set_colwidth (2, 1000);
$sheet->set_data_xy (3, $pos, 'Ejs.');
$sheet->set_data_xy (4, $pos, 'Autor');
$sheet->set_colwidth (4, 4000);
$sheet->set_data_xy (5, $pos, 'Título');
$sheet->set_colwidth (5, 10000);
$sheet->set_data_xy (6, $pos, 'Edic.');
$sheet->set_data_xy (7, $pos, 'Editor');
$sheet->set_data_xy (8, $pos, 'Año');
$sheet->set_data_xy (9, $pos, 'Signatura Topográfica');
$sheet->set_colwidth (9, 1000);
$sheet->set_bold (0);

$pos++;
##


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

	##Lleno los datos
	$sheet->set_data_xy (2, $pos, $line{'barcode'});
	$sheet->set_data_xy (9, $pos, $line{'bulk'});
	$sheet->set_data_xy (4, $pos, $line{'author'});
	if($line{'unititle'} eq ""){
		$sheet->set_data_xy (5, $pos, $line{'title'});
	}
	else{
		my $titulo=$line{'title'}.": ".$line{'unititle'};
		$sheet->set_data_xy (5, $pos, $titulo);
	}
	$sheet->set_data_xy (6, $pos, $line{'number'});
	$sheet->set_data_xy (7, $pos, $line{'publisher'});
	$sheet->set_data_xy (8, $pos, $line{'publicationyear'});
	$pos++;
	##
        push (@results, \%line);
}


my $name='inventario'.$loggedinuser;
$sheet->generate($name);

my $cant=scalar(@results);

#Por los branches
                my $branch=$input->param('branch');
                ($branch ||($branch=C4::Context->preference("defaultbranch")));
#

$template->param( 
			results => \@results,
			name => $name,
			cant =>$cant,
			sigtop => $sigtop,
		);

output_html_with_http_headers $input, $cookie, $template->output;
