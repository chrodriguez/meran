
//opac-searchFunciones.js
//*******************************************Para agregar a Favoritos*******************************************
// function todos(){
// 	var checks=document.getElementsByTagName("input");
// 	if (checks.length>0){
// 		for(i=0;i<checks.length;i++)
// 		{
// 			if((checks[i].type == "checkbox")&&(checks[i].checked)){
// 				checks[i].checked=false
// 			}
//                         else{
// 				checks[i].checked=true
// 			}
// 		}
// 	}
// }

// se va a dejar de usar!!!!!!!!!!!!BORRRRRARR
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
}


var objAH;//Objeto AjaxHelper.

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
//  	pushCache(responseText, 'result');

	checkedAll('todos','checkbox');
	scrollTo('tablaResult');
}


function busquedaCombinable(){

	//seteo normal
	var tipo= $("#checkNormal").val();
	//busqueda exacta
	if($("#checkExacto").attr("checked") == true){
		tipo= $("#checkExacto").val();
	}

	objAH=new AjaxHelper(updateInfo);
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

	objAH=new AjaxHelper(updateInfo);
	objAH.debug= true;
	//para busquedas combinables
	objAH.url= '/cgi-bin/koha/busqueda.pl';
	objAH.idAutor= idAutor;	
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}

function buscarPorCodigoBarra(){
	objAH=new AjaxHelper(updateInfo);
 	objAH.debug= true;
	objAH.url= '/cgi-bin/koha/busqueda.pl';
	objAH.codBarra= $('#codBarra').val();
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
	$('#resultHistoriales').html(responseText);
	$('#resultHistoriales').slideDown('slow');
	zebra('tablaHistorial');
}

function mostrarHistorialPrestamos(bornum){

	objAH=new AjaxHelper(mostrarHistorialUpdate);
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

	objAH=new AjaxHelper(mostrarHistorialUpdate);
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

	objAH=new AjaxHelper(updateInfo);
  	objAH.debug= true;
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




//*******************************************Estantes Virutales**********************************************

function verEstanteVirtual(shelf){
	
	objAH=new AjaxHelper(updateVerEstanteVirtual);
  	objAH.debug= true;
	objAH.url= 'opac-estanteVirtualDB.pl';
	objAH.shelves= shelf;
	objAH.tipo= 'VER_ESTANTE';
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}

function verSubEstanteVirtual(shelf){
	
	objAH=new AjaxHelper(updateVerEstanteVirtual);
  	objAH.debug= true;
	objAH.url= 'opac-estanteVirtualDB.pl';
	objAH.shelves= shelf;
	objAH.tipo= 'VER_SUBESTANTE';
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();

}

function updateVerEstanteVirtual(responseText){
	
	$('#result').html(responseText);
	checkedAll('todos','checkbox');
}

function consultarEstanteVirtual(){

	objAH=new AjaxHelper(updateConsultarEstanteVirutal);
  	objAH.debug= true;
	objAH.url= 'opac-estanteVirtual.pl';
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}

function updateConsultarEstanteVirutal(responseText){
	$('#result').html(responseText);
}
//***************************************Fin****Estantes Virutales*******************************************


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

}

function detalle(id1){

	objAH=new AjaxHelper(updateInfoDetalle);
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
// 			beforeSend: Init,
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


function buscar(){

	//primero verifico las busquedas individuales
	if ($('#codBarra').val() != ''){
		buscarPorCodigoBarra();
	}else
	if ($('#tema').val() != '') {
		buscarPorTema();
	}
	if ($('#searchinc').val() != '') {
		searchinc();
	}
	else {
//si no hay busquedas individuales, se realiza una busqueda combinable y se levantan los parametros
//de la interface
		busquedaCombinable();
	}
}

function registrarEventos(){

	$("input").keypress(function (e) {
 		if(e.which == 13){
 			buscar();
 		}
 	});

}


$(document).ready(function(){

	registrarEventos();

});
