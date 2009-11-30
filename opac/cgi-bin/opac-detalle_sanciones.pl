#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use CGI;

my $query = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-main.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
            });

$t_params->{'opac'};

my $nro_socio = C4::Auth::getSessionNroSocio();
my $sanc= C4::AR::Sanciones::estaSancionado($nro_socio);
my $dateformat = C4::Date::get_date_format();
foreach my $san (@$sanc) {
    if ($san->{'id3'}) {
        my $aux=C4::AR::Nivel1::buscarNivel1PorId3($san->{'id3'}); 
        $san->{'description'}.=": ".$aux->{'titulo'}." (".$aux->{'completo'}.") "; }
        $san->{'fecha_final'}=format_date($san->{'fecha_final'},$dateformat);
        $san->{'fecha_comienzo'}=format_date($san->{'fecha_comienzo'},$dateformat);
    }
if (scalar(@$sanc) > 0){
    $t_params->{'sanciones_loop'}= $sanc;
}

$t_params->{'partial_template'}= "opac-detalle_sanciones.inc";
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
