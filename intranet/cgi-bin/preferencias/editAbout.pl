#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;
use JSON;

my $input = new CGI;
my $texto = $input->param('about');

my ($template, $session, $t_params)= get_template_and_user({
                                template_name   => "about.tmpl",
                                query           => $input,
                                type            => "intranet",
                                authnotrequired => 0,
                                flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'}, # FIXME
                                debug           => 1,
                 });
                 
my ($temp)          = C4::AR::Preferencias::updateInfoAbout($texto);
my $info_about_hash = C4::AR::Preferencias::getInfoAbout(); 

$t_params->{'info_about'}     = $info_about_hash->{'descripcion'};
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Acerca De MERAN");
                 
C4::AR::Auth::output_html_with_http_headers($template, $t_params,$session);
