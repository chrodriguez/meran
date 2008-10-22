/*
 * LIBRERIA usuarios v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */


//************************************************Eliminar Usuario**********************************************
function eliminarUsuario(){

	var is_confirmed = confirm('Confirma la baja ?');

	if (is_confirmed) {

		objAH=new AjaxHelper(updateEliminarUsuario);
		objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.debug= true;
		objAH.borrowernumber= usuario.ID;
		objAH.tipoAccion= 'ELIMINAR_USUARIO';
		objAH.sendToServer();

	}
}

function updateEliminarUsuario(responseText){
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
}

//*********************************************Fin***Eliminar Usuario*********************************************


//*********************************************Modificar Datos Usuario*********************************************
function modificarDatosDeUsuario(){
	objAH=new AjaxHelper(updateModificarDatosDeUsuario);
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.borrowernumber= usuario.ID;
	objAH.tipoAccion= 'MODIFICAR_USUARIO';
	objAH.sendToServer();
}

function updateModificarDatosDeUsuario(responseText){
//se crea el objeto que maneja la ventana para modificar los datos del usuario
	vDatosUsuario=new WindowHelper();
	vDatosUsuario.html=responseText;
	vDatosUsuario.create();	
}

function guardarModificacioUsuario(){

	objAH=new AjaxHelper(updateGuardarModificacioUsuario);
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.borrowernumber= usuario.ID;
	objAH.cardnumber= $('#cardnumber').val();
	objAH.sex= $("input[@name=sex]:checked").val();
	objAH.physstreet= $('#physstreet').val();
	objAH.streetaddress= $('#streetaddress').val();
	objAH.firstname= $('#firstname').val();
	objAH.dateofbirth= $('#dateofbirth').val();
	objAH.emailaddress= $('#emailaddress').val();
	objAH.dateenrolled= $('#dateenrolled').val();
	objAH.dstreetcity= $('#dstreetcity').val();
	objAH.altrelationship= $('#altrelationship').val();
	objAH.othernames= $('#othernames').val();
	objAH.phoneday= $('#phoneday').val();
	objAH.categorycode= $('#categorycode').val();
	objAH.city= $('#city').val();
	objAH.phone= $('#phone').val();
	objAH.borrowernotes= $('#borrowernotes').val();
	objAH.surname= $('#surname').val();
	objAH.ethnicity= $('#ethnicity').val();
	objAH.branchcode= $('#branchcode').val();
	objAH.zipcode= $('#zipcode').val();
	objAH.homezipcode= $('#homezipcode').val();
	objAH.documenttype= $('#documenttype').val();
	objAH.documentnumber= $('#documentnumber').val();
	objAH.studentnumber= $('#studentnumber').val();
	objAH.changepassword=  ( $('#changepassword').attr('checked') )?1:0;
	objAH.tipoAccion= 'GUARDAR_MODIFICACION_USUARIO';
 	objAH.sendToServer();

}

function updateGuardarModificacioUsuario(responseText){
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
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
	vModificarPermisos=new WindowHelper();
	vModificarPermisos.html=responseText;
	vModificarPermisos.titulo= 'PERMISOS DE ACCESO';
	vModificarPermisos.create();
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
		objAH.sendToServer();
 	}
}

function updateGuardarPermisos(responseText){

	vModificarPermisos.close();
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
}

//****************************************Fin para cambiar permisos*********************************************

//************************************************Eliminar Usuario**********************************************
function eliminarUsuario(){

	var is_confirmed = confirm('Confirma la baja ?');

	if (is_confirmed) {

		objAH=new AjaxHelper(updateEliminarUsuario);
		objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.debug= true;
		objAH.borrowernumber= usuario.ID;
		objAH.tipoAccion= 'ELIMINAR_USUARIO';
		objAH.sendToServer();

	}
}

function updateEliminarUsuario(responseText){
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
}

//*********************************************Fin***Eliminar Usuario*********************************************


//************************************************Agregar Usuario**********************************************
function agregarUsuario(){

	objAH=new AjaxHelper(updateAgregarUsuario);
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.cardnumber= $('#cardnumber').val();
	objAH.sex= $("input[@name=sex]:checked").val();
	objAH.streetaddress= $('#streetaddress').val();
	objAH.physstreet= $('#physstreet').val();
	objAH.firstname= $('#firstname').val();
	objAH.dateofbirth= $('#dateofbirth').val();
	objAH.emailaddress= $('#emailaddress').val();
	objAH.dateenrolled= $('#dateenrolled').val();
	objAH.streetcity= $('#dstreetcity').val();
	objAH.altrelationship= $('#altrelationship').val();
	objAH.othernames= $('#othernames').val();
	objAH.phoneday= $('#phoneday').val();
	objAH.categorycode= $('#categorycode').val();
	objAH.city= $('#city').val();
	objAH.phone= $('#phone').val();
	objAH.borrowernotes= $('#borrowernotes').val();
	objAH.surname= $('#surname').val();
	objAH.ethnicity= $('#ethnicity').val();
	objAH.branchcode= $('#branchcode').val();
	objAH.zipcode= $('#zipcode').val();
	objAH.homezipcode= $('#homezipcode').val();
	objAH.documenttype= $('#documenttype').val();
	objAH.documentnumber= $('#documentnumber').val();
	objAH.studentnumber= $('#studentnumber').val();
	objAH.changepassword= ( $('#changepassword').attr('checked') )?1:0;
	objAH.tipoAccion= 'AGREGAR_USUARIO';
 	objAH.sendToServer();

}

function updateAgregarUsuario(responseText){
	var Message=JSONstring.toObject(responseText);
	setMessage(Message);
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
	objAH.usuario= usuario.ID;
	objAH.tipoAccion= 'CAMBIAR_PASSWORD';
	//se envia la consulta
	objAH.sendToServer();
}

function updateGuardarCambiarPassword(responseText){
	clearInput();
	vModificarPassword.close();
	var Message= JSONstring.toObject(responseText);
	setMessage(Message);
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

	vModificarPassword=new WindowHelper();
	vModificarPassword.html=responseText;
 	vModificarPassword.titulo= 'Cambio de Contrase&ntilde;a';
	vModificarPassword.create();
	clearInput();
}

//***********************************************Fin**Cambiar Password*****************************************