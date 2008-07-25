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
	$('#result').show();
	$('#result').html(responseText);
	pushCache(responseText, 'result');
	zebra();
}

function agregarAFavoritos(){

	var result="";
//hacer con jquery
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

	objAH=new AjaxHelper(updateAgregarAFavoritos);
  	objAH.debug= true;
	objAH.url= 'opac-privateshelfsDB.pl';
	objAH.bookmarks= params;
	objAH.Accion= 'ADD';
	//se envia la consulta
	objAH.sendToServer();
}

function updateAgregarAFavoritos(){
	consultarFavoritos();
}

function borrarDeFavoritos(){

	var result="";
//hacer con jquery
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

	objAH=new AjaxHelper(updateAgregarAFavoritos);
  	objAH.debug= true;
	objAH.url= 'opac-privateshelfsDB.pl';
	objAH.bookmarks= params;
	objAH.Accion= 'DELETE';
	//se envia la consulta
	objAH.sendToServer();
	
}
