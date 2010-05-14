#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Auth;         # checkauth, getnro_socio.
use C4::Interface::CGI::Output;
use C4::Date;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-main.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
             });


$t_params->{'partial_template'}= "opac-favoritos.inc";

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

1;
