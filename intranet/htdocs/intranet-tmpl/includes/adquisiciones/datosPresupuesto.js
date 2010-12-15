/*
* LIBRERIA datosPresupuesto v 1.0.0
* Esta es una libreria creada para el sistema KOHA
* Contendran las funciones para editar un presupuesto
* Fecha de creación 12/11/2010
*
*/


//*********************************************Editar Proveedor********************************************* 


function modificarDatosDePresupuesto(){
    objAH                     = new AjaxHelper(updateDatosPresupuesto);
    objAH.url                 = '/cgi-bin/koha/adquisiciones/presupuestoDB.pl';
    objAH.debug               = true;
    var $table = $('#tablaResult');
    $('tr', $table).each(function (i, item){
                $('td',$(this)).each(function(i,item){
                           alert(($(this).html()).val());
                       }); 
    });
    objAH.id_proveedor        = $('#proveedor').val();
    objAH.nombre              = 
   
    objAH.tipoAccion          = 'GUARDAR_MODIFICION_PROVEEDOR';
    objAH.sendToServer();
}


function updateDatosPresupuesto(responseText){
    if (!verificarRespuesta(responseText))
        return(0);
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
}



function changePage(ini){
    objAH.changePage(ini);
}
