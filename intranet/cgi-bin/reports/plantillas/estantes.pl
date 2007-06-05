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
use OpenOffice::OOCBuilder;

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
# - start sxc document
my $sheet=new OpenOffice::OOCBuilder();

# - Set Meta.xml data
$sheet->set_title ('Reportes de Estantes Virtuales');
$sheet->set_author ('KOHA');

# - Set name of first sheet
$sheet->set_sheet_name ('Reporte',1);
# - Set some data
# columns can be in numbers or letters
$sheet->set_bold (1);
my $pos=1;
$sheet->set_fontsize(12);
$sheet->set_data_xy (1, $pos, GetShelfName('',$shelf));
$sheet->set_fontsize(10);
$pos++;
$sheet->set_data_xy (1, $pos, 'Estantes');
$sheet->set_colwidth (1, 15000);
$sheet->set_data_xy (2, $pos, 'Titulos');
$sheet->set_data_xy (3, $pos, 'Ejemplares');
$sheet->set_data_xy (4, $pos, 'No Disponibles');
$sheet->set_data_xy (5, $pos, 'Para Prestar');
$sheet->set_data_xy (6, $pos, 'Para Sala');
$sheet->set_bold (0);

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
	$sheet->set_data_xy (1, $pos, $line{'shelfname'});
	 $sheet->set_data_xy (2, $pos, $line{'titulos'}, 'float');
	$sheet->set_data_xy (3, $pos, $line{'ejemplares'}, 'float');
	$sheet->set_data_xy (4, $pos, $line{'unavailable'}, 'float');
	$sheet->set_data_xy (5, $pos, $line{'forloan'}, 'float');
	$sheet->set_data_xy (6, $pos, $line{'notforloan'}, 'float');
	$pos++;
	##
                push (@shelvesloopshelves, \%line);}

	#TOTALES
	$sheet->set_bold (1);
	$sheet->set_data_xy (1, $pos, 'Totales');
        $sheet->set_data_xy (2, $pos, $titulostot, 'float');
        $sheet->set_data_xy (3, $pos, $ejemplarestot, 'float');
        $sheet->set_data_xy (4, $pos, $unavailabletot, 'float');
        $sheet->set_data_xy (5, $pos, $forloantot, 'float');
        $sheet->set_data_xy (6, $pos, $notforloantot, 'float');
        $pos++;

	#

my $name='estantes'.$loggedinuser;
$sheet->generate($name);

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
