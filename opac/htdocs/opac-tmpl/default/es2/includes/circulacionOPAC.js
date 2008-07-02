/*
* Libreria para menejar la circulacion del OPAC
* Contendran las funciones para permitir la circulacion en el sistema
*/



/*
* Funcion Ajax que hace una reserva
*/
function reservar(id1, id2){

	objAH=new AjaxHelper(updateInfoReserva);
//   	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-reserve.pl';
	objAH.id1= id1;
	objAH.id2= id2;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra la informacion de las reservas
*/
function updateInfoReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#result').html(responseText);
	$('#result').slideDown('slow');	

}

/*
* Funcion que muestra el div de mensajes para usuario
*/
function showMessage(mensaje){
	if(mensaje != null){
		$('#mensajes').slideDown();
		$('#mensajes font').html(objJSON.message);
	}
}

/*
* Funcion que oculta el div de mensajes para el usuario
*/
function hideMessage(){
	$('#mensajes').slideUp();
	$('#mensajes font').html('');
}

/*
* Funcion Ajax que cancela una reserva
*/
function cancelar(reserveNumber){

	objAH=new AjaxHelper(updateInfoCancelarReserva);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-cancelreserv.pl';
	objAH.reserveNumber= reserveNumber;
	objAH.accion= 'CANCELAR';
	//se envia la consulta
	objAH.sendToServer();
}


/*
* Funcion que llama a cancelar una reserva
*/
function cancelarYReservar(reserveNumber,id1Nuevo,id2Nuevo){

// 	cancelar(reserveNumber);
// 	reservar(id1Nuevo, id2Nuevo);

	objAH=new AjaxHelper(updateInfoCancelarReserva);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-cancelreserv.pl';
	objAH.reserveNumber= reserveNumber;
	objAH.id1Nuevo= id1Nuevo;
	objAH.id2Nuevo= id2Nuevo;
	objAH.accion= 'CANCELAR_Y_RESERVAR';
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra el mensaje al usuario, luego de cancelar una reserva
*/
function updateInfoCancelarReserva(responseText){
	objJSON= JSONstring.toObject(responseText);
	showMessage(objJSON.message);
	DetalleReservas();
}

/*
* Funcion que hace consulta Ajax para renovar un prestamo del usuario
*/
function renovar(id3){

	objAH=new AjaxHelper(updateInfoRenovar);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-renew.pl';
	objAH.id3= id3;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra mensajes al usuario luego de renovar un prestamo
*/
function updateInfoRenovar(responseText){
	var infoArray= JSONstring.toObject(responseText);
	var mensajes= '';
	for(i=0; i<infoArray.length;i++){
		mensajes= mensajes + infoArray[i].message + '<br>';
	}
	$('#mensajes font').html(mensajes);
	DetallePrestamos();	
}

/*
* Funcion que hace consulta Ajax para obtener el detalle de las reservas del usuario
*/
function DetalleReservas(){

	objAH=new AjaxHelper(updateDetalleReserva);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetalleReservas.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra el detalle de las reservas del usuario
*/
function updateDetalleReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detalleReservas').html(responseText);
	$('#detalleReservas').slideDown('slow');
	$('#datosUsuario').slideDown('slow');
	$('#result').slideUp('slow');		

}

/*
* Funcion que hace consulta Ajax para obtener el detalle de los prestamos del usuario
*/
function DetallePrestamos(){

	objAH=new AjaxHelper(updateDetallePrestamo);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetallePrestamos.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra el detalle de los prestamos del usuario
*/
function updateDetallePrestamo(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detallePrestamos').html(responseText);
	$('#detallePrestamos').slideDown('slow');	

}

$(document).ready(function() {
	hideMessage();
	
});
