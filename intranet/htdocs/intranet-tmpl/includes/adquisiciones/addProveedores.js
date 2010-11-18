/*
 * LIBRERIA addProveedores v 1.0.1
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
      objAH.apellido            = $('#apellido').val();
      objAH.nombre              = $('#nombre').val();
      objAH.domicilio           = $('#domicilio').val();
      objAH.tipo_doc            = $('#tipo_doc').val();
      objAH.nro_doc             = $('#nro_doc').val();
      objAH.razon_social        = $('#razon_social').val();
      objAH.proveedor_activo    = $("input[@name=proveedor_activo]:checked").val();
      objAH.telefono            = $('#telefono').val();
      objAH.pais                = $('#pais').val();
      objAH.cuit_cuil           = $('#cuit_cuil').val();
      objAH.provincia           = $('#provincia').val();
      objAH.ciudad              = $('#ciudad').val();
      objAH.email               = $('#email').val();
      objAH.fax                 = $('#fax').val();  
      
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
                  apellido: "required",
                  tipo_doc: "required",
                  nro_doc: "required",
                  razon_social: "required",
                  cuit_cuil: "required",
                  pais: "required",
                  provincia: "required",
                  ciudad: "required",
                  domicilio: "required",
                  email: {
                        email: true
                  },
               },
              messages: {
                    nombre: POR_FAVOR_INGRESE_UN_NOMBRE,
                    telefono: POR_FAVOR_INGRESE_UN_TELEFONO,
                    email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
                    apellido: POR_FAVOR_INGRESE_UN_APELLIDO,
                    tipo_doc: POR_FAVOR_INGRESE_UN_TIPO_DE_DOC,
                    nro_doc: POR_FAVOR_INGRESE_UN_NRO_DE_DOC,
                    razon_social: POR_FAVOR_INGRESE_UNA_RAZON_SOCIAL,
                    cuit_cuil: POR_FAVOR_INGRESE_UN_CUIT_CUIL,
                    pais: POR_FAVOR_INGRESE_UN_PAIS,
                    provincia: POR_FAVOR_INGRESE_UNA_PROV,
                    ciudad: POR_FAVOR_INGRESE_UNA_CIUDAD,
                    domicilio: POR_FAVOR_INGRESE_UN_DOMICILIO,
             }
            });
         });
   }