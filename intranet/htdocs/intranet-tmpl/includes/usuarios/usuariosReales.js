/*
 * LIBRERIA usuarios v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */
var nro_socio_temp; //SOLO USADO PARA MODIFICAR_USUARIO
var vDatosUsuario = 0;
//*********************************************Modificar Datos Usuario*********************************************
function modificarDatosDeUsuario(){
	objAH                   = new AjaxHelper(updateModificarDatosDeUsuario);
    objAH.showOverlay       = true;
	objAH.debug             = true;
	objAH.url               = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug             = true; 
	objAH.nro_socio         = USUARIO.ID;
    nro_socio_temp          = objAH.nro_socio; // SETEO LA VARIABLE GLOBAL TEMP
	objAH.tipoAccion        = 'MODIFICAR_USUARIO';
	objAH.sendToServer();
}

function updateModificarDatosDeUsuario(responseText){
//se crea el objeto que maneja la ventana para modificar los datos del usuario
        if (!verificarRespuesta(responseText))
            return(0);

        $('#basic-modal-content').html(responseText);
        $('#basic-modal-content').modal({   containerCss:{
                backgroundColor:"#fff",
        //         borderColor:"#0063dc",
                height:420,
                padding:0,
                width:900
            },
        });
}

function guardarModificacionUsuario(){

	objAH                   = new AjaxHelper(updateGuardarModificacionUsuario);
	objAH.url               = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug             = true;
    objAH.showOverlay       = true;
	objAH.nro_socio         = nro_socio_temp; 
    objAH.sexo              = $("input[@name=sexo]:checked").val();
    objAH.calle             = $('#calle').val();
    objAH.nombre            = $('#nombre').val();
    objAH.nacimiento        = $('#nacimiento').val();
    objAH.email             = $('#email').val();
    objAH.telefono          = $('#telefono').val();
    objAH.cod_categoria     = $('#categoria_socio_id').val();
    objAH.ciudad            = $('#id_ciudad').val();
    objAH.alt_ciudad        = $('#id_alt_ciudad').val();
    objAH.alt_telefono      = $('#alt_telefono').val();
    objAH.apellido          = $('#apellido').val();
    objAH.id_ui             = $('#id_ui').val();
    objAH.tipo_documento    = $('#tipo_documento_id').val();
    objAH.nro_documento     = $('#nro_documento').val();
    objAH.legajo            = $('#legajo').val();
    objAH.institucion       = $('#institucion').val();
    objAH.carrera           = $('#carrera').val();
    objAH.anio              = $('#anio').val();
    objAH.division          = $('#division').val();
    objAH.changepassword    = ( $('#changepassword').attr('checked') )?1:0;
	objAH.tipoAccion        = 'GUARDAR_MODIFICACION_USUARIO';
    objAH.tema              = $('#temas_intra').val();
    objAH.auth_nombre       = $('#auth_nombre').val();
    objAH.auth_dni          = $('#auth_dni').val();
    objAH.auth_telefono     = $('#auth_telefono').val();
 	objAH.sendToServer();

}

function updateGuardarModificacionUsuario(responseText){
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	detalleUsuario();
    $.modal.close();
}

//*********************************************Fin***Modificar Datos Usuario***************************************


// ***************************************** Validaciones ******************************************************


function save(){
	startOverlay();
   $('#userDataForm').submit();
}


function validateForm(func){

   
         $().ready(function() {
            // validate signup form on keyup and submit
            $.validator.setDefaults({
              submitHandler:  func ,
            });
            $("#userDataForm").validate({
    
                debug: true,
                errorElement: "em",
                errorClass: "error_adv",
               rules: {
                  nro_documento: "required",
                  tipo_documento_id: "required",
				  categoria_socio_id: "required",	
                  apellido: "required",
                  nombre: "required",
                  nro_socio: "required",
                  sexo: "required",
                  calle: "required",
                  ciudad: "required",
                  id_ui: "required",

                  nacimiento: {
                        required: true,
                        dateITA: true
                  },
                 
                  email: {
                        required: true,
                        email: true
                  },
               },
               messages: {
				  categoria_socio_id: POR_FAVOR_SELECCIONE_LA_CATEGORIA,
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
                  tipo_documento_id: POR_FAVOR_INGRESE_SU_NRO_DE_DNI,
                  email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
                  id_ui: POR_FAVOR_INGRESE_UNA_UI
               }
            });
         });
   }
