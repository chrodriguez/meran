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

# my ($template, $t_params)= C4::Output::gettemplate("opac-main.tmpl", 'opac');
# my ($session) = CGI::Session->load();

# my $random_number= C4::Auth::_generarNroRandom();
# $t_params->{'RANDOM_NUMBER'}= $random_number;
$t_params->{'opac'};
$t_params->{'partial_template'}= "opac-content_data.inc";
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
