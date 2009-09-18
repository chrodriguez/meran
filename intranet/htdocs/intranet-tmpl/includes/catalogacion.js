/*
 * LIBRERIA catalogacion v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Contendran las funciones para permitir la circulacion en el sistema
 * Las siguientes librerias son necesarias:
 *	<script src="/includes/jquery/jquery.js"></script>
 *	<script src="/includes/json/jsonStringify.js"></script>
 *	<script src="/includes/AjaxHelper.js"></script>
 *	<script src="/intranet-tmpl/includes/util.js"></script>
 *
 */

//************************************************REVISADO******************************************************************

var ID_N1=0; //para saber el id del nivel 1
var ID_N2=0; //para saber el id del nivel 2
var ID_N3=0; //para saber el id del nivel 3
var TAB_INDEX= 0;//tabindex para las componentes
//arreglo de objetos componentes, estos objetos son actualizados por el usuario y luego son enviados al servidor
var COMPONENTES_ARRAY= new Array();
//arreglo con datos del servidor para modificar las componentes
var DATA_ARRAY = new Array();
var MODIFICAR = 0;
var ID3_ARRAY = new Array(); //para enviar 1 o mas ID_N3 para agregar/modificar/eliminar
var BARCODES_ARRAY = new Array(); //para enviar 1 o mas barcodes
var _NIVEL_ACTUAL= 1; //para mantener el nivel que se esta procesando
var _message= CAMPO_NO_PUEDE_ESTAR_EN_BLANCO;
var HASH_RULES = new Array(); //para manejar las reglas de validacion del FORM dinamicamente
var HASH_MESSAGES = new Array();
var AGREGAR_COMPLETO = 1; //flag para verificar si se esta por agregar un documento desde el nivel 1 o no

function agrearAHash (HASH, name, value){
    HASH[name] = value;
}

//objeto generico para enviar parametros a cualquier funcion, se le van creando dinamicamente los mismos
function objeto_params(){
	
}

function inicializarSideLayers(){
    arreglo = $('#nivel2>p');
    for (x = 0; x<arreglo.length; x++){
        $(arreglo[x]).removeClass('activeLayer');
        $(arreglo[x]).addClass('nivel2Selected');
    }
}

function toggleClass(layer){
    inicializarSideLayers();
    $(layer).addClass('activeLayer');
}

function inicializar(){

	_freeMemory(COMPONENTES_ARRAY);
	COMPONENTES_ARRAY= [];
	_freeMemory(DATA_ARRAY);
	DATA_ARRAY= [];
	_freeMemory(BARCODES_ARRAY);
	BARCODES_ARRAY= [];
	TAB_INDEX= 0;
}

function _freeMemory(array){
	for(var i=0;i<array.length;i++){
		delete array[i];
	}
}

function _existeEnArray(array, elemento){
	var cant=0;

	for(var i=0;i<array.length;i++){
		if( jQuery.trim(array[i]) == jQuery.trim(elemento) ){
			cant++;
			if(cant > 1){
			//el elemento existe mas de 1 vez, esta repetido
				return 1;	
			}			
		}
	}
	return 0;
}

function verificarAgregarDocumentoN3(){
	var repetidos_array= new Array();
	var existe= 0;

	if(_getBarcodes()){
		//verifico que los barcodes no esten repetidos
		for(var i=0;i<BARCODES_ARRAY.length;i++){
			if( _existeEnArray(BARCODES_ARRAY, BARCODES_ARRAY[i]) ){
				existe= 1;
				repetidos_array.push(BARCODES_ARRAY[i]);
			}
		}
	
		if(existe){
			jAlert(HAY_BARCODES_REPETIDOS,CATALOGO_ALERT_TITLE);
			return 0;
		}
	}

	return 1;
}

function _setFoco(){
	//obtengo cualquer componente que tenga tabindex = 1
	if($("[tabindex='1']")[0]){
		$("[tabindex='1']")[0].focus();
	}
}

function _recuperarSeleccionados(chckbox){
	var chck=$("input[name="+chckbox+"]:checked");
	var array= new Array;
	var long=chck.length;

	for(var i=0; i< long; i++){
		array[i]=chck[i].value;
	}
	
	return array;
}

function seleccionoAlgo(chckbox){
    var chck = $("input[name="+chckbox+"]:checked");
    var array = new Array;
    var long = chck.length;
    if ( long == 0){
        jAlert(ELIJA_AL_MENOS_UN_EJEMPLAR,CATALOGO_ALERT_TITLE);
        return 0;
    }

    return 1;
}

/*
Esta funcion retorna el ID de la componente en COMPONENTE_ARRAY segun campo, subcampo
*/
function _getIdComponente(campo, subcampo){
	for(var i=0;i<COMPONENTES_ARRAY.length;i++){
		if( (COMPONENTES_ARRAY[i].campo == campo) && (COMPONENTES_ARRAY[i].subcampo == subcampo) ){
			return COMPONENTES_ARRAY[i].idCompCliente;
		}
	}

	return 0;
}

function _getBarcodes(){
	var barcodes_string = $('#'+_getIdComponente('995','f')).val();
	//inicializo el arreglo
	_freeMemory(BARCODES_ARRAY);
	BARCODES_ARRAY= [];

	if(barcodes_string != ''){
		BARCODES_ARRAY = barcodes_string.split(",");
		return 1;
	}
	
	return 0;
}

//esta funcion elimina el arreglo de opciones, para enviar menos info al servidor
function _sacarOpciones(){
	for(var i=0;i<COMPONENTES_ARRAY.length;i++){
		if(COMPONENTES_ARRAY[i].opciones){//si esta definido...
			if(COMPONENTES_ARRAY[i].opciones.length > 0){
				//elimino la propiedad opciones, para enviar menos info al servidor
				COMPONENTES_ARRAY[i].opciones= [];
			}
		}
	}
}

