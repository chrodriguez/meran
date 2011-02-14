/*
 * LIBRERIA generatePresupuesto v 0.0.9
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para la generacion de presupuestos para la compra de ejemplares
 * Fecha de creacion 07/02/2011
 *
 */ 


/******************************************************** AGREGAR PRESUPUESTO **************************************************/

var arreglo                  = new Array() // global, arreglo con las recomendaciones seleccionadas
var array_proveedores        = new Array() //global, arreglo de ids de proveedores a generar presupuesto
var array_recomendaciones    = new Array() //global, arreglo de ids de recomendaciones_detalle

function generatePresupuesto(){

    objAH                       = new AjaxHelper(updateAgregarPresupuesto);
    objAH.url                   = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
    objAH.debug                 = true;

    objAH.proveedores_array     = getProveedoresSelected();
    objAH.recomendaciones_array = getRecomendacionesSelected();
      
    objAH.tipoAccion          = 'AGREGAR_PRESUPUESTO';
    objAH.sendToServer();       
}

function updateAgregarPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}

function getProveedoresSelected(){
    var i = 0
    $('#proveedor option:selected').each(function(){  
        array_proveedores[i] = $(this).val()
        i++
    })
    return array_proveedores
}

function getRecomendacionesSelected(){
    var i = 0
    $('.activo').each(function(){ 
        if($(this).attr('checked') == true){
            $(this).attr('name') // activo1 , activo2 , etc 
            var pos = $(this).attr('name').charAt(6)
            array_recomendaciones[i] = $('#id_recomendacion_detalle'+pos).val()
            i++
        }
    })  
    return array_recomendaciones
}


/************************************************************ FIN - AGREGAR PRESUPUESTO ******************************************/




/************************************************************ EXPORTACIONES  *********************************************/


function exportar(form_id){
    //TODO exportar a excel, usando el template de recomendaciones, pero pasando los ids de los proveedores
    var proveedores = getProveedoresSelected()
    $('#exportHidden').remove()
    $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportXLS' value='xls' />")
    //$('#' + form_id).append("<input type='hidden' name='data' value='getProveedoresSelected()' />")
    $('#' + form_id).submit()   
}

// checkea que se seleccionen recomendaciones para exportar, o para generar el presupuesto
function checkSeleccionados(bool){
    if(bool){
        var checkeados = 0
        $('.activo').each(function() {
             if($(this).attr('checked')){ 
                arreglo[checkeados] = $(this).val()
                 checkeados++
             }
        });
        if(checkeados == 0){
            jConfirm(POR_FAVOR_SELECCIONE_LAS_RECOMENDACIONES, function(){ })
            return false
        }else{
            return true
        }   
    }         
}
    
function submitFormPDF(form_id) {
        $('#exportHidden').remove()
        $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportPDF' value='pdf' />")
        if(checkSeleccionados(true)) { $('#' + form_id).submit() }
}
    
function submitFormDOC(form_id){
        $('#exportHidden').remove()
        $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportDOC' value='doc' />")
        if(checkSeleccionados(true)) { $('#' + form_id).submit() }
}

/************************************************************ FIN - EXPORTACIONES ********************************************/
