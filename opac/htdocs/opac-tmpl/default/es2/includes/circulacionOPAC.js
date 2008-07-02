/*
* Libreria para menejar la circulacion del OPAC
* Contendran las funciones para permitir la circulacion en el sistema
*/
function updateInfoReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#result').html(responseText);
	$('#result').slideDown('slow');	

}

function updateDetalleReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detalleReservas').html(responseText);
	$('#detalleReservas').slideDown('slow');	

}

function updateDetallePrestamo(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detallePrestamos').html(responseText);
	$('#detallePrestamos').slideDown('slow');	

}


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

function cancelarYReservar(reserveNumber,id1Nuevo,id2Nuevo){

	cancelar(reserveNumber);
	reservar(id1Nuevo, id2Nuevo);
}

function showMessage(mensaje){
	if(mensaje != ''){
		$('#mensajes').slideDown();
		$('#mensajes font').html(objJSON.message);
	}
}

function hideMessage(){
	$('#mensajes').slideUp();
	$('#mensajes font').html('');
}

function updateInfoCancelarReserva(responseText){
	objJSON= JSONstring.toObject(responseText);
	showMessage(objJSON.message);
	DetalleReservas();
}

function cancelar(reserveNumber){

	objAH=new AjaxHelper(updateInfoCancelarReserva);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-cancelreserv.pl';
	objAH.reserveNumber= reserveNumber;
	//se envia la consulta
	objAH.sendToServer();
}

function updateInfoRenovar(responseText){
	var infoArray= JSONstring.toObject(responseText);
	var mensajes= '';
	for(i=0; i<infoArray.length;i++){
		mensajes= mensajes + infoArray[i].message + '<br>';
	}
	$('#mensajes font').html(mensajes);
	DetallePrestamos();	
}


function renovar(id3){

	objAH=new AjaxHelper(updateInfoRenovar);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-renew.pl';
	objAH.id3= id3;
	//se envia la consulta
	objAH.sendToServer();
}

function DetalleReservas(){

	objAH=new AjaxHelper(updateDetalleReserva);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetalleReservas.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

function DetallePrestamos(){

	objAH=new AjaxHelper(updateDetallePrestamo);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetallePrestamos.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

$(document).ready(function() {
	hideMessage();
	
});
