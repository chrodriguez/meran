#!/usr/bin/perl

use strict;

require Exporter;

use CGI;
use C4::AR::Auth;
use C4::AR::Nivel3 qw(detalleCompletoINTRA);


my $input=new CGI;

my $ajax = $input->param('ajax') || 0;

my ($template, $session, $t_params) = get_template_and_user({
							template_name   => ('catalogacion/estructura/detalle.tmpl'),
							query           => $input,
							type            => "intranet",
							authnotrequired => 0,
							flagsrequired   => {    ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'datos_nivel1'},
						});

my $id1=$input->param('id1');

$t_params->{'page'} = $input->param('page') || 0;

eval{ 
    my ($cant_total)    =   C4::AR::Nivel3::detalleCompletoINTRA($id1, $t_params);
    $t_params->{'cant_total'}           = $cant_total;
};


$t_params->{'per_page'}             = C4::Context->config("cant_grupos_per_query") || 5;
$t_params->{'ajax'}                 = $ajax;
$t_params->{'page_sub_title'}   = C4::AR::Filtros::i18n("Catalogaci&oacute;n - Detalle del &iacute;tem");
$t_params->{'mensaje'}          = $input->url_param('msg_file');
$t_params->{'pref_e_documents'} = C4::AR::Preferencias::getPreferencia("e_documents");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
