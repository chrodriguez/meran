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
#B400 - B499 para Errores e Informacion de Base de Datos
#C500 - C599 para Catalogacion
#CA600 - CA699 para Control de Autoridades
#F700 - F799 para Favoritos
#VO800 - VO899 para Visualizacion Opac

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
	'R009' => 'Disculpe, no se pudo realizar la reserva, intente nuevamente.',
	'R010' => 'Disculpe, no se pudo cancelar la reserva, intente nuevamente.',
	'R011' => 'Disculpe, no se pudo cancelar y reservar, intente nuevamente.',
	'P100' => 'Disculpe, no puede efectuar reservas porque ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'Disculpe, usted ha alcanzado la cantidad m&aacute;xima de pr&eacute;stamos *?*. No puede efectuar reservas sobre ejemplares.',
	'P102' => '',
	'P103' => '',
	'P104' => '',
	'P105' => '',
	'P106' => '',
	'P107' => '',
	'P108' => '',
	'P109' => '',
	'P110' => '',
	'P111' => 'El ejemplar con c&oacute;digo de barras *?* fue renovado',
	'P112' => 'El ejemplar con c&oacute;digo de barras *?* no pudo ser renovado',
	'P113' => 'Disculpe, no se pudo renovar el pr&eacute;stamo, intente nuevamente.',
	'P114' => 'Disculpe, no puede efectuar renovaciones porque usted no ha realizado a&uacute;n el curso para usuarios.',
	'S200' => 'Disculpe, no puede efectuar reservas porque usted esta sancionado hasta el *?*',
	'S201' => 'Disculpe, no puede efectuar reservas porque usted tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'Disculpe, no puede efectuar reservas porque usted no es un alumno regular.',
	'U301' => 'Disculpe, no puede efectuar reservas porque usted no ha realizado a&uacute;n el curso para usuarios.',
	'U302' => 'El libro que acaba de reservar deber&aacute; ser retirado desde el d&iacute;a  *?* a las *?* hasta el d&iacute;a: *?* hasta las *?*',
	'U303' => 'En este momento no hay ejemplares disponibles para el pr&eacute;stamo inmediato. Cuando haya alg&uacute;n ejemplar a su disposici&oacute;n se le informar&aacute; a su cuenta de usuario y a su mail:
	<br><i> *?* </i><br>Verifique que sus datos sean correctos ya que el mensaje se enviar&aacute; a esta direcci&oacute;n.',
	'U304' => 'Disculpe, no puede reservar porque no hizo el curso para usuarios.',
	'B400' => 'Error al intentar reservar desde OPAC, funcion C4::AR::Reservas::reservarOPAC.',
	'B401' => '',
	'B402' => '',
	'B403' => '',
	'B404' => 'Error al cancelar una reserva desde OPAC, funcion C4::AR::Reservas::t_cancelar_reserva',
	'B405' => 'Error al intentar renovar desde OPAC, funcion C4::AR::Issues::t_renovar',
	'B406' => '',
	'B407' => 'Error al intentar carncelar y reservar desde OPAC, funcion C4::AR::Reservas::t_cancelar_y_reserva',
	'B408' => 'Error al intentar agregar un favorito desde OPAC, funcion C4::AR::BookShelves::t_addPrivateShelfs',	
	'B409' => 'Error al intentar eliminar un favorito desde OPAC, funcion C4::AR::BookShelves::t_delPrivateShelfs',
	'F700' => 'Disculpe, no se pudo agregar el favorito, intente nuevamente.',
	'F701' => 'Se agrego el favorito con &eacute;xito',
	'F702' => 'Se elimin&oacute; el favorito con &eacute;xito',
	'F703' => 'Disculpe, no se pudo eliminar el favorito, intente nuevamente.',

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
	'R009' => '',
	'R010' => 'Se produjo un error al intentar cancelar la reserva, repita la operaci&oacute;n',
	'P100' => 'El usuario ya tiene un ejemplar prestado del mismo grupo y del mismo tipo de prestamo',
	'P101' => 'El usuario alcanzo la cantidad m&aacute;xima  de pr&eacute;stamos *?*, no se pudo prestar *?*',
	'P102' => 'Estamos fuera del horario de realizaci&oacute;n del pr&eacute;stamo especial.',
	'P103' => 'Se realizo el pr&eacute;stamo con exito del ejemplar *?*.',
	'P104' => 'No hay m&aacute;s ejemplares disponibles',
	'P105' => 'El usuario supera el n&uacute;mero m&aacute;ximo de ejemplares para ese tipo de pr&eacute;stamo.',
	'P106' => 'No se pudo realizar el pr&eacute;stamo, intentelo nuevamente.',
	'P107' => 'El documento esta prestado, seleccione otro c&oacute;digo de barra',
	'P108' => 'Pr&eacute;stamo realizado con &eacute;xito *?*, el usuario lleg&oacute; al m&aacute;ximo de pr&eacute;stamos, se le cancelaron todas las reservas',
	'P109' => 'El ejemplar con c&oacute;digo de barras *?* fue devuelto',
	'P110' => 'El ejemplar con c&oacute;digo de barras *?* no pudo ser devuelto',
	'P111' => 'El ejemplar con c&oacute;digo de barras *?* fue renovado',
	'P112' => 'El ejemplar con c&oacute;digo de barras *?* no pudo ser renovado',
	'P113' => 'Disculpe, no se pudo renovar el pr&eacute;stamo, intente nuevamente.',
	'P114' => 'Disculpe, no puede efectuar renovaciones porque usted no ha realizado a&uacute;n el curso para usuarios.',
	'S200' => 'El usuario no puede reservar porque esta sancionado hasta el *?*',
	'S201' => 'El usuario no puede reservar porque tiene una posible sanci&oacute;n pendiente.',
	'U300' => 'El usuario no puede reservar porque no es un alumno regular.',
	'U301' => 'El usuario no puede reservar porque no ha realizado a&uacute;n el curso para usuarios.',
	'U302' => '',
	'U303' => '',
	'U304' => 'El usuario no hizo el curso de koha.',
	'U305' => 'Disculpe, no se pudo eliminar el item con c&oacute;digo de barras *?*, intente nuevamente.',
	'U306' => 'Disculpe, no se pudo eliminar el grupo *?*, intente nuevamente.',
	'U307' => 'Disculpe, no se pudo eliminar el registro *?*, intente nuevamente.',
	'U308' => 'Se cancel&oacute; la reserva con &eacute;xito.',
	'B400' => '',
	'B401' => 'Error al intentar prestar desde INTRA, funcion C4::AR::Reservas::prestar.',
	'B402' => 'Error al intentar guardar un item desde INTRA, funcion C4::AR::Catalogacion::transaccion.',
	'B403' => 'Error al intentar guardar un item desde INTRA, funcion C4::AR::Catalogacion::transaccionNivel3.',
	'B404' => 'Error al cancelar una reserva desde INTRA, funcion C4::AR::Reservas::t_cancelar_reserva',
	'B405' => 'Error al intentar renovar desde la INTRA, funcion C4::AR::Issues::t_renovar',
	'B406' => 'Error al intentar devolver desde la INTRA, funcion C4::AR::Issues::t_devolver',
	'B407' => '',
	'B408' => 'Error en funcion C4::Auth::t_operacionesDeOPAC',
	'B409' => 'Error en funcion C4::Auth::t_operacionesDeINTRA',
	'B410' => 'Error en funcion C4::AR::VisualizacionOpac::t_insertarEncabezado',
	'B411' => 'Error en funcion C4::AR::VisualizacionOpac::t_deleteEncabezado',
	'B412' => 'Error en funcion C4::AR::Nivel3::t_deleteItem',
	'B413' => 'Error en funcion C4::AR::Nivel2::t_deleteGrupo',
	'B414' => 'Error en funcion C4::AR::Nivel1::t_deleteNivel1',
	'C500' => 'Los items fueron guardados correctamente.',
	'C501' => 'Se produjo un error al intentar guardar los datos del item, repita la operacion.',
	'C502' => 'Se produjo un error, el codigo de barra ingresado esta repetido. Vuelva a intentarlo',
	'CA601' => 'Se produjo un error al intentar agregar un sin&oacute;nimo, repita la operaci&oacute;n',
	'CA602' => 'Se produjo un error al intentar agregar un seud&oacute;nimo, repita la operaci&oacute;n',	
	'CA603' => 'Se produjo un error al intentar eliminar un seud&oacute;nimo, repita la operaci&oacute;n',
	'CA604' => 'Se produjo un error al intentar eliminar un sin&oacute;nimo, repita la operaci&oacute;n',
	'CA605' => 'Se produjo un error al intentar actualizar un sin&oacute;nimo, repita la operaci&oacute;n',
	'VO800' => 'Se agreg&oacute; con &eacute;xito el encabezado',
	'VO801' => 'Disculpe, no se pudo ingresar el Encabezado, intente nuevamente',
	'VO802' => 'Disculpe, no se pudo eliminar el Encabezado, intente nuevamente',
	'VO803' => 'Se elimin&oacute; el encabezado con &eacute;xito',
	'M901' => 'Se elimin&oacute; con &eacute;xito el item con c&oacute;digo de barras *?* .',
	'M902' => 'Se elimin&oacute; con &eacute;xito el grupo *?* .',
	'M903' => 'Se elimin&oacute; con &eacute;xito el Registro *?* .',
);

