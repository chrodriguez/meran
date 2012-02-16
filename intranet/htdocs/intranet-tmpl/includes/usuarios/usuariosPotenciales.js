var objAH;
var fromDetail = false;
//*
/*
 * objeto_usuario
 * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
 */
function objeto_usuario(){
    this.text;
    this.ID;
}

function ordenar(orden){
    objAH.sort(orden);
}

function changePage(ini){
    objAH.changePage(ini);
}

// FIXME ver que cuando el usuario no haya borrado, no redireccione
function updateEliminarUsuario(responseText){
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
    if (!(hayError(Messages))){
        window.location.href = URL_PREFIX+"/usuarios/potenciales/buscarUsuario.pl?token="+token;
    }
}

//*********************************************Fin***Eliminar Usuario**********************************************

//*********************************************Modificar Datos Usuario*********************************************

nro_socio_temp = 0; //SOLO USADO PARA MODIFICAR_USUARIO

function modificarDatosDeUsuario(){
    objAH=new AjaxHelper(updateModificarDatosDeUsuario);
    objAH.url=URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
    objAH.debug= true;
    objAH.showOverlay       = true;
    objAH.nro_socio= usuario.ID;
    nro_socio_temp = objAH.nro_socio; // SETEO LA VARIABLE GLOBAL TEMP
    objAH.tipoAccion= 'MODIFICAR_USUARIO';
    objAH.sendToServer();
}

function updateModificarDatosDeUsuario(responseText){
//se crea el objeto que maneja la ventana para modificar los datos del usuario
    vDatosUsuario=new WindowHelper({draggable: false, opacity: true});
    vDatosUsuario.debug= true;
    vDatosUsuario.html=responseText;
    vDatosUsuario.create(); 
    vDatosUsuario.height('85%');
    vDatosUsuario.width('85%');
    vDatosUsuario.open();
}

function guardarModificacioUsuario(){

    objAH=new AjaxHelper(updateGuardarModificacioUsuario);
    objAH.showOverlay       = true;
    objAH.url=URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
    objAH.debug= true;
    objAH.nro_socio= nro_socio_temp;
    objAH.sexo= $("input[@name=sexo]:checked").val();
    objAH.calle= $('#calle').val();
    objAH.nombre= $('#nombre').val();
    objAH.nacimiento= $('#nacimiento').val();
    objAH.email= $('#email').val();
    objAH.telefono= $('#telefono').val();
    objAH.cod_categoria= $('#categoria_socio_id').val();
    objAH.ciudad= $('#id_ciudad').val();
    objAH.alt_ciudad= $('#id_alt_ciudad').val();
    objAH.alt_telefono= $('#alt_telefono').val();
    objAH.apellido= $('#apellido').val();
    objAH.id_ui= $('#id_ui').val();
    objAH.tipo_documento= $('#tipo_documento_id').val();
    objAH.nro_documento= $('#nro_documento').val();
    objAH.legajo= $('#legajo').val();
    objAH.changepassword= ( $('#changepassword').attr('checked') )?1:0;
    objAH.tipoAccion= 'GUARDAR_MODIFICACION_USUARIO';
    objAH.sendToServer();

}

function updateGuardarModificacioUsuario(responseText){
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
    vDatosUsuario.close();
    detalleUsuario();
}

function detalleUsuario(){
    objAH=new AjaxHelper(updateDetalleUsuario);
    objAH.url=URL_PREFIX+'/usuarios/potenciales/detalleUsuario.pl';
    objAH.debug= true;
    objAH.showOverlay = true;
    objAH.nro_socio= usuario.ID;
    objAH.sendToServer();
}

function updateDetalleUsuario(responseText){
    $('#detalleUsuario').html(responseText);
}

function habilitar(){
	var checks=$("#result input[@type='checkbox']:checked");
	var array=checks.get();
	var theStatus="";
	var personNumbers=new Array();
	var cant=checks.length;
	var accion=$("#accion").val();
	if (cant>0){
		theStatus= HABILITAR_POTENCIALES_CONFIRM; 
	
		for(i=0;i<checks.length;i++){
			personNumbers[i]=array[i].value;
		}

		if (cant>0){
			bootbox.confirm(theStatus, function (ok){ 
									if (ok)
										actualizarPersonas(cant,personNumbers);
			}
			);
		}
	}
	else{ jAlert (NO_SE_SELECCIONO_NINGUN_USUARIO);}
}	

function habilitarDesdeDetalle(nro_socio){
	var personas_array = new Array();
	personas_array[0] = nro_socio;
	actualizarPersonas(1,personas_array);
}

function actualizarPersonas(cant,arrayPersonNumbers){
	objAH=new AjaxHelper(updateInfoActualizar);
	objAH.url= URL_PREFIX+"/usuarios/potenciales/usuariosPotencialesDB.pl";
	objAH.debug= true;
	objAH.showOverlay = true;
	objAH.cantidad= cant;
	var tipoAccion = "HABILITAR_PERSON";

	try{
		if ($("#accion").val())
			tipoAccion = $("#accion").val();
		else
			fromDetail = true;
	}
	catch (e){}

	objAH.tipoAccion= tipoAccion;
	objAH.id_personas= arrayPersonNumbers;
	objAH.funcion= "changePage";
	objAH.sendToServer();
}

function updateInfoActualizar(responseText){

 	var Messages=JSONstring.toObject(responseText);

 	setMessages(Messages);
	
	if (!fromDetail)
		buscarUsuariosPotenciales();
}




