#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Catalogacion;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/estructuraCatalo.tmpl",
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

$template->param(
			selectNivel	=> $selectNivel,
			selectItemType  => $selectItemType,
);

output_html_with_http_headers $input, $cookie, $template->output;
