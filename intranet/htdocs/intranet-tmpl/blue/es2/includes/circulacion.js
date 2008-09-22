/*
 * LIBRERIA circulacion v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Las siguientes librerias son necesarias:
 *	<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.js"></script>
 *	<script src="/intranet-tmpl/blue/es2/includes/json/jsonStringify.js"></script>
 *	<script src="/intranet-tmpl/blue/es2/includes/AjaxHelper.js"></script>
 *	<script src="/intranet-tmpl/blue/es2/includes/util.js"></script>
 *	<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.bgiframe.min.js"></script>
 *	<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.js"></script>
 * @author Carbone Miguel, Di Costanzo Damian
 * Fecha de creacion 19/06/2008
 *
 */


var infoPrestamos_array= new Array();//Arreglo que contendra los objetos, con info que pertenece a los prestamos.
var objAH;//Objeto AjaxHelper.

/*
 * infoPrestamo
 * Representa al objeto que contendra la informacion para poder prestar el item. 
 * Que se pasara con json al servidor, en un arreglo (infoPrestamos_array).
 * prestamos.tmpl
 */
function infoPrestamo(){
	this.id3= '';
	this.id3Old= '';
	this.tipoPrestamo; //este es el tipo de prestamo para el id3
}

/*
 * objeto_usuario
 * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
 */
function objeto_usuario(){
	this.text;
	this.ID;
}

/*
 * AutocompleteUsuario
 * Funcion que asigna al input que busca el usuario la funcion de autocomplete.
 */
function AutocompleteUsuario(idInput,funcionDetalle,funcionUpdateInfo){
	// q= valor de campoHelp
	$("#"+idInput).search();
	$("#"+idInput).autocomplete('/cgi-bin/koha/autocompletables/usuarioAutocomplete.pl',{
 		formatItem: function(row){
			return row[0];
		},
		minChars:1,
        	matchSubset:1,
        	matchContains:1,
		maxItemsToShow:10,
        	cacheLength:10,
        	selectOnly:1,
	});//end autocomplete
	$("#"+idInput).result(function(event, data, formatted) {
		//muestro en el input el usuario seleccioinado
		$("#"+idInput).val(data[0]);
	
 		usuario= new objeto_usuario();
		usuario.text= data[0];
		usuario.ID= data[1];
		
		detalleUsuario(usuario.ID);
		detalleSanciones(usuario.ID);
		funcionDetalle(usuario.ID,funcionUpdateInfo);//Puede ser detallePrestamo o detalleReserva
	});
}

/*
 * detalleUsuario
 * Funcion que hace la consulta Ajax para buscar los datos del usuario seleccionado, con el autocomplete.
 */
function detalleUsuario(borrower){
	objAH=new AjaxHelper(updateInfoUsuario);
	objAH.url= '/cgi-bin/koha/circ/detalleUsuario.pl';
	objAH.borrowernumber= borrower;
	//se envia la consulta
	objAH.sendToServer();
}

/*
 * updateInfoUsuario
 * Funcion que se realiza cuando se completa la consulta ajax de detalleUsuario, muestra los datos del usuario.
 */
function updateInfoUsuario(responseText){
	$('#detalleUsuario').slideDown('slow');
	//se borran los mensajes de error/informacion del usuario
	clearMessages();
	$('#detalleUsuario').html(responseText);
}

/*
 * detalleSanciones
 * Funcion que se realiza una consulta para mostrar el detalle de las sanciones del borrower
 */
function detalleSanciones(borr){

	objAH=new AjaxHelper(updateDetalleSanciones);
	objAH.url='/cgi-bin/koha/members/detalleSanciones.pl';
	objAH.borrowernumber= borr;
	objAH.sendToServer();
}


function updateDetalleSanciones(responseText){
	$('#sanciones').html(responseText);
}

/*
 * detalleReservas
 * Funcion que hace la consulta Ajax para traer las reservas del usuario seleccionado.
 * El parametro funcion, es lo que se hace despues de que se completa el ajax. 
 * (updateInfoReservas o updateInfoReservaConChck -- esta definida en prestamos.tmpl)
 * prestamos.tmpl---> tabla de reservas para poder prestar.
 */
