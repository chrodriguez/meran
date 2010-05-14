#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;

my $input = new CGI;

my ($template, $session, $t_params, $socio)  = get_template_and_user({
                            template_name => "admin/global/mailConfig.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
                 });


$t_params->{'smtp_server'}                              = C4::Context->preference("smtp_server");
$t_params->{'smtp_metodo'}                              = C4::Context->preference("smtp_metodo")||1;
$t_params->{'port_mail'}                                = C4::Context->preference("port_mail");
$t_params->{'username_mail'}                            = C4::Context->preference("username_mail");
$t_params->{'password_mail'}                            = C4::Context->preference("password_mail");
$t_params->{'mailFrom'}                                 = C4::Context->preference("mailFrom");
$t_params->{'reserveFrom'}                              = C4::Context->preference("reserveFrom");
$t_params->{'smtp_server_sendmail'}                     = C4::Context->preference("smtp_server_sendmail");
$t_params->{C4::Context->preference("smtp_metodo")}     = 1;

    
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
