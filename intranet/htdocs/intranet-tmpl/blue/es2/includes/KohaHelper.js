/*
 * LIBRERIA KohaHelper v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 *
 */

function usuariosConectados(){
	objAH=new AjaxHelper(updateInfoUsuariosConectados);
	objAH.url= '/cgi-bin/koha/KohaDB.pl';
// 	objAH.borrowernumber= borrower;
	//se envia la consulta
	objAH.tipo= 'USUARIOS_CONECTADOS';
	objAH.sendToServer();
}


function _AddDiv(){

	var contenedor = $('#state')[0];
	if(contenedor == null){
		$('body').append("<div id='stateUsers' class='loading' style='position:absolute'></div>");
// 		$('#state').html("<img src='/intranet-tmpl/blue/es2/images/indicator.gif' />");
		$('#state').css('top', '0px');
		$('#state').css('left', '0px');

	}
}

function updateInfoUsuariosConectados(responseText){
	$('#stateUsers').html("Usuarios Conectados: " + responseText);
	resfreshUsuariosConectados();
}

function resfreshUsuariosConectados(){
	var segundos= 10;
	setTimeout(usuariosConectados, segundos*1000);
}

//Init Form
$(document).ready(function() {
	
// 	_AddDiv();
// 	resfreshUsuariosConectados();

});
