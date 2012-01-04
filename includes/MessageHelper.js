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


// TODO armar objeto
// function MessageHelper(){
//     //defino las propiedades  
// //     this.nombre                     = obj.nombre;
// 
//     function fClearMessages(){     
//         $('#mensajes').css({opacity:0,"filter":"alpha(opacity=0)"});
//         $('#mensajes').hide();
//         $('#mensajes').html(''); 
//     };
//     
//     //metodos
//     this.clearMessages = fClearMessages;
// 
// }

function clearMessages(){
    $('#mensajes').css({opacity:0,"filter":"alpha(opacity=0)"});
    $('#mensajes').hide();
	$('#mensajes').html('');
}

function verificarRespuesta(responseText){
    if (responseText == 0){
        jAlert(DATOS_ENVIADOS_INCORRECTOS,'Info', 'errboxid');
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
    try{

//         if (!($('#mensajes').html()))
         _createContentMessages();
        var i;
        //se agregan todos los mensajes
        for(i=0;i<Messages_hashref.messages.length;i++){
            $('#mensajes').append('<div class="message_text" >'+Messages_hashref.messages[i].message + '</div>');
            
        }
        $('#mensajes').css("display","block");

        _show();
        $('html, body').animate({scrollTop:0}, 'slow');
        _delay(clearMessages, 20);
    }
    catch (e){
      // We do nothing ;)
    }
}


function assignCloseButton(){
    $('#close_message').click(function()
    {
      //the messagebox gets scrool down with top property and gets hidden with zero opacity
      $('#mensajes').animate({opacity:0}, "slow");
      clearMessages();
    });

}
//crea el contenedor para los mensajes, si ya esta creado, borra el contenido
function _createContentMessages(){

	var contenedor = $('#mensajes')[0];

	if(contenedor == null){
     //no existe el contenedor, se crea
		//console.log("MessageHelper: Se crea el div cotenedor");
		$('#end_top').append("<div class='mensajes_informacion'><div id='mensajes'><img id='close_message' style='float:right;cursor:pointer' src="+imagesForJS+'/iconos/12-em-cross.png'+" /></div></div>");
	}
	else{
    //existe el contenedor, lo limpio
        clearMessages();
        $('#mensajes').append("<img id='close_message' style='float:right;cursor:pointer' src='"+imagesForJS+'/iconos/12-em-cross.png'+ " />");
	}

    _show();
    assignCloseButton();
}

function _show(){
    $('#mensajes').animate({opacity:90,"filter":"alpha(opacity=90)"}, "fast");
}

//luego de x segundos se ejecuta la funcion pasada por parametro
function _delay(funcion, segundos){
	setTimeout(funcion, segundos*1000);
}

function hayError(msg){
	if (msg.error == 1)
		return (true);

	return (false);
}
