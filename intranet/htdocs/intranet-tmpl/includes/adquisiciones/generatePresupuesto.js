/*
 * LIBRERIA generatePresupuesto v 0.0.9
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para la generacion de presupuestos para la compra de ejemplares
 * Fecha de creacion 07/02/2011
 *
 */ 

/******************************************************** AGREGAR PRESUPUESTO **************************************************/

var arreglo                  = new Array() //global, arreglo con las recomendaciones seleccionadas
var array_proveedores        = new Array() //global, arreglo de ids de proveedores a generar presupuesto

function presupuestar(position){
    var pos = position
    objAH                       = new AjaxHelper(updatePresupuestar)
    objAH.url                   = '/cgi-bin/koha/adquisiciones/pedidoCotizacionDB.pl'
    objAH.debug                 = true
        
    objAH.pedido_cotizacion_id  = $('#pedido_cotizacion_id'+position).val()
 
    objAH.tipoAccion            = 'PRESUPUESTAR'
    objAH.sendToServer()  
    $('#pedidoCotizacion'+position).css('background-color', 'blue')
}
  
function updatePresupuestar(responseText){
    $('#presupuesto').html(responseText)
    $('#presupuesto').show()
}

function generatePresupuesto(pedido_cotizacion_id){

    var proveedores = getProveedoresSelected()
    if(proveedores == ""){
        jConfirm(POR_FAVOR_SELECCIONE_PROVEEDORES_A_PRESUPUESTAR, function(){ })
        return false
    }

    objAH                       = new AjaxHelper(updateAgregarPresupuesto)
    objAH.url                   = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl'
    objAH.debug                 = true

    objAH.proveedores_array     = getProveedoresSelected()
    objAH.pedido_cotizacion_id  = pedido_cotizacion_id
          
    objAH.tipoAccion            = 'AGREGAR_PRESUPUESTO'
    objAH.sendToServer()  
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
}


/************************************************************ FIN - AGREGAR PRESUPUESTO ******************************************/





/************************************************************ EXPORTACIONES  *********************************************/

/*function editar(){
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
}*/

/************************************************************ FIN - EXPORTACIONES ********************************************/
