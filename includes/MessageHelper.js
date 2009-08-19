/*
 * LIBRERIA MessageHelper v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 * @author Carbone Miguel
 * Fecha de creacion 09/09/2008
 *
 */
/*
* En esta libreria se denerian manejar todos los mensajes de respuesta desde el servidor al cliente,
* ya sean de error, informacion, warnings, etc
*/

// FIXME 
//Faltaria manejar mejor el log, opcion debug idem a demas helpers


function _clearMessages(){
	$('#mensajes').html('');
}

function verificarRespuesta(responseText){
    if (responseText == 0){
        alert(DATOS_ENVIADOS_INCORRECTOS);
        return(0);
    }else{
        return (1);
    }
}
//Esta funcion setea varios mensajes enviados desde el servidor
function setMessages(Messages_hashref){
//@params
//Message.messages, arreglo de mensajes mensaje para el usuario
//Message.error, error=1 o 0

//Mensajes:
//Message.error, hay error (error=1)
//Message.messages: [message_1, message_2, ... , message_n]
//message1: 	codMsg: 'U324'
//		message: 'Texto para informar'

	_createContentMessages();
	var i;
	for(i=0;i<Messages_hashref.messages.length;i++){
		$('#mensajes').append(Messages_hashref.messages[i].message + '<br>');
	}

	scrollTo('mensajes');
	_delay(_clearMessages, 10);
}

//crea el contenedor para los mensajes, si ya esta creado, borra el contenido
function _createContentMessages(){

	var contenedor = $('#mensajes')[0];

	if(contenedor == null){
		//console.log("MessageHelper: Se crea el div cotenedor");
		$('#end_top').append("<div class='mensajes_informacion'><div id='mensajes'></div></div>");
	}
	else{
		_clearMessages();
	}
}

//luego de x segundos se ejecuta la funcion pasada por parametro
function _delay(funcion, segundos){
	setTimeout(funcion, segundos*600);
}

function hayError(msg){
	if (msg.error == 1)
		return (true);

	return (false);
}