function detalleReservas(borrower,funcion){
	objAH=new AjaxHelper(funcion);
	objAH.url= '/cgi-bin/koha/circ/detalleReservas.pl';
	objAH.borrnumber= borrower;
	//se envia la consulta
	objAH.sendToServer();
}

/*
 * updateInfoReservas
 * Funcion que se realiza cuando se completa la consulta ajax de detalleReservas, muestra las reservas del usuario
 * prestamos.tmpl---> se muestra la tabla.
 */
function updateInfoReservas(responseText){
	$('#tablaReservas').slideDown('slow');
	$('#tablaReservas').html(responseText);
	zebra('tablaReservas');
	checkedAll('checkAllReservas','chkboxReservas');
}

/*
 * detallePrestamos
 * Funcion que hace la consulta Ajax para traer los prestamos del usuario seleccionado.
 * devoluviones.tmpl---> tabla de prestmos para poder devolver o renovar.
 */
function detallePrestamos(borrower,funcion){
	objAH=new AjaxHelper(funcion);
	objAH.url= '/cgi-bin/koha/circ/detallePrestamos.pl';
	objAH.borrnumber= borrower;
	//se envia la consulta
	objAH.sendToServer();
}

/*
 * updateInfoPrestamos
 * Funcion que se realiza cuando se completa la consulta ajax de detallePrestamos, 
 * muestra los prestamos del usuario.
 * devoluciones.tmpl---> se muestra la tabla
 */
function updateInfoPrestamos(responseText){
	$('#tablaPrestamos').slideDown('slow');
	$('#tablaPrestamos').html(responseText);
 	zebra('tablaPrestamos');
	checkedAll('checkAllPrestamos','chkboxPrestamos');
}

/*
 * realizarAccion
 * Realiza la accion correspondiente segun el parametro que recibe.
 * @params: accion--> lo que se va a realizar en circulacionDB.pl,(CONFIRMAR_PRESTAMO,RENOVAR,DEVOLVER)
 *          chckbox-> nombre del los checkbox correspondientes a las tablas.
 *	    funcion-> la funcion que se tiene que ejecutar cuando termina la consulta ajax.
 */
function realizarAccion(accion,chckbox,funcion){
	var chck=$("input[@name="+chckbox+"]:checked");
	var array= new Array;
	var long=chck.length;
	if ( long == 0){
		alert("Elija al menos un documento para realizar la acci&oacute;n");
	}
	else{

		for(var i=0; i< long; i++){
			array[i]=chck[i].value;
		}
		objAH=new AjaxHelper(funcion);
		objAH.url= '/cgi-bin/koha/circ/circulacionDB.pl';
		objAH.tipoAccion= accion;
		objAH.datosArray= array;
		objAH.borrowernumber=usuario.ID;
		//se envia la consulta
		objAH.sendToServer();
	}
}

/*
 * generaComboPrestamo
 * Funcion que se hace cuando termina la funcion realizarAccion.
 * Genera el div con los datos de los prestamos a realizar, con la posibilidad de seleccionar el tipo de prestamo
 * y el item que se va a prestar.
 * prestamos.tmpl---> crea el div para los prestamos
 */
