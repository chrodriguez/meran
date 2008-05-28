
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


var objBusqueda;

function Complete(){
	HiddeState();
}

function ordenarPor(ord){
	//seteo el orden de los resultados
	objBusqueda.sort(ord);
}

function changePage(ini){
	objBusqueda.changePage(ini);
}

function updateInfo(responseText){

	$('#result').html(responseText);
	zebra('tablaResult');
 	pushCache(responseText, 'result');
	Complete();

}

function buscar(){

	//seteo normal
	var tipo= $("#checkNormal").val();
	//busqueda exacta
	if($("#checkExacto").attr("checked") == true){
		tipo= $("#checkExacto").val();
	}

	objBusqueda=new SearchHelper(updateInfo, Init);
 	objBusqueda.debug= true;
	//para busquedas combinables
	objBusqueda.url= '/cgi-bin/koha/busqueda.pl';
	objBusqueda.codBarra= $('#codBarra').val();
	objBusqueda.tema=  $('#tema').val();
	objBusqueda.autor= $('#autor').val();
	objBusqueda.titulo= $('#titulo').val();
 	objBusqueda.tipo= tipo;
 	objBusqueda.comboItemTypes= $('#comboItemTypes').val();
	
	//se setea la funcion para cambiar de pagina
	objBusqueda.funcion= 'changePage';
	//se envia la consulta
	objBusqueda.sendToServer();

}

function buscarPorAutor(idAutor){

	objBusqueda=new SearchHelper(updateInfo, Init);
 	objBusqueda.debug= true;
	//para busquedas combinables
	objBusqueda.url= '/cgi-bin/koha/busqueda.pl';
	objBusqueda.idAutor= idAutor;	
	//se setea la funcion para cambiar de pagina
	objBusqueda.funcion= 'changePage';
	//se envia la consulta
	objBusqueda.sendToServer();
}

//****************************************Busqueda para usuario no logueado************************************
function searchinc(orden, ini){

var params= 	$('#criteria').val() + '=' + $('#searchinc').val() + 
		'&comboItemTypes= -1' +
		'&ini=' + ini +
  		'&tipo=normal';

	$.ajax({	type: "POST", 
			url: "busqueda.pl",
			data: params,
 			complete: function(ajax){
					//si estoy logueado, oculta la informacion del usuario
					$('#datosUsuario').slideUp('slow');
					$('#result').html(ajax.responseText);
					pushCache(ajax.responseText, 'result');
					zebra();
				}
	});
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

function mostrarHistorialPrestamos(bornum){

	$.ajax({	type: "POST", 
			url: "readingrec.pl",
 			data: "bornum=" + bornum,
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

function detalle(id1){
var params= 'id1=' + id1;

	$.ajax({	type: "POST", 
 			url: "opac-detail.pl",
			data: params,
			beforeSend: Init,
 			complete: function(ajax){
					$('#result').html(ajax.responseText);
					pushCache(ajax.responseText, 'result');
					zebra();
					Complete();
				}
	});
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
// 			buscar('', 1);
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
  			searchinc('', 1);
 		}
 	});
});
