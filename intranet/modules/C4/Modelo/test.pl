#!/usr/bin/perl -w

use C4::AR::Reservas;
use C4::AR::Usuarios;
use C4::Modelo::CircReserva::Manager;


my @filtros;


my ($reservas_array_ref) = C4::Modelo::CircReserva::Manager->get_circ_reserva( query => \@filtros, sort_by => 'id_reserva DESC');
my $reserva = $reservas_array_ref->[0];


my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio("gaspo53");

C4::AR::Enviar_Email_Reserva_A_Espera($reserva,$socio);