function generaDivPrestamo(responseText){
	infoArray= new Array;
	infoArray= JSONstring.toObject(responseText);
	var html="<div class='divCirculacion'> <p class='fontMsgConfirmation'>";
	var i;

	for(i=0; i<infoArray.length;i++){
	
		var infoPrestamoObj= new infoPrestamo();
		infoPrestamoObj.id3Old= infoArray[i].id3Old;
		infoPrestamos_array[i]= infoPrestamoObj;
 
		var comboItems =crearCombo(infoArray[i].items, 'comboItems' + i);
		var comboTipoPrestamo =crearCombo(infoArray[i].tipoPrestamo, 'tiposPrestamos' + i);
		if(infoArray[i].autor != ""){ html= html + infoArray[i].autor + ", "};
		html= html + infoArray[i].titulo + ", ";
		if(infoArray[i].unititle != ""){html= html + infoArray[i].unititle + ", "};
		if(infoArray[i].edicion != ""){html= html + infoArray[i].edicion + ". <br>"};
		html= html + "C&oacute;digo de barras: " + comboItems + "<br>";
		html= html + "Tipo de pr&eacute;stamo: " + comboTipoPrestamo + "<br>";
	}

	html= html + "</p>";
	html= html + "<center><input type='button' value='Aceptar' onClick='prestar()'><input type='button' value='Cancelar' onClick='cancelarDiv();'></center><br>";
	html= html + "</div>";

	$('#confirmar_div').html(html);
	scrollTo('confirmar_div');
}

/*
 * crearCombo
 * Crea los combos necesarios para poder seleccionar el item y el tipo de prestamo, para cada item que se va a
 * prestar.
 * prestamos.tmpl--->se usa en la funcion generarDivPrestamos.
 * PUEDE IR EN OTRA LIBRERIA, COMO UTIL.js !!!!!!???????
 */
function crearCombo(items_array, idSelect){
	var opciones= '';	
	var html= "<select id='" + idSelect + "'>";
	var i;
	for(i=0;i<items_array.length;i++){
		opciones= opciones + "<option value=" + items_array[i].value + ">" + items_array[i].label + "</option>";
	}
	html= html + opciones + "</select>";
	return html;
}

/*
 * prestar
 * Funcion que realiza los prestamos correspondientes a los items seleccionados.
 * prestamos.tmpl---> se prestan los libros.
 */
function prestar(){

	for(var i=0; i< infoPrestamos_array.length; i++){
		//se setea el id3 que se va a prestar
		infoPrestamos_array[i].id3= $('#comboItems' + i).val();
		infoPrestamos_array[i].barcode= $("#comboItems" + i + " option:selected").text();
		infoPrestamos_array[i].tipoPrestamo= $('#tiposPrestamos' + i).val();
		infoPrestamos_array[i].descripcionTipoPrestamo= $("#tiposPrestamos" + i + " option:selected").text();
	}
	
	objAH=new AjaxHelper(updateInfoPrestarReserva);
	objAH.url= '/cgi-bin/koha/circ/circulacionDB.pl';
	objAH.tipoAccion= 'PRESTAMO';
	objAH.datosArray= infoPrestamos_array;
	objAH.borrowernumber= usuario.ID;
	//se envia la consulta
	objAH.sendToServer();

}

/*
 * updateInfoPrestarReserva
 * Funcion que se realiza cuando se realiza el prestamo.
 * prestamos.tmpl---> se actualiza la tabla de reservas despues que se presto algun item.
 */
function updateInfoPrestarReserva(responseText){
	cancelarDiv();
	clearMessages();

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.messages;
	var ticketsArray= infoHash.tickets;
	var mensajes= '';
	for(var i=0; i<messageArray.length;i++){
		imprimirTicket(ticketsArray[i].ticket,i);
  		setMessages(messageArray[i]);
	}

	detalleReservas(usuario.ID,updateInfoReservas);
}

/*
 * cancelarDiv
 * Cancela el prestamo, renovacion, o devolucion que se iba a realizar.
 * Borra el div generado por la funcion generaDivPrestamo
 * prestamos.tmpl---> se borra el div que contiene los datos de los prestamos.
 */
function cancelarDiv(){
	$('#confirmar_div').html('');
}

/*
 * cancelarReserva
 * Funcion que cancela la reserva seleccionada.
 * prestamos.tmpl---> se cancela la reserva.
 */
function cancelarReserva(reserveNumber){

	var is_confirmed = confirm('Esta seguro que desea cancelar la reserva?');
        if (is_confirmed) {
		objAH=new AjaxHelper(updateInfoCancelacion);
		objAH.url='/cgi-bin/koha/circ/circulacionDB.pl';
		objAH.tipoAccion= 'CANCELAR_RESERVA';
		objAH.borrowernumber=usuario.ID;
		objAH.reserveNumber=reserveNumber;
		objAH.sendToServer();
        }
}