function _clearDataFromComponentesArray(){
    for(var i=0;i< COMPONENTES_ARRAY.length;i++){
        COMPONENTES_ARRAY[i].dato= '';
		$('#'+COMPONENTES_ARRAY[i].idCompCliente).val('');
    }
}

function _clearContentsEstructuraDelNivel(){
    $("#estructuraDelNivel1").html("");
    $("#estructuraDelNivel2").html("");
    $("#estructuraDelNivel3").html("");
}

// muestra/oculta los divs de la estructura segun el nivel que se este procesando
function _showAndHiddeEstructuraDelNivel(nivel){
	 if(nivel == 0){
        $('#nivel1Tabla').hide();
        $('#nivel2Tabla').hide();
        $('#nivel3Tabla').hide();	
    }else if(nivel == 1){
        $('#nivel1Tabla').show();
        $('#nivel2Tabla').hide();
        $('#nivel3Tabla').hide();
    }else if(nivel == 2){
        $('#nivel2Tabla').show();
        $('#nivel1Tabla').hide();
        $('#nivel3Tabla').hide();
    }else if(nivel == 3){
        $('#nivel3Tabla').show();
        $('#nivel1Tabla').hide();
        $('#nivel2Tabla').hide();
    }
}

//esta funcion sincroniza la informacion del cliente con el arreglo de componentes para enviarlos al servidor
function syncComponentesArray(){
    for(var i=0; i < COMPONENTES_ARRAY.length; i++){
       COMPONENTES_ARRAY[i].dato= $('#'+COMPONENTES_ARRAY[i].idCompCliente).val();
    }
}

function getDivDelNivel(){
    
    switch(_NIVEL_ACTUAL){
        case 1:
            return 'estructuraDelNivel1';   
        break;
        case 2:
            return 'estructuraDelNivel2';
        break;
        case 3:
            return 'estructuraDelNivel3';
        break;
    }
}


// FIXME esto podria ser generico para los 3 niveles
function mostrarEstructuraDelNivel1(){
    _NIVEL_ACTUAL= 1;
    objAH=new AjaxHelper(updateMostrarEstructuraDelNivel1);
    objAH.debug= true;
// 	objAH.cache= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_ESTRUCTURA_DEL_NIVEL";
    objAH.nivel= _NIVEL_ACTUAL;
    
    objAH.id_tipo_doc= 'ALL';
    objAH.sendToServer();
}


function mostrarDataNivel(){

    if (MODIFICAR){
        for (x=0; x<COMPONENTES_ARRAY.length; x++){
            if(x < DATA_ARRAY.length){
                //seteo el dato "DATA_ARRAY[x].dato" en la componete con ID  "DATA_ARRAY[x].idCompCliente"
                $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
                if(DATA_ARRAY[x].referencia == 1){
                    COMPONENTES_ARRAY[x].datoReferencia = DATA_ARRAY[x].datoReferencia;
                    $('#'+DATA_ARRAY[x].idCompCliente + '_hidden').val(DATA_ARRAY[x].datoReferencia);
                }
            }
        }
   }
}

function mostrarDataNivel1(){

    if (MODIFICAR){
        for (x=0; x<COMPONENTES_ARRAY.length; x++){
            if(x < DATA_ARRAY.length){
            //seteo el dato "DATA_ARRAY[x].dato" en la componete con ID  "DATA_ARRAY[x].idCompCliente"    
                
                $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
                if(DATA_ARRAY[x].referencia == 1){
                    COMPONENTES_ARRAY[x].datoReferencia = DATA_ARRAY[x].datoReferencia;
                    $('#'+DATA_ARRAY[x].idCompCliente + '_hidden').val(DATA_ARRAY[x].datoReferencia);
                }

// FIXME DEPRECATED, se usa Id_rep
//                 COMPONENTES_ARRAY[x].rep_n1_id = DATA_ARRAY[x].id_rep;
            }
        }
   }
}

function mostrarDataNivel2(){

    if (MODIFICAR){
        for (x=0; x<COMPONENTES_ARRAY.length; x++){
            if(x < DATA_ARRAY.length){
                //seteo el dato "DATA_ARRAY[x].dato" en la componete con ID  "DATA_ARRAY[x].idCompCliente"
//                 $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
//                 COMPONENTES_ARRAY[x].rep_n2_id = DATA_ARRAY[x].id_rep;

                $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
                if(DATA_ARRAY[x].referencia == 1){
                    COMPONENTES_ARRAY[x].datoReferencia = DATA_ARRAY[x].datoReferencia;
                    $('#'+DATA_ARRAY[x].idCompCliente + '_hidden').val(DATA_ARRAY[x].datoReferencia);
                }
// FIXME DEPRECATED, se usa Id_rep
//                 COMPONENTES_ARRAY[x].rep_n2_id = DATA_ARRAY[x].id_rep;
            }
        }
   }
}

function mostrarDataNivel3(){

    if (MODIFICAR){
        for (x=0; x<COMPONENTES_ARRAY.length; x++){
            if(x < DATA_ARRAY.length){
                //seteo el dato "DATA_ARRAY[x].dato" en la componete con ID  "DATA_ARRAY[x].idCompCliente"
//                 $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
//                 COMPONENTES_ARRAY[x].rep_n3_id = DATA_ARRAY[x].id_rep;
                $('#'+DATA_ARRAY[x].idCompCliente).val(DATA_ARRAY[x].dato);
                if(DATA_ARRAY[x].referencia == 1){
                    COMPONENTES_ARRAY[x].datoReferencia = DATA_ARRAY[x].datoReferencia;
                    $('#'+DATA_ARRAY[x].idCompCliente + '_hidden').val(DATA_ARRAY[x].datoReferencia);
                }

// FIXME DEPRECATED, se usa Id_rep
//                 COMPONENTES_ARRAY[x].rep_n3_id = DATA_ARRAY[x].id_rep;
            }
        }
   }
}

