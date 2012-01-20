/*
 * LIBRERIA detalleImportacion v 1.0.1
 * Esta es una libreria creada para el sistema MERAN
 * Fecha de creacion 09/01/2012
 *
 */

//*********************************************Detalle *********************************************


function ordenar(orden){
    objAH.sort(orden);
}

function detalleImportacion(id_importacion){

    objAH=new AjaxHelper(updateDetalleImportacion);
    objAH.url               = URL_PREFIX+'/herramientas/importacion/importarDB.pl';
    objAH.debug             = true;
    objAH.showOverlay       = true;
    objAH.funcion           = 'changePage';
    objAH.tipoAccion        = "DETALLE";
    objAH.id_importacion  = id_importacion;
    objAH.record_filter  =  $("input[@name=record_filter]:checked").val();
    objAH.sendToServer();

}

function changePage(ini){
    objAH.changePage(ini);
}

function updateDetalleImportacion(responseText){
    $('#detalleImportacion').html(responseText);
    zebra('datos_tabla');
}


function detalleRegistroMARC(id){
    objAHDetalle=new AjaxHelper(updateDetalleRegistroMARC);
    objAHDetalle.url               = URL_PREFIX+'/herramientas/importacion/importarDB.pl';
    objAHDetalle.debug             = true;
    objAHDetalle.showOverlay       = true;
    objAHDetalle.tipoAccion        = "DETALLE_REGISTRO";
    objAHDetalle.id = id;
    objAHDetalle.sendToServer();

}

function updateDetalleRegistroMARC(responseText){
            $('#detalleRegistroMARC').html(responseText);
            $.scrollTo('#detalleRegistroMARC');
}

/*
 * eleccionCampoX
 * Funcion que se ejecuta cuando se selecciona un valor del combo campoX (ej. 1xx), y hace un llamado a la
 * funcion que ejecuta el ajax, con los parametros correspondiente a la accion realizada.
 */
function eleccionCampoOrigenX(id,id_esquema){
    if ( $("#campoX"+id).val() != -1){
        objAH               = new AjaxHelper(updateEleccionCampoOrigenX);
        objAH.debug         = true;
        objAH.showOverlay   = true;
        objAH.url           = URL_PREFIX+'/herramientas/importacion/importarDB.pl';
        objAH.id_campo_seleccion = id;
        objAH.id_esquema = id_esquema;
        objAH.campoX        = $('#campoX'+id).val();
        objAH.tipoAccion    = "GENERAR_ARREGLO_CAMPOS_ESQUEMA_ORIGEN";
        objAH.sendToServer();
    }else
        enable_disableSelectsOrigen();
}

//se genera el combo en el cliente
function updateEleccionCampoOrigenX(responseText){
    //Arreglo de Objetos Global
    var campos_array = JSONstring.toObject(responseText);
    //se inicializa el combo
    var id = objAH.id_campo_seleccion;
    $("#campo"+id).html('');
    var options = "<option value='-1'>Seleccionar CampoX</option>";
    var vacio=1;
    for (x=0;x < campos_array.length;x++){
        if ((campos_array[x].campo_origen)&&(campos_array[x].campo_origen != '')&&(campos_array[x].campo_origen != ' ')) {
         options+= "<option value=" + campos_array[x].campo_origen +" >" + campos_array[x].campo_origen + "</option>";
         vacio = 0;
        }
    }


    if(vacio != 1){
        $("#campo"+id).append(options);
        //se agrega la info al combo
        $("#campo"+id).show();
        $("#subcampo"+id).hide();
    }else{
        $("#campo"+id).hide();
        }
}


function eleccionCampoOrigen(id,id_esquema){

    if ($("#campo"+id).val() != -1){
        objAH               = new AjaxHelper(updateEleccionCampoOrigen);
        objAH.debug         = true;
        objAH.showOverlay   = true;
        objAH.url           = URL_PREFIX+"/herramientas/importacion/importarDB.pl";
        objAH.id_campo_seleccion=id;
        objAH.id_esquema = id_esquema;
        objAH.campo         = $('#campo'+id).val();
        objAH.tipoAccion    = "GENERAR_ARREGLO_SUBCAMPOS_ESQUEMA_ORIGEN";
        objAH.sendToServer();
    }
    else
        enable_disableSelectsOrigen(id);

}

//se genera el combo en el cliente
function updateEleccionCampoOrigen(responseText){

    var id = objAH.id_campo_seleccion;
    //Arreglo de Objetos Global
    var subcampos_array=JSONstring.toObject(responseText);
    //se inicializa el combo
    $("#subcampo"+id).html('');
    var options = "<option value='-1'>Seleccionar SubCampo</option>";
    var vacio=1;
    for (x=0;x < subcampos_array.length;x++){
        if ((subcampos_array[x].subcampo_origen)&&(subcampos_array[x].subcampo_origen != '')&&(subcampos_array[x].subcampo_origen != ' ')) {
            options+= "<option value=" + subcampos_array[x].subcampo_origen +" >" + subcampos_array[x].subcampo_origen + "</option>";
            vacio = 0;
        }
    }

    if (vacio != 1){
        //se agrega la info al combo
        $("#subcampo"+id).append(options);
        $("#campo"+id).show();
        $("#subcampo"+id).show();
    }else{
        $("#subcampo"+id).hide();
        }
}

function enable_disableSelectsOrigen(id){

    $("#campo"+id).show();
    $("#subcampo"+id).show();

    if ( $('#campoX'+id).val() == -1){
         $("#campo"+id).hide();
         $("#subcampo"+id).hide();
    }
    else
      if ( $('#campo'+id).val() == -1){
         $("#campo"+id).show();
         $("#subcampo"+id).hide();
      }
}

function procesarRelacionRegistroEjemplares(id){
    if ($("#campo1").val() != -1){
        objAHDetalle=new AjaxHelper(updateRelacionRegistroEjemplares);
        objAHDetalle.url               = URL_PREFIX+'/herramientas/importacion/importarDB.pl';
        objAHDetalle.debug             = true;
        objAHDetalle.showOverlay       = true;
        objAHDetalle.tipoAccion        = "RELACION_REGISTRO_EJEMPLARES";
        objAHDetalle.id = id;


        objAHDetalle.campo_identificacion = $("#campo1").val();
        if ( $("#subcampo1").val()){
            objAHDetalle.subcampo_identificacion = $("#subcampo1").val();
        }

        objAHDetalle.campo_relacion = $("#campo2").val();
        if ( $("#subcampo2").val()){
        objAHDetalle.subcampo_relacion = $("#subcampo2").val();
        }
        objAHDetalle.preambulo_relacion = $("#preambulo").val();

        objAHDetalle.sendToServer();
    }

}

function updateRelacionRegistroEjemplares(responseText){
        var Messages=JSONstring.toObject(responseText);
        setMessages(Messages);
}
