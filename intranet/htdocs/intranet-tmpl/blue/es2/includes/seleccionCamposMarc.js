//funciones para ajax recibe el parametro accion, para identificar en que nivel de consulta estoy.

var objAH; //Objeto AjaxHelper.

function foco(){
	$('#campoX').focus();
}

/*
 * updateInfo
 * Funcion que se ejecuta cuando termina el llamado ajax.
 */
function updateInfo(responseText){
	$("#result").html(responseText);
	foco();
}

/*
 * eleccionCampoX
 * Funcion que se ejecuta cuando se selecciona un valor del combo campoX (ej. 1xx), y hace un llamado a la 
 * funcion que ejecuta el ajax, con los parametros correspondiente a la accion realizada.
 */
function eleccionCampoX(accion){
	objAH=new AjaxHelper(updateInfo);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/seleccionCamposMarc.pl";
	objAH.campoX=$('#campoX').val();
	objAH.nivel=$('#nivel').val();
	objAH.itemtype=$('#itemtype').val();
	objAH.tmpl= $('#tmpl').val();
	objAH.accion=accion;
	objAH.sendToServer();
}

/*
 * eleccionCampo
 * Funcion que se ejecuta cuando se selecciona un valor del combo tagField, y hace un llamado a la funcion que
 * ejecuta el ajax, con los parametros correspondiente a la accion realizada.
 */
function eleccionCampo(accion){
	objAH=new AjaxHelper(updateInfo);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/seleccionCamposMarc.pl";
	objAH.campoX=$('#campoX').val();
	objAH.nivel=$('#nivel').val();
	objAH.itemtype=$('#itemtype').val();
	objAH.tmpl= $('#tmpl').val();
	objAH.tagField=$('#tagField').val();
	objAH.accion=accion;
	objAH.sendToServer();
}


/*
 * objetoSeleccionSubCampo
 * Objeto que guarda la opcion que se selecciono del combo que pertenece al subcampo.
 * Esto se hace para poder saber que se selecciono despues del llamado ajax.
 */
function objetoSeleccionSubCampo(){
	this.subcampo;
	this.texto;
	this.obligatorio;
	this.indice;
}

/* Objeto que guarda lo que se selecciono */
var objSubCampo=new objetoSeleccionSubCampo();

/*
 * updateInfoSubCampo
 * Funcion que se ejecuta cuando termina el llamado ajax de la seleccion del subcampo.
 */
function updateInfoSubCampo(responseText){
	$("#result").html(responseText);
	$('#tagsubField')[0].selectedIndex=objSubCampo.indice;
	$('#subcampo').val(objSubCampo.subcampo);
	$('#lib').val(objSubCampo.texto);
	$('#obligatorio').val(objSubCampo.obligatorio);
	verificarRef($('#ok').val());
}

/*
 * eleccionSubCampo
 * Funcion que se ejecuta cuando se selecciona un valor del combo tagsubField, y hace un llamado ajax, para 
 * determinar el nombre del campo seleccionado y si ya estaba guardado en la base de datos.
 */
function eleccionSubCampo(accion){
	var sel= $('#tagsubField')[0];
	var ind=sel.selectedIndex;
	var opcion= sel.options[ind].value;
	var array= opcion.split(",");
	objSubCampo.indice=ind;
	objSubCampo.subcampo=array[0];
	objSubCampo.texto=array[1];
	objSubCampo.obligatorio=array[2];

	objAH=new AjaxHelper(updateInfoSubCampo);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/seleccionCamposMarc.pl";
	objAH.campoX=$('#campoX').val();
	objAH.nivel=$('#nivel').val();
	objAH.itemtype=$('#itemtype').val();
	objAH.tagField=$('#tagField').val();
	objAH.tagsubField=$('#tagsubField').val();
	objAH.subcampo=objSubCampo.subcampo;
	objAH.tmpl= $('#tmpl').val();
	objAH.accion=accion;
	objAH.sendToServer();
}

/*
 * verificarRef
 * Habilita o deshabilita el combo de seleccion de tabla dependiendo si el campo ya estaba guardado en la base de 
 * datos y si hace referencia o no a una tabla de referencia.
 */
function verificarRef(ok){
	if(ok == 0){
// 		$('#tabla').attr("disabled","disabled");
	}
	else{
// 		$('#tabla').attr("enabled","enabled");
	}
}

/*
 * updateInfoEleccionTabla
 * Funcion que se ejecuta cuando termina el llamado ajax de la seleccion del combo de las tabla de referencia
 * y la accion2 es igual a Agregar.
 */
function updateInfoEleccionTablaAgr(responseText){
	$("#result").html(responseText);
	$('#tagsubField')[0].selectedIndex=objSubCampo.indice;
}

/*
 * updateInfoEleccionTabla
 * Funcion que se ejecuta cuando termina el llamado ajax de la seleccion del combo de las tabla de referencia
 * y la accion2 es igual a Modificar.
 */
