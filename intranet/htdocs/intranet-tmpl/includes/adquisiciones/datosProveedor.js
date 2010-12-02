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
        CrearAutocompleteMonedas({IdInput: 'moneda', IdInputHidden: 'id_moneda'})
        ocultarDatos()
        monedas()
   
      });   
      
      
    function monedas(){
      $('#agregar_moneda').click(function() {
          //alert($('#moneda').val() + $('#id_moneda').val() )
          //aler($('#id_moneda').val())
          if(($('#moneda').val() == "") || ($('#id_moneda').val() == "")){
              alert('Por favor ingrese una moneda')            
          }else{
              var idMonedaNueva = $('#id_moneda').val()
              agregarMoneda(idMonedaNueva)
          }
          
      });   
     
   }
   
   // agregar la moneda en la base por ajax y volver a cargarlas en el div
   function agregarMoneda(idMonedaNueva){
      objAH                     = new AjaxHelper(updateMonedasProveedor)
      objAH.url                 = '/cgi-bin/koha/adquisiciones/proveedoresDB.pl'
      objAH.debug               = true

      objAH.id_proveedor        = $('#id_proveedor').val()
      objAH.id_moneda           = idMonedaNueva

      objAH.tipoAccion          = 'GUARDAR_MONEDA_PROVEEDOR'
      objAH.sendToServer();   
   }
   
   
   function updateMonedasProveedor(){
//        if (!verificarRespuesta(responseText))
//             return(0)
//        var Messages=JSONstring.toObject(responseText)
//        alert(Messages)
//         alert('ok')
   }
      
      
   function ocultarDatos(){
     
      if(($('#apellido').val() == "") && ($('#razon_social').val() != "")){
        
          //es una persona juridica
          $('#datos_proveedor').show()
          $('#nombre').hide()
          $('#label_nombre').hide()
          $('#apellido').hide()  
          $('#label_apellido').hide()  
          $('#nro_doc').hide()    
          $('#label_tipo_documento_id').hide()
          $('#numero_documento').hide()
          $('#tipo_documento_id').hide()
          $('#razon_social').show()
          $('#label_razon_social').show()    
      }else{
        
          //es una persona fisica
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
        
      }     
   }

   function modificarDatosDeProveedor(){
        objAH                     = new AjaxHelper(updateDatosProveedor);
        objAH.url                 = '/cgi-bin/koha/adquisiciones/proveedoresDB.pl';
        objAH.debug               = true;

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