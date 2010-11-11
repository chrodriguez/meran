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
   
   
function consultar(filtro,doScroll){
    if (doScroll)
      shouldScrollUser = doScroll;
    objAH=new AjaxHelper(updateInfoProveedores);
    objAH.cache = true;
    busqueda = jQuery.trim($('#nombre_proveedor').val());
    inicial = '0';
    if (filtro){
        inicial = filtro;
        busqueda = jQuery.trim(filtro);
        objAH.inicial= inicial;
        $('#nombre_proveedor').val(FILTRO_POR + filtro);
    }
    else
       {
        if (busqueda.substr(8,5).toUpperCase() == 'TODOS'){
                busqueda = busqueda.substr(8,5);
                $('#nombre_proveedor').val(busqueda);
                consultar(busqueda);
        }
        else
           {
            if (busqueda.substr(0,6).toUpperCase() == 'FILTRO'){
                busqueda = busqueda.substr(8,1);
                $('#nombre_proveedor').val(busqueda);
                consultar(busqueda);
            }
           }
    }
    if(jQuery.trim(busqueda).length > 0){
        objAH.url= '/cgi-bin/koha/usuarios/reales/buscarProveedorResult.pl';
        objAH.debug= true;
//      objAH.cache= true;
        objAH.funcion= 'changePage';
        objAH.socio= busqueda;
        objAH.sendToServer();
    }
    else{
        jAlert(INGRESE_UN_DATO,USUARIOS_ALERT_TITLE);
        $('#nombre_proveedor').focus();
    }

}

function updateInfoProveedores(responseText){
    $('#result').html(responseText);
    zebra('datos_tabla');
    var idArray = [];
    var classes = [];
    idArray[0] = 'proveedor';
    classes[0] = 'nombre';
    classes[1] = 'direccion';
    classes[2] = 'telefono';
    classes[3] = 'email';
    busqueda = jQuery.trim($('#nombre_proveedor').val());
    if (busqueda.substr(0,6).toUpperCase() != 'FILTRO') //SI NO SE QUISO FILTRAR POR INICIAL, NO TENDRIA SENTIDO MARCARLO
        highlight(classes,idArray);
    if (shouldScrollUser)
        scrollTo('result');
}

function Borrar(){
    $('#nombre_proveedor').val('');
}

function checkFilter(eventType){
    var str = $('#nombre_proveedor').val();
    
    if (eventType.toUpperCase() == 'FOCUS'){

        if (str.substr(0,6).toUpperCase() == 'FILTRO'){
            globalSearchTemp = $('#nombre_proveedor').val();
            Borrar();
        }
    }
    else
       {
        if (jQuery.trim($('#nombre_proveedor').val()) == "")
            $('#nombre_proveedor').val(globalSearchTemp);
       }
}