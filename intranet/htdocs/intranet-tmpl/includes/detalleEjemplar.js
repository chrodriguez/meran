function generarForm(id1, id2){

    if(seleccionoAlgo("checkEjemplares"+id2)){
        var id3_array   = recuperarSeleccionados("checkEjemplares"+id2);
        var html        = "";

        if(id3_array.length > 1){

            for (i = 0; i < id3_array.length; i++){
                html = html  + "<input type='hidden' id='n3_" + i + "' name='n3_" + i + "' value='" + id3_array[i] + "' />"
            }

            html = html  + "<input type='hidden' id='id1' name='id1' value='" + id1 + "' />"
            html = html  + "<input type='hidden' id='id2' name='id2' value='" + id2 + "' />"
            html = html  + "<input type='hidden' id='tipoAccion' name='tipoAccion' value='MODIFICAR_NIVEL_3_ALL' />";
            html = html  + "<input type='hidden' id='token' name='token' value='[% token %]' />";
          
            $("#edicion_grupal"+id2).html(html);

            $("#edicion_grupal"+id2).submit();
        } else {
            jAlert(DEBE_SELECCIONAR_MAS_DE_UN_EJEMPLAR);
        }
    }
}

function inicializar(){
	ID_N1=0; //para saber el id del nivel 1
	ID_N2=0; //para saber el id del nivel 2
	ID_N3=0; //para saber el id del nivel 3
}

// function borrarNivel1(id1) implementado en catalogacion.js

function updateBorrarN1(responseText){
    var info=JSONstring.toObject(responseText);  
    //se borrar el nivel 1 y en cascada nivel 2 y 3 si esta permitido
    //se refresca la info   
    var Messages = info.Message_arrayref;
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        //oculto todo el registro con los grupos y sus items
        $('#detalleComun').slideUp('slow');
        //borro el contenido
        $('#detalleComun').html('');
    }
}

// function borrarN2(id2) //esta implementado en catalogacion.js

function updateBorrarN2(responseText){
    var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        //oculto todo el grupo con los items
        $('#grupo'+objAH.id2).slideUp('slow');
        //borro el contenido
        $('#fieldset_grupo'+objAH.id2).html('');
    }
}

function borrarN3(id2, id3){
//id2 es necesario para luego de eliminar un ejemplar, se debe refrescar los ejemplares del nivel3

    jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_TITLE, function(confirmStatus){if (confirmStatus) {
		ID_N2               = id2;
		objAH               = new AjaxHelper(updateBorrarN3);
		objAH.debug         = true;
        objAH.showOverlay   = true;
		objAH.url=URL_PREFIX+"/catalogacion/estructura/estructuraCataloDB.pl";
 		objAH.id3_array     = [id3];
		objAH.nivel         = 3;
		objAH.itemtype      = $("#id_tipo_doc").val();
		objAH.tipoAccion    = "ELIMINAR_NIVEL";
		objAH.sendToServer();
	}
});
}

function updateBorrarN3(responseText){
    var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
	    ejemplaresDelGrupo(ID_N2);
    }
}

//muestra los ejemplares del grupo
function ejemplaresDelGrupo(id2){

	objAH               = new AjaxHelper(updateEjemplaresDelGrupo);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url=URL_PREFIX+'/catalogacion/estructura/estructuraCataloDB.pl';
	objAH.id2           = id2;
	objAH.tipoAccion    = 'MOSTRAR_DETALLE_NIVEL3';
	//se envia la consulta
	objAH.sendToServer();

}

function updateEjemplaresDelGrupo(responseText){
	$('#ejemplaresDelGrupo'+objAH.id2).html(responseText);
	zebra('tablaResult');
}


function buscarUsuario(id2, id3){
	objAH                   = new AjaxHelper(updateBuscarUsuario);
	objAH.debug             = true;
    objAH.showOverlay       = true;
    objAH.url=URL_PREFIX+'/utils/pop_ups.pl';
    objAH.pop_up_template   = 'buscar_usuario'; 
	objAH.debug             = true;
	objAH.sendToServer();

	items_array[0]=id3;
 	ID_N2= id2;
}

function updateBuscarUsuario(responseText){

    $('#basic-modal-content').html(responseText);
    $('#basic-modal-content').modal({   containerCss:{
            backgroundColor:"#fff",
    //         borderColor:"#0063dc",
            height:200,
            padding:0,
            width:600
        },
    });

}

/*=============================================================FIN====REVISADO================================================================*/

function detalleMARC(id3){
	objAH               = new AjaxHelper(updateInfoMARC);
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url			= URL_PREFIX+"/busquedas/MARCDetalle.pl";
	objAH.id3           = id3;
	//se envia la consulta
	objAH.sendToServer();
}

function updateInfoMARC(responseText){
	$('#detalleComun').slideUp("slow");
	$('#detalleMARC').html(responseText);
	$('#detalleMARC').show();
	scrollTo('detalleMARC');
}

function verDivs(){
	$('#detalleComun').slideDown("slow");
	$('#detalleComun').show();
	$('#detalleMARC').slideUp("slow");
// 	scrollTo('ejemplaresDelGrupo'+ID_N2);
}

/*************************************************CIRCULACUION***************************************************/
// ESTO PARECE QUE NO SE VA A USAR
function objeto_datos(){
	this.array_ids3;
	this.usuario;
	this.id3;
	this.accion;
}


