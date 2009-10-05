#!/usr/bin/perl

use strict;
use C4::AR::Z3950;

#Eliminar entradas viejas de la cola y los resultaods
C4::AR::Z3950::limpiarBusquedas();

my $cola =C4::AR::Z3950::busquedasEncoladas();

if  ($cola) {
#si hay algo que buscar agarro el primero
        C4::AR::Z3950::efectuarBusquedaZ3950($cola->[0]);
}