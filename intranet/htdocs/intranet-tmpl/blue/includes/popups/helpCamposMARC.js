/*
 * LIBRERIA helpCamposMARC v 1.0.0
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 * 
 * El fin de la libreria es centralizar el manejo de la ventan de ayuda de campos MARC
 */

function abrirVentanaHelperMARC(){
    objAH=new AjaxHelper(updateAbrirVentanaHelperMARC);
// FIXME parametrizar /blue/
    objAH.url='/intranet-tmpl/blue/includes/popups/helpCamposMARC.inc';
    objAH.debug= true;
    objAH.sendToServer();
}

function updateAbrirVentanaHelperMARC(responseText){
//se crea el objeto que maneja la ventana para modificar los/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl' datos del usuario
    vHelperMARC=new WindowHelper({draggable: false, opacity: true});
    vHelperMARC.debug= true;
    vHelperMARC.html=responseText;
    vHelperMARC.titulo= 'Ayuda campos MARC';
    vHelperMARC.draggable= true;
    vHelperMARC.create(); 
    vHelperMARC.dimmer_On= false;
    vHelperMARC.height('60%');
    vHelperMARC.width('50%');
    vHelperMARC.open();
}