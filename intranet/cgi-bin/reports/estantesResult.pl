#!/usr/bin/perl

#
use strict;
use C4::AR::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::AR::Utilidades;
use C4::BookShelves;
use C4::AR::SxcGenerator;

my $input = new CGI;

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $shelf=$obj->{'shelf'};
my $nameShelf=GetShelfName('',$shelf);

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/estantesResult.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
			    });

my $nro_socio = $session->param('nro_socio');
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


my $name=generar_planilla_estantes(\@shelvesloopshelves,$nro_socio,$nameShelf);

my $cant=scalar(@shelvesloopshelves);


$t_params->{'cantidad'}= $cant;
$t_params->{'shelvesloopshelves'}= \@shelvesloopshelves;
$t_params->{'shelf'}= $shelf;
$t_params->{'name'}= $name;
$t_params->{'titulostot'}= $titulostot;
$t_params->{'ejemplarestot'}=$ejemplarestot;
$t_params->{'unavailabletot'}=$unavailabletot;
$t_params->{'forloantot'}=$forloantot;
$t_params->{'notforloantot'}=$notforloantot;


C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
