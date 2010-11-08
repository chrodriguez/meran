/*
 * LIBRERIA proveedores v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */


//*********************************************Agregar Proveedor*********************************************


function updateAgregarProveedor(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}

function agregarProveedor(){

      objAH         = new AjaxHelper(updateAgregarProveedor);
      objAH.url     = '/cgi-bin/koha/adquisiciones/addProveedores.pl';
      objAH.debug   = true;

      objAH.nombre              = $('#nombre').val();
      objAH.direccion           = $('#direccion').val();
      objAH.proveedor_activo    = $("input[@name=proveedor_activo]:checked").val();
      objAH.telefono            = $('#telefono').val();
      objAH.email               = $('#email').val();
      objAH.tipoAccion          = 'AGREGAR_PROVEEDOR';
      objAH.sendToServer();
}


// ***************************************** Validaciones ******************************************************

function save(){
   $('#proveedorDataForm').submit();
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