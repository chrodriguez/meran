#!/usr/bin/perl

#Genera un inventario a partir de la busqueda por nro. de inventario



use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use ooolib;

my $input = new CGI;

my @results;
my  $from=$input->param('from');
my $to=$input->param('to');

#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");
$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Reporte de Inventario (C&oacute;digo de barras)");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Reporte");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 11);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Ministerio de Educación
Universidad Nacional de La Plata
");
$sheet->oooSet("text-size", 10);
$pos++;
#$sheet->set_colwidth (1, 2000);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Nro. Inventario");
#$sheet->set_colwidth (2, 1000);
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "Autor");
#$sheet->set_colwidth (4, 4000);
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", "Título");
#$sheet->set_colwidth (5, 10000);
$sheet->oooSet("cell-loc", 4, $pos);
$sheet->oooData("cell-text", "Edic.");
$sheet->oooSet("cell-loc", 5, $pos);
$sheet->oooData("cell-text", "Editor");
$sheet->oooSet("cell-loc", 6, $pos);
$sheet->oooData("cell-text", "Año");
$sheet->oooSet("cell-loc", 7, $pos);
$sheet->oooData("cell-text", "Signatura Topográfica");
#$sheet->set_colwidth (9, 1000);
$sheet->oooSet("bold", "off");

$pos++;
##


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
my @res = C4::Circulation::Circ2::listitemsforinventory($from,$to);
#

my $class='par';       
foreach my $element (@res) {
                my %line;
		$line{'clase'}= $class;
		if($class eq 'par'){$class='impar'}else{$class='par'}; 
                
		$line{'barcode'}=$element->{'barcode'};
		$line{'biblionumber'}=$element->{'biblionumber'};
		$line{'bulk'}=$element->{'bulk'};
		$line{'author'}=$element->{'author'}->{'completo'};
		$line{'title'}=$element->{'title'};
		$line{'unititle'}=$element->{'unititle'};
		$line{'publisher'}=$element->{'publisher'};
		$line{'publicationyear'}=$element->{'publicationyear'};
		$line{'number'}=$element->{'number'};

	##Lleno los datos
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", $line{'barcode'});

	$sheet->oooSet("cell-loc", 7, $pos);
	$sheet->oooData("cell-text", $line{'bulk'});
	
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-text", $line{'author'});
	
	$sheet->oooSet("cell-loc", 3, $pos);
	if($line{'unititle'} eq ""){$sheet->oooData("cell-text", $line{'title'});}
	else{	my $titulo=$line{'title'}.": ".$line{'unititle'};
		$sheet->oooData("cell-text", $titulo);}

	$sheet->oooSet("cell-loc", 4, $pos);
	$sheet->oooData("cell-text", $line{'number'});
	
	$sheet->oooSet("cell-loc", 5, $pos);
	$sheet->oooData("cell-text", $line{'publisher'});
	
	$sheet->oooSet("cell-loc", 6, $pos);
	$sheet->oooData("cell-text", $line{'publicationyear'});
	
	$pos++;
	##
        push (@results, \%line);
}


my $name='inventario-'.$loggedinuser;
$sheet->oooGenerate($name);

my $cant=scalar(@results);

#Por los branches
                my $branch=$input->param('branch');
                ($branch ||($branch=C4::Context->preference("defaultbranch")));
#


my $MIN=C4::Circulation::Circ2::getminbarcode($branch);
my $MAX=C4::Circulation::Circ2::getmaxbarcode($branch);

$template->param( 
			results => \@results,
			name => $name,
			cant =>$cant,
			from => $from,
			to => $to,
			MAX => $MAX,
			MIN => $MIN
		);

output_html_with_http_headers $input, $cookie, $template->output;
