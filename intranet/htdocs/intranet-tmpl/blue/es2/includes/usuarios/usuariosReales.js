/*
 * LIBRERIA usuarios v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */




//*********************************************Modificar Datos Usuario*********************************************
function modificarDatosDeUsuario(){
	objAH=new AjaxHelper(updateModificarDatosDeUsuario);
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.id_socio= usuario.ID;
	objAH.tipoAccion= 'MODIFICAR_USUARIO';
	objAH.sendToServer();
}

function updateModificarDatosDeUsuario(responseText){
//se crea el objeto que maneja la ventana para modificar los/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl' datos del usuario
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
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.nro_socio= $('#nro_socio').val();
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
    objAH.id_ui= $('#ui_id').val();
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

//*********************************************Fin***Modificar Datos Usuario***************************************



//*******************************************Para cambiar permisos***********************************************

function modificarPermisos(){
	objAH=new AjaxHelper(updateModificarPermisos);
	objAH.debug= true;
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.usuario= usuario.ID;
	objAH.tipoAccion= 'MOSTRAR_PERMISOS';
	objAH.sendToServer();
}

function updateModificarPermisos(responseText){
//se crea el objeto que maneja la ventana para modificar los permisos
	vModificarPermisos=new WindowHelper({draggable: true, opacity: true});
	vModificarPermisos.debug= true;
	vModificarPermisos.html=responseText;
	vModificarPermisos.titulo= 'PERMISOS DE ACCESO';
	vModificarPermisos.create();
	vModificarPermisos.height('220px');
	vModificarPermisos.width('550px');
	vModificarPermisos.open();
}

function guardarPermisos(){

	var chck= $("input[@name=chkpermisos]:checked"); //obtengo todos los check seleccionados
	var array= new Array;
	var long=chck.length;
 	if ( long == 0){
 		alert("Elija al menos un permiso");
 	}
 	else{

		for(var i=0; i< long; i++){
			array[i]=chck[i].value;
		}

		objAH=new AjaxHelper(updateGuardarPermisos);
		//objAH.debug= true;
		objAH.tipoAccion= 'GUARDAR_PERMISOS';
		objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.usuario= usuario.ID;
		objAH.array_permisos= array;
		objAH.sendToServer();usuario
 	}
}

function updateGuardarPermisos(responseText){

	vModificarPermisos.close();
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}

//****************************************Fin para cambiar permisos*********************************************

//************************************************Eliminar Usuario**********************************************
function eliminarUsuario(){

	var is_confirmed = confirm('Confirma la baja ?');

	if (is_confirmed) {

		objAH=new AjaxHelper(updateEliminarUsuario);
		objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.debug= true;
		objAH.id_socio= usuario.ID;
		objAH.tipoAccion= 'ELIMINAR_USUARIO';
		objAH.sendToServer();

	}
}



/// FIXME ver que cuando el usuario no haya borrado, no redireccione
function updateEliminarUsuario(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	if (!(hayError(Messages))){
		window.location.href = "/cgi-bin/koha/usuarios/reales/buscarUsuario.pl";
	}
}

//*********************************************Fin***Eliminar Usuario*********************************************


//************************************************Agregar Usuario**********************************************
function agregarUsuario(){

    objAH=new AjaxHelper(updateAgregarUsuario);
    objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
    objAH.debug= true;
    objAH.nro_socio= $('#nro_socio').val();
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
    objAH.id_ui= $('#ui_id').val();
    objAH.tipo_documento= $('#tipo_documento_id').val();
    objAH.nro_documento= $('#nro_documento').val();
    objAH.legajo= $('#legajo').val();
    objAH.changepassword= ( $('#changepassword').attr('checked') )?1:0;
    objAH.tipoAccion= 'AGREGAR_USUARIO';
    objAH.sendToServer();

}

function updateAgregarUsuario(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}

//*********************************************Fin***Agregar Usuario******************************************

//*************************************************Cambiar Password*******************************************

//muestra los ejemplares del grupo
function guardarCambiarPassword(claveUsuario, confirmeClave){

	objAH=new AjaxHelper(updateGuardarCambiarPassword);
	//objAH.debug= true;
	objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.newpassword= claveUsuario;
	objAH.newpassword1= confirmeClave;
    objAH.actualPassword= confirmeClave;
	objAH.usuario= usuario.ID;
	objAH.tipoAccion= 'CAMBIAR_PASSWORD';
	//se envia la consulta
	objAH.sendToServer();
}

function updateGuardarCambiarPassword(responseText){
	clearInput();
	vModificarPassword.close();
	var Messages= JSONstring.toObject(responseText);
	setMessages(Messages);
}

function resetPassword(claveUsuario, confirmeClave){

    objAH=new AjaxHelper(updateResetPassword);
    //objAH.debug= true;
    objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
    objAH.newpassword= claveUsuario;
    objAH.newpassword1= confirmeClave;
    objAH.usuario= usuario.ID;
    objAH.tipoAccion= 'RESET_PASSWORD';
    //se envia la consulta
    objAH.sendToServer();
}

function updateResetPassword(responseText){
    var Messages= JSONstring.toObject(responseText);
    setMessages(Messages);
}

function verificarClaveUsuario(){
	var claveUsuario= $('#newpassword').val();
	var confirmeClave= $('#newpassword1').val();
	

	if (claveUsuario == ''){
		alert("Ingrese una contraseña.");
		clearInput();
		$('#newpassword').focus();

	}else{
		if (claveUsuario != confirmeClave){
			alert("Las claves son distintas.\nIngreselas nuevamente.");
			clearInput();
			$('#newpassword').focus();
	
		}else{
			guardarCambiarPassword(claveUsuario, confirmeClave);
		}
	}
}

function clearInput(){
	$('#newpassword').val('');
	$('#newpassword1').val('');
}

function cambiarPassword(){
	objAH=new AjaxHelper(updateCambiarPassword);
	objAH.url='/intranet-tmpl/blue/es2/includes/popups/cambiarPassword.inc';
	objAH.debug= true;
	objAH.sendToServer();
}

function updateCambiarPassword(responseText){

	vModificarPassword=new WindowHelper({draggable: true, opacity: true});
	vModificarPassword.debug= true;
	vModificarPassword.html=responseText;
 	vModificarPassword.titulo= 'Cambio de Contrase&ntilde;a';
	vModificarPassword.create();
	vModificarPassword.height('220px');
	vModificarPassword.width('550px');
	vModificarPassword.open();
	clearInput();
}

//***********************************************Fin**Cambiar Password*****************************************

function eliminarFoto(foto){
	objAH=new AjaxHelper(updateEliminarFoto);
// 	objAH.debug= true;
	objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.tipoAccion= 'ELIMINAR_FOTO';
	objAH.foto_name= foto;
	objAH.sendToServer();
}

function updateEliminarFoto(responseText){
	//se muestran mensajes
	//se resfresca la info de usuario
	detalleUsuario();
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}
