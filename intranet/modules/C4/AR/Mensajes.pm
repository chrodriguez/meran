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
my %mensajes = (
    	'000' => 'No hay error',
    	'R001' => 'R001 El Usuario llegá al máximo de reservas permitidas ',
    	'R002' => 'R002 El Usuario ya tiene una reserva para el mismo tipo de préstamo',
# 	'R003' => 'R003 El Usuario ya tiene una reserva de Sala',
	'P100' => 'P100 El Usuario ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'S200' => 'S200 El usuario tiene sanciones pendientes',
	'U300' => 'U300 El usuario no es regular',
);


sub getMensaje {
	my($codigo)=@_;

	return $mensajes{$codigo};
}


1;
