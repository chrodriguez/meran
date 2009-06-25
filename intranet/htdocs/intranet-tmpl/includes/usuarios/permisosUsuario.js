function obtenerPermisos(){
    objAH=new AjaxHelper(updateObtenerPermisos);
    objAH.url= '/cgi-bin/koha/admin/permisosDB.pl';
    objAH.cache = false;
    objAH.nro_socio = $('#nro_socio_hidden').val();
    objAH.id_ui = $('#id_ui').val();
    objAH.accion="OBTENER_PERMISOS";
    objAH.tipo_documento = $('#tipo_nivel3_id').val();
    objAH.permiso = $('#permisos').val();
    objAH.sendToServer();
}

function updateObtenerPermisos(responseText){
    $('#permisos_assign_chk').html(responseText);
}

function permiso(nombre){

    this.nombre = nombre;
    this.alta = ($('#'+nombre+'_alta').is(':checked'))?1:0;
    this.baja = ($('#'+nombre+'_baja').is(':checked'))?1:0;
    this.modif = ($('#'+nombre+'_modif').is(':checked'))?1:0;
    this.consulta = ($('#'+nombre+'_consulta').is(':checked'))?1:0;
    this.todos = ($('#'+nombre+'_todos').is(':checked'))?1:0;

}


function armarArregloDePermisos(){

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
    objAH.id_ui = $('#id_ui').val();
    objAH.accion="ACTUALIZAR_PERMISOS";
    objAH.tipo_documento = $('#tipo_nivel3_id').val();
    objAH.permisos = armarArregloDePermisos();
    objAH.sendToServer();
}

function updateActualizarPermisos(responseText){
    obtenerPermisos();
}

