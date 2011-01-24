#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use CGI;

my $input = new CGI;

my ($template, $session, $t_params, $cookie)= get_template_and_user({
                            template_name => "reports/logueoBusqueda.tmpl",
			                query => $input,
			                type => "intranet",
			                authnotrequired => 0,
			                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			                debug => 1,
			     });

my %params;
$params{'default'}= 'SIN SELECCIONAR';
my $comboCategoriasDeSocio= C4::AR::Utilidades::generarComboCategoriasDeSocio(\%params);


$t_params->{'selectCatUsuarios'}= $comboCategoriasDeSocio;
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Logueo de B&uacute;quedas");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

