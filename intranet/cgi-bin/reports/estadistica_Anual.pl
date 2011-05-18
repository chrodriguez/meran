#!/usr/bin/perl


use strict;
use C4::AR::Auth;

use CGI;


my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/estadistica_Anual.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
			    });

my  $branch=$input->param('branch');


$t_params->{'year'}= C4::AR::Utilidades::generarComboDeAnios();
$t_params->{'branch'}= $branch;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