/******************************************CIRCULACUION DESDE EL DETALLE****************************************/
var items_array = new Array();
// parche, ver si se puede hacer mejor
var grupo;


function renovarPrestamo(userId,userNom,id2,id_prestamo){
	
	USUARIO             = new objeto_usuario();
	USUARIO.ID          = userId;
	USUARIO.text        = userNom;
	objAH               = new AjaxHelper(generaDivRenovacion); //generaDivRenovacion esta en circulacion.js
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url			= URL_PREFIX+'/circ/circulacionDB.pl';
	objAH.tipoAccion    = 'RENOVACION';
	array               = new Array;
	array[0]            = id_prestamo;
	objAH.datosArray    = array;
	objAH.nro_socio     = USUARIO.ID;
	//se envia la consulta
	objAH.sendToServer();
	//guardo el id2 para actualizar los ejemplares del grupo, por ahora lo hago asi!!!!!!!
	ID_N2= id2;
}

function devolverPrestamo(userId,userNom,id2,id_prestamo){

	array               = new Array;
	array[0]            = id_prestamo;
	USUARIO             = new objeto_usuario();
	USUARIO.ID          = userId;
	USUARIO.text        = userNom;

	objAH               = new AjaxHelper(generaDivDevolucion); //llama a generar div de ciculacion.js
	objAH.debug         = true;
    objAH.showOverlay   = true;
	objAH.url			= URL_PREFIX+'/circ/circulacionDB.pl';
	objAH.tipoAccion    = 'DEVOLUCION';
	objAH.datosArray    = array;
	objAH.nro_socio     = USUARIO.ID;
	//se envia la consulta
	objAH.sendToServer();
	//guardo el id2 para actualizar los ejemplares del grupo, por ahora lo hago asi!!!!!!!
	ID_N2               = id2;
}

/*
* REDEFINIDA, se encuentra definida en circulacion.js
*/
function updateInfoRenovar(responseText){
	cancelarDiv();

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.messages;
	var ticketsArray= infoHash.tickets;
	//Mensajes 
	for(i=0; i<messageArray.length;i++){
  		setMessages(messageArray[i]);
	}
	//Tickets si hay
	for(i=0; i<ticketsArray.length;i++){
		imprimirTicket(ticketsArray[i].ticket,i);
	}

	ejemplaresDelGrupo(ID_N2);
	inicializar();
}

/*
* REDEFINIDA, se encuentra definida en circulacion.js
*/
function updateInfoDevolver(responseText){
	cancelarDiv();

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.Messages_arrayref;
	setMessages(messageArray);

	ejemplaresDelGrupo(ID_N2);
	inicializar();
}

function confirmarPrestamo(){

	if( $('#campoUsuario').val() != ''){
		objAH               = new AjaxHelper(generaDivPrestamo);
		objAH.debug         = true;
        objAH.showOverlay   = true;
		objAH.url			= URL_PREFIX+'/circ/circulacionDB.pl';
		objAH.tipoAccion    = 'CONFIRMAR_PRESTAMO';
		objAH.datosArray    = items_array;
		objAH.nro_socio     = USUARIO.ID;
		//se envia la consulta
		objAH.sendToServer();
		$.modal.close();
	}else{
		jAlert(INGRESE_EL_USUARIO);
		$('#campoUsuario').focus();
	}
}


//esta funcion esta REDEFINIDA de la libreria de circulacion.js, es invocada desde la funcion prestar()
function updateInfoPrestarReserva(responseText){
	cancelarDiv();

	var infoHash= JSONstring.toObject(responseText);
	var messageArray= infoHash.messages;
	var ticketsArray= infoHash.tickets;
	var mensajes= '';
	for(var i=0; i<messageArray.length;i++){
		imprimirTicket(ticketsArray[i].ticket,i);
  		setMessages(messageArray[i]);
	}
	ejemplaresDelGrupo(ID_N2);
}


 function generarVariasEtiquetas(){
//             var selectedItems = new Array();
//             $('#checkEjemplares:checked').each(function(){
//                                                   selectedItems.push($(this).val());
//                                             });
//                                             
//             if (selectedItems.length == 0) {
//                   jAlert('Debe seleccionar al menos un ejemplar','Advertencia de catalogo');
//             } else {  
//                 var id1= selectedItems[0];
//                 var id2= selectedItems[selectedItems.length - 1];
//                 window.open (URL_PREFIX+"/catalogacion/barcode_gen.pl?token="+token+"&id1="+id1+"&id2="+id2,"width=650,height=550,status=no,location=no,menubar=no,personalbar=no,resizable=no,scrollbars=no");
//             }
             var selectedItems = new Array();
                $('.icon_seleccionar:checked').each(function(){
                                                      selectedItems.push($(this).val());
                                                });
             if (selectedItems.length == 0) {
                        jAlert('Debe seleccionar al menos un ejemplar','Advertencia de catalogo');
             }else{  
                    $('#tablaEjemplares').submit();
             }

 }


function generarEtiqueta(id3,barcode){
	window.open (URL_PREFIX+"/catalogacion/barcode_gen.pl?token="+token+"&id="+id3, "Barcode "+barcode,"width=650,height=550,status=no,location=no,menubar=no,personalbar=no,resizable=no,scrollbars=no");
	
}