//************************************************Eliminar Usuario**********************************************
function eliminarUsuario(){

	var is_confirmed = confirm(CONFIRMA_LA_BAJA);

	if (is_confirmed) {

		objAH=new AjaxHelper(updateEliminarUsuario);
		objAH.url=URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
		objAH.debug= true;
	    objAH.showOverlay       = true;
		objAH.nro_socio= USUARIO.ID;
		objAH.tipoAccion= 'ELIMINAR_USUARIO';
		objAH.sendToServer();

	}
}



/// FIXME ver que cuando el usuario no haya borrado, no redireccione
function updateEliminarUsuario(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
	if (!(hayError(Messages))){
// FIXME esta feo
		window.location.href = URL_PREFIX+"/usuarios/potenciales/buscarUsuario.pl?token="+token;
	}
}

//*********************************************Fin***Eliminar Usuario*********************************************


//************************************************gu Usuario**********************************************
function agregarUsuario(){

      objAH         = new AjaxHelper(updateAgregarUsuario);
      objAH.url     = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
      objAH.showOverlay       = true;
      objAH.debug   = true;
      if ( (($.trim(nro_socio)).length == 0 ) || ( $('#nro_socio').val() == 'Auto-generar' ) ) {
        objAH.auto_nro_socio=1;
      }else{
        objAH.nro_socio= $('#nro_socio').val();
      }

      objAH.sexo            = $("input[@name=sexo]:checked").val();
      objAH.calle           = $('#calle').val();
      objAH.nombre          = $('#nombre').val();
      objAH.nacimiento      = $('#nacimiento').val();
      objAH.email           = $('#email').val();
      objAH.telefono        = $('#telefono').val();
      objAH.cod_categoria   = $('#categoria_socio_id').val();
      objAH.ciudad          = $('#id_ciudad').val();
      objAH.alt_ciudad      = $('#id_alt_ciudad').val();
      objAH.alt_telefono    = $('#alt_telefono').val();
      objAH.apellido        = $('#apellido').val();
      objAH.id_ui           = $('#id_ui').val();
      objAH.tipo_documento  = $('#tipo_documento_id').val();
      objAH.credential_type = $('#credential').val();
      objAH.nro_documento   = $('#nro_documento').val();
      objAH.legajo          = $('#legajo').val();
      objAH.institucion     = $('#institucion').val();
      objAH.carrera         = $('#carrera').val();
      objAH.anio            = $('#anio').val();
      objAH.division        = $('#division').val();
      objAH.changepassword  = ($('#changepassword').attr('checked') )?1:0;
      objAH.tipoAccion      = 'AGREGAR_USUARIO';
      objAH.tema            = $('#temas_intra').val();

      objAH.sendToServer();
}

function checkUserData(){

   $('#userDataForm').validate();

}

function updateAgregarUsuario(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
	var Messages=JSONstring.toObject(responseText);
	setMessages(Messages);
}

//*********************************************Fin***Agregar Usuario******************************************

//*************************************************Cambiar Password*******************************************

function desautorizarTercero(claveUsuario, confirmeClave){

    jConfirm(CONFIRMAR_ELIMINAR_AFILIADO, USUARIOS_ALERT_TITLE, function(confirmStatus){

    	if (confirmStatus){
	    	objAH=new AjaxHelper(updateDesautorizarTercero);
	        objAH.debug= true;
	        objAH.showOverlay       = true;
	        objAH.url= URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
	        objAH.nro_socio= USUARIO.ID;
	        objAH.tipoAccion= 'ELIMINAR_AUTORIZADO';
	        //se envia la consulta
	        objAH.sendToServer();
    	}
    });
}