sub getMensaje {
	my($codigo,$tipo,$param)=@_;
	my $msj="";

	($tipo eq "OPAC") ? ($msj=$mensajesOPAC{$codigo}) : ($msj=$mensajesINTRA{$codigo});
	
	my $p;
	foreach $p (@$param){
		$msj=~ s/\*\?\*/$p/o;
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
		$acciones{'maximoReservas'}= 1;
# 		$acciones{'materialEnEspera'}= 0;
	}

 	if($codigo eq 'U302'){
 		$acciones{'materialParaRetirar'}= 1;
 	}

	if($codigo eq 'U303'){
		$acciones{'reservaGrupo'}= 1;
	}

	return \%acciones;
}

=item
printErrorDB
Esta funcion logea los bugs que ocurren cuando una transaccion no es ejecutada con exito.
Guarda los errores en el siguiente archivo: /var/log/koha/debugErrorDBA.txt
=cut
sub printErrorDB {
	my($errorsDB_array,$codigo,$tipo)=@_;

	my $paraMens;
	my $path=">>".C4::Context->config("kohalogdir")."debugErrorDBA.txt";
	open(A,$path);
	print A "\n";
	print A "**************Error en la transaccion - Fecha:". C4::Date::ParseDate("today")."**************\n";
	print A "Codigo: $codigo\n";
	my $message= &C4::AR::Mensajes::getMensaje($codigo,$tipo,$paraMens);
	print A "Message: $message\n";
	print A "$@ \n";
	print A "\n";
	close(A);
}

1;
