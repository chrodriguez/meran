/*
 * LIBRERIA addProveedores v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creacion 22/10/2008
 *
 */


//*********************************************Agregar Proveedor*********************************************
   
   
     //var HASH_RULES = new Array(); //para manejar las reglas de validacion del FORM dinamicamente
     var HASH_MESSAGES = new Array();
     
     function _freeMemory(array){
        for(var i=0;i<array.length;i++){
            delete array[i];
     }
}
    
     function agregarAHash(HASH, name, value){
           HASH[name] = value;
     }
     
//      function addRules(){
//          $(elemente).rules("remove");
//          $(elemento).rules("add", RULES_OPTIONS);
//      }
               
   //funcion que muestra solo los input necesarios para una persona fisica
   function verDatosPersonaFisica(){
       $('#datos_proveedor').show()
       $('#razon_social').hide()
       $('#label_razon_social').hide()
       $('#nombre').show()
       $('#label_nombre').show()
       $('#apellido').show()  
       $('#label_apellido').show()  
       $('#nro_doc').show()    
       $('#label_nro_doc').show()
       $('#tipo_documento_id').show()
       
    //   HASH_RULES = null
//         _freeMemory(HASH_MESSAGES)
//         HASH_MESSAGES = []
       
       agregarAHash(HASH_MESSAGES, "nombre", POR_FAVOR_INGRESE_UN_NOMBRE)   
       agregarAHash(HASH_MESSAGES, "apellido", POR_FAVOR_INGRESE_UN_APELLIDO) 
       agregarAHash(HASH_MESSAGES, "nro_doc", POR_FAVOR_INGRESE_UN_NRO_DE_DOC) 
       agregarAHash(HASH_MESSAGES, "tipo_documento_id", POR_FAVOR_INGRESE_UN_TIPO_DE_DOC) 
       agregarAHash(HASH_MESSAGES, "cuit_cuil", POR_FAVOR_INGRESE_UN_CUIT_CUIL)
       agregarAHash(HASH_MESSAGES, "ciudad", POR_FAVOR_INGRESE_UNA_CIUDAD)
       agregarAHash(HASH_MESSAGES, "domicilio", POR_FAVOR_INGRESE_UN_DOMICILIO)
       agregarAHash(HASH_MESSAGES, "telefono", POR_FAVOR_INGRESE_UN_TELEFONO)
       agregarAHash(HASH_MESSAGES, "email", POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA)
       
       $('.error_adv ').remove()
       
        //quitar class required a los input que no se validan       
        $('#razon_social ').removeClass('required');
       
       
       //$('#razon_social').rules("remove", "required");


       
//        $('#nombre').rules("add", {
//             minlength: 2,
//             messages: {
//               minlength: "holaa",
//             }
//         });

       
       //agregar las clases a los campos que se validan. Porque si viene de datos persona_fisica no tiene class
//        $('#nombre ').addClass('required');      
//        $('#apellido ').addClass('required');  
//        $('#nro_doc ').addClass('required');  
//        $('#tipo_documento_id ').addClass('required');  
//        
       
       
//        reglas = {     nombre: "required",
//                       telefono: "required",
//                       apellido: "required",
//                       tipo_doc: "required",
//                       nro_doc: "required",
//                       cuit_cuil: "required",
//                       ciudad: "required",
//                       domicilio: "required",
//                       email: {
//                             email: true
//                       },
//                }
               
         
               
//        mensajes = { nombre: POR_FAVOR_INGRESE_UN_NOMBRE,
//                     telefono: POR_FAVOR_INGRESE_UN_TELEFONO,
//                     email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
//                     apellido: POR_FAVOR_INGRESE_UN_APELLIDO,
//                     tipo_doc: POR_FAVOR_INGRESE_UN_TIPO_DE_DOC,
//                     nro_doc: POR_FAVOR_INGRESE_UN_NRO_DE_DOC,
//                     cuit_cuil: POR_FAVOR_INGRESE_UN_CUIT_CUIL,
//                     ciudad: POR_FAVOR_INGRESE_UNA_CIUDAD,
//                     domicilio: POR_FAVOR_INGRESE_UN_DOMICILIO,
//                   }
//        
      validateForm(agregarProveedor)
  }

   //funcion que muestra solo los input necesarios para una persona juridica
  function verDatosPersonaJuridica(){
       $('#datos_proveedor').show()
       $('#nombre').hide()
       $('#label_nombre').hide()
       $('#apellido').hide()  
       $('#label_apellido').hide()  
       $('#nro_doc').hide()    
       $('#label_nro_doc').hide()
       $('#tipo_documento_id').hide()
       $('#razon_social').show()
       $('#label_razon_social').show()
       
//        _freeMemory(HASH_MESSAGES)
//        HASH_MESSAGES = []
       
       agregarAHash(HASH_MESSAGES, "razon_social", POR_FAVOR_INGRESE_UNA_RAZON_SOCIAL)
       agregarAHash(HASH_MESSAGES, "cuit_cuil", POR_FAVOR_INGRESE_UN_CUIT_CUIL)
       agregarAHash(HASH_MESSAGES, "ciudad", POR_FAVOR_INGRESE_UNA_CIUDAD)
       agregarAHash(HASH_MESSAGES, "domicilio", POR_FAVOR_INGRESE_UN_DOMICILIO)
       agregarAHash(HASH_MESSAGES, "telefono", POR_FAVOR_INGRESE_UN_TELEFONO)
       agregarAHash(HASH_MESSAGES, "email", POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA)
       
       
       //agregar las clases a los campos que se validan. Porque si viene de datos persona_fisica no tiene class
//        $('#razon_social ').addClass('required');      

        $('.error_adv ').remove()
//        
//        //quitar class required a los input que no se validan
        $('#nombre ').removeClass('required')
        $('#apellido ').removeClass('required')
        $('#tipo_documento_id ').removeClass('required')
        $('#nro_doc ').removeClass('required')
        

       
//        reglas = {     razon_social: "required",
//                       cuit_cuil: "required",
//                       ciudad: "required",
//                       domicilio: "required",
//                       email: {
//                             email: true
//                       },
//                 }
//                 
//        mensajes = { razon_social: POR_FAVOR_INGRESE_UNA_RAZON_SOCIAL,
//                     cuit_cuil: POR_FAVOR_INGRESE_UN_CUIT_CUIL,
//                     ciudad: POR_FAVOR_INGRESE_UNA_CIUDAD,
//                     domicilio: POR_FAVOR_INGRESE_UN_DOMICILIO,
//                     telefono: POR_FAVOR_INGRESE_UN_TELEFONO,
//                     email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
//                   }
    validateForm(agregarProveedor)
  }

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
      objAH.plazo_reclamo       = $('#plazo_reclamo').val();
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
                rules: "",
