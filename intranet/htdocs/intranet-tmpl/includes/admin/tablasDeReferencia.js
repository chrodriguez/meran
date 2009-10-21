function obtenerTabla(){
    objAH=new AjaxHelper(updateObtenerTabla);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="OBTENER_TABLAS";
    objAH.alias_tabla = $('#tablas_ref').val();
    objAH.sendToServer();
}


function updateObtenerTabla(responseText){

    $('#detalle_tabla').html(responseText);

}

function obtenerTablaFiltrada(){
    objAH=new AjaxHelper(updateObtenerTablaFiltrada);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="OBTENER_TABLAS";
    objAH.alias_tabla = $('#tablas_ref').val();
    objAH.filtro = $.trim($('#search_tabla').val());
    objAH.sendToServer();
}


function updateObtenerTablaFiltrada(responseText){

    $('#detalle_tabla').html(responseText);

}

function agregarRegistro(tabla){
    objAH=new AjaxHelper(updateAgregarRegistro);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="AGREGAR_REGISTRO";
    objAH.alias_tabla = tabla;
    objAH.sendToServer();
}


function updateAgregarRegistro(responseText){

    $('#detalle_tabla').html(responseText);

}


function mostrarReferencias(tabla,value_id){
    objAH=new AjaxHelper(updateObtenerTabla);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="MOSTRAR_REFERENCIAS";
    objAH.alias_tabla = tabla;
    objAH.value_id = value_id;
    objAH.sendToServer();
}


function asignarReferencia(tabla,related_id,referer_involved){
    $('#fieldset_tablaResult_involved').addClass("warning");
    jConfirm(TITLE_FIRST_ASSIGN_REFERENCIES+referer_involved+TITLE_TO_ASSIGN_REFERENCIES+related_id,"Titulo",function(confirmed){
        if (confirmed){
            objAH=new AjaxHelper(updateObtenerTabla);
            objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
            objAH.cache = false;
            objAH.accion="ASIGNAR_REFERENCIA";
            objAH.referer_involved= referer_involved;
            objAH.alias_tabla = tabla;
            objAH.related_id = related_id;
            objAH.sendToServer();
        }
        $('#fieldset_tablaResult_involved').removeClass("warning");
    });
}

function asignarEliminarReferencia(tabla,related_id,referer_involved){
    $('#fieldset_tablaResult_involved').addClass("warning");
    jConfirm(TITLE_FIRST_ASSIGN_DELETE_REFERENCIES+referer_involved+TITLE_TO_ASSIGN_REFERENCIES+related_id,"Titulo",function(confirmed){
        if (confirmed){
            objAH=new AjaxHelper(updateObtenerTabla);
            objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
            objAH.cache = false;
            objAH.accion="ASIGNAR_Y_ELIMINAR_REFERENCIA";
            objAH.alias_tabla = tabla;
            objAH.referer_involved= referer_involved;
            objAH.related_id = related_id;
            objAH.sendToServer();
        }
        $('#fieldset_tablaResult_involved').removeClass("warning");
    });

}
