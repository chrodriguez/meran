#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::Context;

my $input = new CGI;




my ($template, $session, $t_params, $socio)  = get_template_and_user({
                            template_name => "admin/global/mailConfig.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {  ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'undefined'},
                            debug => 1,
                 });

if($input->Vars->{'msj'}){
    $t_params->{'mensaje'}    = $input->Vars->{'msj'};
    
}
my $preferencias_mail         = C4::AR::Preferencias::getPreferenciasByCategoriaHash('mail');
$t_params->{'preferencias'}   = $preferencias_mail;
$t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Configuraci&oacute;n del Mail");
C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
