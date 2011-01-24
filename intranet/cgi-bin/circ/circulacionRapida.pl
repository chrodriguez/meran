#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;


my $input=new CGI;


my ($template, $session, $t_params, $usuario_logueado) =  get_template_and_user ({
							template_name	=> 'circ/circulacionRapida.tmpl',
							query		    => $input,
							type		    => "intranet",
							authnotrequired	=> 0,
							flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                });


$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Circulaci&oacute;n R&aacute;pida");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
