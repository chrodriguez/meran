/*
 * LIBRERIA circulacion v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Las siguientes librerias son necesarias:
 *	<script src="/intranet-tmpl/includes/jquery/jquery.js"></script>
 *	<script src="/intranet-tmpl/includes/json/jsonStringify.js"></script>
 *	<script src="/intranet-tmpl/includes/AjaxHelper.js"></script>
 *	<script src="/intranet-tmpl/includes/util.js"></script>
 *	<script src="/intranet-tmpl/includes/jquery/jquery.bgiframe.js"></script>
 *	<script src="/intranet-tmpl/includes/jquery/jquery.autocomplete.js"></script>
 * @author Carbone Miguel, Di Costanzo Damian
 * Fecha de creacion 19/06/2008
 *
 */


var INFO_PRESTAMOS_ARRAY= new Array();//Arreglo que contendra los objetos, con info que pertenece a los prestamos.
var objAH;//Objeto AjaxHelper.

/*
 * infoPrestamo
 * Representa al objeto que contendra la informacion para poder prestar el item. 
 * Que se pasara con json al servidor, en un arreglo (INFO_PRESTAMOS_ARRAY).
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
 * detalleUsuario
 * Funcion que hace la consulta Ajax para buscar los datos del usuario seleccionado, con el autocomplete.
 */
function detalleUsuario(nro_socio){
	objAH               = new AjaxHelper(updateInfoUsuario);
	objAH.debug         = true;
    objAH.cache         = true;
    objAH.showOverlay   = true;
	objAH.url           = URL_PREFIX+'/circ/detalleUsuario.pl';
	objAH.nro_socio     = nro_socio;
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
	$('#detalleUsuario').html(responseText);
}

/*
 * detalleSanciones
 * Funcion que se realiza una consulta para mostrar el detalle de las sanciones del nro_socio
 */
function detalleSanciones(nro_socio){

	objAH                   = new AjaxHelper(updateDetalleSanciones);
	objAH.debug             = true;
    objAH.showOverlay       = true;
	objAH.url               = URL_PREFIX+'/usuarios/reales/detalleSanciones.pl';
	objAH.nro_socio         = nro_socio;
	objAH.sendToServer();
}


function updateDetalleSanciones(responseText){
    $('#sanciones').slideDown('slow');
	$('#sanciones').html(responseText);
}

/*
 * detalleReservas
 * Funcion que hace la consulta Ajax para traer las reservas del usuario seleccionado.
 * El parametro funcion, es lo que se hace despues de que se completa el ajax. 
 * (updateInfoReservas o updateInfoReservaConChck -- esta definida en prestamos.tmpl)
 * prestamos.tmpl---> tabla de reservas para poder prestar.
 */
