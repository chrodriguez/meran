use strict;
use CGI;
use C4::AR::Auth;
use C4::Output;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                        template_name   => "admin/global/ldapConfig.tmpl",
                        query           => $input,
                        type            => "intranet",
                        authnotrequired => 0,
                        flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        debug           => 1,
			    });

$t_params->{'page_sub_title'}          = C4::AR::Filtros::i18n("Configuraci&oacute;n Servidor LDAP");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