function updateMostrarEstructuraDelNivel1(responseText){
    _clearContentsEstructuraDelNivel();
    _showAndHiddeEstructuraDelNivel(1);
    //proceso la info del servidor y se crean las componentes en el cliente
    //ademas se carga el arreglo COMPONENTES_ARRAY donde se hace el mapeo de componente del cliente y dato
    procesarInfoJson(responseText); 
    //carga los datos en los campos solo si se esta modificando
//     mostrarDataNivel1();
    mostrarDataNivel();
    scrollTo('nivel1Tabla');
    
	//asigno el handler para el validador
	validateForm('formNivel1',guardarModificarDocumentoN1);
}

function mostrarEstructuraDelNivel2(){
    _NIVEL_ACTUAL= 2;
    objAH=new AjaxHelper(updateMostrarEstructuraDelNivel2);
    objAH.debug= true;
// 	objAH.cache= true;
    objAH.showStatusIn = 'estructuraDelNivel2';
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_ESTRUCTURA_DEL_NIVEL";
    objAH.nivel= 2;
    objAH.id_tipo_doc= $("#tipo_nivel3_id").val();
    objAH.sendToServer();
}

function updateMostrarEstructuraDelNivel2(responseText){
    _clearContentsEstructuraDelNivel();
    _showAndHiddeEstructuraDelNivel(2);
    //proceso la info del servidor y se crean las componentes en el cliente
    procesarInfoJson(responseText);
// 	mostrarDataNivel2();
    mostrarDataNivel();
    scrollTo('nivel2Tabla');
    
	//asigno el handler para el validador
	validateForm('formNivel2',guardarModificarDocumentoN2);
}


/*
    Esta funcion selecciona en el combo de tipo de documento q se crea dinamicamente, el tipo de documento seleccionado en el combo
    esquema de ingreso de datos.
*/
function _seleccionarTipoDocumentoYDeshabilitarCombo(){
    //obtengo el ID de la componente del combo de tipo de nivel3
    id = _getIdComponente('910','a');
    $('#'+ id).val($('#tipo_nivel3_id').val());    
    $('#'+ id).attr('disabled', 'true');
}

function mostrarEstructuraDelNivel3(){
    _NIVEL_ACTUAL= 3;

    objAH=new AjaxHelper(updateMostrarEstructuraDelNivel3);
    objAH.debug= true;
// 	objAH.cache= true;
    objAH.showStatusIn = 'estructuraDelNivel3';
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_ESTRUCTURA_DEL_NIVEL";
    objAH.nivel= _NIVEL_ACTUAL;
    objAH.id_tipo_doc= $("#tipo_nivel3_id").val();
    objAH.sendToServer();
}

function updateMostrarEstructuraDelNivel3(responseText){
    _clearContentsEstructuraDelNivel();
    _showAndHiddeEstructuraDelNivel(3);
	TAB_INDEX= 0;
    //proceso la info del servidor y se crean las componentes en el cliente
    procesarInfoJson(responseText);
// 	mostrarDataNivel3();
    mostrarDataNivel();
    scrollTo('nivel3Tabla');
	
	//asigno el handler para el validador
	validateForm('formNivel3',guardarModificarDocumentoN3);
    if(MODIFICAR == 0){
    //si se esta agregando se muestra el input para la cantidad    
        var id = _getIdComponente('995','f');
        $('#'+id).click(function(){
            registrarToggleOnChangeForBarcode(id);
        });
    }
}

function switchTipoBarcode(chosen, readOnly){

    readOnly.val('');
    readOnly.attr("readonly",true);
    chosen.val('');
    chosen.removeAttr("readonly");
    chosen.focus();
}

function registrarToggleOnChangeForBarcode(callFromBarcode){
        var cantidad_comp = $('#cantEjemplares');
        var cantidad_val = $.trim(cantidad_comp.val());
        var id = _getIdComponente('995','f');
        var barcode_comp = $('#'+id);
        var barcode_val = $.trim(barcode_comp.val());

        if (callFromBarcode){       
            if ((cantidad_val.length)>0)
                jConfirm(BORRAR_CANTIDAD_DE_EJEMPLARES, CATALOGO_ALERT_TITLE, function(confirmStatus){
                    if (confirmStatus){
                        switchTipoBarcode(barcode_comp,cantidad_comp);
                        $('#cantEjemplares').removeClass('required');
                    }
                })  
            else
                switchTipoBarcode(barcode_comp,cantidad_comp);
        }
        else{
            if ((barcode_val.length)>0)
                jConfirm(BORRAR_LISTA_DE_CODIGOS, CATALOGO_ALERT_TITLE, function(confirmStatus){
                    if (confirmStatus){
                        switchTipoBarcode(cantidad_comp,barcode_comp);
                        $('#cantEjemplares').addClass('required');
                    }
                })  
            else
                switchTipoBarcode(cantidad_comp,barcode_comp);
        }
}

function agregarN2(){
    if( (TIENE_NIVEL_2 == 0)&&($('#tipo_nivel3_id').val() == 'SIN SELECCIONAR') ){
        jAlert(SELECCIONE_EL_ESQUEMA,CATALOGO_ALERT_TITLE);
        $('#tipo_nivel3_id').focus();
    }else{
        MODIFICAR = 0;
        AGREGAR_COMPLETO = 0;
        mostrarEstructuraDelNivel2();
        inicializarSideLayers();
    }
}

