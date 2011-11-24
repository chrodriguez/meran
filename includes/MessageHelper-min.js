function clearMessages(){$('#mensajes').css({opacity:0,"filter":"alpha(opacity=0)"});$('#mensajes').hide();$('#mensajes').html('');}
function verificarRespuesta(responseText){if(responseText==0){jAlert(DATOS_ENVIADOS_INCORRECTOS,'Info','errboxid');return(0);}else{return(1);}}
function setMessages(Messages_hashref){//@params
try{_createContentMessages();var i;for(i=0;i<Messages_hashref.messages.length;i++){$('#mensajes').append('<div class="message_text" >'+Messages_hashref.messages[i].message+'</div>');}
$('#mensajes').css("display","block");_show();$('html, body').animate({scrollTop:0},'slow');_delay(clearMessages,180);}
catch(e){}}
function assignCloseButton(){$('#close_message').click(function()
{$('#mensajes').animate({opacity:0},"slow");clearMessages();});}
function _createContentMessages(){var contenedor=$('#mensajes')[0];if(contenedor==null){$('#end_top').append("<div class='mensajes_informacion'><div id='mensajes'><img id='close_message' style='float:right;cursor:pointer' src="+imagesForJS+'/iconos/12-em-cross.png'+" /></div></div>");}
else{clearMessages();$('#mensajes').append("<img id='close_message' style='float:right;cursor:pointer' src='"+imagesForJS+'/iconos/12-em-cross.png'+" />");}
_show();assignCloseButton();}
function _show(){$('#mensajes').animate({opacity:90,"filter":"alpha(opacity=90)"},"fast");}
function _delay(funcion,segundos){setTimeout(funcion,segundos*1000);}
function hayError(msg){if(msg.error==1)
return(true);return(false);}