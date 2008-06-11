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
	&getAccion
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
	'R004' => '',
	'R005' => '',
	'R006' => '',
	'R007' => 'Disculpe, pero no se puede reservar un item para sala.',
	'R008' => 'Disculpe, llego al m&aacute;ximo de reservas en espera.',
	'P100' => 'Disculpe, no puede efectuar reservas porque ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'Disculpe, usted ha alcanzado la cantidad m&aacute;xima de pr&eacute;stamos *?*. No puede efectuar reservas sobre ejemplares.',
	'P102' => '',
	'S200' => 'Disculpe, no puede efectuar reservas porque usted esta sancionado hasta el *?*',
	'S201' => 'Disculpe, no puede efectuar reservas porque usted tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'Disculpe, no puede efectuar reservas porque usted no es un alumno regular.',
	'U301' => 'Disculpe, no puede efectuar reservas porque usted no ha realizado a&uacute;n el curso para usuarios.',
	'U302' => 'El libro que acaba de reservar deber&aacute; ser retirado desde el d&iacute;a  *?* a las *?* hasta el d&iacute;a: *?* hasta las *?*',
	'U303' => 'En este momento no hay ejemplares disponibles para el pr&eacute;stamo inmediato. Cuando haya alg&uacute;n ejemplar a su disposici&oacute;n se le informar&aacute; a su cuenta de usuario y a su mail:
	<br><i> *?* </i><br>Verifique que sus datos sean correctos ya que el mensaje se enviar&aacute; a esta direcci&oacute;n.',
	'U304' => 'Disculpe, no puede reservar porque no hizo el curso para usuarios.'
);

my %mensajesINTRA = (
    	'000' => 'No hay error',
    	'R001' => 'El usuario lleg&oacute; al m&acute;ximo de reservas permitidas (*?*).',
    	'R002' => 'El usuario ya tiene una reserva para el mismo tipo de prestamo ',
	'R003' => 'El usuario lleg&oacute; al m&acute;ximo de reservas en espera (*?*).',
	'R004' => 'No hay ejemplares libres para el prestamo, y no se pueden realizar reservas sobre un grupo desde intranet.',
	'R005' => 'No hay ejemplares libres para el prestamo, y se realizo una reserva sobre el grupo.',
	'R006' => 'No hay m&aacute;s ejemplares disponibles y no puede hacer m&aacute;s reservas porque lleg&oacute; el l&iacute;mite',
	'R007' => '',
	'R008' => '',
	'P100' => 'El usuario ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'El usuario alcanzo la cantidad m&aacute;xima  de pr&eacute;stamos *?*',
	'P102' => 'Estamos fuera del horario de realizaci&oacute;n del pr&eacute;stamo especial.',
	'P103' => 'Se realizo el pr&acute;stamo con exito.',
	'P104' => 'No hay m&aacute;s ejemplares disponibles',
	'P105' => 'El usuario supera el n&uacute;mero m&aacute;ximo de ejemplares para ese tipo de pr&eacute;stamo.',
	'P106' => 'Estamos fuera del horario de realizaci&oacute;n del pr&eacute;stamo especial.',
	'P107' => 'El documento esta prestado, seleccione otro c&oacute;digo de barra',
	'S200' => 'El usuario no puede reservar porque esta sancionado hasta el *?*',
	'S201' => 'El usuario no puede reservar porque tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'El usuario no puede reservar porque no es un alumno regular.',
	'U301' => 'El usuario no puede reservar porque no ha realizado a&uacute;n el curso para usuarios.',
	'U302' => '',
	'U303' => '',
	'U304' => 'El usuario no hizo el curso de koha.'
);

sub getMensaje {
	my($codigo,$tipo,$param)=@_;
	my $msj="";
	($tipo eq "OPAC") ? ($msj=$mensajesOPAC{$codigo}) : ($msj=$mensajesINTRA{$codigo});
	for(my $p=0; $p<scalar(@$param); $p++){
		my $p2=$param->[$p];
		$msj=~ s/\*\?\*/$p2/o;
	}
	return $msj;
}

=item
Esta funcion se encarga de setear variables para los distintos pl que la invocan segun un codigo de error,
estas variables se setean para mostrar u ocultar cosas en los tmpls
=cut
sub getAccion {
	my($codigo,$tipo)=@_;
	my %acciones;
	
	if($codigo eq 'R001'){
		$acciones{'tablaReservas'}= 1;
	}

	if($codigo eq 'U303'){
		$acciones{'reservaGrupo'}= 1;
	}

	return \%acciones;
}


1;
