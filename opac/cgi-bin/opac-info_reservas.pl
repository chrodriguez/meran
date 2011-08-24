#!/usr/bin/perl
use strict;
require Exporter;

use CGI;
use C4::AR::Auth;
use C4::Date;;
use Date::Manip;
use C4::AR::Busquedas;

my $input       = new CGI;
my $action      = $input->param('action') || 0;
my $from_bubble = 0;
my $obj         = $input->param('obj') || 0;

if ($obj){
  $obj          = C4::AR::Utilidades::from_json_ISO($obj);
  $action       = $obj->{'action'} || 0;
  $from_bubble  = $obj->{'bubble'};
}

my $template = ($action && (!$from_bubble))?"opac-main.tmpl":"includes/opac-reservas_info.inc";

if ( ($obj) && (!$from_bubble) ){

    $template = "includes/opac-detalle_reservas_espera.inc"; #caso default
    if ($action eq "detalle_espera"){
        $template = "includes/opac-detalle_reservas_espera.inc";
    }
    elsif ($action eq "detalle_asignadas"){
        $template = "includes/opac-detalle_reservas_asignadas.inc";
    }

}

my ($template, $session, $t_params)= get_template_and_user({
                template_name   => $template,
                query           => $input,
                type            => "opac",
                authnotrequired => 0,
                flagsrequired   => {    ui => 'ANY', 
                                        tipo_documento => 'ANY', 
                                        accion => 'CONSULTA', 
                                        entorno => 'undefined'},
                debug           => 1,
          });

if ($action eq "detalle_espera"){
    $t_params->{'partial_template'} = "opac-detalle_reservas_espera.inc";
}
elsif ($action eq "detalle_asignadas"){
    $t_params->{'partial_template'} = "opac-detalle_reservas_asignadas.inc";
}

my $nro_socio                    = C4::AR::Auth::getSessionNroSocio();
my $reservas                     = C4::AR::Reservas::obtenerReservasDeSocio($nro_socio);
my ($cant_prestamos, $prestamos) = C4::AR::Prestamos::getHistorialPrestamosVigentesParaTemplate($nro_socio);
my $racount                      = 0;
my $recount                      = 0;

if ($reservas){
    my @reservas_asignadas;
    my @reservas_espera;

    foreach my $reserva (@$reservas) {
	    if ($reserva->getId3) {
		    #Reservas para retirar
		    push @reservas_asignadas, $reserva;
		    $racount++;
        }else{
		    #Reservas en espera
		    push @reservas_espera, $reserva;
		    $recount++;
        }
    }
    $t_params->{'RESERVAS_ASIGNADAS'}   = \@reservas_asignadas;
    $t_params->{'RESERVAS_ESPERA'}      = \@reservas_espera;
}

$t_params->{'reservas_asignadas_count'} = $racount;
$t_params->{'prestamos_count'}          = $cant_prestamos;
$t_params->{'reservas_espera_count'}    = $recount;
$t_params->{'pagetitle'}                = "Usuarios";
$t_params->{'content_title'}            = C4::AR::Filtros::i18n("Reservas");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
