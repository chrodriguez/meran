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
#SP000 - SP999 para errores de sistema
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
	'U309' => 'Se elimin&oacute; el seud&oacute;nimo con &eacute;xito.',
	'U310' => 'Se elimin&oacute; el sin&oacute;nimo con &eacute;xito.',
	'U311' => 'Usted ha ingresado un ID de usuario que ya existe. Por favor elija otro. userid: *?* Apellido: *?* Nombre: *?*',
	'U312' => 'Se realiz&oacute; el cambio de la password con &eacute;xito.',
	'U313' => 'Disculpe, no se pudo realizar el cambio de la password, intente nuevamente.',
	'U314' => 'Password en blanco, debe ingresar la password.',
	'U315' => 'Las passwords no coinciden, ingrese la password nuevamente.',
	'U316' => 'La password no respeta la longitud m&iacute;nima.',
	'U317' => 'Se cambiaron los permisos con &eacute;xito.',
	'U318' => 'La password no respeta la longitud m&iacute;nima de s&iacute;mbolos.',
	'U319' => 'Disculpe, no se pudo eliminar el usuario *?*, intente nuevamente.',
	'U320' => 'Se elimin&oacute; el usuario *?* con &eacute;xito.',
	'U321' => 'No existe el usuario *?*, intente nuevamente.',
	'U322' => 'Disculpe, no se pudo eliminar el usuario *?*, intente nuevamente.',
	'U323' => 'Se agreg&oacute; el usuario *?* con &eacute;xito.',
	'U324' => 'La password no respeta la longitud m&iacute;nima de car&aacute;cteres alfanum&eacute;ricos.',
	'U325' => 'La password no respeta la longitud m&iacute;nima de car&aacute;cteres alfab&eacute;ticos.',
	'U326' => 'La password no respeta la longitud m&iacute;nima de car&aacute;cteres num&eacute;ricos.',
	'U327' => 'La password no respeta la longitud m&iacute;nima de min&uacute;sculas.',
	'U328' => 'La password no respeta la longitud m&iacute;nima de may&uacute;sculas.',
	'U329' => 'Se agregr&oacute; el usuario con &eacute;xito.',
	'U330' => 'Disculpe, no se pudo agregar el usuario, intente nuevamente.',
	'U331' => 'Disculpe, no se pudo cambiar el permiso, intente nuevamente.',
	'U332' => 'Disculpe, la direcci&oacute;n de mail es inv&aacute;lida.',
	'U333' => 'El n&uacute;mero de tarjeta de indentificaci&oacute;n no puede estar en blanco.',
	'U334' => 'El apellido no puede estar en blanco.',
	'U335' => 'El nombre no puede estar en blanco.',
	'U336' => 'El n&uacute;mero de documento no puede estar en blanco, o no respeta el formato adecuado.',
	'U337' => 'El nombre de la ciudad no puede estar en blanco.',
	'U338' => 'Se modificaron los datos del usuario correctamente.',
	'U339' => 'Disculpe, no se pudo modificar los datos del usuario, intente nuevamente.',
	'U340' => 'Se subi&oacute; la foto con &eacute;xito.',
	'U341' => 'S&oacute;lo se permiten im&aacute;genes de tipo JPG,BMP,GIF o PNG.',
	'U342' => 'Hay un error y el archivo no puede escribirse en el servidor.',
	'U343' => 'El nombre del archivo no tiene un formato correcto',
	'U344' => 'La foto ha sido eliminada.',
	'U345' => 'No se pudo eliminar la foto.',
	'U346' => 'El usuario con tarjeta id: *?* ya se encuentra habilitado!!!',
	'U347' => 'El usuario con tarjeta id: *?* se ha habilit&oacute; con &eacute;xito', 
	'U348' => 'Disculple, no se pudo hablitar el usurio, intente nuevamente',
	'U349' => 'El usuario con tarjeta id: *?* es IRREGULAR y no puede ser habilitado!!!',
	'U350' => 'El usuario con tarjeta id: *?* NO se encuentra habilitado!!!',
	'U351' => 'El usuario no se puede borrar ya que cuenta con prestamos activos y/o vencidos!!!',
	'U352' => 'El usuario no se puede borrar ya que es el mismo que est&aacute; activo en la sesi&oacute;n.',
	'U353' => 'El usuario solicitado no existe.',
	'U354' => 'Disculpe, Koha cree que usted no tenga permiso para esta p&aacute;gina.',
	'U355' => 'Disculpe, su sesi&oacute;n ha caducado. Por favor ingrese nuevamente.',
	'U356' => 'Esta accediendo a Koha desde una direcci&oacute;n IP diferente! Por favor ingrese nuevamente.',
	'U357' => 'Ha ingresado un nombre de usuario o password incorrecto. Por favor intente nuevamente.',
	'U358' => 'Ud. ha cerrado su sesion. Gracias por usar KOHA.',
    'U359' => 'El password ha sido reseteado.',
    'U360' => 'El password NO ha sido reseteado, intentelo m&aacute;s tarde.',
    'U361' => 'El password actual NO coincide con el suyo.',
    'U362' => 'UD. no puede personalizar el password de otro usuario.',
    'U363' => 'El usuario con tarjeta id: *?* se ha deshabilit&oacute; con &eacute;xito',
    'U364' => 'Se agreg&oacute; la estructura de catalogaci&oacute;n con &eacute;xito', 
    'U365' => 'Disculpe, no se pudo agregar la estructura de catalogaci&oacute;n, intente nuevamente',
    'U366' => 'Se modific&oacute; la estructura de catalogaci&oacute;n con &eacute;xito', 
    'U367' => 'Disculpe, no se pudo modificar la estructura de catalogaci&oacute;n, intente nuevamente',    
    'U368' => 'Se agreg&oacute; con &Eacute;xito el Nivel 1',
    'U369' => 'Se agreg&oacute; con &Eacute;xito el Nivel 2',
    'U370' => 'Se agreg&oacute; con &Eacute;xito el Nivel 3',
    'U371' => 'Disculpe, no se pudo agregar el Nivel 1, intente nuevamente',
    'U372' => 'Disculpe, no se pudo agregar el Nivel 2, intente nuevamente',
    'U373' => 'Disculpe, no se pudo agregar el Nivel 3, intente nuevamente',
	'U374' => 'Se elimin&oacute; con &Eacute;xito el Nivel 1',
    'U375' => 'Se elimin&oacute; con &Eacute;xito el Nivel 2',
    'U376' => 'Se elimin&oacute; con &Eacute;xito el Nivel 3',
    'U377' => 'Disculpe, no se pudo eliminar el Nivel 1, intente nuevamente',
    'U378' => 'Disculpe, no se pudo eliminar el Nivel 2, intente nuevamente',
    'U379' => 'Disculpe, no se pudo eliminar el Nivel 3, intente nuevamente',
	'B400' => '',
	'B401' => 'Error al intentar prestar desde INTRA, funcion C4::AR::Reservas::t_realizarPrestamo.',
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
	'B415' => 'Error en funcion C4::AR::VisualizacionOpac::t_deleteEncabezado',
	'B416' => 'Error en funcion C4::AR::VisualizacionOpac::t_insertConfVisualizacion',
	'B417' => 'Error en funcion C4::AR::ControlAutoridades::t_eliminarSeudonimosAutor',
	'B418' => 'Error en funcion C4::AR::ControlAutoridades::t_eliminarSeudonimosTema',
	'B419' => 'Error en funcion C4::AR::ControlAutoridades::t_eliminarSinonimosAutor',
	'B420' => 'Error en funcion C4::AR::Usuarios::t_cambiarPassword',
	'B421' => 'Error en funcion C4::AR::Usuarios::t_cambiarPermisos',
	'B422' => 'Error en funcion C4::AR::Usuarios::t_eliminarUsuario',
	'B423' => 'Error en funcion C4::AR::Usuarios::t_addBorrower',
	'B424' => 'Error en funcion C4::AR::Usuarios::t_updateBorrower',
	'B425' => 'Error en funcion C4::AR::Usuarios::t_addPersons',
    'B426' => 'Error en funcion C4::AR::Catalogacion::t_guardarEnEstructuraCatalogacion',
    'B427' => 'Error en funcion C4::AR::Catalogacion::t_guardarNivel1',
    'B428' => 'Error en funcion C4::AR::Catalogacion::t_guardarNivel2',
    'B429' => 'Error en funcion C4::AR::Catalogacion::t_guardarNivel3',
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
	'VO804' => 'Se elimin&oacute; la configuraci&oacute;n de visulizaci&oacute;n con &eacute;xito',
	'VO805' => 'Disculpe, no se pudo eliminar la configuraci&oacute;n de visualizaci&oacute;n, intente nuevamente',
	'VO806' => 'Se agreg&oacute; la configuraci&oacute;n de visulizaci&oacute;n con &eacute;xito',
	'VO807' => 'Disculpe, no se pudo agregar la configuraci&oacute;n de visualizaci&oacute;n, intente nuevamente',
	'M901' => 'Se elimin&oacute; con &eacute;xito el item con c&oacute;digo de barras *?* .',
	'M902' => 'Se elimin&oacute; con &eacute;xito el grupo *?* .',
	'M903' => 'Se elimin&oacute; con &eacute;xito el Registro *?* .',
	'SP001' => 'Se produjo un error al actualizar la preferencia.',
	'SP002' => 'Se produjo un error al guardar la preferencia.',
	'SP003' => 'La preferencia ha sido modificada con &eacute;xito.',
	'SP004' => 'La preferencia ha sido agregada al sistema con &eacute;xito.',
	'SP005' => 'La preferencia ya existe, no puede ser agregada.',
	'SP006' => 'La preferencia no existe.',
	
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




