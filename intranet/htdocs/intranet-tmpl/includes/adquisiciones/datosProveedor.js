/*
 * LIBRERIA datosProveedores v 1.0.0
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Fecha de creación 12/11/2010
 *
 */


//*********************************************Editar Proveedor********************************************* 


   function modificarDatosDeProveedor(){
        objAH         = new AjaxHelper(updateDatosProveedor);
        objAH.url     = '/cgi-bin/koha/adquisiciones/proveedoresDB.pl';
        objAH.debug   = true;

        objAH.nombre              = $('#nombre').val();
        objAH.direccion           = $('#direccion').val();
        objAH.proveedor_activo    = $("input[@name=proveedor_activo]:checked").val();
        objAH.telefono            = $('#telefono').val();
        objAH.email               = $('#email').val();
        objAH.tipoAccion          = 'GUARDAR_MODIFICION_PROVEEDOR';
        objAH.id_proveedor        = $('#id_proveedor').val();
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