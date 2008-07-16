#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Busquedas;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "busquedas/filtradoExperto.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });


my ($branchcount,@branches)=branches();

my $mapeoHash=&buscarMapeoTotal();
my @valuesMapeo;
my %labelsMapeo;
my $value;
$labelsMapeo{-1}="Elegir Campo";
push(@valuesMapeo,-1);
$labelsMapeo{"nivel1#autor"}="Autor";
push(@valuesMapeo,"nivel1#autor");
foreach my $key (keys %$mapeoHash){
	$value=%$mapeoHash->{$key}->{'tabla'}."#".%$mapeoHash->{$key}->{'campoTabla'};
	push(@valuesMapeo,$value);
	$labelsMapeo{$value}=%$mapeoHash->{$key}->{'nombre'};
}

my $mapeo=CGI::scrolling_list(  
			-name      => 'mapeo',
			-id	   => 'mapeo',
			-values    => \@valuesMapeo,
			-labels    => \%labelsMapeo,
			-default   => -1,
			-size	   => 1,
			-onChange  => 'buscarReferencia()',
                );

$template->param(type => 'intranet',
		 mapeo=> $mapeo,
		);

output_html_with_http_headers $query, $cookie, $template->output;