function agregarN3(){
	MODIFICAR = 0;
	$('#divCantEjemplares').show();
	mostrarEstructuraDelNivel3();
}

//esta funcion muestra la info en la barra laterarl del NIVEL 1 luego de ser guardado
function mostrarInfoAltaNivel1(id1){

	ID_N1= id1;
    objAH=new AjaxHelper(updateMostrarInfoAltaNivel1);
    objAH.debug= true;
    objAH.showStatusIn = 'nivel1';
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_INFO_NIVEL1_LATERARL";
    objAH.id1= ID_N1;
    objAH.sendToServer();
}

function updateMostrarInfoAltaNivel1(responseText){
    $('#nivel1Tabla').slideUp('slow');
    $('#estructuraDelNivel1').html('');
    $('#nivel1').html(responseText);
}

//esta funcion muestra la info en la barra laterarl del NIVEL 2 luego de ser guardado
function mostrarInfoAltaNivel2(id2){
    objAH=new AjaxHelper(updateMostrarInfoAltaNivel2);
    objAH.debug= true;
    objAH.showStatusIn = 'nivel2';
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_INFO_NIVEL2_LATERARL";
    objAH.id2= id2; //mostrar todos los nivel 2 del nivel1 con el q se esta trabajando, asi este vuela
    objAH.id1= ID_N1;
    objAH.sendToServer();
}

function updateMostrarInfoAltaNivel2(responseText){
    $('#nivel2Tabla').slideUp('slow');
    $('#estructuraDelNivel2').html('');
    $('#nivel2').html(responseText);
}

/*
Esta funcion es la asignada al handler del validate, ejecuta guardarModificacionDocumentoN1 o guardarDocumentoN1
dependiendo de si se esta modificando o agregando
*/
function guardarModificarDocumentoN1(){
	if(MODIFICAR){
		guardarModificacionDocumentoN1();
	}else{
		guardarDocumentoN1();
	}
}

/*
Esta funcion es la asignada al handler del validate, ejecuta guardarModificacionDocumentoN2 o guardarDocumentoN2
dependiendo de si se esta modificando o agregando
*/
function guardarModificarDocumentoN2(){
	if(MODIFICAR){
		guardarModificacionDocumentoN2();
	}else{
		guardarDocumentoN2();
	}
}

/*
Esta funcion es la asignada al handler del validate, ejecuta guardarModificacionDocumentoN3 o guardarDocumentoN3
dependiendo de si se esta modificando o agregando
*/
function guardarModificarDocumentoN3(){
	if(MODIFICAR){
		guardarModificacionDocumentoN3();
	}else{
		guardarDocumentoN3();
	}
}

function guardarDocumentoN1(){

    syncComponentesArray();
    objAH=new AjaxHelper(updateGuardarDocumentoN1);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "GUARDAR_NIVEL_1";
    objAH.id_tipo_doc= $("#tipo_nivel3_id").val();
	_sacarOpciones();
    objAH.infoArrayNivel1= COMPONENTES_ARRAY;
    objAH.id1 = ID_N1;
    objAH.sendToServer();
}

function updateGuardarDocumentoN1(responseText){

    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref;
    ID_N1= info.id1; //recupero el id desde el servidor
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        inicializar();
        //carga la barra lateral con info de nivel 1
        mostrarInfoAltaNivel1(ID_N1);
        mostrarEstructuraDelNivel2();
    }
}

function guardarDocumentoN2(){
    syncComponentesArray();
    objAH=new AjaxHelper(updateGuardarDocumentoN2);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "GUARDAR_NIVEL_2";
	_sacarOpciones();
    objAH.infoArrayNivel2= COMPONENTES_ARRAY;
    objAH.id1 = ID_N1;
    objAH.id2 = ID_N2; //por si se modificó
    objAH.sendToServer();
}

function updateGuardarDocumentoN2(responseText){

    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref;//obtengo los mensajes para el usuario
    ID_N2= info.id2; //recupero el id desde el servidor
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        inicializar();
        //carga la barra lateral con info de nivel 2
        mostrarInfoAltaNivel2(ID_N2);
        mostrarEstructuraDelNivel3();
    }
}


function guardarDocumentoN3(){
	if( verificarAgregarDocumentoN3() ){
		syncComponentesArray();
        var porBarcode = $("#cantEjemplares").attr("readonly");
		objAH=new AjaxHelper(updateGuardarDocumentoN3);
		objAH.debug= true;
        objAH.modificado = 0;
		objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
		objAH.tipoAccion= "GUARDAR_NIVEL_3";
		objAH.tipo_documento= $("#tipo_nivel3_id").val();
        objAH.esPorBarcode = porBarcode;
        if (porBarcode)
            objAH.BARCODES_ARRAY= BARCODES_ARRAY;
        else
            objAH.cantEjemplares= $("#cantEjemplares").val();
		_sacarOpciones();
		objAH.infoArrayNivel3= COMPONENTES_ARRAY;
		objAH.id1 = ID_N1;
		objAH.id2 = ID_N2;
		objAH.sendToServer();
	}
}

function updateGuardarDocumentoN3(responseText){

    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref; //obtengo los mensajes para el usuario
    setMessages(Messages);

   //PARA LIMPIAR EL VALUE DE TODOS (ASI INGRESA UNO NUEVO)
   var allInputs = $('#estructuraDelNivel3 :input');
       for (x=0; x< allInputs.length; x++)
            allInputs[x].value="";
    if (! (hayError(Messages) ) ){
		//inicializo el arreglo
		_freeMemory(ID3_ARRAY);
		ID3_ARRAY= [];
		_freeMemory(BARCODES_ARRAY);
		BARCODES_ARRAY= [];
        //deja la misma estructura, solo borra el campo dato
        _clearDataFromComponentesArray();
        //muestra la tabla con los ejemplares agregados
        mostrarInfoAltaNivel3(ID_N1, ID_N2);
    }
}