function updateInfoEstrCatalogo(responseText){
	$("#result2").html(responseText);
	zebra("tablaResult");
}

/*
 * eleccionTabla
 * Funcion que se ejecuta cuando se selecciona un valor del combo tabla, y hace un llamado ajax.
 */
function eleccionTabla(accion,accion2){
	if(accion2 == 'Agregar'){
		objAH=new AjaxHelper(updateInfoEleccionTablaAgr);
		objAH.url="/cgi-bin/koha/catalogacion/estructura/seleccionCamposMarc.pl";
		objAH.campoX=$('#campoX').val();
		objAH.nivel=$('#nivel').val();
		objAH.itemtype=$('#itemtype').val();
		objAH.tagField=$('#tagField').val();
		objAH.tagsubField=$('#tagsubField').val();
		objAH.subcampo=objSubCampo.subcampo;
		objAH.tipoInput=$('#tipoInput').val();
		objAH.tabla=$('#tabla').val();
		objAH.lib=$('#lib').val();
		objAH.obligatorio=objSubCampo.obligatorio;
		objAH.tmpl= $('#tmpl').val();
		objAH.accion=accion;
		objAH.sendToServer();
	}
	if(accion2 == 'Modificar'){
		objAH=new AjaxHelper(updateInfoEstrCatalogo);
		objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloResults.pl";
		objAH.nivel=$('#nivel').val();
		objAH.itemtype=$('#itemtype').val();
		objAH.idMod= $('#idMod').val();
		objAH.tablaMod=$('#tablaMod').val();
		objAH.disable=0;
		objAH.accion=accion;
		objAH.sendToServer();
	}
}

function cancelar(){
	document.getElementById("result").innerHTML="";
}



/* Funciones para el agregado de campos temporales usadas en agregarItem y editarEjemplar */


/*
 * agregarCampoTemp
 * Se genera la parte de la pagina dedicada a seleccionar el campo y subcampo marc para agregarlo a la 
 * modificacion del ejemplar o ejemplares.
 */
function agregarCampoTemp(paso,nivel){
	$("#nivel").val(nivel);
	
	objAH=new AjaxHelper(updateInfo);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/seleccionCamposMarc.pl";
	objAH.nivel=nivel;
	objAH.itemtype=$('#itemtype').val();
	objAH.tmpl="agregar";
	objAH.accion2="agregar";
	objAH.paso=paso;
	objAH.sendToServer();
}

/*
 * objetoCampoTemp
 * funcion que guarda los datos necesarios para crear un componente temporal
 */
function objetoCampoTemp(nivel,campo,subcampo,liblibrarian,tipoInput,tabla,indice){
	this.nivel=nivel;
	this.campo=campo;
	this.subcampo=subcampo;
	this.liblibrarian=liblibrarian;
	this.tipo=tipoInput;
	this.tabla=tabla;
	this.indice=indice;
	this.referencia=0;
	this.varios=0;
	this.valor="";
	this.idRep="";
}

/*
 * updateInfoCampoTemp
 * Funcion que se ejecuta cuando termina el llamado ajax del guardado del campo temporal
 */
function updateInfoCampoTemp(responseText){
	var objetoResp=JSONstring.toObject(responseText);
	if(objetoResp.ok > 0){
		procesarObjeto(objetoResp);
	}
	else{
		alert("Error, intente otra vez");
	}
}

/*
 * guardarCampoTemp
 * Genera el componente del campo temporal seleccionado.
 */
function guardarCampoTemp(nivel){
	var campo=$("#tagField").val();
	var subcampo=objSubCampo.subcampo;
	var lib=$("#lib").val();
	var tipoInput=$("#tipoInput").val();
	var tabla=$("#tabla").val();
	var cantIds=$("#cantIds").val();
	var objeto=new objetoCampoTemp(nivel,campo,subcampo,lib,tipoInput,tabla,cantIds);
	if(tabla != -1){
		var orden=$("#orden").val();
		var camposRef=$("#camposRef").val();
		var separador=$("#separador").val();
		objeto.referencia=1;
		objeto.orden=orden;
		objeto.campos=camposRef;
		objeto.separador=separador;
		switch(tipoInput){
			case "text": objeto.valText="";break;
			case "texta": objeto.valTextArea="";break;
			case "text2": objeto.valTextArea="";break;
		}
		
	}

	var itemtype=$("#itemtype").val();
	if(nivel==1){
		itemtype="ALL";
	}

	objAH=new AjaxHelper(updateInfoCampoTemp);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/agregarItemResults2.pl";
	objAH.nivel=nivel;
	objAH.itemtype=itemtype;
	objAH.cant=cantIds;
	objAH.objeto=objeto;
	objAH.sendToServer();

	$("#cantIds").val(parseInt(cantIds)+1);
}
