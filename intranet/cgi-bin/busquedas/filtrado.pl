#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Catalogue;
use C4::AR::Utilidades;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "busquedas/filtrado.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });


my ($branchcount,@branches)=branches();

#combo itemtype
	my ($cant,@results)= C4::Biblio::getitemtypes();
	my @valuesItemtypes;
	my %labelsItemtypes;
	my $i=0;
	push(@valuesItemtypes,-1);
	$labelsItemtypes{-1}="Cualquiera";
	for ($i; $i<scalar(@results); $i++){
		push(@valuesItemtypes,$results[$i]->{'itemtype'});
		$labelsItemtypes{$results[$i]->{'itemtype'}}=$results[$i]->{'description'};
	}
#fin combo
	my $comboItemTypes= &crearComponentes('combo',
						'comboItemTypes',
						\@valuesItemtypes,
						\%labelsItemtypes,'');


$template->param(
			type => 'intranet',
		 	branches=>\@branches,
		 	comboItemTypes=> $comboItemTypes
		);

output_html_with_http_headers $query, $cookie, $template->output;
