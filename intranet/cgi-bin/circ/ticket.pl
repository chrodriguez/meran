#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;


my $input=new CGI;


my ($template, $session, $t_params) =  get_template_and_user ({
			template_name	=> 'circ/ticket.tmpl',
			query		=> $input,
			type		=> "intranet",
			authnotrequired	=> 0,
			flagsrequired	=> {    ui => 'ANY', 
                                    tipo_documento => 'ANY', 
                                    accion => 'CONSULTA', 
                                    entorno => 'undefined'},
    });


my %env;
my $obj                             = C4::AR::Utilidades::from_json_ISO($input->param('obj'));

$t_params->{'socio'}                = C4::AR::Usuarios::getSocioInfoPorNroSocio($obj->{'socio'});
$t_params->{'responsable'}          = C4::AR::Usuarios::getSocioInfoPorNroSocio($obj->{'responsable'});
$t_params->{'prestamo'}             = C4::AR::Prestamos::getPrestamoDeId3($obj->{'id3'});
$t_params->{'adicional_selected'}   = $obj->{'adicional_selected'};


   C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);