/*
 * LIBRERIA generatePedidoCotizacion v 0.0.9
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para la generacion de pedidos de cotizacion
 * Fecha de creacion 07/02/2011
 *
 */ 


/******************************************************** AGREGAR PRESUPUESTO **************************************************/

var arreglo                  = new Array() //global, arreglo con las recomendaciones seleccionadas
var array_proveedores        = new Array() //global, arreglo de ids de proveedores a generar presupuesto
var array_recomendaciones    = new Array() //global, arreglo de ids de recomendaciones_detalle

/*function generatePresupuesto(){

    var proveedores = getProveedoresSelected()
    if(proveedores == ""){
        jConfirm(POR_FAVOR_SELECCIONE_PROVEEDORES_A_PRESUPUESTAR, function(){ })
        return false
    }
    if(checkSeleccionados(true)){

        objAH                       = new AjaxHelper(updateAgregarPresupuesto)
        objAH.url                   = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl'
        objAH.debug                 = true

        objAH.proveedores_array     = getProveedoresSelected()
        objAH.recomendaciones_array = getRecomendacionesSelected()
          
        objAH.tipoAccion            = 'AGREGAR_PRESUPUESTO'
        objAH.sendToServer()  
    }
}

function updateAgregarPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
            return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}

function getProveedoresSelected(){
    array_proveedores = new Array()
    var i = 0
    $('#proveedor option:selected').each(function(){  
        array_proveedores[i] = $(this).val()
        i++
    })
    return array_proveedores
}*/

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





/************************************************************ AGREGAR PEDIDO COTIZACION ************************************************/


function addPedidoCotizacion(){
  
    objAH                           = new AjaxHelper(updateAddPedidoCotizacion)
    objAH.url                       = '/cgi-bin/koha/adquisiciones/pedidoCotizacionDB.pl'
    objAH.debug                     = true

      
    objAH.tipoAccion                = 'AGREGAR_PEDIDO_COTIZACION'
    objAH.sendToServer()     
}

function updateAddPedidoCotizacion(){

}

/************************************************************ FIN - AGREGAR PEDIDO COTIZACION ******************************************/





/************************************************************ EXPORTACIONES  *********************************************/

function editar(){
    $('.editable').attr('disabled', false)
} 

function exportar(form_id){
    var proveedores = getProveedoresSelected()
    if(proveedores == ""){
        jConfirm(POR_FAVOR_SELECCIONE_PROVEEDORES_A_PRESUPUESTAR, function(){ })
        return false
    }
    if(checkSeleccionados(true)){
        $('#exportHidden').remove()
        $('.editable').attr('disabled', false) 
        $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportXLS' value='xls' />")
        $('#proveedores').val(proveedores)
        $('#' + form_id).submit()  
        $('.editable').attr('disabled', true) 
    }
 
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
        $('.editable').attr('disabled', false) 
        $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportPDF' value='pdf' />")
        if(checkSeleccionados(true)) { $('#' + form_id).submit() }
        $('.editable').attr('disabled', true) 
}
    
function submitFormDOC(form_id){
        $('#exportHidden').remove()
        $('.editable').attr('disabled', false) 
        $('#' + form_id).append("<input id='exportHidden' type='hidden' name='exportDOC' value='doc' />")
        if(checkSeleccionados(true)) { $('#' + form_id).submit() }
        $('.editable').attr('disabled', true) 
}

/************************************************************ FIN - EXPORTACIONES ********************************************/
