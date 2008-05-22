/*
 * LIBRERIA SearchHelper v 1.0.0
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 * @author Carbone Miguel
 * Fecha de creacion 22/05/2008
 *
 */





function SearchHelper(fncUpdateInfo, fncInit){

	this.ini= '';		//para manejar el actual del paginador
	this.funcion= '';	//nombre de funcion que tiene q conocer el paginador
	this.url= '/cgi-bin/koha/busquedas/busqueda.pl';
	this.orden= '';		//para ordenar los resultados
	this.debug= false;	
	this.onComplete= fncUpdateInfo;  //se ejecuta cuando se completa el ajax
	this.onBeforeSend= fncInit;	//se ejecuta antes de consultar al servidor con ajax

	this.sendToServer= function(){

			//se ejecuta el ajax
			this.ajaxCallback(this);

	}//end sendToServer

	this.sort= function(ord){

			if(this.debug){
 				console.log("SearchHelper => sort: " + ord);
 			}
			
			//seteo el orden de los resultados
			this.orden= ord;
			//se envia la consulta
			this.sendToServer();
	}

	this.changePage= function(ini){

				if(this.debug){
 					console.log("SearchHelper => changePage: " + ini);
 				}

				this.ini= ini;
				this.sendToServer();

	}

	this.ajaxCallback= function(helper){
			
			var params= "obj="+JSONstring.make(helper);

			if(this.debug){
 				console.log("SearchHelper => ajaxCallback \n" + params);
			}

	
			$.ajax({	type: "POST", 
					url: helper.url,
					data: params,
 					beforeSend: helper.onBeforeSend,
					complete: function(ajax){
 						helper.onComplete(ajax.responseText);
  					}
				});
	}

}


