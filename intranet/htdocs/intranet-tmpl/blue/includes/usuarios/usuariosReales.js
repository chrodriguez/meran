/*
 * LIBRERIA usuarios v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */
var nro_socio_temp; //SOLO USADO PARA MODIFICAR_USUARIO

//*********************************************Modificar Datos Usuario*********************************************
function modificarDatosDeUsuario(){
	objAH=new AjaxHelper(updateModificarDatosDeUsuario);
	objAH.debug= true;
	objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug= true;
	objAH.nro_socio= usuario.ID;
    nro_socio_temp = objAH.nro_socio; // SETEO LA VARIABLE GLOBAL TEMP
	objAH.tipoAccion= 'MODIFICAR_USUARIO';
	objAH.sendToServer();
}

function updateModificarDatosDeUsuario(responseText){
//se crea el objeto que maneja la ventana para modificar los/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl' datos del usuario
	vDatosUsuario=new WindowHelper({draggable: true, opacity: true});
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
	vModificarPermisos.titulo= PERMISOS_DE_ACCESO;
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
 		alert(ELIJA_AL_MENOS_UN_PERMISO);
 	}
 	else{

		for(var i=0; i< long; i++){
			array[i]=chck[i].value;
		}

		objAH=new AjaxHelper(updateGuardarPermisos);
		objAH.debug= true;
		objAH.tipoAccion= 'GUARDAR_PERMISOS';
		objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.nro_socio= usuario.ID;
		objAH.array_permisos= array;
		objAH.sendToServer();
 	}
}

function updateGuardarPermisos(responseText){

	vModificarPermisos.close();
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}

//****************************************Fin para cambiar permisos*********************************************



// ***************************************** Validaciones ******************************************************


function save(){

   $('#userDataForm').submit();
}


function validateForm(func){

   if( jQuery.browser.mozilla ) {
      // do when DOM is ready
      $( function() {
         // search form, hide it, search labels to modify, filter classes nocmx and error
         $( '#userDataForm' ).hide().find( 'p>label:not(.nocmx):not(.error)' ).each( function() {
            var $this = $(this);
            var labelContent = $this.html();
            var labelWidth = document.defaultView.getComputedStyle( this, '' ).getPropertyValue( 'width' );
            // create block element with width of label
            var labelSpan = $("<span>")
               .css("display", "block")
               .width(labelWidth)
               .html(labelContent);
            // change display to mozilla specific inline-box
            $this.css("display", "-moz-inline-box")
               // remove children
               .empty()
               // add span element
               .append(labelSpan);
         // show form again
         }).end().show();
      });
   };
         $.validator.setDefaults({
            submitHandler:  func ,
         });
   
         $().ready(function() {
            // validate signup form on keyup and submit
            $("#userDataForm").validate({
               rules: {
				  categoria_socio_name: "required",	
                  apellido: "required",
                  nombre: "required",
                  nro_socio: "required",
                  sexo: "required",
                  calle: "required",
                  ciudad: "required",
                  nacimiento: "required",
                  email: "required",
                  
                  email: {
                     email: true
                  },
               },
               messages: {
				  categoria_socio_name: POR_FAVOR_SELECCIONE_LA_CATEGORIA,
                  apellido: POR_FAVOR_INGRESE_SU_APELLIDO,
                  nombre: POR_FAVOR_INGRESE_SU_NOMBRE,
                  nro_socio: POR_FAVOR_INGRESE_LA_TARJETA_DE_IDENTIFICACION,
                  sexo: POR_FAVOR_INGRESE_EL_SEXO,
                  calle: POR_FAVOR_INGRESE_LA_CALLE_DONDE_VIVE,
                  ciudad: POR_FAVOR_INGRESE_LA_CIUDAD_EN_DONDE_VIVE,
                  nacimiento: POR_FAVOR_INGRESE_LA_FECHA_DE_NACIMIENTO,
                  telefono: POR_FAVOR_INGRESE_EL_TELEFONO,
                  nro_documento: {
                     required: POR_FAVOR_INGRESE_SU_NRO_DE_DNI,
                  },
                  email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
               }
            });
         });
   }
//************************************************Eliminar Usuario**********************************************
function eliminarUsuario(){

	var is_confirmed = confirm(CONFIRMA_LA_BAJA);

	if (is_confirmed) {

		objAH=new AjaxHelper(updateEliminarUsuario);
		objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
		objAH.debug= true;
		objAH.nro_socio= usuario.ID;
		objAH.tipoAccion= 'ELIMINAR_USUARIO';
		objAH.sendToServer();

	}
}



