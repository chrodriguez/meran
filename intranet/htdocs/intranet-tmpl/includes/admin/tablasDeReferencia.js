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


function mostrarReferencias(tabla,value_id){
    objAH=new AjaxHelper(updateObtenerTabla);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="MOSTRAR_REFERENCIAS";
    objAH.alias_tabla = tabla;
    objAH.value_id = value_id;
    objAH.sendToServer();
}


function asignarReferencia(tabla,referer_involved,related_id){
    objAH=new AjaxHelper(updateObtenerTabla);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="ASIGNAR_REFERENCIA";
    objAH.referer_involved= referer_involved;
    objAH.alias_tabla = tabla;
    objAH.related_id = related_id;
    objAH.sendToServer();
}

function asignarEliminarReferencia(tabla,referer_involved,related_id){
    objAH=new AjaxHelper(updateObtenerTabla);
    objAH.url= '/cgi-bin/koha/admin/referencias/referenciasDB.pl';
    objAH.cache = false;

    objAH.accion="ASIGNAR_Y_ELIMINAR_REFERENCIA";
    objAH.alias_tabla = tabla;
    objAH.referer_involved= referer_involved;
    objAH.related_id = related_id;
    objAH.sendToServer();
}