function updateDesautorizarTercero(responseText){
    if (!verificarRespuesta(responseText))
            return(0);

    var Messages= JSONstring.toObject(responseText);
    setMessages(Messages);
    detalleUsuario();
}


function resetPassword(claveUsuario, confirmeClave){
    jConfirm(RESET_PASSWORD, USUARIOS_ALERT_TITLE, function(confirmStatus){
        if (confirmStatus){
            objAH=new AjaxHelper(updateResetPassword);
            objAH.showOverlay       = true;
            objAH.url= URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
            objAH.nro_socio= USUARIO.ID;
            objAH.tipoAccion= 'RESET_PASSWORD';
            //se envia la consulta
            objAH.sendToServer();
        }
    });
}

function updateResetPassword(responseText){
    if (!verificarRespuesta(responseText))
            return(0);

    var Messages= JSONstring.toObject(responseText);
    setMessages(Messages);
}

function clearInput(){
	$('#newpassword').val('');
	$('#newpassword1').val('');
}

function cambiarPassword(){
    $('#formCambioPassword').submit();
}


//***********************************************Fin**Cambiar Password*****************************************

function eliminarFoto(foto){

    jConfirm(CONFIRMAR_ELIMINAR_FOTO, USUARIOS_ALERT_TITLE, function(confirmStatus){
    	if (confirmStatus){
			objAH               = new AjaxHelper(updateEliminarFoto);
		 	objAH.debug         = true;
		    objAH.showOverlay       = true;
			objAH.url           = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
			objAH.tipoAccion    = 'ELIMINAR_FOTO';
			objAH.foto_name     = foto;
			objAH.nro_socio     = USUARIO.ID;
			objAH.sendToServer();
    	}
    });
}

function updateEliminarFoto(responseText){
	//se muestran mensajes
	//se resfresca la info de usuario
    if (!verificarRespuesta(responseText))
            return(0);

    $('#foto').html('');
	var Messages = JSONstring.toObject(responseText);
	setMessages(Messages);
    $('#div_uploader').show();
    $('#div_boton_eliminar_foto').hide();
    detalleUsuario();
}

function agregarAutorizado(){
    objAH               = new AjaxHelper(updateAgregarAutorizado);
    objAH.showOverlay   = true;
    objAH.url           = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
    objAH.tipoAccion    = "MOSTRAR_VENTANA_AGREGAR_AUTORIZADO";
    objAH.debug         = true;
    objAH.sendToServer();
}

function updateAgregarAutorizado(responseText){
    if (!verificarRespuesta(responseText))
            return(0);

    $('#basic-modal-content').html(responseText);
    $('#basic-modal-content').modal({   containerCss:{
            backgroundColor:"#fff",
    //         borderColor:"#0063dc",
            height:200,
            padding:0,
            width:650
        },
    });
}

function validarDatosCensales(){
	objAH                   = new AjaxHelper(updateValidarDatosCensales);
	objAH.debug             = true;
    objAH.showOverlay       = true;
	objAH.url               = URL_PREFIX+'/usuarios/reales/usuariosRealesDB.pl';
	objAH.debug             = true; 
	objAH.nro_socio         = USUARIO.ID;
    nro_socio_temp          = objAH.nro_socio; // SETEO LA VARIABLE GLOBAL TEMP
	objAH.tipoAccion        = 'VALIDAR_DATOS_CENSALES';
	objAH.sendToServer();
}

function updateValidarDatosCensales(responseText){
//se crea el objeto que maneja la ventana para modificar los datos del usuario
        if (!verificarRespuesta(responseText))
            return(0);

    	var Messages = JSONstring.toObject(responseText);
    	setMessages(Messages);
    	detalleUsuario();
    	
}