function guardarModificacionDocumentoN1(){

    syncComponentesArray();
    objAH=new AjaxHelper(updateGuardarModificacionDocumentoN1);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MODIFICAR_NIVEL_1";
    objAH.id_tipo_doc= $("#tipo_nivel3_id").val();
	_sacarOpciones();
    objAH.infoArrayNivel1= COMPONENTES_ARRAY;
    objAH.id1 = ID_N1;
    objAH.sendToServer();
}

function updateGuardarModificacionDocumentoN1(responseText){

	MODIFICAR=0;
    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref;
    ID_N1= info.id1; //recupero el id desde el servidor
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        inicializar();
        //carga la barra lateral con info de nivel 1
        mostrarInfoAltaNivel1(ID_N1);
        mostrarEstructuraDelNivel2();
    }
}

function guardarModificacionDocumentoN2(){
    syncComponentesArray();
    objAH=new AjaxHelper(updateGuardarModificacionDocumentoN2);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MODIFICAR_NIVEL_2";
	_sacarOpciones();
    objAH.infoArrayNivel2= COMPONENTES_ARRAY;
    objAH.id1 = ID_N1;
    objAH.id2 = ID_N2; //por si se modificó
    objAH.sendToServer();
}

function updateGuardarModificacionDocumentoN2(responseText){

	MODIFICAR=0;
    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref;//obtengo los mensajes para el usuario
    ID_N2= info.id2; //recupero el id desde el servidor
    setMessages(Messages);
    if (! (hayError(Messages) ) ){
        inicializar();
        //carga la barra lateral con info de nivel 2
        mostrarInfoAltaNivel2(ID_N2);
        mostrarEstructuraDelNivel3();
    }
}

function guardarModificacionDocumentoN3(){
    syncComponentesArray();
    objAH=new AjaxHelper(updateGuardarModificacionDocumentoN3);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MODIFICAR_NIVEL_3";
    objAH.tipo_documento= $("#tipo_nivel3_id").val();
	objAH.cantEjemplares= $("#cantEjemplares").val();
	_sacarOpciones();
    objAH.infoArrayNivel3= COMPONENTES_ARRAY;
    objAH.id1 = ID_N1;
    objAH.id2 = ID_N2;
	objAH.ID3_ARRAY= ID3_ARRAY;
    objAH.sendToServer();
}

function updateGuardarModificacionDocumentoN3(responseText){

	//inicializo el arreglo
	_freeMemory(ID3_ARRAY);
	ID3_ARRAY= [];
	MODIFICAR=0;
    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref; //obtengo los mensajes para el usuario
    setMessages(Messages);

   	//PARA LIMPIAR EL VALUE DE TODOS (ASI INGRESA UNO NUEVO)
  	var allInputs = $('#estructuraDelNivel3 :input');
	for (x=0; x< allInputs.length; x++){
		allInputs[x].value="";
	}

    if (! (hayError(Messages) ) ){
        //deja la misma estructura, solo borra el campo dato
        _clearDataFromComponentesArray();
        //muestra la tabla con los ejemplares agregados
        mostrarInfoAltaNivel3(ID_N1, ID_N2);
    }
}


function guardar(nivel){
    if(nivel == 1){
        $('#formNivel1').submit();        
    } 
    if(nivel == 2){
        $('#formNivel2').submit();
    }
    if(nivel == 3){
        $('#formNivel3').submit(); //hace el submit
// FIXME
// 		guardarDocumentoN3(); //ojo asi no va a validad
    }
}

//esta funcion muestra la info en la barra laterarl del NIVEL 2 luego de ser guardado
function mostrarInfoAltaNivel3(id1, idNivel2){
    objAH=new AjaxHelper(updateMostrarInfoAltaNivel3);
    objAH.debug= true;
    objAH.showStatusIn = 'detalleDelNivel3';
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.tipoAccion= "MOSTRAR_INFO_NIVEL3_TABLA";
    objAH.id1= id1;
    objAH.id2= idNivel2;
    ID_N2= idNivel2;
    objAH.sendToServer();
}

function updateMostrarInfoAltaNivel3(responseText){
	$('#divCantEjemplares').show();	
    $('#detalleDelNivel3').html(responseText);
    zebra('tablaResult');
	checkedAll('checkAllEjemplares','checkEjemplares');
}

/*
 * procesarInfoJson
 * procesa la informacion que esta en notacion json, que viene del llamado ajax.
 * @params
 * json, string con formato json.
 */
function procesarInfoJson(json){

    var objetos=JSONstring.toObject(json);

    for(var i=0; i < objetos.length; i++){
		//guardo el objeto para luego enviarlo al servidor una vez que este actualizado
        COMPONENTES_ARRAY[i]= objetos[i];
        procesarObjeto(objetos[i]);
    }
	//hago foco en la primer componente
	_setFoco();
    if( MODIFICAR == 0 && _NIVEL_ACTUAL == 2 && AGREGAR_COMPLETO == 1){  
    //si se esta agregando un NIVEL 2  
        _seleccionarTipoDocumentoYDeshabilitarCombo();
    }    
}

/*
 * procesarObjeto
 * procesa el objeto json, para poder crear el componente adecuado al tipo de datos que vienen en el objeto.
 * @params
 * objeto, elemento que contiene toda la info necesaria.
 */

function crearRegla(comp,idComp){
   $('#'+idComp).rules("add", { required:true } );
}

