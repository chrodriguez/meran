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
use C4::AR::SxcGenerator;

my $input = new CGI;

my  $shelf=$input->param('shelf');
my $nameShelf=GetShelfName('',$shelf);
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/estantesResult.tmpl",

			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });


my $env;
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
foreach my $element (@key) {
                my %line;
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

                push (@shelvesloopshelves, \%line);
}


my $name=generar_planilla_estantes(\@shelvesloopshelves,$loggedinuser,$nameShelf);

my $cant=scalar(@shelvesloopshelves);
$template->param(
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
