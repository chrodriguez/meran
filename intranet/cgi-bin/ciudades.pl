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
= get_template_and_user({template_name => "ciudades.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });

my $depto_partido =( $input->param("localidades")); 
my %ciudades;
if ($depto_partido != 0){
	 %ciudades=mostrarCiudades($depto_partido);}

my @codigos;
foreach my $ciudad ( sort { $ciudades{$a} cmp $ciudades{$b} } keys(%ciudades)){
         push @codigos, $ciudad;
       }


my $lista_Ciudad=CGI::scrolling_list(      
					-name      => 'ciudades',
                                        -values    => \@codigos,
					-defaults   =>$codigos[0],
					-labels    =>\%ciudades,
					-size	   => 1,
					-onChange  => 'hacerSubmit()',
                                 );
$template->param( 
		   lista_Ciudad        => $lista_Ciudad,
		   modificando        => $input->param('modificando')
		);

output_html_with_http_headers $input, $cookie, $template->output;