function detalleReservas(nro_socio,funcion){
	objAH               = new AjaxHelper(funcion);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url           = URL_PREFIX+'/circ/detalleReservas.pl';
	objAH.nro_socio     = nro_socio;
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
function detallePrestamos(nro_socio,funcion){
	objAH               = new AjaxHelper(funcion);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url           = URL_PREFIX+'/circ/detallePrestamos.pl';
	objAH.nro_socio     = nro_socio;
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
function realizarAccion(accion,id_table,funcion) {
    var chck    = $('#'+id_table).find(':checked');
	var array   = new Array;
	var long    = chck.length;

	if ( long == 0){
		jAlert(ELIJA_AL_MENOS_UN_EJEMPLAR);
	} else {
      
		for(var i=0; i< long; i++){
                array[i]=chck[i].value;
		}
        
		objAH                   = new AjaxHelper(funcion);
		objAH.debug             = true;
        objAH.showOverlay       = true;
		objAH.url               = URL_PREFIX+"/circ/circulacionDB.pl";
		objAH.tipoAccion        = accion;
		objAH.datosArray        = array;
		objAH.nro_socio         = USUARIO.ID;
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

// TODO habría que ver si esto puede ser un partial
function generaDivPrestamo(responseText){
	var infoArray       = new Array;
	infoArray           = JSONstring.toObject(responseText);
	var html            = "<div class='divCirculacion'> <p class='fontMsgConfirmation'>";
	var i;
    

	for(i=0; i<infoArray.length;i++){
	
        var coma                = "";
		var infoPrestamoObj     = new infoPrestamo();
		infoPrestamoObj.id3Old  = infoArray[i].id3Old;
		INFO_PRESTAMOS_ARRAY[i] = infoPrestamoObj;
 
        var comboItems          = crearComboDeItems(infoArray[i].items, 'comboItems' + i, infoArray[i].id3Old);
		var comboTipoPrestamo   = crearComboDeItems(infoArray[i].tipoPrestamo, 'tiposPrestamos' + i);
      
		if((infoArray[i].autor != "")&&(infoArray[i].autor != null)){ 
            html    = html + infoArray[i].autor;
            coma    = ", ";
        };

		if((infoArray[i].titulo != "")&&(infoArray[i].titulo != null)){ 
            html= html + coma + infoArray[i].titulo;
            coma    = ", ";
        };

		if((infoArray[i].edicion != "")&&(infoArray[i].edicion != null)){ html= html + coma + infoArray[i].edicion};
		html= html + "<br>C&oacute;digo de barras: " + comboItems;
		html= html + "<br>Tipo de pr&eacute;stamo: " + comboTipoPrestamo;
	}

	html= html + "</p>";
	html= html + "<center><input type='button' value='Aceptar' onClick='prestar()'>";
	html= html + "<input type='button' value='Cancelar' onClick='cancelarDiv();'></center><br>";
	html= html + "</div>";

	$('#confirmar_div').html(html);
	scrollTo('confirmar_div');
}

/*
 * crearComboDeItems
 * Crea los combos necesarios para poder seleccionar el item y el tipo de prestamo, para cada item que se va a
 * prestar.
 * prestamos.tmpl--->se usa en la funcion generarDivPrestamos.
 * PUEDE IR EN OTRA LIBRERIA, COMO UTIL.js !!!!!!???????
 */
function crearComboDeItems(items_array, idSelect, itemSelected){
	var opciones= '';	
	var html= "<select id='" + idSelect + "'>";
	var i;
	for(i=0;i<items_array.length;i++){
        
		opciones= opciones + "<option value=" + items_array[i].value;
        if((itemSelected)&&(itemSelected==items_array[i].value)){
            opciones= opciones + " selected ";
        }
        opciones= opciones + ">" + items_array[i].label + "</option>";
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

	for(var i=0; i< INFO_PRESTAMOS_ARRAY.length; i++){
		//se setea el id3 que se va a prestar
		INFO_PRESTAMOS_ARRAY[i].id3                     = $('#comboItems' + i).val();
		INFO_PRESTAMOS_ARRAY[i].barcode                 = $("#comboItems" + i + " option:selected").text();
		INFO_PRESTAMOS_ARRAY[i].tipoPrestamo            = $('#tiposPrestamos' + i).val();
		INFO_PRESTAMOS_ARRAY[i].descripcionTipoPrestamo = $("#tiposPrestamos" + i + " option:selected").text();
	}
	
	objAH               = new AjaxHelper(updateInfoPrestarReserva);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url           = URL_PREFIX+'/circ/circulacionDB.pl';
	objAH.tipoAccion    = 'PRESTAMO';
	objAH.datosArray    = INFO_PRESTAMOS_ARRAY;
	objAH.nro_socio     = USUARIO.ID;
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
	var infoHash        = JSONstring.toObject(responseText);  
	var messageArray    = infoHash.messages;
	var ticketsArray    = infoHash.tickets;
	var mensajes        = '';  
    var hayError=0;
    
   	for(i=0; i<messageArray.length;i++){
//         imprimirTicket(ticketsArray[i].ticket,i);
        setMessages(messageArray[i]);
    }
     
    for(i=0; i<messageArray.length;i++){
       if  (messageArray[i].error){
           hayError= 1;
       }
    }
    if (!hayError){
         imprimirTicket(ticketsArray);
    }

	detalleReservas(USUARIO.ID,updateInfoReservas);
    ejemplaresDelGrupo(ID_N2);
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

	jConfirm(ESTA_SEGURO_QUE_DESEA_CANCELAR_LA_RESERVA,'Info',function(is_confirmed){
        if (is_confirmed) {
            objAH               = new AjaxHelper(updateInfoCancelacion);
            objAH.debug         = true;
            objAH.showOverlay   = true;  
            objAH.url           = URL_PREFIX+'/circ/circulacionDB.pl';
            objAH.tipoAccion    = 'CANCELAR_RESERVA';
            objAH.nro_socio     = USUARIO.ID;
            objAH.id_reserva    = reserveNumber;
            objAH.sendToServer();
        }
    });
}


/*
 * updateInfoCancelacion
 * Funcion que se ejecuta cuando se cancela una reserva, muestra el mensaje si hay algun error y actualiza la
 * tabla de reservas.
 */
function updateInfoCancelacion(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	detalleReservas(USUARIO.ID,updateInfoReservas);
}


/*
 * generaDivDevolucion
 * Genera el div con los datos de los items que se van a devolver o renovar.
 */
function generaDivDevolucion(responseText){

	var infoArray           = new Array;
	INFO_PRESTAMOS_ARRAY    = new Array();
	infoArray               = JSONstring.toObject(responseText);
	var html                = "<div class='divCirculacion'> <p class='fontMsgConfirmation'>";
	var accion              = infoArray[0].accion;
	html                    = html + infoArray[0].accion +":<br>";

	for(var i=0; i<infoArray.length;i++){
	
		INFO_PRESTAMOS_ARRAY[i]= infoArray[i].id_prestamo;
 
		if((infoArray[i].autor != "")&&(infoArray[i].autor != null)){ 
            html= html + infoArray[i].autor;
            if((infoArray[i].titulo != "")&&(infoArray[i].titulo != null)){html= html + ", ";}
        }

        if((infoArray[i].titulo != "")&&(infoArray[i].titulo != null)){
            html= html + infoArray[i].titulo;
        }

        if((infoArray[i].edicion != "")&&(infoArray[i].edicion != null)){
            html= html + " - " + infoArray[i].edicion + "<br>"
        };
        
        html= html + " (" + infoArray[i].barcode + ")<br>"  
  
        html= html + "<br>"
	}

	html= html + "</p>";
	html= html + "<center><input type='button' value='Aceptar' onClick=devolver()>";
	html= html + "<input type='button' value='Cancelar' onClick='cancelarDiv();'></center><br>";
	html= html + "</div>";

	$('#confirmar_div').html(html);
	scrollTo('confirmar_div');
}

/*
 * generaDivRenovacion
 * Genera el div con los datos de los items que se van a devolver o renovar.
 */
function generaDivRenovacion(responseText){
	var infoArray= new Array;
	INFO_PRESTAMOS_ARRAY= new Array();
	infoArray= JSONstring.toObject(responseText);
	var html="<div class='divCirculacion'> <p class='fontMsgConfirmation'>";
	var accion=infoArray[0].accion;
	html=html + infoArray[0].accion +":<br>";
	for(var i=0; i<infoArray.length;i++){
	
		var infoDevRenObj= new infoPrestamo();
		infoDevRenObj.nro_socio= infoArray[0].nro_socio;
        infoDevRenObj.id_prestamo= infoArray[i].id_prestamo;
		infoDevRenObj.id3= infoArray[i].id3;
		infoDevRenObj.barcode=infoArray[i].barcode;
		INFO_PRESTAMOS_ARRAY[i]= infoDevRenObj;
 
        
        if((infoArray[i].autor != "")&&(infoArray[i].autor != null)){ 
            html= html + infoArray[i].autor;
            if((infoArray[i].titulo != "")&&(infoArray[i].titulo != null)){html= html + ", ";}
        }
        
        if((infoArray[i].titulo != "")&&(infoArray[i].titulo != null)){
            html= html + infoArray[i].titulo;
        }
        
        if((infoArray[i].edicion != "")&&(infoArray[i].edicion != null)){
            html= html + " - " + infoArray[i].edicion + "<br>"
        };
        
        html= html + " (" + infoArray[i].barcode + ")<br>"  
        
        html= html + "<br>"

	}
	html= html + "</p>";
	html= html + "<center><input type='button' value='Aceptar' onClick=renovar()>";
	html= html + "<input type='button' value='Cancelar' onClick='cancelarDiv();'></center><br>";
	html= html + "</div>";

	$('#confirmar_div').html(html);
	scrollTo('confirmar_div');
}

/*
 * devolver_renovar
 * Devuelve o renueva el o los items seleccionados.
 */
// function devolver_renovar(accion){
function renovar(){
	objAH               = new AjaxHelper(updateInfoRenovar);
	objAH.debug         = true;
    objAH.showOverlay   = true;  
	objAH.url           = URL_PREFIX+'/circ/circulacionDB.pl';
	objAH.tipoAccion    = 'REALIZAR_RENOVACION';
	objAH.datosArray    = INFO_PRESTAMOS_ARRAY;
	objAH.nro_socio     = USUARIO.ID;
	//se envia la consulta
	objAH.sendToServer();
}


/*
 * updateInfoRenovar
 * Funcion que se ejecuta cuando se realiza devoluviones o renovaciones y actualiza la tabla de prestamos.
 * IGUAL A updateInfoPrestarReserva SALVO POR EL LLAMADO A LOS DETALLES.
 */
function updateInfoRenovar(responseText){
	cancelarDiv();

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.messages;
	var ticketsArray= infoHash.tickets;
	var hayError=0;
    
    setMessages(messageArray);
    
    for(i=0; i<messageArray.length;i++){
//         imprimirTicket(ticketsArray[i].ticket,i);
        setMessages(messageArray[i]);
    }
     
    for(i=0; i<messageArray.length;i++){
       if  (messageArray[i].error){
           hayError= 1;
       }
    }
    
    if (!hayError){
         imprimirTicket(ticketsArray);
    }
  
	detallePrestamos(USUARIO.ID,updateInfoPrestamos);
    ejemplaresDelGrupo(ID_N2);
}


/* devolver
* realiza la devolucion de 1 a n ejemplares segun INFO_PRESTAMOS_ARRAY
*/
function devolver(){
	objAH               = new AjaxHelper(updateInfoDevolver);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url           = URL_PREFIX+'/circ/circulacionDB.pl';
	objAH.tipoAccion    = 'REALIZAR_DEVOLUCION';
	objAH.datosArray    = INFO_PRESTAMOS_ARRAY;
	objAH.nro_socio     = USUARIO.ID;
	//se envia la consulta
	objAH.sendToServer();
}

/*
* Esta funcion debe estar implementada en los templates devoluciones.tmpl
* si no se implementa ahi, hereda esta funcion, debe ser redefinida para cada template en particular
*/
function updateInfoDevolver(responseText){
//implementado en cada template en particular
}


/*
 * imprimirTicket
 * Abre la ventana para poder imprimir el ticket del prestamo o renovacion.
 * @params: ticket, es el objeto que representa al ticket, o 0 si hubo algun error antes de generar el ticket.
 *          num, es el indice que se usa para darle nombre a la ventana.
 */

function imprimirTicket(tickets){
    var comprobantes=new Array();
    if(tickets.length > 0){
        for(i=0; i< tickets.length;i++){
                     comprobantes[i]= tickets[i]; 

        }
    }
    
    var obj=JSONstring.make(comprobantes);   
    window.open (URL_PREFIX+"/circ/ticket.pl?token="+token+"&obj="+obj,this.href);
//         objAH               = new AjaxHelper(updateImprimirTicket);
//         objAH.debug         = true;
//         objAH.showOverlay   = true;
//         objAH.url           = URL_PREFIX+'/circ/circulacionDB.pl';
//         objAH.tipoAccion    = 'IMPRIMIR_COMPROBANTE';
//         objAH.comprobantes  = comprobantes;
// //         objAH.nroBoleta     = num;
//         //se envia la consulta
//         objAH.sendToServer();
//   }
}


function updateImprimirTicket(responseText){
    
 
   //     $('#ticket').html(responseText);
       
        
 //       $('#ticket').printElement({ printBodyOptions:
 //                                       { styleToAdd:'color:#FFFFFF;' ,
  //                                      classNameToAdd : 'comprobante'} 
  //                                }
  //      );*/
//         $('#ticket').hide();
//         var infoHash= JSONstring.toObject(responseText);
//         var filename= infoHash.filename;
//         var html="<a id='link_comp' onclick='filename;'> Imprimir</a>";
//         $('#mensajes').append(html);

}

function mostrarComprobante(){

    $('#ticket').modal({   containerCss:{
             backgroundColor:"#fff",
//             height:420,
//             padding:0,
//             width:650,
               color: "#000",
            
        },
      });

}

// FIXME esta muy feo esto!!!!!!!!!!!!!!!!!!!!!!!!!!!
/*
function imprimirTicket(ticket,num){

	if(ticket != 0){
		var obj=JSONstring.make(ticket);        
  		window.open (URL_PREFIX+"/circ/ticket.pl?token="+token+"&obj="+obj, "Boleta "+num,this.href);
	}  
}*/

