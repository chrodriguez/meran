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
// EN PRINCIPIO ES NECESARIO QUE EN EL TMPL QUE SE VAYA A UTILIZAR SE CREE UN DIV CON ID "mensajes",
//estaria bueno que esto se genere dinamicamente

/*
//Esta funcion setea un mensaje enviado desde el servidor
function setMessage(Message){
//@params
//Message.message, mensaje para el usuario
//Message.error, hay error (error=1)
//Message.codMsg, codigo del mensaje
	$('#mensajes').html('');
	$('#mensajes').append(Message.message + '<br>');
	scrollTo('mensajes');
}
*/

/*
//Esta funcion setea varios mensajes enviados desde el servidor
function setMessages(Message){
//@params
//Message.message, mensaje para el usuario
//Message.error, hay error (error=1)
//Message.codMsg, codigo del mensaje

	$('#mensajes').append(Message.message + '<br>');
	scrollTo('mensajes');
}
*/

function clearMessages(){
	$('#mensajes').html('');
}

// FIXME deje setMessages2 hasta q se modifique todo lo referenciado por setMessages q no se usa mas
//Esta funcion setea varios mensajes enviados desde el servidor
function setMessages(Messages_hasref){
//@params
//Message.messages, arreglo de mensajes mensaje para el usuario
//Message.error, error=1 o 0

//Mensajes:
//Message.error, hay error (error=1)
//Message.messages: [message_1, message_2, ... , message_n]
//message1: 	codMsg: 'U324'
//		message: 'Texto para informar'

	clearMessages();
	var i;
	for(i=0;i<Messages_hasref.messages.length;i++){
		$('#mensajes').append(Messages_hasref.messages[i].message + '<br>');
	}

	scrollTo('mensajes');
}

