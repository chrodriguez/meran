#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use HTML::Template;
use C4::Koha;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/logueoBusqueda.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });



#Cargo todos los Select
#*********************************Select de Categoria de Usuarios**********************************
my @select_catUsuarios_Values;
my %select_catUsuarios_Labels;

my ($array,$hasheado)=&borrowercategories(); 
push @select_catUsuarios_Values, 'SIN SELECCIONAR';
my $i=0;
my @catUsuarios_Values;

foreach my $codCatUsuario (@$array) {

	push @select_catUsuarios_Values, $codCatUsuario;
	$select_catUsuarios_Labels{$codCatUsuario} = $hasheado->{$codCatUsuario};
	$i++;
}

my $CGISelectCatUsuarios=CGI::scrolling_list(	-name      => 'catUsuarios',
                                        	-id        => 'catUsuarios',
                                        	-values    => \@select_catUsuarios_Values,
                                        	-labels    => \%select_catUsuarios_Labels,
                                        	-size      => 1,
						-defaults  => 'SIN SELECCIONAR'
                                 		);
#Se lo paso al template
$template->param(selectCatUsuarios => $CGISelectCatUsuarios);
#*********************************Fin Select de Categoria de Usuarios******************************

output_html_with_http_headers $input, $cookie, $template->output;
