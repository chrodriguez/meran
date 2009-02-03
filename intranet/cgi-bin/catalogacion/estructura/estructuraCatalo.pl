#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Catalogacion;

my $input = new CGI;

        my ($template, $session, $t_params) = get_template_and_user({
                 template_name => "catalogacion/estructura/estructuraCatalo.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });


#item type
my ($cant,@results)= C4::AR::Busquedas::getItemTypes();
my @valuesItemtypes;
my %labelsItemtypes;
my $i=0;
push(@valuesItemtypes,'ALL');
$labelsItemtypes{'ALL'}='TODOS';
for ($i; $i<scalar(@results); $i++){
	push(@valuesItemtypes,$results[$i]->{'itemtype'});
	$labelsItemtypes{$results[$i]->{'itemtype'}}=$results[$i]->{'description'};
}

my $selectItemType=CGI::scrolling_list(  -name      => 'itemtype',
				-id	   => 'itemtype',
                                -values    => \@valuesItemtypes,
				-labels    => \%labelsItemtypes,
                                -defaults  => 'LIB',
                                -size      => 1,
				-onChange  => 'eleccionDeNivel("0")',
                                 );
#fin item type
my $comboTiposNivel3= &C4::AR::Utilidades::generarComboCategoriasDeSocio();
$t_params->{'selectItemType'}= $comboTiposNivel3;

#Niveles
my @nivel;
my $cantNivel=3;
push(@nivel, "Niveles");
for (my $i=1; $i<=$cantNivel; $i++){
	push(@nivel, $i);
}
my $selectNivel=CGI::scrolling_list(  -name      => 'nivel',
				-id	   => 'nivel',
                                -values    => \@nivel,
                                -defaults  => 'Niveles',
                                -size      => 1,
				-onChange  => 'eleccionDeNivel("0")',
                                 );
#fin niveles

$t_params->{'selectNivel'}=$selectNivel;
# $t_params->{'selectItemType'}= $selectItemType;


C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