function procesarObjeto(objeto){
    var libtext = $.trim(objeto.liblibrarian);
    var tipo = $.trim(objeto.tipo);
    var ref = objeto.referencia;
    var valor = objeto.valor;         
    var varios = objeto.varios;
    var idComp = objeto.idCompCliente;
    var comp;
    var strComp;
    var auto = 0;
    var unoLinea = 0;
    var idDiv = "div"+idComp;
    var divComp = crearDivComponente(idDiv);

    if(objeto.obligatorio == "1"){  
        libtext = libtext + "<b> * </b>";
    }

    var divLabel= crearDivLabel(libtext, idComp);

    strComp="<li class='sub_item'> "+divLabel+divComp+"</li>";
    $(strComp).appendTo("#"+getDivDelNivel());
    switch(tipo){
        case "text":
            //tipo,id,opciones,valor
            comp = crearComponente(tipo,idComp,"","");
            $(comp).appendTo("#"+idDiv);
            $("#"+idComp).val(objeto.valText);
        break;
        case "combo":
            comp= crearComponente(tipo,idComp,objeto,valor);
            $(comp).appendTo("#"+idDiv);
        break;
        case "texta2":
            compText=crearComponente("text",idComp,"","");
            comp=crearComponente("texta","texta"+idComp,"readonly='readonly'","");
            var boton="<input type='image' value='borrar ultima opcion' onclick='borrarEleccion("+idComp+")' src='[% themelang %]/images/sacar.png'>";
            comp="<div style='float: left;padding-right:1%; padding-bottom: 1%;'>"+comp+"</div>";
            compText=compText+" "+boton;
            $(compText).appendTo("#"+idDiv);
            $(comp).appendTo("#strComp"+idComp);
            $("#texta"+idComp).val(objeto.valTextArea);
        break;
		 case "auto":
            //tipo,id,opciones,valor
            comp= crearComponente(tipo,idComp,"","");
            $(comp).appendTo("#"+idDiv);
            $("#"+idComp).val(objeto.valText);
			_cearAutocompleteParaCamponente(objeto);
			//se crea un input hidden para guardar el ID del elemento de la lista que se selecciono
			comp= crearComponente('hidden',objeto.idCompCliente + '_hidden','','');
			 $(comp).appendTo("#"+idDiv);
			_cambiarIdDeAutocomplete();
        break;
		case "calendar":
            //tipo,id,opciones,valor
            comp= crearComponente(tipo,idComp,"","");
            $(comp).appendTo("#"+idDiv);
            $("#"+idComp).val(objeto.valText);
			$("#"+idComp).datepicker({ dateFormat: 'dd/mm/yy' });
		break;
    }
//     crearRegla(comp,idComp);
   //Se agregan clases para cuando tenga que recuperar los datos.
    if(objeto.obligatorio == "1"){
        hacerComponenteObligatoria(idComp);
    }

}


function _cambiarIdDeAutocomplete(){
	 for(var i=0; i< COMPONENTES_ARRAY.length; i++){
       	//si es un autocomplete, guardo el ID del input hidden
		if(COMPONENTES_ARRAY[i].tipo == 'auto'){	
			//si es un autocomplete, el dato es un ID y se encuentra en el hidden
			COMPONENTES_ARRAY[i].idCompCliente= COMPONENTES_ARRAY[i].idCompCliente + '_hidden';
// FIXME esto no esta funcionando, se pierde el id de la referencia
			$('#'+COMPONENTES_ARRAY[i].idCompCliente).val(COMPONENTES_ARRAY[i].datoReferencia);
		}
    }
}

//crea el Autocomplete segun lo indicado en el parametro "referenciaTabla"
function _cearAutocompleteParaCamponente(o){

	switch(o.referenciaTabla){
		case "autor": CrearAutocompleteAutores(		{IdInput: o.idCompCliente, 
													IdInputHidden: o.idCompCliente + '_hidden'}
									);
        break;
		case "pais": CrearAutocompletePaises(	{IdInput: o.idCompCliente, 
												IdInputHidden: o.idCompCliente + '_hidden' }
									);
        break;
		case "lenguaje": CrearAutocompleteLenguajes(	{IdInput: o.idCompCliente, 
														IdInputHidden: o.idCompCliente + '_hidden' }
									);
        break;
		case "ciudad": CrearAutocompleteCiudades(	{IdInput: o.idCompCliente, 
													IdInputHidden: o.idCompCliente + '_hidden' }
									);
        case "ui": CrearAutocompleteUI(   {IdInput: o.idCompCliente, 
                                                    IdInputHidden: o.idCompCliente + '_hidden' }
                                    );

        break;
	}
}

/*
 * crearComponente
 * crea el string HTML del componente correspondiente al parametro tipo.
 * @params
 * tipo, corresponde a la clase de componente html que se quiere crear.
 * id, identificador para el componente que se va a crear.
 * opciones, son las opciones que se generan si el componente es un combobox, para los demas esta en blanco.
 */
function crearComponente(tipo,id,objeto,valor){
    var comp;
	TAB_INDEX++;

    switch(tipo){
        case "text": comp="<input type='"+tipo+"' id='"+id+"' value='"+valor+"' size='60' tabindex="+TAB_INDEX+" name='"+id+"'>";
        break;
        case "combo": comp="<select id='"+id+"' name='"+id+"' tabindex="+TAB_INDEX+">\n<option value=''>Elegir opci&oacute;n</option>\n";
            var op="";
            var def="";
            var opciones= objeto.opciones;

            for(var i=0; i< opciones.length; i++){
                if(valor == opciones[i].clave){
                    def=" selected='selected' ";
                }
                op=op+"<option value='"+opciones[i].clave+ "'" + def +"'>"+opciones[i].valor+"</option>\n";
                def="";
            }

            comp=comp+op+"</select>";
        break;
        case "texta": comp="<textarea id='"+id+"' name='"+id+"'" + opciones +" rows='4' tabindex="+TAB_INDEX+">"+valor+"</textarea>";
        break;
		case "auto": comp="<input type='"+tipo+"' id='"+id+"' name='"+id+"' value='"+valor+"' size='60' tabindex="+TAB_INDEX+">";
        break;
		case "hidden": comp="<input type='hidden' id='"+id+"' name='"+id+"' value='"+valor+"'>";
        break;
		case "calendar": comp="<input type='"+tipo+"' id='"+id+"' name='"+id+"' value='"+valor+"' size='10' tabindex="+TAB_INDEX+">";
        break;
    }

    return comp;
}


