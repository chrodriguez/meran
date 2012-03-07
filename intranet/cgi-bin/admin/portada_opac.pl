#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::MensajesContacto;
my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name   => "admin/portada_opac.tmpl",
									query           => $input,
									type            => "intranet",
									authnotrequired => 0,
									flagsrequired   => {  ui => 'ANY', 
                                                        accion => 'TODOS', 
                                                        entorno => 'usuarios'},
									debug => 1,
			    });


my %hash_temp   = {};
my $obj         = \%hash_temp;
my $accion      = $obj->{'tipoAccion'} = $input->param('tipoAccion');
my $id_mensaje  = $input->param('id') || 0;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