=item
sub new {
    my $self = {
        _error => undef,
        _messages => [],
    };
    bless $self, "Mensajes";
    return $self;
}

sub error {
    my ( $self, $error ) = @_;
    $self->{_error} = $error if defined($error);
    return $self->{_error};
}

sub messages {
    my ( $self, $messages ) = @_;
    $self->{_messages} = $messages if defined($messages);
    return $self->{_messages};
}

sub messagesPush {
    my ( $self, $messages , $hash) = @_;
    $self->{_messages} = $messages if defined($messages);
    push (@{$self->{_messages}}, $hash);
    return $self->{_messages};
}
=cut


sub create {

	#se crea el objetos contenedor de mensajes
	my %msg_object;
	$msg_object{'error'}= 0;
	$msg_object{'messages'}= [];

	return \%msg_object;
}

#Esta funcion agrega un mensaje al arreglo de objetos mensajes
sub add {
	my($Message_hashref, $msg_hashref)=@_;
#@param $Message_hashref es el objeto mensaje contenedor de los mensajes
#@param $msg_hashref es un mensaje
# open(A,">>/tmp/debug.txt");
# print A "Mensajes::add => \n";
	#se obtiene el texto del mensaje
  	my $messageString= &C4::AR::Mensajes::getMensaje($msg_hashref->{'codMsg'},'INTRA',$msg_hashref->{'params'});	
	$msg_hashref->{'message'}= $messageString;
# print A "Mensajes::add => message: ".$messageString."\n";
# print A "Mensajes::add => params: ".$msg_hashref->{'params'}->[0]."\n";

 	push (@{$Message_hashref->{'messages'}}, $msg_hashref);

# print A "Mensajes::add => cant: ".scalar(@{$Message_hashref->{'messages'}})."\n";
# close(A);
}

1;
