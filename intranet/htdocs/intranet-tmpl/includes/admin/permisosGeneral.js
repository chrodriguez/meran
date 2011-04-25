//Para saber si se dio algun TODOS

// NUNCA CAMBIAR EL ORDEN FISICO DE LOS PERMISOS, ES POR PRIORIDAD

var tipoPermiso = "GENERAL";

function armarArregloDePermisosSave(){

    var arreglo = new Array();

    arreglo[0] = new permiso('preferencias');
    arreglo[1] = new permiso('reportes');
    arreglo[2] = new permiso('permisos');

    return(arreglo);
}

function armarArregloDePermisos(){
    superUserGranted = 0;
    var arreglo = new Array();

    arreglo[0] = 'preferencias';
    arreglo[1] = 'reportes';
    arreglo[2] = 'permisos';

    return(arreglo);
}
