#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::CatalogacionOpac;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/estructuraCataloOpac.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });


#***********************************************item type*********************************
 my ($cant,@results)= C4::AR::Busquedas::getItemTypes();
 my @valuesItemtypes;
 my %labelsItemtypes;
 my $i=0;
 
 for ($i; $i<scalar(@results); $i++){
 	push(@valuesItemtypes,$results[$i]->{'itemtype'});
 	$labelsItemtypes{$results[$i]->{'itemtype'}}=$results[$i]->{'description'};
 }

#fin item type

 my $selectItemType=CGI::scrolling_list(  	-name      => 'comboTiposItems',
 						-id	   => 'comboTiposItems',
                                 		-values    => \@valuesItemtypes,
 						-labels    => \%labelsItemtypes,
                                 		-defaults  => 'LIB',
                                 		-size      => 1,
						-onChange	=> 'changeTipoItem()',
                                  	);

 my $selectItemTypeAltaEncabezado=CGI::scrolling_list(  	-name      => 'comboTiposItems',
 						-id	   => 'comboTiposItemsAltaEncabezado',
                                 		-values    => \@valuesItemtypes,
 						-labels    => \%labelsItemtypes,
                                 		-defaults  => 'LIB',
                                 		-size      => 1,
                                  	);
#*********************************************fin item type*********************************


$template->param(
			selectItemType  => $selectItemType,
			selectItemTypeAltaEncabezado  => $selectItemTypeAltaEncabezado,
);

output_html_with_http_headers $input, $cookie, $template->output;
