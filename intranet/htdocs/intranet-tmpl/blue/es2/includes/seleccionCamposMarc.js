//funciones para ajax recibe el parametro accion, para identificar en que nivel de consulta estoy.

/*
 * consultarAjaxSeleccion
 * Funcion que hace un llamado ajax para realizar la funcion correspondiente en el pl.
 */
function consultarAjaxSeleccion(params){
	$.ajax({
		type: "POST",
		url: "/cgi-bin/koha/acqui.simple/seleccionCamposMarc.pl",
		data: params,
		beforeSend: Init,
		complete: function(ajax){
				$("#result").html(ajax.responseText);
				HiddeState();
				foco();
			}
	});
}

function foco(){
	$('#campoX').focus();
}

/*
 * eleccionCampoX
 * Funcion que se ejecuta cuando se selecciona un valor del combo campoX (ej. 1xx), y hace un llamado a la 
 * funcion que ejecuta el ajax, con los parametros correspondiente a la accion realizada.
 */
function eleccionCampoX(accion){
	var params='campoX='+ $('#campoX').val() + 
		'&nivel=' +  $('#nivel').val() +
		'&itemtype=' +  $('#itemtype').val() +
		'&tmpl=' + $('#tmpl').val()  + '&accion=' + accion;
	consultarAjaxSeleccion(params);
}

/*
 * eleccionCampo
 * Funcion que se ejecuta cuando se selecciona un valor del combo tagField, y hace un llamado a la funcion que
 * ejecuta el ajax, con los parametros correspondiente a la accion realizada.
 */
function eleccionCampo(accion){
	var params='campoX='+ $('#campoX').val() + 
		'&nivel=' +  $('#nivel').val() +
		'&itemtype=' +  $('#itemtype').val() +
		'&tagField=' +  $('#tagField').val() +
		'&tmpl=' + $('#tmpl').val() + '&accion=' + accion;
	consultarAjaxSeleccion(params);
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
	
	var params='campoX='+ $('#campoX').val() +
		'&nivel=' +  $('#nivel').val() +
		'&itemtype=' + $('#itemtype').val() +
		'&tagField=' + $('#tagField').val() +
		'&tagsubField=' + $('#tagsubField').val() +
		'&subcampo=' + array[0] +
		'&tmpl=' + $('#tmpl').val() + '&accion=' + accion;

	$.ajax({
		type: "POST",
		url: "/cgi-bin/koha/acqui.simple/seleccionCamposMarc.pl",
		data: params,
		beforeSend: Init,
		complete: function(ajax){
				$("#result").html(ajax.responseText);
				HiddeState();
				$('#tagsubField')[0].selectedIndex=ind;
				$('#subcampo').val(array[0]);
				$('#lib').val(array[1]);
				$('#obligatorio').val(array[2]);
				verificarRef($('#ok').val());
			}
	});
}

/*
 * verificarRef
 * Habilita o deshabilita el combo de seleccion de tabla dependiendo si el campo ya estaba guardado en la base de 
 * datos y si hace referencia o no a una tabla de referencia.
 */
function verificarRef(ok){
	if(ok == 0){
		$('#tabla').attr("disabled","disabled");
	}
	else{
		$('#tabla').attr("enabled","enabled");
	}
}

/*
 * eleccionTabla
 * Funcion que se ejecuta cuando se selecciona un valor del combo tabla, y hace un llamado ajax.
 */
function eleccionTabla(accion,accion2){
	var params='nivel=' +  $('#nivel').val() +
		'&itemtype=' +  $('#itemtype').val() +
		'&accion=' + accion;
	
	if(accion2 == 'Agregar'){       
		params=params + '&tagField=' + $('#tagField').val() +
			'&campoX=' + $('#campoX').val() +
			'&subcampo=' + $('#subcampo').val() +
			'&tagsubField=' + $('#tagsubField').val() +
			'&tipoInput=' + $('#tipoInput').val() +
			'&tabla=' + $('#tabla').val() +
			'&lib=' + $('#lib').val() +
			'&obligatorio=' + $('#obligatorio').val() +
			'&tmpl=' + $('#tmpl').val();
		var ind=$('#tagsubField')[0].selectedIndex;
		$.ajax({
		type: "POST",
		url: "/cgi-bin/koha/acqui.simple/seleccionCamposMarc.pl",
		data: params,
		beforeSend: Init,
		complete: function(ajax){
				$("#result").html(ajax.responseText);
				HiddeState();;
				$('#tagsubField')[0].selectedIndex=ind;
			}
		});
	}
	if(accion2 == 'Modificar'){
		params=params + '&idMod=' + $('#idMod').val() +
			'&tablaMod=' + $('#tablaMod').val() + '&disable=0';
		consultarAjax(params);
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
	var params="nivel=" +  nivel +
		"&itemtype=" +  $("#itemtype").val() +
		"&tmpl=agregar"  + "&accion2=agregar" + "&paso="+paso;
	consultarAjaxSeleccion(params);
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
 * guardarCampoTemp
 * Genera el componente del campo temporal seleccionado.
 */
function guardarCampoTemp(nivel){
	var campo=$("#tagField").val();
	var subcampo=$("#subcampo").val();
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
	var str=JSONstring.make(objeto);
	$("#cantIds").val(parseInt(cantIds)+1);
	var itemtype=$("#itemtype").val();
	if(nivel==1){
		itemtype="ALL";
	}
	var params ="itemtype="+itemtype+"&nivel="+nivel+"&cant="+cantIds+"&objeto="+str;
	$.ajax({
		type: "POST",
		url: "/cgi-bin/koha/acqui.simple/agregarItemResults2.pl",
		data: params,
		beforeSend: Init,
		complete: function(ajax){
				var objetoResp=JSONstring.toObject(ajax.responseText);
				if(objetoResp.ok > 0){
					procesarObjeto(objetoResp);
				}
				else{
					alert("Error, intente otra vez");
				}
				HiddeState();
			}
	});
}

