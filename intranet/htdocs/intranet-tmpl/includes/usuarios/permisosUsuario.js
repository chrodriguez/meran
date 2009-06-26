//Para saber si se dio algun TODOS
superUserGranted = 0;

function seleccionoPerfil(combo){

    valueSelected = $(combo).val();
    return (valueSelected != 'custom');
}


function armarPermisos(){
}

function profileSelection(combo){

    valueSelected = $(combo).val();
    if (seleccionoPerfil(combo))
        armarPermisos(valueSelected);
}

function adviceGrant(checkBox,divID,risk,dontCallChecks){
    array = new Array();
    array['low']="green";
    array['medium']="blue";
    array['high']="red";
    dontCallChecks = dontCallChecks?dontCallChecks:false;
    returnValue = false;

    isChecked = ($(checkBox).is(':checked'))?true:false;

    if (isChecked){
        $('#'+divID).css("background-color",array[risk]);
        returnValue = true;
    }else{
        $('#'+divID).css("background-color","");
    }
    if (!dontCallChecks){
        checkChecks();
    }
    return(returnValue);

}

function checkChecks(){

    arreglo = new Array();
    arreglo[0] = 'datos_nivel1';
    arreglo[1] = 'datos_nivel2';
    arreglo[2] = 'datos_nivel3';
    arreglo[3] = 'estantes_virtuales';
    arreglo[4] = 'estructura_catalogacion_n1';
    arreglo[5] = 'estructura_catalogacion_n2';
    arreglo[6] = 'estructura_catalogacion_n3';
    arreglo[7] = 'tablas_de_refencia';
    arreglo[8] = 'control_de_autoridades';
    arreglo[9] = 'usuarios';
    arreglo[10] = 'sistema';
    arreglo[11] = 'undefined';

    riskArray = new Array();
    riskArray['consulta'] = "low";
    riskArray['alta'] = "medium";
    riskArray['modif'] = "high";
    riskArray['baja'] = "high";
    riskArray['todos'] = "high";
    for (x=0;x<12;x++){
        checkBoxItems = $('#'+arreglo[x]+" > span > input");
        checkTouched = false;
        for (y=0; y<checkBoxItems.length; y++){
            riskPart = checkBoxItems[y].id.split("_");
            if (riskPart.length > 2)
                riskPart[1] = riskPart[riskPart.length-1];
            risk = riskArray[riskPart[1]];
            if (!checkTouched)
                checkTouched = adviceGrant(checkBoxItems[y],arreglo[x],risk,true);
          }
    }
}


function obtenerPermisos(){
    objAH=new AjaxHelper(updateObtenerPermisos);
    objAH.url= '/cgi-bin/koha/admin/permisosDB.pl';
    objAH.cache = false;
    objAH.nro_socio = $('#nro_socio_hidden').val();
        if ($('#id_ui').val() != "SIN SELECCIONAR")
            objAH.id_ui = $('#id_ui').val();
        else
            objAH.id_ui = 0;
    comboPerfiles = $('#perfiles');
    if (seleccionoPerfil(comboPerfiles)){
        objAH.perfil=comboPerfiles.val();
    }
    objAH.accion="OBTENER_PERMISOS";
    objAH.tipo_documento = $('#tipo_nivel3_id').val();
    objAH.permiso = $('#permisos').val();
    objAH.sendToServer();
}


function toggleGrantsDiv(state){

    checkBoxItems = $('#permisos_assign_chk > div > span > input');
    for (y=0; y<checkBoxItems.length; y++){
        riskPart = $(checkBoxItems[y]).attr("disabled",state);
    }
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

function nuevoPermisoSHOW(){
    objAH=new AjaxHelper(updateNuevoPermisoSHOW);
    objAH.url= '/cgi-bin/koha/admin/permisosDB.pl';
    objAH.cache = false;
    objAH.accion="SHOW_NUEVO_PERMISO";
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
    if (this.todos)
        superUserGranted = 1;

}


function armarArregloDePermisos(){
    superUserGranted = 0;
    arreglo = new Array();
    arreglo[0] = new permiso('datos_nivel1');
    arreglo[1] = new permiso('datos_nivel2');
    arreglo[2] = new permiso('datos_nivel3');
    arreglo[3] = new permiso('estantes_virtuales');
    arreglo[4] = new permiso('estructura_catalogacion_n1');
    arreglo[5] = new permiso('estructura_catalogacion_n2');
    arreglo[6] = new permiso('estructura_catalogacion_n3');
    arreglo[7] = new permiso('tablas_de_refencia');
    arreglo[8] = new permiso('control_de_autoridades');
    arreglo[9] = new permiso('usuarios');
    arreglo[10] = new permiso('sistema');
    arreglo[11] = new permiso('undefined');

    return(arreglo);
}


function actualizarPermisos(){
    objAH=new AjaxHelper(updateActualizarPermisos);
    objAH.url= '/cgi-bin/koha/admin/permisosDB.pl';
    objAH.cache = false;
    objAH.nro_socio = $('#nro_socio_hidden').val();

    if ($('#id_ui').val() != "SIN SELECCIONAR")
        objAH.id_ui = $('#id_ui').val();
    else
        objAH.id_ui = 0;

    objAH.accion="ACTUALIZAR_PERMISOS";
    objAH.tipo_documento = $('#tipo_nivel3_id').val();
    objAH.permisos = armarArregloDePermisos();
    confirmMessage = "\n\n";
        if (superUserGranted == 1)
            confirmMessage += SUPER_USER_GRANTED;
        var is_confirmed = jConfirm(confirmMessage,'Advertencia de cesión de Permisos');
    if (is_confirmed) {
        objAH.sendToServer();
    }
}

function updateActualizarPermisos(responseText){
    obtenerPermisos();
}

function nuevoPermiso(){

    usuario = $('#nro_socio_hidden').val();
    if ($.trim(usuario) != ""){
        objAH=new AjaxHelper(updateNuevoPermiso);
        objAH.url= '/cgi-bin/koha/admin/permisosDB.pl';
        objAH.cache = false;
        objAH.nro_socio = $('#nro_socio_hidden').val();

        if ($('#id_ui').val() != "SIN SELECCIONAR")
            objAH.id_ui = $('#id_ui').val();
        else
            objAH.id_ui = 0;

        objAH.accion="NUEVO_PERMISO";
        objAH.tipo_documento = $('#tipo_nivel3_id').val();
        objAH.permisos = armarArregloDePermisos();
        confirmMessage = NEW_GRANT+"\n\n";
        if (superUserGranted == 1)
            confirmMessage += SUPER_USER_GRANTED;
        var is_confirmed = jConfirm(confirmMessage,'Advertencia de cesión de Permisos');
        if (is_confirmed) {
            objAH.sendToServer();
        }
    }else{
        jAlert(NO_SE_SELECCIONO_NINGUN_USUARIO, 'Error');
        $('#usuario').focus();
        $.scrollTo('#usuario');
    }
}

function updateNuevoPermiso(responseText){
    obtenerPermisos();
}