#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
require Exporter;
use Net::Twitter;
use Net::Twitter::Role::OAuth;
use Scalar::Util 'blessed';
use WWW::Shorten::Bitly;
use C4::AR::Social;

# my $consumer_key        = "ee4q1gf165jmFQTObJVY2w";
# my $consumer_secret     = "F4TEnfC1SjYm3XG6vHZ0aJmsYQIFysyu9bwjG9BDdQ";
# my $token               = "148446079-IL4MsMqXzKU24xMr32No58H5meHmsqLMZHk4qZ0";
# my $token_secret        = "fSCpzZELbLFYQPJtP7nRJFQjgfGXvR0538a0i0AIcj0"; 

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "/main.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'usuarios'},
                                    debug => 1,
                });



my $post=$input->param('post_twitter');

my $mensaje= C4::AR::Social::sendPost($post);

# my $nt= C4::AR::Social::connectTwitter();
# 
# my $result = $nt->update($post);
#     
# if ( my $err = $@ ) {
#       $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('SC001','intranet').$err->isa('Net::Twitter::Error') ;
#     
# #     $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('SC000'.':' $@ unless blessed $err && $err->isa('Net::Twitter::Error') ,'intranet');
# #         warn "HTTP Response Code: ", $err->code, "\n",
# #              "HTTP Message......: ", $err->message, "\n",
# #              "Twitter error.....: ", $err->error, "\n";
# } else {
#     $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('SC000','intranet');
#     
# #     $t_params->{'mensaje'}    = C4::AR::Mensajes::getMensaje('SC000','intranet');
# }

$t_params->{'mensaje'} = $mensaje;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);










