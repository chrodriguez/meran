/*
* Libreria para menejar los favoritos de OPAC
* Contendran las funciones para permitir la circulacion en el sistema
*/



function consultarFavoritos(){

	objAH=new AjaxHelper(updateConsultarFavoritos);
  	objAH.debug= true;
	objAH.url= 'opac-privateshelfs.pl';
	//se setea la funcion para cambiar de pagina
	objAH.funcion= 'changePage';
	//se envia la consulta
	objAH.sendToServer();
}

function updateConsultarFavoritos(responseText){

	$('#datosUsuario').slideUp('slow');
    $('#resultHistoriales').slideUp('slow');
	$('#result').html(responseText);
    $('#result').show();
// 	pushCache(responseText, 'result');
	zebra('zebra');

	checkedAll('todos','checkbox');
}

function agregarAFavoritos(){

	var chck=$("input[@name=checkbox]:checked");
	var array= new Array;
	var long=chck.length;
	if ( long == 0){
		alert("Seleccione un ejemplar para agregar a Favoritos");
	}
	else{

		for(var i=0; i< long; i++){
			array[i]=chck[i].value;
		}
		
		objAH=new AjaxHelper(updateAgregarAFavoritos);
		objAH.debug= true;
		objAH.url= 'opac-privateshelfsDB.pl';
		objAH.datosArray= array;
		objAH.Accion= 'ADD';
		//se envia la consulta
		objAH.sendToServer();
	}
}

function updateAgregarAFavoritos(){
	consultarFavoritos();
}

function borrarDeFavoritos(){

// 	var result="";
// //hacer con jquery
// 	var checks=document.getElementsByTagName("input");
// 	if (checks.length>0){
// 		for(i=0;i<checks.length;i++)
// 		{
// 			if((checks[i].type == "checkbox")&&(checks[i].checked)){ 		
// 				result= result + checks[i].name + '#';
// 			}
// 		}       
// 	}
// // 	params= result;



	var chck=$("input[@name=checkbox]:checked");
	var array= new Array;
	var long=chck.length;
	if ( long == 0){
		alert("Seleccione un ejemplar para eliminar de Favoritos");
	}
	else{

		for(var i=0; i< long; i++){
			array[i]=chck[i].value;
		}
		
		objAH=new AjaxHelper(updateAgregarAFavoritos);
		objAH.debug= true;
		objAH.url= 'opac-privateshelfsDB.pl';
		objAH.datosArray= array;
		objAH.Accion= 'DELETE';
		//se envia la consulta
		objAH.sendToServer();	
	}
	
}

function obtenerFavoritos(){
    objAH=new AjaxHelper(updateObtenerFavoritos);
    objAH.debug= true;
    objAH.url='/cgi-bin/koha/opac-favoritosDB.pl';
    objAH.debug= true;
    objAH.action='get_favoritos';
    objAH.sendToServer();
    objAH.showStatusIn='ajax_indicator';
}

function updateObtenerFavoritos(responseText){
        if (!verificarRespuesta(responseText))
            return(0);
        $('#mis_favoritos').html(responseText);
        zebra('datos_tabla');
}

function eliminarFavorito(id_favorito){
    jConfirm(FAVORITE_CONFIRM_DELETE, CATALOGO_TITLE, function(confirmStatus){
        if (confirmStatus){
            objAH=new AjaxHelper(updateEliminarFavorito);
            objAH.debug= true;
            objAH.url='/cgi-bin/koha/opac-favoritosDB.pl';
            objAH.debug= true;
            objAH.action='delete_favorite';
            objAH.id1=id_favorito;
            objAH.sendToServer();
        }
    });
}

function updateEliminarFavorito(responseText){
        if (!verificarRespuesta(responseText))
            return(0);
        $('#mis_favoritos').html(responseText);
        zebra('datos_tabla');
}