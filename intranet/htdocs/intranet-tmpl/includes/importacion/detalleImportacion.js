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
