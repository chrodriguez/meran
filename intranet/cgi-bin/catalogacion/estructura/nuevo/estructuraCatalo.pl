#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                                                template_name => "catalogacion/estructura/nuevo/estructuraCatalo.tmpl",
			                                                    query => $input,
			                                                    type => "intranet",
			                                                    authnotrequired => 0,
			                                                    flagsrequired => {editcatalogue => 1},
			                                                    debug => 1,
			     });

my %params_combo;
$params_combo{'onChange'}= 'eleccionDeNivel("0")';
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboTipoNivel3(\%params_combo);
$t_params->{'selectItemType'}= $comboTiposNivel3;

#Niveles
my @nivel;
my $cantNivel=3;
push(@nivel, "Niveles");
for (my $i=1; $i<=$cantNivel; $i++){
	push(@nivel, $i);
}
my $selectNivel=CGI::scrolling_list(  
                                    -name      => 'nivel',
				                    -id	   => 'nivel',
                                    -values    => \@nivel,
                                    -defaults  => 'Niveles',
                                    -size      => 1,
				                    -onChange  => 'eleccionDeNivel("0")',
                                 );
#fin niveles

$t_params->{'selectNivel'}=$selectNivel;



C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
