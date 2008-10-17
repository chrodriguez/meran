/*
 * LIBRERIA WindowHelper v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 *
 */


//Funciones Privadas para manejar el estado del la consulta de AJAX

function _WinInit(objWin){
	_WinAddDiv(objWin);
}

function _WinAddDiv(objWin){

	var contenedor = $('#ventana')[0];

  	if(contenedor == null){
	//se crea el dimmer que bloquea el fondo
		$('body').append("<div id='dimmer' class='dimmer' style='height: 1000px; width: 100%;top: 0px; visibility: visible; position:absolute'></div>");
	//se crea la ventana 
		$('body').append("<div id='ventana' class='dimming' style='display:none; height:85%; width:85%; top:10px;'><div class='winHeader'><img align='right' id='cerrar' src='/intranet-tmpl/blue/es2/images/cerrar.gif'/><span width=100px>" + objWin.titulo + "</span></div><div id='ventanaContenido'></div></div>");
	//se loguea 
		if( (objWin.debug)&&(window.console) ){
  				console.log("WindowHelper => create()");
  		}
 	}

	$('#ventanaContenido').html(objWin.html);	
	$('#ventana').draggable({opacity: 0.7777});
	$('#cerrar').click( function (){objWin.hide()} );

}



function WindowHelper(){

	this.html= '';		//respuesta del servidor, responseText
	this.dimmer= '';	//oscurecimiento y bloqueo del fondo
	this.showState= true;   //muestra o no el gif animado
	this.opacity= '';	//opacidad de la ventana
	this.debug= false;	
	this.titulo= '';

	this.show= function(){
			//se muestra la ventana
			$('#ventana').show();
	}//end show

	this.hide= function(){
			//se oculta la ventana
			$('#ventana').hide();
			$('#dimmer').hide();
	}//end hide

	this.create= function(){
			//crea una ventana
			_WinInit(this);
			this.show();
			alert('heignt: ' + $('#ventanaContenido').innerHeight() + 'width: ' + $('#ventanaContenido').innerWidth());
	}//end create

}


