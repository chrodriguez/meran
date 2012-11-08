#!/usr/bin/perl
use strict;
use C4::AR::Auth;
use CGI;
use C4::AR::Prestamos;

my $input = new CGI;

my $obj = $input->Vars;

my ($template, $session, $t_params);
my $prestamos_array_ref;

if ($obj->{'ok'}){

   ($template, $session, $t_params) = C4::AR::Auth::get_template_and_user({
                                        template_name   => "includes/partials/prestamos/_prestamos_vencidos.inc",
                                        query           => $input,
                                        type            => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => {  ui            => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'ALTA', 
                                                            entorno         => 'undefined'},
    });

    my $ini = $obj->{'ini'};

    $prestamos_array_ref   = C4::AR::Prestamos::getPrestamosVencidosPaginado($ini);

    $t_params->{'ini'} = $ini;



} else {


        ($template, $session, $t_params) = C4::AR::Auth::get_template_and_user({
                                            template_name   => "admin/circulacion/prestamos_vencidos.tmpl",
                                            query           => $input,
                                            type            => "intranet",
                                            authnotrequired => 0,
                                            flagsrequired   => {  ui            => 'ANY', 
                                                                tipo_documento  => 'ANY', 
                                                                accion          => 'ALTA', 
                                                                entorno         => 'undefined'},
        });

        $prestamos_array_ref   = C4::AR::Prestamos::getPrestamosVencidosPaginado(0);
        
        $t_params->{'ini'}  = 0;
      

        if(C4::AR::Preferencias::getValorPreferencia('enableMailPrestVencidos')){

            $t_params->{'mensaje'}  = 'Se enviar&aacute;n los mails de pr&eacute;stamos vencidos a la brevedad';

        }


}

$t_params->{'prestamos'}  = $prestamos_array_ref;
$t_params->{'cantidad'}   = $prestamos_array_ref?scalar(@$prestamos_array_ref):0;

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
