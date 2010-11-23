#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
<<<<<<< HEAD:intranet/cgi-bin/catalogacion/estructura/detalle.pl
=======

>>>>>>> 392fc8ce7552b2fe84deab2c0361e9e6d69bab87:intranet/cgi-bin/catalogacion/estructura/detalle.pl

my $input=new CGI;

BEGIN {$Exporter::Verbose=1}

my ($template, $session, $t_params) = get_template_and_user({
							template_name   => ('catalogacion/estructura/detalle.tmpl'),
							query           => $input,
							type            => "intranet",
							authnotrequired => 0,
							flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'datos_nivel1'},
						});

my $id1=$input->param('id1');

#genera el detalle para intra y setea los parametros para el template
C4::AR::Nivel3::detalleCompletoINTRA($id1, $t_params);
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Catalogaci&oacute;n - Detalle del &iacute;tem");

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
