#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;

# my ($template, $t_params)= C4::Output::gettemplate("changepassword.tmpl", 'intranet');

# my ($userid, $session, $flags) = checkauth( $input, 
#                                             $authnotrequired,
#                                             {   ui => 'ANY', 
#                                                 tipo_documento => 'ANY', 
#                                                 accion => 'MODIFICACION', 
#                                                 entorno => 'usuarios'
#                                             },
#                                             "intranet"
#                             );

# 
#     my ($template, $session, $t_params)= get_template_and_user({
#                                         template_name => "changepassword.tmpl",
#                                         query => $input,
#                                         type => "intranet",
#                                         authnotrequired => 1,
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

my %params;
$params{'nro_socio'}= $input->param('usuario');
$params{'actualPassword'}= $input->param('actual_password');
$params{'changePassword'}= $input->param('changePassword');
$params{'newpassword'}= $input->param('new_password1');
$params{'newpassword1'}= $input->param('new_password2');
$params{'token'}= $input->param('token');
# $t_params->{'nro_socio'}= '26320';
#     $params{'session'}= $session;

my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);

# $t_params->{'mensaje'} = C4::AR::Mensajes::getMensaje($Message_arrayref->{'messages'}->[0]->{'codMsg'});

# &C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
C4::Auth::redirectTo('/cgi-bin/koha/usuarios/change_password.pl');




