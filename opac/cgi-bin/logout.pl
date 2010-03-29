#!/usr/bin/perl

use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI::Session;

my $input=new CGI;

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
            template_name   => 'opac-main.tmpl',
            query       => $input,
            type        => "intranet",
            authnotrequired => 0,
            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
            loging_out      => 1,
    });

my ($session)= C4::Auth::cerrarSesion();

$t_params->{'partial_template'}= "opac-content_data.inc";

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
