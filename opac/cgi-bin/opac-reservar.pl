#!/usr/bin/perl
# NOTE: This file uses standard 8-character tabs

use strict;
require Exporter;
use CGI;
use C4::AR::Auth;        
use C4::AR::Reservas;

use C4::AR::Mensajes;
use C4::AR::Utilidades;
use C4::Date;


my $input = new CGI;
my ($template, $session, $t_params)= get_template_and_user({
        template_name => "opac-reservar.tmpl",
        query => $input,
        type => "opac",
        authnotrequired => 0,
        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'circ_opac', tipo_permiso => 'circulacion'},
        debug => 1,
});

## FIXME se deberia separar el detalle de las resrvas del usuario y aqui solo realizar la reserva e informar al usuario si se realizo
# con exito o no
my $obj=$input->param('obj');

$obj=C4::AR::Utilidades::from_json_ISO($obj);


my $id1= $obj->{'id1'};
my $id2= $obj->{'id2'};
my $socio= $session->param('userid');

my %params;
# $params{'tipo'}= 'OPAC';
$params{'tipo'}= 'OPAC';
$params{'id1'}= $id1;
$params{'id2'}= $id2;
$params{'nro_socio'}= $socio;
$params{'loggedinuser'}= $socio;
$params{'tipo_prestamo'}= 'DO';

my ($msg_object)= &C4::AR::Reservas::t_reservarOPAC(\%params);

my $acciones;
$acciones= C4::AR::Mensajes::getAccion($msg_object->{'messages'}->[0]->{'codMsg'});

my $reservas = C4::AR::Reservas::obtenerReservasDeSocio($socio);
# FIXME esto esta feo!!!
if($msg_object->{'error'}){
#SE PRODUJO ALGUN ERROR
	if($acciones->{'maximoReservas'}){
	#EL USUARIO LLEGO AL MAXIMO DE RESERVAS, Y SE MUESTRAN LAS RESERVAS HECHAS
		$t_params->{'RESERVAS'}= $reservas;
	}
}else{
# SE REALIZO LA RESERVA CON EXITO
	if($reservas){
	#si tiene reservas anteriores, las muestro
		my @reservas_asignadas;
		my $racount = 0;
		my @reservas_espera;
		my $recount = 0;
	
	
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
	
		$t_params->{'RESERVAS_ASIGNADAS'}= \@reservas_asignadas;
		$t_params->{'reservas_asignadas_count'}= $racount;
		$t_params->{'RESERVAS_ESPERA'}= \@reservas_espera;
		$t_params->{'reservas_espera_count'}=$recount;
	}# END if($reservas)
}


$t_params->{'message'}= $msg_object->{'messages'}->[0]->{'message'};
$t_params->{'error'}=  $msg_object->{'error'};
$t_params->{'reservaGrupo'}= $acciones->{'reservaGrupo'};
$t_params->{'maximoReservas'}= $acciones->{'maximoReservas'};
$t_params->{'materialParaRetirar'}= $acciones->{'materialParaRetirar'};
$t_params->{'CirculationEnabled'}= C4::AR::Preferencias::getValorPreferencia("circulation");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

