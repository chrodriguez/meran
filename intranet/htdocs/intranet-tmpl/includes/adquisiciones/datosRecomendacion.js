/*
* LIBRERIA datosPresupuesto v 1.0.0
* Esta es una libreria creada para el sistema KOHA
* Contendran las funciones para editar un presupuesto
* Fecha de creación 12/11/2010
*
*/

var test;


function presupuestosParaRecomendacion(){
                 objAH                     = new AjaxHelper(updatePresupuestosParaRecomendacion);
                 objAH.url                 = '/cgi-bin/koha/adquisiciones/recomendacionesDB.pl';
                 objAH.debug               = true;
                 objAH.recomendacion       = $('#combo_recomendaciones').val();
                 objAH.tipoAccion          = 'MOSTRAR_PRESUPUESTOS_REC';
                 objAH.sendToServer();
}


function updatePresupuestosParaRecomendacion(responseText){
   $('#presupuestos').html(responseText);
}