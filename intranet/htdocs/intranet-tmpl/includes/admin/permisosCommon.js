var objAH = 0;
var superUserGranted = 0;

function armarPermisos(){
}

function seleccionoPerfil(combo){

    valueSelected = $(combo).val();
    return (valueSelected != 'custom');
}

function toggleGrantsDiv(state){

    checkBoxItems = $('#permisos_assign_chk > div > ul > li > input');
    for (y=0; y<checkBoxItems.length; y++){
        riskPart = $(checkBoxItems[y]).attr("disabled",state);
    }
}

function checkChecks(){

    var arreglo = armarArregloDePermisos();

    riskArray = new Array();
    riskArray['consulta'] = "low";
    riskArray['alta'] = "medium";
    riskArray['modif'] = "high";
    riskArray['baja'] = "high";
    riskArray['todos'] = "high";
    
    var dim = arreglo.length;

    for (x=0;x<dim;x++){
        checkBoxItems = $('#'+arreglo[x]+" > ul > li > input");
        checkTouched = false;
        for (y=0; y<checkBoxItems.length; y++){
            riskPart = checkBoxItems[y].id.split("_");
            if (riskPart.length > 2)
                riskPart[1] = riskPart[riskPart.length-1];
            risk = riskArray[riskPart[1]];
            if (!checkTouched){
                checkTouched = adviceGrant(checkBoxItems[y],arreglo[x],risk,true);
            }
          }
    }
}

function adviceGrant(checkBox,divID,risk,dontCallChecks){
    array = new Array();
    array['low']="permissionLow";
    array['medium']="permissionMedium";
    array['high']="permissionHigh";
    dontCallChecks = dontCallChecks?dontCallChecks:false;
    returnValue = false;

    isChecked = ($(checkBox).is(':checked'))?true:false;

    if (isChecked){
        $('#'+divID).addClass(array[risk]);
        returnValue = true;
    }else{
        $('#'+divID).removeClass(array[risk]);
        returnValue = false;
    }
    if (!dontCallChecks){
        checkChecks();
    }
    return(returnValue);

}

function obtenerPermisos(){
    objAH               = new AjaxHelper(updateObtenerPermisos);
    objAH.url           = '/cgi-bin/koha/admin/permisos/permisosDB.pl';
    objAH.cache         = false;
    objAH.showOverlay   = true;  
    objAH.nro_socio     = $('#nro_socio_hidden').val();
        if ($('#id_ui').val() != "SIN SELECCIONAR")
            objAH.id_ui = $('#id_ui').val();
        else
            objAH.id_ui = 0;
    comboPerfiles       = $('#perfiles');
    if (seleccionoPerfil(comboPerfiles)){
        objAH.perfil=comboPerfiles.val();
    }
    objAH.accion            = "OBTENER_PERMISOS_"+tipoPermiso;
    objAH.tipo_documento    = $('#tipo_nivel3_id').val();
    objAH.permiso           = $('#permisos').val();
    objAH.sendToServer();
}


function nuevoPermisoSHOW(){
    objAH               = new AjaxHelper(updateNuevoPermisoSHOW);
    objAH.url           = '/cgi-bin/koha/admin/permisos/permisosDB.pl';
    objAH.cache         = false;
    objAH.showOverlay   = true;    
    objAH.accion        = "SHOW_NUEVO_PERMISO_"+tipoPermiso;
    objAH.sendToServer();
}

function updateNuevoPermisoSHOW(responseText){
    $('#permisos_assign_chk').html(responseText);
}

function permiso(nombre){

    this.nombre = nombre;
    this.alta = ($('#'+nombre+'_alta').is(':checked'))?1:0;
    this.baja = ($('#'+nombre+'_baja').is(':checked'))?1:0;
    this.modif = ($('#'+nombre+'_modif').is(':checked'))?1:0;
    this.consulta = ($('#'+nombre+'_consulta').is(':checked'))?1:0;
    this.todos = ($('#'+nombre+'_todos').is(':checked'))?1:0;
    if (this.todos || this.baja || this.modif)
        superUserGranted = 1;

}

function actualizarPermisos(){
    objAH               = new AjaxHelper(updateActualizarPermisos);
    objAH.url           = '/cgi-bin/koha/admin/permisos/permisosDB.pl';
    objAH.cache         = false;
    objAH.showOverlay   = true;  
    objAH.nro_socio     = $('#nro_socio_hidden').val();

    if ($('#id_ui').val() != "SIN SELECCIONAR")
        objAH.id_ui = $('#id_ui').val();
    else
        objAH.id_ui = 0;

    objAH.accion="ACTUALIZAR_PERMISOS_"+tipoPermiso;
    objAH.tipo_documento = $('#tipo_nivel3_id').val();
    objAH.permisos = armarArregloDePermisosSave();
    confirmMessage = "\n\n";
    if (superUserGranted == 1)
        confirmMessage += SUPER_USER_GRANTED;
    else
        confirmMessage += PERMISSION_GRANTED;
	    jConfirm(confirmMessage,GRANT_PERMISSION_TITLE, function(confirmStatus){
	    	if (confirmStatus) objAH.sendToServer();
		});
}

function updateActualizarPermisos(responseText){
	var Messages=JSONstring.toObject(responseText);

	setMessages(Messages);
	
    obtenerPermisos();
}

function nuevoPermiso(){

    usuario = $('#nro_socio_hidden').val();
    if ($.trim(usuario) != ""){
        objAH               = new AjaxHelper(updateNuevoPermiso);
        objAH.url           = '/cgi-bin/koha/admin/permisos/permisosDB.pl';
        objAH.cache         = false;
        objAH.showOverlay   = true;  
        objAH.nro_socio     = $('#nro_socio_hidden').val();

        if ($('#id_ui').val() != "SIN SELECCIONAR")
            objAH.id_ui = $('#id_ui').val();
        else
            objAH.id_ui = 0;

        objAH.accion="NUEVO_PERMISO_"+tipoPermiso;
        objAH.tipo_documento = $('#tipo_nivel3_id').val();
        objAH.permisos = armarArregloDePermisosSave();
        confirmMessage = NEW_GRANT+"\n\n";
        if (superUserGranted == 1)
            confirmMessage += SUPER_USER_GRANTED;
        jConfirm(confirmMessage,GRANT_PERMISSION_TITLE, function(confirmStatus){if (confirmStatus) objAH.sendToServer();});
    }else{
        jAlert(NO_SE_SELECCIONO_NINGUN_USUARIO, ERROR_ITSELF);
        $('#usuario').focus();
        $.scrollTo('#usuario');
    }
}

function updateNuevoPermiso(responseText){
	var Messages=JSONstring.toObject(responseText);

	setMessages(Messages);
	
    obtenerPermisos();
}

function updateObtenerPermisos(responseText){
    $('#permisos_assign_chk').html(responseText);
    superUserGranted = 0;
    checkChecks();
    comboPerfiles = $('#perfiles');
//     if (seleccionoPerfil(comboPerfiles))
//         toggleGrantsDiv(true);
//     else
//         toggleGrantsDiv(false);
}



