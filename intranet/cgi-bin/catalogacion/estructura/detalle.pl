#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input=new CGI;

my ($template, $session, $t_params) = get_template_and_user({
																	template_name   => ('catalogacion/estructura/nuevo/detalle.tmpl'),
																	query           => $input,
																	type            => "intranet",
																	authnotrequired => 0,
																	flagsrequired   => {catalogue => 1},
										});

my $id1=$input->param('id1');

#genera el detalle para intra y setea los parametros para el template
C4::AR::Nivel3::detalleCompletoINTRA($id1, $t_params);

C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
