// NUNCA CAMBIAR EL ORDEN FISICO DE LOS PERMISOS, ES POR PRIORIDAD

var tipoPermiso = "CIRCULACION";

function armarArregloDePermisosSave(){
    superUserGranted = 0;
    var arreglo = new Array();
    arreglo[0] = new permiso('prestamos');
    arreglo[1] = new permiso('circ_opac');


    return(arreglo);
}

function armarArregloDePermisos(){
    superUserGranted = 0;
    var arreglo = new Array();
    arreglo[0] = 'prestamos';
    arreglo[1] = 'circ_opac';


    return(arreglo);
}
