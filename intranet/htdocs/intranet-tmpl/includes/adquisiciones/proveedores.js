/*
 * LIBRERIA usuarios v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */

// ***************************************** Validaciones ******************************************************


function save(){

   $('#proveedorDataForm').submit();
}

function agregarProveedor(){

      objAH         = new AjaxHelper(updateAgregarUsuario);
      objAH.url     = '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
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
      objAH.changepassword  = ( $('#changepassword').attr('checked') )?1:0;
      objAH.tipoAccion      = 'AGREGAR_USUARIO';
      objAH.tema            = $('#temas_intra').val();

      objAH.sendToServer();
}


function validateForm(func){

   
         $().ready(function() {
            // validate signup form on keyup and submit
            $.validator.setDefaults({
              submitHandler:  func ,
            });
            $("#proveedorDataForm").validate({
    
                debug: true,
                errorElement: "em",
                errorClass: "error_adv",
                rules: {
                  nombre: "required",
                  telefono: "required",
                  email: {
                        email: true
                  },
               },
               messages: {
              nombre: POR_FAVOR_INGRESE_EL_NOMBRE,
              telefono: POR_FAVOR_INGRESE_UN_TELEFONO,
              email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,

               }
            });
         });
   }