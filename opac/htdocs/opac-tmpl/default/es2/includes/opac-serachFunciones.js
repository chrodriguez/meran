
//opac-searchFunciones.js
//*******************************************Para agregar a Favoritos*******************************************
function todos(){
	var checks=document.getElementsByTagName("input");
	if (checks.length>0){
		for(i=0;i<checks.length;i++)
		{
			if((checks[i].type == "checkbox")&&(checks[i].checked)){
				checks[i].checked=false
			}
                        else{
				checks[i].checked=true
			}
		}
	}
}

// se va a dejar de usar
function mandarArreglo(valores){
        arreglo= new Array();
	
	var checks=document.getElementsByTagName("input");
	if (checks.length>0){
		for(i=0;i<checks.length;i++)
		{
			if((checks[i].type == "checkbox")&&(checks[i].checked)){ 		
				arreglo[arreglo.length]=checks[i].name;
			}
		}       
	}
        valores.value= arreglo.join("#");
// 	return valores.value;
}


var objAH;

function Complete(){
	HiddeState();
}

function ordenarPor(ord){
	//seteo el orden de los resultados
	objAH.sort(ord);
}

function changePage(ini){
	objAH.changePage(ini);
}

function updateInfo(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#datosUsuario').slideUp('slow');
	$('#result').html(responseText);
	zebra('tablaResult');
	$('#result').slideDown('slow');
 	pushCache(responseText, 'result');
	Complete();

}

function updateInfoReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#result').html(responseText);
	$('#result').slideDown('slow');	
	Complete();

}

function updateDetalleReserva(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detalleReservas').html(responseText);
	$('#detalleReservas').slideDown('slow');	
	Complete();

}

function updateDetallePrestamo(responseText){
	
	//si estoy logueado, oculta la informacion del usuario
	$('#detallePrestamos').html(responseText);
	$('#detallePrestamos').slideDown('slow');	
	Complete();

}


function reservar(id1, id2){

	objAH=new AjaxHelper(updateInfoReserva, Init);
//   	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-reserve.pl';
	objAH.id1= id1;
	objAH.id2= id2;
	//se envia la consulta
	objAH.sendToServer();
}

function cancelarYReservar(reserveNumber,id1Nuevo,id2Nuevo){

	cancelar(reserveNumber);
	reservar(id1Nuevo, id2Nuevo);
}

function updateInfoCancelarReserva(responseText){
	objJSON= JSONstring.toObject(responseText);
	$('#mensajes').html(objJSON.message);
	DetalleReservas();
}

function cancelar(reserveNumber){

	objAH=new AjaxHelper(updateInfoCancelarReserva, Init);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-cancelreserv.pl';
	objAH.reserveNumber= reserveNumber;
	//se envia la consulta
	objAH.sendToServer();
}

function updateInfoRenovar(responseText){
	var infoArray= JSONstring.toObject(responseText);
	var mensajes= '';
	for(i=0; i<infoArray.length;i++){
		mensajes= mensajes + infoArray[i].message + '<br>';
	}
	$('#mensajes').html(mensajes);
	DetallePrestamos();	
}


function renovar(id3){

// 	objAH=new AjaxHelper(updateInfoReserva, Init);
	objAH=new AjaxHelper(updateInfoRenovar, Init);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-renew.pl';
	objAH.id3= id3;
	//se envia la consulta
	objAH.sendToServer();
}

