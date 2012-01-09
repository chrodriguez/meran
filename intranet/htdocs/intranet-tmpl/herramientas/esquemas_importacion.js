function nuevoEsquemaImportacion(title){

	objAH               = new AjaxHelper(updateNuevoEsquemaImportacion);
    objAH.url           = URL_PREFIX+'/herramientas/importacion/esquemas_importacionDB.pl';
    objAH.cache         = false;
    objAH.showOverlay   = true;  
    objAH.accion        = "NUEVO_ESQUEMA";
    objAH.esquema_title = title;
    objAH.sendToServer();	
}

function updateNuevoEsquemaImportacion(responseText){
    $('#esquema_result').html(responseText);
    scrollTo('esquema_result');
}

function showEsquemaImportacion(){
	
    objAH               = new AjaxHelper(updateShowEsquemaImportacion);
    objAH.url           = URL_PREFIX+'/herramientas/importacion/esquemas_importacionDB.pl';
    objAH.cache         = false;
    objAH.showOverlay   = true;  
        if ($('#esquemaImportacion').val() != "-1")
            objAH.esquema = $('#esquemaImportacion').val();
        else
            objAH.esquema = 0;
        
    objAH.accion            = "OBTENER_ESQUEMA";
    objAH.sendToServer();	
}

function updateShowEsquemaImportacion(responseText){
    $('#esquema_result').html(responseText);
    scrollTo('esquema_result');
}

function agregarCampo(id_esquema){
    objAH=new AjaxHelper(updateAgregarCampo);
    objAH.url           = URL_PREFIX+'/herramientas/importacion/esquemas_importacionDB.pl';
    objAH.cache = false;
    objAH.showOverlay       = true;
    objAH.accion="AGREGAR_CAMPO";
    objAH.esquema = id_esquema;
    
    objAH.sendToServer();
}


function updateAgregarCampo(responseText){

    $('#esquema_result').html(responseText);
}

function eliminarEsquemaRow(id_esquema){

    objAH=new AjaxHelper(updateAgregarCampo);
    objAH.url           = URL_PREFIX+'/herramientas/importacion/esquemas_importacionDB.pl';
    objAH.cache = false;
    objAH.showOverlay       = true;
    objAH.accion="ELIMINAR_CAMPO";
    objAH.id_row = id_esquema;
    
    objAH.sendToServer();
    
}