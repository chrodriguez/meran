/*
 * LIBRERIA generatePresupuesto v 0.0.9
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para la generacion de presupuestos para la compra de ejemplares
 * Fecha de creacion 07/02/2011
 *
 */ 

var arreglo = new Array() // global, arreglo con las recomendaciones seleccionadas


/******************************************************** AGREGAR PRESUPUESTO **************************************************/

var array_proveedores        = new Array() //global, arreglo de ids de proveedores a generar presupuesto
var array_recomendaciones    = new Array() //global, arreglo de ids de recomendaciones_detalle

function generatePresupuesto(){

    objAH                       = new AjaxHelper(updateAgregarPresupuesto);
    objAH.url                   = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
    objAH.debug                 = true;

    objAH.proveedores_array     = getProveedoresSelected();
    objAH.recomendaciones_array = getRecomendacionesSelected();
      
    objAH.tipoAccion          = 'AGREGAR_PRESUPUESTO';
    //objAH.sendToServer();       
}

function updateAgregarPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}

//TODO ver esto
function getProveedoresSelected(){
    var i = 0
    $('#proveedor:selected').each(function(){  
        alert('entro')
        // para no agregar en el arreglo el option "SIN SELECCIONAR"
        if($(this).val() != ""){
            array_proveedores[i] = $(this).val()
            i++
            alert($(this).val())
        }
    })
    return array_proveedores
}

function getRecomendacionesSelected(){
    var i = 0
    //alert('entra')
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






// checkea que se seleccionen recomendaciones para exportar
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