// Esta funcion convierte una componete segun idObj en obligatoria, agrega * a la derecha de la misma
function hacerComponenteObligatoria(idObj){
    $("#"+idObj).addClass("obligatorio");
    $("#"+idObj).addClass("required");
    agrearAHash(HASH_RULES, idObj, "required");
    agrearAHash(HASH_MESSAGES, idObj, ESTE_CAMPO_NO_PUEDE_ESTAR_EN_BLANCO);    
}

// Esta funcion crea un divComponente con un id segun parametro idObj
function crearDivComponente(idObj){
    return "<div id='"+idObj+"' class='divComponente'></div>";
}

// Esta funcion crea un divLabel con un Label segun parametro
function crearDivLabel(label, idComp){
//     return "<label for='div"+ idComp +"'><div class='divLabelComponente'>  "+label+": </div></label>";
    return "<label for='"+ idComp +"'> " +label + " </label>";
}


/*
 * borrarN1
 * Elimina de la base de datos el documento con id1 igual al parametro que ingresa y todos los otros datos 
 * correspondiente a los otros niveles que hacen referencia al id1.
 */
function borrarN1(id1){
	
    jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_ALERT_TITLE, function(confirmStatus){
        if(confirmStatus){
		    objAH=new AjaxHelper(updateBorrarN1);
		    objAH.debug= true;
		    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
		    objAH.id1=id1;
		    objAH.nivel=1;
		    objAH.itemtype=$("#id_tipo_doc").val();
		    objAH.tipoAccion="ELIMINAR_NIVEL";
		    objAH.sendToServer();
        }
	});
}

function updateBorrarN1(responseText){
    var info=JSONstring.toObject(responseText);  
	//se borrar el nivel 1 y en cascada nivel 2 y 3 si esta permitido
	//se refresca la info	
    var Messages= info.Message_arrayref;
    setMessages(Messages);
	inicializar();
	mostrarEstructuraDelNivel1();
	mostrarInfoAltaNivel2(ID_N2);
	mostrarInfoAltaNivel3(ID_N1,ID_N2);
}

function borrarN2(id2){
    jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_ALERT_TITLE, function(confirmStatus){
        if(confirmStatus){
		    objAH=new AjaxHelper(updateBorrarN2);
		    objAH.debug= true;
		    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
		    objAH.id2=id2;
		    objAH.nivel=2;
		    objAH.itemtype=$("#id_tipo_doc").val();
		    objAH.tipoAccion="ELIMINAR_NIVEL";
		    objAH.sendToServer();
	    }
     
    });
}

function updateBorrarN2(responseText){
    var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);
	inicializar();
	mostrarEstructuraDelNivel2();
	mostrarInfoAltaNivel2(ID_N2);
	mostrarInfoAltaNivel3(ID_N1,ID_N2);
}

function borrarN3(id3){

    jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_ALERT_TITLE, function(confirmStatus){
        if(confirmStatus){
		    objAH=new AjaxHelper(updateBorrarN3);
		    objAH.debug= true;
		    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
            objAH.id3_array= [id3];
		    objAH.nivel=3;
		    objAH.itemtype=$("#id_tipo_doc").val();
		    objAH.tipoAccion="ELIMINAR_NIVEL";
		    objAH.sendToServer();
        }
	});
}

function updateBorrarN3(responseText){
	inicializar();
	mostrarEstructuraDelNivel3();
	mostrarInfoAltaNivel3(ID_N1,ID_N2);
	var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);
}

function borrarEjemplaresN3(id3){
	
    jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_ALERT_TITLE, function(confirmStatus){
        if(confirmStatus){
		    objAH=new AjaxHelper(updateBorrarEjemplaresN3);
		    objAH.debug= true;
		    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
		    var id3_array= _recuperarSeleccionados("checkEjemplares");
		    objAH.id3_array= id3_array;
		    objAH.nivel=3;
		    objAH.itemtype=$("#id_tipo_doc").val();
		    objAH.tipoAccion="ELIMINAR_NIVEL";
		    if(id3_array.length > 0){objAH.sendToServer();}
        }
	});
}

function updateBorrarEjemplaresN3(responseText){
    var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);
	inicializar();
	mostrarEstructuraDelNivel3();
	mostrarInfoAltaNivel3(ID_N1,ID_N2);
}
/*
 * modificarN1
 * Funcion que obtiene los datos ingresados en el nivel 1 para poder crear los componentes con los valores
 * guardados en la base de datos y poder modificarlos.
 */
function modificarN1(id1){
	inicializar();
    ID_N1 = id1;
	objAH = new AjaxHelper(updateModificarN1);
	objAH.url = "/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.showStatusIn = "centro";
	objAH.debug = true;
//     objAH.cache = true;
	objAH.tipoAccion = "MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
	objAH.itemtype = "ALL";
	objAH.id = ID_N1;
	objAH.nivel = 1;
	objAH.sendToServer();
}