/*
 * updateInfoCancelacion
 * Funcion que se ejecuta cuando se cancela una reserva, muestra el mensaje si hay algun error y actualiza la
 * tabla de reservas.
 */
function updateInfoCancelacion(responseText){
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
	detalleReservas(usuario.ID,updateInfoReservas);
}

/*
 * generaDivDevRen
 * Genera el div con los datos de los items que se van a devolver o renovar.
 */
function generaDivDevRen(responseText){
	infoArray= new Array;
	infoPrestamos_array= new Array();
	infoArray= JSONstring.toObject(responseText);
	var html="<div class='divCirculacion'> <p class='fontMsgConfirmation'>";
	var accion=infoArray[0].accion;
	html=html + infoArray[0].accion +":<br>";
	for(var i=0; i<infoArray.length;i++){
	
		var infoDevRenObj= new infoPrestamo();
		infoDevRenObj.id3= infoArray[i].id3;
		infoDevRenObj.barcode=infoArray[i].barcode;
		infoPrestamos_array[i]= infoDevRenObj;
 
		if(infoArray[i].autor != ""){ html= html + infoArray[i].autor + ", "};
		html= html + infoArray[i].titulo + ", ";
		if(infoArray[i].unititle != ""){html= html + infoArray[i].unititle + ", "};
		if(infoArray[i].edicion != ""){html= html + infoArray[i].edicion + ". <br>"};
	}
	html= html + "</p>";
	html= html + "<center><input type='button' value='Aceptar' onClick=devolver_renovar('"+accion+"')><input type='button' value='Cancelar' onClick='cancelarDiv();'></center><br>";
	html= html + "</div>";

	$('#confirmar_div').html(html);
	scrollTo('confirmar_div');
}

/*
 * devolver_renovar
 * Devuelve o renueva el o los items seleccionados.
 */
function devolver_renovar(accion){
	objAH=new AjaxHelper(updateInfoDevRen);
	objAH.url= '/cgi-bin/koha/circ/circulacionDB.pl';
	objAH.tipoAccion= 'DEVOLVER_RENOVAR';
	objAH.datosArray= infoPrestamos_array;
	objAH.borrowernumber= usuario.ID;
	objAH.accion=accion;
	//se envia la consulta
	objAH.sendToServer();
}

/*
 * updateInfoDevRen
 * Funcion que se ejecuta cuando se realiza devoluviones o renovaciones y actualiza la tabla de prestamos.
 * IGUAL A updateInfoPrestarReserva SALVO POR EL LLAMADO A LOS DETALLES.
 */
function updateInfoDevRen(responseText){
	cancelarDiv();
	clearMessages()

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.messages;
	var ticketsArray= infoHash.tickets;
	
	var mensajes= '';
	for(i=0; i<messageArray.length;i++){
		imprimirTicket(ticketsArray[i].ticket,i);
  		setMessages(messageArray[i]);
	}

	detallePrestamos(usuario.ID,updateInfoPrestamos);
}

/*
 * imprimirTicket
 * Abre la ventana para poder imprimir el ticket del prestamo o renovacion.
 * @params: ticket, es el objeto que representa al ticket, o 0 si hubo algun error antes de generar el ticket.
 *          num, es el indice que se usa para darle nombre a la ventana.
 */
function imprimirTicket(ticket,num){

	if(ticket != 0){
		var obj=JSONstring.make(ticket)
		window.open ("../circ/receipt.pl?obj="+obj, "Boleta "+num,"width=650,height=550,status=no,location=no,menubar=no,personalbar=no,resizable=no,scrollbars=no");
	}
}

// function scrollTo(idObj){
// 		var divOffset = $('#'+idObj).offset().top;
// 		$('html,body').animate({scrollTop: divOffset}, 1000);
// }


