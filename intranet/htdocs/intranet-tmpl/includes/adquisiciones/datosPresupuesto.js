/*
* LIBRERIA datosPresupuesto v 1.0.0
* Esta es una libreria creada para el sistema KOHA
* Contendran las funciones para editar un presupuesto
* Fecha de creación 12/11/2010
*
*/

var test;
//*********************************************Editar Proveedor********************************************* 

/*
function modificarDatosDePresupuesto(){
 
        $("#tablaResult").tabletojson({
            headers: "Renglon,Cantidad,Articulo,Precio Unitario, Total",
            attribHeaders: "{'customerID':'CustomerID','orderID':'OrderID'}",
            returnElement: "#hf",
            complete: function(x){
                alert(x);
            }
        })
    objAH                     = new AjaxHelper(updateDatosPresupuesto);
    objAH.url                 = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
    objAH.debug               = true;
    objAH.id_proveedor        = $('#proveedor').val();
 
   
    objAH.tipoAccion          = 'GUARDAR_MODIFICION_PROVEEDOR';
    objAH.sendToServer();
}*/
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



function updateDatosPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
        return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}



function changePage(ini){
    objAH.changePage(ini);
}
