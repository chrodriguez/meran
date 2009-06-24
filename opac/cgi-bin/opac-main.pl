#!/usr/bin/perl
use strict;
require Exporter;

use C4::Output;  # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use CGI::Session;

my $input = new CGI;


my ($template, $session, $t_params)= get_template_and_user({
									template_name => "opac-main.tmpl",
									type => "opac",
									query => $input,
# 									                                    authnotrequired => 1,
# FIXME no esta funcionando el loggin desde aca!!!!
									authnotrequired => 0, 
									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    });

# if( $session->param('nro_socio') ){
# }else{
#     #se inicializa la session y demas parametros para autenticar
# 	$t_params->{'opac'};
#     ($session)= C4::Auth::inicializarAuth($input, $t_params);
# }

# my ($template, $t_params)= C4::Output::gettemplate("opac-main.tmpl", 'opac');

#se inicializa la session y demas parametros para autenticar
$t_params->{'opac'};
my ($session)= C4::Auth::inicializarAuth($input, $t_params);

$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
