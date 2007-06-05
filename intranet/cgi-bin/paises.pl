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

my $query = new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "paises.tmpl",
                                query => $query,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });

my %paises=mostrarPaises();
my @codigos;

foreach my $pais ( sort { $paises{$a} cmp $paises{$b} } keys(%paises)){
         push @codigos, $pais;
       } 


my $lista_Paises=CGI::scrolling_list(      
					-name      => 'paises',
                                        -values    => \@codigos,
                                        -defaults  => $codigos[0],
					-labels    => \%paises,
					-size	   => 1,
					-onChange  => 'hacerSubmit()',
                                 );
$template->param( 
		   lista_Paises        => $lista_Paises,
		   modificando        => $query->param('modificando')
		);

output_html_with_http_headers $query, $cookie, $template->output;
