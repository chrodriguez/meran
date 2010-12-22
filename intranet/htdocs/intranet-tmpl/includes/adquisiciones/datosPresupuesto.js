/*
* LIBRERIA datosPresupuesto v 1.0.0
* Esta es una libreria creada para el sistema KOHA
* Contendran las funciones para editar un presupuesto
* Fecha de creación 12/11/2010
*
*/

var test;
//*********************************************Editar Proveedor********************************************* 


function modificarDatosDePresupuesto(){
 
        $("#tablaResult").tabletojson({
            headers: "Renglon,Cantidad,Articulo,Precio Unitario, Total",
            attribHeaders: "{}",
            returnElement: "#table",
            complete: function(x){
                 objAH                     = new AjaxHelper(updateDatosPresupuesto);
                 objAH.url                 = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
                 objAH.debug               = true;
                 objAH.id_proveedor        = $('#proveedor').val();
                 objAH.table               = JSONstring.toObject(x);
                 objAH.tipoAccion          = 'GUARDAR_MODIFICACION_PRESUPUESTO';
                 objAH.sendToServer();
            }
        })
   
}
//     var table = $('#tablaResult');
//     var renglones= new Array();
//     
//     $('#tablaResult tr').each(function (i, item){
//                 renglones[i]=$(this).find("name=renglon");                 
//                 valor= renglones[i].val();              
//                 $('#tablaResult td').each(function(i,item){
          
/*                              alert(item.html().val());*/  
                      /* });*/ 
//   });
//     test = renglones;

function procesarPlanilla(){
                 objAH                     = new AjaxHelper(updateDatosPresupuesto);
                 objAH.url                 = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
                 objAH.debug               = true;
                 objAH.id_proveedor        = $('#proveedor').val();
                 objAH.tipoAccion          = 'GUARDAR_MODIFICACION_PRESUPUESTO';
                 objAH.sendToServer();

}



function updateDatosPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
        return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}

function mostrarPresupuesto(){
                 objAH                     = new AjaxHelper(updateMostrarPresupuesto);
                 objAH.url                 = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
                 objAH.debug               = true;
                 objAH.id_proveedor        = $('#proveedor').val(); 
                 objAH.filepath            = $('#myUploadFile').val();
                 objAH.tipoAccion          = 'MOSTRAR_PRESUPUESTO';
                 objAH.sendToServer();

}


function updateMostrarPresupuesto(responseText){
   $('#presupuesto').html(responseText);
}

function changePage(ini){
    objAH.changePage(ini);
}
