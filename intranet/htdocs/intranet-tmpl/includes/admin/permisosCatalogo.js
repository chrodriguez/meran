//Para saber si se dio algun TODOS

// NUNCA CAMBIAR EL ORDEN FISICO DE LOS PERMISOS, ES POR PRIORIDAD


var tipoPermiso = "CATALOGO";

function armarArregloDePermisosSave(){

    var arreglo = new Array();
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

function armarArregloDePermisos(){
    superUserGranted = 0;
    var arreglo = new Array();
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

    return(arreglo);
}
