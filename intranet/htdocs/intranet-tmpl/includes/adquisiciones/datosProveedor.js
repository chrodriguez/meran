/*
 * LIBRERIA datosProveedores v 1.0.0
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creación 12/11/2010
 *
 */


//*********************************************Editar Proveedor********************************************* 
   $(document).ready(function() {
        CrearAutocompleteCiudades({IdInput: 'ciudad', IdInputHidden: 'id_ciudad'})
   
   
      });   
     
 




   function modificarDatosDeProveedor(){
        objAH         = new AjaxHelper(updateDatosProveedor);
        objAH.url     = '/cgi-bin/koha/adquisiciones/proveedoresDB.pl';
        objAH.debug   = true;

        objAH.id_proveedor        = $('#id_proveedor').val();
        objAH.nombre              = $('#nombre').val();
        objAH.apellido            = $('#apellido').val();
        objAH.tipo_documento      = $('#tipo_documento_id').val();
        objAH.numero_documento    = $('#numero_documento').val();
        objAH.razon_social        = $('#razon_social').val();
        objAH.cuit_cuil           = $('#cuit_cuil').val();
        objAH.cuidad              = $('#cuidad').val();
        objAH.domicilio           = $('#domicilio').val();
        objAH.telefono            = $('#telefono').val();
        objAH.fax                 = $('#fax').val();
        objAH.email               = $('#email').val();
        objAH.plazo_reclamo       = $('#plazo_reclamo').val();
        objAH.proveedor_activo    = $("input[@name=proveedor_activo]:checked").val();
//         monedas aca

        objAH.tipoAccion          = 'GUARDAR_MODIFICION_PROVEEDOR';
        objAH.sendToServer();
    }

    function updateDatosProveedor(responseText){
          if (!verificarRespuesta(responseText))
            return(0);
        var Messages=JSONstring.toObject(responseText);
        setMessages(Messages);
    }

    function changePage(ini){
        objAH.changePage(ini);
    }