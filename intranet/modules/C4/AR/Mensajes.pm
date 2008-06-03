package C4::AR::Mensajes;

#Este modulo provee funcionalidades para la reservas de documentos
#
#Copyright (C) 2003-2008  Linti, Facultad de Inform�tica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
	&getMensaje
);

#000 - Todo normal
#R000 - R099 para Reservas
#P100 - P199 para Prestamos
#S200 - S299 para Sanciones
#U300 - U399 para Usuarios

# %mensajes mapea codigo de mensaje con la descripcion del mismo
my %mensajesOPAC = (
    	'000' => 'No hay error',
    	'R001' => 'Disculpe, usted no puede realizar m&aacute;s de *?* reservas',
    	'R002' => 'Disculpe, no puede efectuar reservas porque ya tiene una reserva para el mismo grupo y tipo de prestamo ',
	'R003' => 'Disculpe, usted no puede tener m&aacute;s de *?* reservas en espera.',
# 	'R004' => '',
	'P100' => 'Disculpe, no puede efectuar reservas porque ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'Disculpe, usted ha alcanzado la cantidad m&aacute;xima de pr&eacute;stamos *?*. No puede efectuar reservas sobre ejemplares.',
	'P102' => '';
	'S200' => 'Disculpe, no puede efectuar reservas porque usted esta sancionado hasta el *?*',
	'S201' => 'Disculpe, no puede efectuar reservas porque usted tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'Disculpe, no puede efectuar reservas porque usted no es un alumno regular.',
	'U301' => 'Disculpe, no puede efectuar reservas porque usted no ha realizado a&uacute;n el curso para usuarios.',
);

my %mensajesINTRA = (
    	'000' => 'No hay error',
    	'R001' => 'El usuario lleg&oacute; al m&acute;ximo de reservas permitidas (*?*).',
    	'R002' => 'El usuario ya tiene una reserva para el mismo tipo de prestamo ',
	'R003' => 'El usuario lleg&oacute; al m&acute;ximo de reservas en espera (*?*).',
# 	'R004' => 'El usuario ya tienen una reserva para el item.',
	'P100' => 'El usuario ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'El usuario alcanzo la cantidad m&aacute;xima  de pr&eacute;stamos *?*',
	'P102' => 'Estamos fuera del horario de realizaci&oacute;n del pr&eacute;stamo especial.'
	'S200' => 'El usuario no puede reservar porque esta sancionado hasta el *?*',
	'S201' => 'El usuario no puede reservar porque tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'El usuario no puede reservar porque no es un alumno regular.',
	'U301' => 'El usuario no puede reservar porque no ha realizado a&uacute;n el curso para usuarios.',
);

sub getMensaje {
	my($codigo,$tipo,$param)=@_;
	my $msj="";
	($tipo eq "OPAC")?$msj=$mensajesOPAC{$codigo}:$msj=$mensajesINTRA{$codigo};
	foreach my $p (keys %$param){
		my $p2=$param->{$p};
		$msj=~ s/\*\?\*/$p2/o;
	}
	return $msj;
}


1;
