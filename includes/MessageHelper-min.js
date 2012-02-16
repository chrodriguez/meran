function clearMessages(){$('#mensajes').css({opacity:0,"filter":"alpha(opacity=0)"});$('#mensajes').hide();$('#mensajes').html('');}
function verificarRespuesta(responseText){if(responseText==0){jAlert(DATOS_ENVIADOS_INCORRECTOS,'Info','errboxid');return(0);}else{return(1);}}
function setMessages(Messages_hashref){//@params
try{_createContentMessages();var i;for(i=0;i<Messages_hashref.messages.length;i++){$('#mensajes').append('<p>'+Messages_hashref.messages[i].message+'</p>');}
$('#mensajes').removeClass('hide');$('html, body').animate({scrollTop:0},'slow');_delay(clearMessages,60);}
catch(e){}}
function _createContentMessages(){var contenedor=$('#mensajes')[0];if(contenedor==null){$('#end_top').append("<div id='mensajes' class='alert hide pagination-centered'><br /> </div>");}
else{clearMessages();}}
function _delay(funcion,segundos){setTimeout(funcion,segundos*1000);}
function hayError(msg){if(msg.error==1)
return(true);return(false);}