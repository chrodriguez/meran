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
= get_template_and_user({template_name => "localidades.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {permissions => 1},
                                debug => 1,
                                });

my $prov=($input->param("provincias"));
my %local;
if ($prov != 0 ){
	 %local=mostrarDepartamentos($prov);
}
my @codigos;
foreach my $ciudad ( sort { $local{$a} cmp $local{$b} } keys(%local)){
         push @codigos, $ciudad;
       }


my $lista_Loc=CGI::scrolling_list(      
					-name	   => 'localidades',
                                        -values    => \@codigos,
					-defaults  => $codigos[0],
					-labels    =>\%local,
					-size	   => 1,
					-onChange  =>'hacerSubmit()',
                                 );
$template->param( 
		   lista_Loc        => $lista_Loc,
		   modificando        => $input->param('modificando')
		);
output_html_with_http_headers $input, $cookie, $template->output;