function DetalleReservas(){

	objAH=new AjaxHelper(updateDetalleReserva, Init);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetalleReservas.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

function DetallePrestamos(){

	objAH=new AjaxHelper(updateDetallePrestamo, Init);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-DetallePrestamos.pl';
// 	objAH.borrowernumber= borrowernumber;
	//se envia la consulta
	objAH.sendToServer();
}

function MostrarReservasYPrestamos(borrowernumber){
	DetallePrestamos(borrowernumber);
	DetalleReservas(borrowernumber);
}

function buscar(){

	//seteo normal
	var tipo= $("#checkNormal").val();
	//busqueda exacta
	if($("#checkExacto").attr("checked") == true){
		tipo= $("#checkExacto").val();
	}

	objAH=new AjaxHelper(updateInfo, Init);
  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/busqueda.pl';
	objAH.codBarra= $('#codBarra').val();
	objAH.tema=  $('#tema').val();
	objAH.autor= $('#autor').val();
	objAH.titulo= $('#titulo').val();
 	objAH.tipo= tipo;
 	objAH.comboItemTypes= $('#comboItemTypes').val();
	
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();

}

function buscarPorAutor(idAutor){

	objAH=new AjaxHelper(updateInfo, Init);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/busqueda.pl';
	objAH.idAutor= idAutor;	
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}

//***************************************Historiales**********************************************************

function volverDesdeHistorial(){
	$('#resultHistoriales').slideUp('up');
	$('#datosUsuario').slideDown('slow');
	$('#result').slideDown();
}

function mostrarHistorialUpdate(responseText){

	$('#datosUsuario').slideUp('slow');
	$('#result').slideUp('slow');
// 	$('#result').html(responseText);
	$('#resultHistoriales').html(responseText);
// 	$('#result').slideDown('slow');
	$('#resultHistoriales').slideDown('slow');
	zebra('tablaHistorial');
	Complete();

}

function mostrarHistorialPrestamos(bornum){

	objAH=new AjaxHelper(mostrarHistorialUpdate, Init);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-HistorialPrestamos.pl';
	objAH.bornum= bornum;
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();

}

function mostrarHistorialReservas(bornum){

	objAH=new AjaxHelper(mostrarHistorialUpdate, Init);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-HistorialReservas.pl';
	objAH.bornum= bornum;
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();

}
//************************************Fin***Historiales*******************************************************

//****************************************Busqueda para usuario no logueado************************************
function searchinc(){

	objAH=new AjaxHelper(updateInfo, Init);
//  	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/busqueda.pl';
	objAH.criteria= $('#criteria').val();
	objAH.searchinc= $('#searchinc').val();
	objAH.tipo= 'normal';
	objAH.comboItemTypes= '-1';
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}
//**************************************Fin**Busqueda para usuario no logueado********************************








function consultarEstanteVirtual(){

	$.ajax({	type: "POST", 
			url: "opac-shelves.pl",
 			data: "startfrom=0",
			beforeSend: Init,
 			complete: function(ajax){
					$('#datosUsuario').slideUp('slow');
					$('#result').html(ajax.responseText);
					zebra();
					Complete();
				}
	});

}


//**********************************************************************************************************





//********************************************Favoritos****************************************************

function consultarFavoritos(){
	
	$.ajax({	type: "POST", 
			url: "opac-privateshelfs.pl",
			beforeSend: Init,
 			complete: function(ajax){
					$('#datosUsuario').slideUp('slow');
					$('#result').html(ajax.responseText);
					pushCache(ajax.responseText, 'result');
					zebra();
					Complete();
				}
	});	
}

function agregarAFavoritos(){

	var result="";
	
	var checks=document.getElementsByTagName("input");
	if (checks.length>0){
		for(i=0;i<checks.length;i++)
		{
			if((checks[i].type == "checkbox")&&(checks[i].checked)){ 		
				result= result + checks[i].name + '#';
			}
		}       
	}
	params= result;

	$.ajax({	type: "POST", 
			url: "opac-privateshelfs.pl",
			beforeSend: Init,
 			data: 'bookmarks=' + params,
 			complete: function(ajax){
					$('#result').html(ajax.responseText);
					zebra();
					Complete();
				}
	});
}

function borrarDeFavoritos(){

	var result="";
	
	var checks=document.getElementsByTagName("input");
	if (checks.length>0){
		for(i=0;i<checks.length;i++)
		{
			if((checks[i].type == "checkbox")&&(checks[i].checked)){ 		
				result= result + checks[i].name + '#';
			}
		}       
	}
	params= result;

	$.ajax({	type: "POST", 
			url: "opac-privateshelfs.pl",
 			data: 	'bookmarks=' + params + 
				'&bookmarkOp=del',
			beforeSend: Init,
 			complete: function(ajax){
					$('#result').html(ajax.responseText);
					zebra();
					Complete();
				}
	});
	
}

//****************************************Fin****Favoritos****************************************************

//****************************************Busqueda Avanzada****************************************************

function clearAll(){
	$('#autor').val("");
	$('#dictionary').val("");
	$('#titulo').val("");
	$('#tema').val("");
	$('#codBarra').val("");
	$('#shelves').val("");
	$('#analytical').val("");
}

//************************************Fin****Busqueda Avanzada**************************************************

//*******************************************Detalles***********************************************************

function updateInfoDetalle(responseText){

	$('#datosUsuario').slideUp('slow');
	$('#resultHistoriales').slideUp('slow');
	$('#result').html(responseText);
	zebra('tablaDetalleNivel3');
	$('#result').slideDown('slow');
	pushCache(responseText, 'result');
	Complete();

}

function detalle(id1){

	objAH=new AjaxHelper(updateInfoDetalle, Init);
//   	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/opac-detail.pl';
	objAH.id1= id1;
	//se envia la consulta
	objAH.sendToServer();
}

function MARCDetail(id3, IdDivDetalle, IdDivMARC){

	var params= 'id3=' + id3;

	$.ajax({	type: "POST", 
			url: "opac-MARCDetail.pl",
			data: params,
			beforeSend: Init,
 			complete: function(ajax){
					//seteo el estado en cached
// 					$('#content'+IdDivMARC).attr('state', 'cached');
					//se oculta el Detalle Normal
					$('#'+IdDivDetalle).slideUp('slow');
					//se agrega resultado MARC
					$('#'+IdDivMARC).html(ajax.responseText);
					//se muestra el resultado MARC
					$('#'+IdDivMARC).slideDown('slow');
					//se muestra el boton volver
					$('#volver'+IdDivMARC).show();
					Complete();
				}
	});
}

function Volver(IdDivDetalle, IdDivMARC){
	//se oculta el Detalle MARC
	$('#'+IdDivMARC).slideUp('slow');
	//se oculta el boton volver
	$('#volver'+IdDivMARC).hide();
	//se muestra el Detalle Normal
	$('#'+IdDivDetalle).slideDown('slow');
}

//**************************************Fin*****Detalles*********************************************************

$(document).ready(function(){

	$('#codBarra').keypress(function (e) {
		if(e.which == 13){
			buscar();
		}
	});
	$('#tema=').keypress(function (e) {
		if(e.which == 13){
			buscar();
		}
	});
	$('#autor').keypress(function (e) {
		if(e.which == 13){
			buscar();
		}
	});
	$('#titulo').keypress(function (e) {
		if(e.which == 13){
			buscar();
		}
	});
 	$('#tipo').keypress(function (e) {
		if(e.which == 13){
			buscar();
		}
	});
	$('#searchinc').keypress(function (e) {
 		if(e.which == 13){
  			searchinc();
 		}
 	});
});
