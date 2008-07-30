/*
 * LIBRERIA AjaxhHelper v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 * @author Carbone Miguel, Di Costanzo Damian
 * Fecha de creacion 22/05/2008
 *
 */


//Funciones Privadas para manejar el estado del la consulta de AJAX

function _Init(options){
	_AddDiv();
	_ShowState(options);
}

function _AddDiv(){

	var contenedor = $('#state')[0];
	if(contenedor == null){
		$('body').append("<div id='state' class='loading' style='position:absolute'></div>");
		$('#state').html("<img src='/opac-tmpl/default/es2/images/indicator.gif' />");
		$('#state').css('top', '0px');
		$('#state').css('left', '0px');

	}
}

//muestra el div
function _ShowState(options){
	$('#state').centerObject(options);	
	$('#state').show();
};

//oculta el div
function _HiddeState(){
 	$('#state').hide();
};

//Esta funcion sirve para centrar un objeto
jQuery.fn.centerObject = function(options) {

	var obj = this;
	var total= 0;
	var dif= 0;

	//se calcula el centro verticalmente
	if($(window).scrollTop() == 0){
		obj.css('top',  $(window).height()/2 - this.height()/2);
	}else{
	//se hizo scroll
	
		total= $(window).height() + $(window).scrollTop();
		dif= total - $(window).height();
		obj.css('top', dif + ( $(window).height() )/2);
	}

	//se calcula el centro horizontalmente
	obj.css('left',$(window).width()/2 - this.width()/2);

	if(options.debug){

		window.console.log(	"centerObject => \n" +
				"Total Vertical: " + total + "\n" + 
				"Dif: " + dif + "\n" + 
				"Medio: " + (dif + ( $(window).height() )/2) +
				"\n" +
				"Total Horizontal: " + $(window).width() + "\n" + 
				"Medio: " +  $(window).width()/2
		);

	}

}


function AjaxHelper(fncUpdateInfo, fncInit){

	this.ini= '';		//para manejar el actual del paginador
	this.funcion= '';	//nombre de funcion que tiene q conocer el paginador
	this.url= '/cgi-bin/koha/busquedas/busqueda.pl';
	this.orden= '';		//para ordenar los resultados
	this.debug= false;	
	this.onComplete= fncUpdateInfo;  //se ejecuta cuando se completa el ajax
	this.onBeforeSend= fncInit;	//se ejecuta antes de consultar al servidor con ajax
	this.showState= true;

	this.sendToServer= function(){

			//se ejecuta el ajax
			this.ajaxCallback(this);

	}//end sendToServer

	this.sort= function(ord){

			if(this.debug){
  				window.console.log("AjaxHelper => sort: " + ord);
 			}
			
			//seteo el orden de los resultados
			this.orden= ord;
			//se envia la consulta
			this.sendToServer();
	}

	this.changePage= function(ini){

				if(this.debug){
  					window.console.log("AjaxHelper => changePage: " + ini);
 				}

				this.ini= ini;
				this.sendToServer();

	}

	this.ajaxCallback= function(helper){
			
			var params= "obj="+JSONstring.make(helper);

			if(this.debug){
  				window.console.log("AjaxHelper => ajaxCallback \n" + params);
			}

	
			$.ajax({	type: "POST", 
					url: helper.url,
					data: params,
 					beforeSend: function(){

						if(helper.showState){
						//muestra el estado del AJAX
							_Init({debug: helper.debug});
						}

						if(helper.onBeforeSend){
							helper.onBeforeSend();
						}

					},
					complete: function(ajax){
						//oculta el estado del AJAX
						_HiddeState();
 						if(helper.onComplete){
 							helper.onComplete(ajax.responseText);
						}

  					}
				});
	}

}


