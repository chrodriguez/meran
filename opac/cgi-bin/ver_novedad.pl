#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::AR::Auth;         # checkauth, getnro_socio.

use C4::AR::Novedades;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name   => "opac-main.tmpl",
                                    query           => $query,
                                    type            => "opac",
                                    authnotrequired => 1,
                                    flagsrequired   => {  ui            => 'ANY', 
                                                        tipo_documento  => 'ANY', 
                                                        accion          => 'CONSULTA', 
                                                        entorno         => 'undefined'},
             });


my $id_novedad                  = $input->param('id');
my $novedad                     = C4::AR::Novedades::getNovedad($id_novedad);

$t_params->{'novedad'}          = $novedad;
$t_params->{'partial_template'} = "ver_novedad.inc";

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
