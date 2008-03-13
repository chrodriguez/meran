#!/usr/bin/perl



# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
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
use ooolib;

my $input = new CGI;

my  $shelf=$input->param('shelf');


#Por los shelfs
my @select_shelfs;
my %select_shelfs;
my $env;
my ($count)=      &getshelfListCount('public');
my  %shelflist = &GetShelfList('public',0, $count);
 
foreach my $she (keys %shelflist) {
        push @select_shelfs, $she;
        $select_shelfs{$she} = %shelflist->{$she}->{'shelfname'};
	if ($shelf eq ''){$shelf=$she; }
}

#Miguel - 03-04-07 - Le agrego una opcion para que le indique al usuario que no se ha seleccionado nada aùn, ver si queda
push @select_shelfs, 'SIN SELECCIONAR';
                                                                                                                             
my $CGIshelf=CGI::scrolling_list(      -name      => 'shelf',
                                        -id        => 'shelf',
                                        -values    => \@select_shelfs,
                                        -defaults  => $shelf,
                                        -labels    => \%select_shelfs,
                                        -size      => 1,
                                        -onChange  =>'hacerSubmit()',
					default    =>'SIN SELECCIONAR'
                                 );
#Fin: 


#Genero la hoja de calculo Openoffice
my $sheet=new ooolib("sxc");

$sheet->oooSet("builddir","./plantillas");
$sheet->oooSet("title","Reporte de Estantes");
$sheet->oooSet("author","KOHA");
$sheet->oooSet("subject","Reporte");
$sheet->oooSet("bold", "on");
my $pos=1;
$sheet->oooSet("text-size", 12);
$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", GetShelfName('',$shelf) );
$sheet->oooSet("text-size", 10);
$pos++;

$sheet->oooSet("cell-loc", 1, $pos);
$sheet->oooData("cell-text", "Estantes");
$sheet->oooSet("cell-loc", 2, $pos);
$sheet->oooData("cell-text", "Títulos");
$sheet->oooSet("cell-loc", 3, $pos);
$sheet->oooData("cell-text", "Ejemplares");
$sheet->oooSet("cell-loc", 4, $pos);
$sheet->oooData("cell-text", "No Disponibles");
$sheet->oooSet("cell-loc", 5, $pos);
$sheet->oooData("cell-text", "Para Prestar");
$sheet->oooSet("cell-loc", 6, $pos);
$sheet->oooData("cell-text", "Para Sala");
$sheet->oooSet("bold", "off");
$pos++;
##

my $theme = $input->param('theme') || "default";
my $campoIso = $input->param('code') || ""; 
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estantes.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });



my $titulostot=0;
my $ejemplarestot=0;
my $unavailabletot=0;
my $forloantot=0;
my $notforloantot=0;
        my (%shelfcontentslist)= GetShelfContentsShelf($env,'public',$shelf);

#para los subestantes
       my @shelvesloopshelves;
	my @key;
	@key=sort { noaccents($shelfcontentslist{$a}->{'shelfname'} ) cmp noaccents($shelfcontentslist{$b}->{'shelfname'} ) } keys(%shelfcontentslist);
	my $class='par';       
foreach my $element (@key) {
                my %line;
		$line{'clase'}= $class;
		if($class eq 'par'){$class='impar'}else{$class='par'}; 
                $line{'shelfname'}=$shelfcontentslist{$element}->{'shelfname'};
                $line{'shelfnumber'}=$shelfcontentslist{$element}->{'shelfnumber'};
                $line{'count'}=$shelfcontentslist{$element}->{'count'};
($line{'titulos'},$line{'ejemplares'},$line{'unavailable'},$line{'forloan'},$line{'notforloan'})=shelfitemcount($shelfcontentslist{$element}->{'shelfnumber'});
                $line{'countshelf'}=$shelfcontentslist{$element}->{'countshelf'};

	#Sumas totales
	$titulostot+=$line{'titulos'};
	$ejemplarestot+=$line{'ejemplares'};
	$unavailabletot+=$line{'unavailable'};
	$forloantot+=$line{'forloan'};
	$notforloantot+=$line{'notforloan'};

	##Lleno los datos
	 $sheet->oooSet("cell-loc", 1, $pos);
	 $sheet->oooData("cell-text", $line{'shelfname'});
	 $sheet->oooSet("cell-loc", 2, $pos);
         $sheet->oooData("cell-float", $line{'titulos'});
	 $sheet->oooSet("cell-loc", 3, $pos);
	 $sheet->oooData("cell-float", $line{'ejemplares'});
	 $sheet->oooSet("cell-loc", 4, $pos);
         $sheet->oooData("cell-float", $line{'unavailable'});
	 $sheet->oooSet("cell-loc", 5, $pos);
         $sheet->oooData("cell-float", $line{'forloan'});
	 $sheet->oooSet("cell-loc", 6, $pos);
	 $sheet->oooData("cell-float", $line{'notforloan'});
	 $pos++;
	##
                push (@shelvesloopshelves, \%line);}

	#TOTALES
	
	$sheet->oooSet("bold", "on");
	$sheet->oooSet("cell-loc", 1, $pos);
	$sheet->oooData("cell-text", "Totales");
	$sheet->oooSet("cell-loc", 2, $pos);
	$sheet->oooData("cell-float", $titulostot);
	$sheet->oooSet("cell-loc", 3, $pos);
	$sheet->oooData("cell-float", $ejemplarestot);
	$sheet->oooSet("cell-loc", 4, $pos);
	$sheet->oooData("cell-float", $unavailabletot);
	$sheet->oooSet("cell-loc", 5, $pos);
	$sheet->oooData("cell-float", $forloantot);
	$sheet->oooSet("cell-loc", 6, $pos);
	$sheet->oooData("cell-float", $notforloantot);
        $sheet->oooSet("bold", "off");
	$pos++;

	#

my $name='estantes-'.$loggedinuser;
$sheet->oooGenerate($name);

my $cant=scalar(@shelvesloopshelves);
$template->param( 
			estantes         => $CGIshelf,	
			cantidad         => $cant,
			shelvesloopshelves => \@shelvesloopshelves,
			shelf => $shelf,
			name => $name,
			titulostot => $titulostot,
			ejemplarestot =>$ejemplarestot,
			unavailabletot =>$unavailabletot,
			forloantot =>$forloantot,
			notforloantot =>$notforloantot

		);

output_html_with_http_headers $input, $cookie, $template->output;
