#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Koha;
use C4::Date;
use C4::Search;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "provincias.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });

my $pais=($input->param('paises'));

my @codigos;
my $provincias;
my %provincias;
if ($pais != 0){
	 %provincias=mostrarProvincias($pais);}

foreach my $prov ( sort { $provincias{$a} cmp $provincias{$b} } keys(%provincias)){
         push @codigos, $prov;
       }




foreach my $prov (keys %provincias) {
         push @codigos, $prov;
}

my $lista_Provincias=CGI::scrolling_list(      
					-name      => 'provincias',
                                        -values    => \@codigos,
					-defaults  => $codigos[0],
                                        -labels    => \%provincias,
                                        -size      => 1,
					-onChange  => 'hacerSubmit()',
                                 );

$template->param( 
		   lista_Provincias        => $lista_Provincias,
		   modificando        => $input->param('modificando')
		);
output_html_with_http_headers $input, $cookie, $template->output;
