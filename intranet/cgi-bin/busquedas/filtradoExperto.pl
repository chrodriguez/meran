#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Utilidades;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user ({
                                template_name	=> 'busquedas/filtradoExperto.tmpl',
                                query		=> $input,
                                type		=> "intranet",
                                authnotrequired	=> 0,
                                flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
    					});

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

$t_params->{'type'}= 'intranet';
$t_params->{'mapeo'}= $mapeo;

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
