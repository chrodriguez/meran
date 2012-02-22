#!/usr/bin/perl
use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Prestamos;

my $input = new CGI;

my ($template, $session, $t_params) = C4::AR::Auth::get_template_and_user({
									template_name   => "admin/circulacion/prestamos_vencidos.tmpl",
									query           => $input,
									type            => "intranet",
									authnotrequired => 0,
                                    flagsrequired   => {  ui            => 'ANY', 
                                                        tipo_documento  => 'ANY', 
                                                        accion          => 'ALTA', 
                                                        entorno         => 'undefined'},
});

my $prestamos_array_ref   = C4::AR::Prestamos::getAllPrestamosVencidos();
$t_params->{'prestamos'}  = $prestamos_array_ref;
$t_params->{'cantidad'}   = scalar(@$prestamos_array_ref);

if(C4::AR::Preferencias::getValorPreferencia('enableMailPrestVencidos')){

    $t_params->{'mensaje'}  = 'Se enviar&aacute;n los mails de pr&eacute;stamos vencidos a la brevedad';

}

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
