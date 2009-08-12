#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;

my ($template, $t_params)= C4::Output::gettemplate("changepassword.tmpl", 'intranet');

# my ($userid, $session, $flags) = checkauth( $input, 
#                                             $authnotrequired,
#                                             {   ui => 'ANY', 
#                                                 tipo_documento => 'ANY', 
#                                                 accion => 'MODIFICACION', 
#                                                 entorno => 'usuarios'
#                                             },
#                                             "intranet"
#                             );


#     my ($template, $session, $t_params)= get_template_and_user({
#                                         template_name => "changepassword.tmpl",
#                                         query => $input,
#                                         type => "intranet",
#                                         authnotrequired => 0,
#                                         flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
#                                         debug => 1,
#             });
# my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
#             template_name   => 'changepassword.tmpl',
#             query       => $input,
#             type        => "intranet",
#             authnotrequired => 0,
#             flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
#     });

my $session = CGI::Session->load();

# my %params;
$t_params->{'nro_socio'}= $input->param('usuario');
$t_params->{'actualPassword'}= $input->param('actual_password');
$t_params->{'changePassword'}= $input->param('changePassword');
$t_params->{'newpassword'}= $input->param('new_password1');
$t_params->{'newpassword1'}= $input->param('new_password2');
$t_params->{'token'}= $input->param('token');
# $t_params->{'nro_socio'}= '26320';
#     $params{'session'}= $session;

$t_params->{'loggedinusername'}= $session->param('userid');
$t_params->{'loggedinuser'}= $session->param('userid');
my $nro_socio = $session->param('userid');
# FIXME sacar luego de pasar todo a los nombre nuevos
$session->param('borrowernumber',$nro_socio);#se esta pasadon por ahora despues sacar
$t_params->{'nro_socio'}= $nro_socio;
$session->param('nro_socio',$nro_socio);
# $session->param('id_socio',$socio->getId_socio);
$t_params->{'token'}= $session->param('token');

# my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);

# $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($Message_arrayref->{'messages'}->[0]->{'codMsg'});

&C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);