//                   if (persona_juridica == true){
//                     razon_social: "required",
//                   }else{
//                     nombre: "required",
//                     telefono: "required",
//                     apellido: "required",
//                     tipo_doc: "required",
//                     nro_doc: "required",
//                   }
//                    nombre: "required",
//                    telefono: "required",
//                    apellido: "required",
//                    tipo_doc: "required",
//                    nro_doc: "required",
//                    razon_social: "required",
//                   cuit_cuil: "required",
//                   ciudad: "required",
//                   domicilio: "required",
//                   email: {
//                         email: true
//                   },
//                },
              messages: HASH_MESSAGES,
//                     nombre: POR_FAVOR_INGRESE_UN_NOMBRE,
//                     telefono: POR_FAVOR_INGRESE_UN_TELEFONO,
//                     email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
//                     apellido: POR_FAVOR_INGRESE_UN_APELLIDO,
//                     tipo_doc: POR_FAVOR_INGRESE_UN_TIPO_DE_DOC,
//                     nro_doc: POR_FAVOR_INGRESE_UN_NRO_DE_DOC,
//                     razon_social: POR_FAVOR_INGRESE_UNA_RAZON_SOCIAL,
//                     cuit_cuil: POR_FAVOR_INGRESE_UN_CUIT_CUIL,
//                     ciudad: POR_FAVOR_INGRESE_UNA_CIUDAD,
//                     domicilio: POR_FAVOR_INGRESE_UN_DOMICILIO,
//              }
            });
         });
   }