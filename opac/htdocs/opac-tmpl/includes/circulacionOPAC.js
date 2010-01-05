/*
* Libreria para menejar la circulacion del OPAC
* Contendran las funciones para permitir la circulacion en el sistema
*/



/*
* Funcion Ajax que hace una reserva
*/
function reservar(id1, id2){

    jConfirm(ESTA_SEGURO_QUE_DESEA_RESERVAR,OPAC_ALERT_TITLE, function(confirmStatus){
        if (confirmStatus){
            objAH=new AjaxHelper(updateInfoReserva);
            objAH.debug= true;
            //para busquedas combinables
            objAH.url= '/cgi-bin/koha/opac-reservar.pl';
            objAH.id1= id1;
            objAH.id2= id2;
            //se envia la consulta
            objAH.sendToServer();
        }
    });
}

/*
* Funcion que muestra la informacion de las reservas
*/
function updateInfoReserva(responseText){

	//si estoy logueado, oculta la informacion del usuario
	$('#resultadoReserva').html(responseText);
	$('#resultadoReserva').slideDown('slow');
    infoReservas();
    infoSanciones();

}

/*
* Funcion Ajax que cancela una reserva
*/
function cancelarReserva(id_reserva){

    objAH=new AjaxHelper(updateInfoCancelarReserva);

    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/reservasDB.pl';
    objAH.id_reserva= id_reserva;
    objAH.accion= 'CANCELAR_RESERVA';

    objAH.sendToServer();
}

/*
* Funcion que muestra el mensaje al usuario, luego de cancelar una reserva
*/
function updateInfoCancelarReserva(responseText){
//  objJSON= JSONstring.toObject(responseText);
//  showMessage(objJSON.message);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);  
    DetalleReservas();
}
/*
* Funcion que llama a cancelar una reserva
*/
function cancelarYReservar(reserveNumber,id1Nuevo,id2Nuevo){

    objAH=new AjaxHelper(updateInfoCancelarReserva);

    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/reservasDB.pl';
    objAH.reserveNumber= reserveNumber;
    objAH.id1Nuevo= id1Nuevo;
    objAH.id2Nuevo= id2Nuevo;
    objAH.accion= 'CANCELAR_Y_RESERVAR';

    objAH.sendToServer();
}

/*
* Funcion que hace consulta Ajax para renovar un prestamo del usuario
*/
function renovar(id_prestamo){

	objAH=new AjaxHelper(updateInfoRenovar);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-renovar.pl';
	objAH.id_prestamo= id_prestamo;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra mensajes al usuario luego de renovar un prestamo
*/
function updateInfoRenovar(responseText){
// 	var infoArray= JSONstring.toObject(responseText);
// 	var mensajes= '';
// 	for(i=0; i<infoArray.length;i++){
// 		mensajes= mensajes + infoArray[i].message + '<br>';
// 	}
// 	$('#mensajes font').html(mensajes);
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	DetallePrestamos();	
}

/*
* Funcion que hace consulta Ajax para obtener el detalle de las reservas del usuario
*/
function DetalleReservas(){

	objAH=new AjaxHelper(updateDetalleReserva);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-info_reservas.pl';
    objAH.action = 'detalle_espera';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Funcion que muestra el detalle de las reservas del usuario
*/
function updateDetalleReserva(responseText){

    //si estoy logueado, oculta la informacion del usuario
    if (responseText != 0){
        $('#detalleReservas').html(responseText);
        $('#detalleReservas').slideDown('slow');
        $('#datosUsuario').slideDown('slow');
        $('#result').slideUp('slow');
    }

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

function infoReservas(){
    objAH=new AjaxHelper(updateInfoReservas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/opac-info_reservas.pl';
    objAH.action = 'detalle_espera';
    objAH.sendToServer();
}

function updateInfoReservas(responseText){
    $('#info_reservas').html(responseText);
}
