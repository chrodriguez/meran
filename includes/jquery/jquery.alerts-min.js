function jAlert(message){bootbox.alert(message);}
function jPrompt(mensaje,inputText,title,funcion){var result=prompt(mensaje,inputText);if(result)
funcion(result);}