/// FIXME ver que cuando el usuario no haya borrado, no redireccione
function updateEliminarUsuario(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	if (!(hayError(Messages))){
// FIXME esta feo
		window.location.href = "/cgi-bin/koha/usuarios/reales/buscarUsuario.pl?token="+token;
	}
}

//*********************************************Fin***Eliminar Usuario*********************************************


//************************************************Agregar Usuario**********************************************
function agregarUsuario(){

      objAH=new AjaxHelper(updateAgregarUsuario);
      objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
      objAH.debug= true;
      if ( (($.trim(nro_socio)).length == 0 ) || ( $('#nro_socio').val() == 'Auto-generar' ) ) {
        objAH.auto_nro_socio=1;
      }else{
        objAH.nro_socio= $('#nro_socio').val();
      }
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
      objAH.tipoAccion= 'AGREGAR_USUARIO';
      objAH.sendToServer();
}

function checkUserData(){

   $('#userDataForm').validate();

}

function updateAgregarUsuario(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}

//*********************************************Fin***Agregar Usuario******************************************

//*************************************************Cambiar Password*******************************************

//muestra los ejemplares del grupo
function guardarCambiarPassword(claveUsuario, confirmeClave, actualPassword){

	objAH=new AjaxHelper(updateGuardarCambiarPassword);
	//objAH.debug= true;
	objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.newpassword= claveUsuario;
	objAH.newpassword1= confirmeClave;
    objAH.actualPassword= actualPassword;
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
    var actualPassword= $('#actualPassword').val();
	

	if (claveUsuario == ''){
		alert(POR_FAVOR_INGRESE_UNA_CONTRASENIA);
		clearInput();
		$('#newpassword').focus();

	}else{
		if (claveUsuario != confirmeClave){
			alert(LAS_CLAVES_SON_DISTINTAS);
			clearInput();
			$('#newpassword').focus();
	
		}else{
			guardarCambiarPassword(claveUsuario, confirmeClave, actualPassword);
		}
	}
}

function clearInput(){
	$('#newpassword').val('');
	$('#newpassword1').val('');
}

function cambiarPassword(){
	objAH=new AjaxHelper(updateCambiarPassword);
	objAH.url='/intranet-tmpl/blue/includes/popups/cambiarPassword.inc';
	objAH.debug= true;
	objAH.sendToServer();
}

function updateCambiarPassword(responseText){

	vModificarPassword=new WindowHelper({draggable: true, opacity: true});
	vModificarPassword.debug= true;
	vModificarPassword.html=responseText;
 	vModificarPassword.titulo= CAMBIO_DE_CONTRASENIA;
	vModificarPassword.create();
	vModificarPassword.height('220px');
	vModificarPassword.width('550px');
	vModificarPassword.open();
	clearInput();
}

//***********************************************Fin**Cambiar Password*****************************************

function eliminarFoto(foto){
	objAH=new AjaxHelper(updateEliminarFoto);
 	objAH.debug= true;
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


function agregarAutorizado(){

    var is_confirmed = confirm(CONFIRMAR_AFILIADO);

    if (is_confirmed) {

        objAH=new AjaxHelper(updateAgregarAutorizado);
        objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
        objAH.debug= true;
        objAH.nro_socio= usuario.ID;
        objAH.tipoAccion= 'AGREGAR_AUTORIZADO';
        objAH.sendToServer();

    }
}



function updateAgregarAutorizado(responseText){
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
    if (!(hayError(Messages))){
    }
}

function agregarAutorizado(nro_socio){
    objAH=new AjaxHelper(updateAgregarAutorizado);
    objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
    objAH.tipoAccion = "MOSTRAR_VENTANA_AGREGAR_AUTORIZADO";
    objAH.debug= true;
    objAH.sendToServer();
}

function updateAgregarAutorizado(responseText){

    vAgregarAutorizado=new WindowHelper({draggable: true, opacity: true});
    vAgregarAutorizado.debug= true;
    vAgregarAutorizado.html=responseText;
    vAgregarAutorizado.create();    
    vAgregarAutorizado.titulo= 'Agregar autorizado';
    vAgregarAutorizado.height('30%');
    vAgregarAutorizado.width('60%');
    vAgregarAutorizado.focus= 'nombreAutorizado';
    vAgregarAutorizado.open();
}