function updateModificarN1(responseText){
    MODIFICAR = 1;
    //se genera un arreglo de objetos con la informacion guardada, campo, subcampo    
    DATA_ARRAY = JSONstring.toObject(responseText);
//FIXME estoy probado esto
    _NIVEL_ACTUAL = 1;
    updateMostrarEstructuraDelNivel1(responseText);
// fin prueba
// parece q no es necesario llamar y hacer otro ajax para traer la estructura, se reusa la estructura q viene con los datos
//     mostrarEstructuraDelNivel1();
}

function modificarN2(id2){
    inicializar();
    ID_N2 = id2;
    objAH=new AjaxHelper(updateModificarN2);
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.showStatusIn = "centro";
    objAH.debug= true;
//     objAH.cache = true;
    objAH.tipoAccion="MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
    objAH.itemtype=$("#id_tipo_doc").val();
    objAH.id = ID_N2;
    objAH.nivel = 2;
    objAH.sendToServer();
}

function updateModificarN2(responseText){
   MODIFICAR = 1;
   DATA_ARRAY = JSONstring.toObject(responseText);
// parece q no es necesario llamar y hacer otro ajax para traer la estructura, se reusa la estructura q viene con los datos
//    mostrarEstructuraDelNivel2();
//FIXME estoy probado esto
    _NIVEL_ACTUAL = 2;
    updateMostrarEstructuraDelNivel2(responseText);
// fin prueba
}

function modificarN3(id3){
	inicializar();
	ID_N3= id3;	
	objAH=new AjaxHelper(updateModificarN3);
	objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
	objAH.debug= true;
//     objAH.cache = true;
    objAH.showStatusIn = "centro";
	objAH.tipoAccion="MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
	objAH.itemtype=$("#id_tipo_doc").val();
 	objAH.id3 = ID_N3;
 	ID3_ARRAY[0]= ID_N3;
	objAH.nivel = 3;
	objAH.sendToServer();
}

function updateModificarN3(responseText){
	MODIFICAR = 1;
	$('#divCantEjemplares').hide();	
	DATA_ARRAY = JSONstring.toObject(responseText);
// parece q no es necesario llamar y hacer otro ajax para traer la estructura, se reusa la estructura q viene con los datos
// 	mostrarEstructuraDelNivel3();
//FIXME estoy probado esto
    _NIVEL_ACTUAL = 3;
    updateMostrarEstructuraDelNivel3(responseText);
// fin prueba
}

/*
Esta funcion modifica 1 a n Ejemplares, los ID_N3 se encuentran en ID3_ARRAY
se toma el 1er elemento del arreglo ID3_ARRAY como Ejemplar a modificar, ya
que se puede haber seleccionado por ej. 3 ejemplares distintos, luego se envia
lo modificado al servidor y a los 3 ID_N3 se les modifica esta informacion 
*/
function modificarEjemplaresN3(id3){

    if(seleccionoAlgo("checkEjemplares")){
    //si selecciono los ejemplares para editar....
	    inicializar();
	    ID_N3= id3;	
	    objAH=new AjaxHelper(updateModificarEjemplaresN3);
	    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
	    objAH.debug= true;
	    objAH.tipoAccion="MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
	    objAH.itemtype=$("#id_tipo_doc").val();
	    //obtengo todos los ejemplares seleccionados para modificar
	    ID3_ARRAY= _recuperarSeleccionados("checkEjemplares");
	    objAH.id3= ID3_ARRAY[0]; //muestra la info del primer ejemplar en el arreglo de ejemplares
	    objAH.nivel = 3;
	    objAH.sendToServer();
    }
}

function updateModificarEjemplaresN3(responseText){
	MODIFICAR = 1;
	$('#divCantEjemplares').hide();	
	DATA_ARRAY = JSONstring.toObject(responseText);
	mostrarEstructuraDelNivel3();
}

/*
 * borrarGrupo
 * Elimina de la base de datos el grupo correspodiente a los parametros que ingresan, y los ejemplares que hay en 
 * ese grupo.
 */
function borrarGrupo(id1,id2){	
	objAH=new AjaxHelper(updateBorrarGrupo);
    objAH.debug= true;
	objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
	objAH.id2=id2;
	objAH.nivel=2;
	objAH.itemtype=$("#id_tipo_doc").val();
	objAH.tipoAccion="ELIMINAR_NIVEL";
	objAH.sendToServer();
}

function updateBorrarGrupo(){
// TODO
}

/*
Esta funcion es usada cuando se quiere editar N1, N2 o N3 desde otra ventana, se redirecciona aqui
*/
function cargarNivel1(params){
/*
	params.id1
	params.id2
	params.id3
	params.tipoAccion= ('MODIFICAR_NIVEL_1'|'MODIFICAR_NIVEL_2'|'MODIFICAR_NIVEL_3') por defecto 'MODIFICAR_NIVEL_1'
*/
	ID_N1= params.id1;
	ID_N2= params.id2;

	if(params.tipoAccion == 'MODIFICAR_NIVEL_2'){
		modificarN2(params.id2);
	}else	
	if(params.tipoAccion == 'MODIFICAR_NIVEL_3'){
		modificarN3(params.id3);
	}else{
		//por defecto se carga el Nivel 1 para modificar
		modificarN1(params.id1);
	}

	mostrarInfoAltaNivel1(params.id1);
	mostrarInfoAltaNivel2(params.id2);	
	mostrarInfoAltaNivel3(params.id1, params.id2);	
}

function validateForm(formID, func){

    //se setea el handler para el error
    $.validator.setDefaults({
        submitHandler:  func ,
    });

    var _message= LLENE_EL_CAMPO;

    $().ready(function() {
    $("#"+formID).validate({
            errorElement: "div",
            errorClass: "error_adv",
            rules: HASH_RULES,
            messages: HASH_MESSAGES,
    })});


    $("#"+formID).validate();
}
