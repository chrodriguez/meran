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
var ID_TIPO_EJEMPLAR=0; //para saber con tipo de ejemplar se esta trabajando
var TAB_INDEX= 0;//tabindex para las componentes
//arreglo de objetos componentes, estos objetos son actualizados por el usuario y luego son enviados al servidor
var MARC_OBJECT_ARRAY= new Array();
//arreglo con datos del servidor para modificar las componentes
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
    arreglo = $('#nivel2>fieldset legend');
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

	_freeMemory(MARC_OBJECT_ARRAY);
	MARC_OBJECT_ARRAY= [];
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
				existe = 1;
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
	for(var i=0;i<MARC_OBJECT_ARRAY.length;i++){
        var marc_object = MARC_OBJECT_ARRAY[i];

        if (marc_object.getCampo() == campo) {

            var subcampos_array = marc_object.getSubCamposArray();
            for(var j=0;j< subcampos_array.length;j++){
                if (subcampos_array[j].getSubCampo() == subcampo) {
                    return subcampos_array[j].getIdCompCliente();
                }
            }
        }
	}

	return 0;
}

/*
    Esta funcion busca un objeto en el arreglo de objetos de configuracion MARC, sgeun el idCompCliente
*/
function _getMARC_conf_ById(id){
    for(var i=0;i<MARC_OBJECT_ARRAY.length;i++){
        var subcampos_array = MARC_OBJECT_ARRAY[i].getSubCamposArray();
        for(var s=0;s<subcampos_array.length;s++){
            if(subcampos_array[s].getIdCompCliente() == id){
//                 return MARC_OBJECT_ARRAY[i];
                return subcampos_array[s];
            }
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
	for(var i=0;i<MARC_OBJECT_ARRAY.length;i++){
        var subcampos_array = MARC_OBJECT_ARRAY[i].getSubCamposArray();
        for(var s=0;s<subcampos_array.length;s++){
	        if(subcampos_array[s].opciones){//si esta definido...
		        if(subcampos_array[s].opciones.length > 0){
			        //elimino la propiedad opciones, para enviar menos info al servidor
			        subcampos_array[s].opciones= [];
		        }
	        }
        }
	}
}

function _clearDataFromComponentesArray(){
    for(var i=0;i< MARC_OBJECT_ARRAY.length;i++){
        MARC_OBJECT_ARRAY[i].dato= '';
		$('#'+MARC_OBJECT_ARRAY[i].idCompCliente).val('');
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
    for(var i=0; i < MARC_OBJECT_ARRAY.length; i++){
        var subcampos_array = MARC_OBJECT_ARRAY[i].getSubCamposArray();
        var subcampos_hash = MARC_OBJECT_ARRAY[i].subcampos_hash;
        var subcampo_valor = '';
        MARC_OBJECT_ARRAY[i].cant_subcampos = 0; //para llevar la cantidad de subcampos del campo q se esta procesando


// TODO falta setear el indicador primero y segundo
        MARC_OBJECT_ARRAY[i].indicador_primario     = $("#select_indicador_primario" + i).val();
        MARC_OBJECT_ARRAY[i].indicador_secundario   = $("#select_indicador_secundario" + i).val();
    
        for(var s=0; s < subcampos_array.length; s++){
            subcampo_valor = new Object();

            if(subcampos_array[s].getTieneEstructura() == '1'){

                if(subcampos_array[s].getReferencia() == '1'){
                    log("TIENE REFERENCIA");
                    if($('#'+subcampos_array[s].getIdCompCliente()).val() != '' && subcampos_array[s].getTipo() == 'combo'){
//                         subcampo_valor[subcampos_array[s].getSubCampo()] = $('#'+subcampos_array[s].getIdCompCliente()).val();
                        subcampos_array[s].setDato($('#'+subcampos_array[s].getIdCompCliente()).val());
                        subcampo_valor[subcampos_array[s].getSubCampo()] = $('#'+subcampos_array[s].getIdCompCliente()).val();
                        log("COMBO");
                    }else if($('#'+subcampos_array[s].getIdCompCliente()).val() != '' && subcampos_array[s].getTipo() == 'auto'){
//                         subcampos_array[s].setDatoReferencia($('#'+subcampos_array[s].getIdCompCliente() + '_hidden').val());
                        subcampos_array[s].setDato($('#'+subcampos_array[s].getIdCompCliente() + '_hidden').val());
                        subcampo_valor[subcampos_array[s].getSubCampo()] = $('#'+subcampos_array[s].getIdCompCliente() + '_hidden').val();
                        log("AUTO");
                    }else{
                        subcampos_array[s].datoReferencia = 0;
//                         subcampos_array[s].setDato('');
                        subcampos_array[s].setDato($('#'+subcampos_array[s].getIdCompCliente()).val());
                        subcampo_valor[subcampos_array[s].getSubCampo()] = 0;
                    }
                }else{  
                    log("NO TIENE REFERENCIA");
                    log("DATO: "+$('#'+subcampos_array[s].getIdCompCliente()).val());
                       subcampos_array[s].setDato($('#'+subcampos_array[s].getIdCompCliente()).val());
//                        subcampo_valor = new Object();
                       subcampo_valor[subcampos_array[s].getSubCampo()] = $('#'+subcampos_array[s].getIdCompCliente()).val();
                      
                }
                
                subcampos_hash[s] = subcampo_valor;
            }
             
        }//END for(var s=0; s < subcampos_array.length; s++)
            MARC_OBJECT_ARRAY[i].cant_subcampos = subcampos_array.length;
            
    }//END for(var i=0; i < MARC_OBJECT_ARRAY.length; i++)
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


function updateMostrarEstructuraDelNivel1(responseText){
    _clearContentsEstructuraDelNivel();
    _showAndHiddeEstructuraDelNivel(1);
    //proceso la info del servidor y se crean las componentes en el cliente
    //ademas se carga el arreglo MARC_OBJECT_ARRAY donde se hace el mapeo de componente del cliente y dato
    procesarInfoJson(responseText); 
    //carga los datos en los campos solo si se esta modificando
    scrollTo('nivel1Tabla');
    
	//asigno el handler para el validador
	validateForm('formNivel1',guardarModificarDocumentoN1);
    addRules();
}

function mostrarEstructuraDelNivel2(){
    _NIVEL_ACTUAL= 2;
    objAH=new AjaxHelper(updateMostrarEstructuraDelNivel2);
    objAH.debug= true;
// 	  objAH.cache= true;
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
    scrollTo('nivel2Tabla');
	//asigno el handler para el validador
	validateForm('formNivel2',guardarModificarDocumentoN2);
    addRules();
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
// 	  objAH.cache= true;
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

    addRules();
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
        if( $('#tipo_nivel3_id').val() == 'SIN SELECCIONAR') {
            jAlert(SELECCIONE_EL_ESQUEMA,CATALOGO_ALERT_TITLE);
            $('#tipo_nivel3_id').focus();
        }else{
            MODIFICAR = 0;
            AGREGAR_COMPLETO = 0;
            mostrarEstructuraDelNivel2();
            inicializarSideLayers();
        }
    }
}

function agregarN3( id2){
    ID_N2 = id2; 
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
    if((MODIFICAR == 0)&&(_NIVEL_ACTUAL == 1)){
    //si no se esta modificando y es el NIVEL 1
        $('#nivel1Tabla').slideUp('slow');
        $('#estructuraDelNivel1').html('');
    }

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
    if((MODIFICAR == 0)&&(_NIVEL_ACTUAL == 2)){
    //si no se esta modificando y es el NIVEL 1
        $('#nivel2Tabla').slideUp('slow');
        $('#estructuraDelNivel2').html('');
    }

    $('#nivel2').html(responseText);
}

/*
Esta funcion es la asignada al handler del validate, ejecuta guardarModificacionDocumentoN1 o guardarDocumentoN1
dependiendo de si se esta modificando o agregando
*/
function guardarModificarDocumentoN1(){

	if(MODIFICAR == 1){
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

	if(MODIFICAR == 1){
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

	if(MODIFICAR == 1){
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
    objAH.infoArrayNivel1= MARC_OBJECT_ARRAY;
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
    objAH.tipo_ejemplar = $('#tipo_nivel3_id').val();
	_sacarOpciones();
    objAH.infoArrayNivel2= MARC_OBJECT_ARRAY;
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
		objAH.infoArrayNivel3= MARC_OBJECT_ARRAY;
		objAH.id1 = ID_N1;
		objAH.id2 = ID_N2;
		objAH.sendToServer();
	}
}

function updateGuardarDocumentoN3(responseText){

    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref; //obtengo los mensajes para el usuario
    setMessages(Messages);

//    //PARA LIMPIAR EL VALUE DE TODOS (ASI INGRESA UNO NUEVO)
//    var allInputs = $('#estructuraDelNivel3 :input');
//        for (x=0; x< allInputs.length; x++)
//             allInputs[x].value="";
    if (! (hayError(Messages) ) ){
		//inicializo el arreglo
		_freeMemory(ID3_ARRAY);
		ID3_ARRAY= [];
		_freeMemory(BARCODES_ARRAY);
		BARCODES_ARRAY= [];
        //deja la misma estructura, solo borra el campo dato
        _clearDataFromComponentesArray();
        //acutalizo los datos de nivel 2
        mostrarInfoAltaNivel2(ID_N2);
        //muestra la tabla con los ejemplares agregados
        mostrarInfoAltaNivel3(ID_N2);
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
    objAH.infoArrayNivel1= MARC_OBJECT_ARRAY;
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
    objAH.infoArrayNivel2= MARC_OBJECT_ARRAY;
    objAH.tipo_ejemplar = ID_TIPO_EJEMPLAR;
    objAH.id1 = ID_N1;
    objAH.id2 = ID_N2; //por si se modificó
    objAH.sendToServer();
}

function updateGuardarModificacionDocumentoN2(responseText){
    
    if (!verificarRespuesta(responseText)) return(0);

	MODIFICAR = 0;
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
    objAH.infoArrayNivel3= MARC_OBJECT_ARRAY;
    objAH.tipo_ejemplar = ID_TIPO_EJEMPLAR;
    objAH.id1 = ID_N1;
    objAH.id2 = ID_N2;
	objAH.ID3_ARRAY= ID3_ARRAY;
    objAH.sendToServer();
}

function updateGuardarModificacionDocumentoN3(responseText){

    var info=JSONstring.toObject(responseText);
    var Messages= info.Message_arrayref; //obtengo los mensajes para el usuario
    setMessages(Messages);

   	//PARA LIMPIAR EL VALUE DE TODOS (ASI INGRESA UNO NUEVO)
  	var allInputs = $('#estructuraDelNivel3 :input');
	for (x=0; x< allInputs.length; x++){
		allInputs[x].value="";
	}

    if (! (hayError(Messages) ) ){
        //inicializo el arreglo
        _freeMemory(ID3_ARRAY);
        ID3_ARRAY= [];
        MODIFICAR=0;
        //deja la misma estructura, solo borra el campo dato
        _clearDataFromComponentesArray();
        //muestra la tabla con los ejemplares agregados
//         mostrarInfoAltaNivel3(ID_N1, ID_N2);
        mostrarInfoAltaNivel3(ID_N2);
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
    }
}

//esta funcion muestra la info en la barra laterarl del NIVEL 2 luego de ser guardado
/*
    Muestra el Nivel 3 para el Nivel 1 (id1) y Nivel 2 (idNivel2)
*/
// function mostrarInfoAltaNivel3(id1, idNivel2){
function mostrarInfoAltaNivel3(idNivel2){
    if(idNivel2 != 0){
        objAH=new AjaxHelper(updateMostrarInfoAltaNivel3);
        objAH.debug= true;
        objAH.showStatusIn = 'detalleDelNivel3';
        objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
        objAH.tipoAccion= "MOSTRAR_INFO_NIVEL3_TABLA";
//         objAH.id1= id1;
        objAH.id2= idNivel2;
        ID_N2= idNivel2;
        objAH.sendToServer();
    }
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

    var objetos = JSONstring.toObject(json);
    var campo_ant = '';
    var campo;
    var strComp;
    var strIndicadores;
    var marc_group;

    for(var i=0; i < objetos.length; i++){
    //recorro los campos
        strComp = "";
        strIndicadores = "";
    
		//guardo el objeto para luego enviarlo al servidor una vez que este actualizado
        var campo_marc_conf_obj = new campo_marc_conf(objetos[i]);
        var subcampos_array     = campo_marc_conf_obj.getSubCamposArray();
        //genero el header para el campo q contiene todos los subcampos
        strComp = "<div id='marc_group" + i + "' ><li class='MARCHeader'>";
        strComp = strComp + "<div class='MARCHeader_content'>";
        strComp = strComp + "<div class='MARCHeader_info'>";
    
        //genero el indicador primario
        if(campo_marc_conf_obj.getIndicadorPrimario() != ''){
            strIndicadores = "<label>Indicador Primero: " + campo_marc_conf_obj.getIndicadorPrimario() + "</label>";
            strIndicadores = strIndicadores + crearSelectIndicadoresPrimarios(campo_marc_conf_obj, i);
        }

        //genero el indicador secundario
        if(campo_marc_conf_obj.getIndicadorSecundario() != ''){
            strIndicadores = strIndicadores + "<label>Indicador Segundo: " + campo_marc_conf_obj.getIndicadorSecundario() + "</label>";
            strIndicadores = strIndicadores + crearSelectIndicadoresSecundarios(campo_marc_conf_obj, i);
        }

        strComp = strComp + "<label>" + crearBotonAyudaCampo(campo_marc_conf_obj.getCampo())  + " " + campo_marc_conf_obj.getCampo() + " - " + campo_marc_conf_obj.getNombre() + strIndicadores + "</label></div>";

        strComp = strComp + "<div class='MARCHeader_controls'> + - </div></div></li></div>";
        $("#" + getDivDelNivel()).append(strComp);
        
        //seteo los datos de los indicadores
        $("#select_indicador_primario"+i).val(campo_marc_conf_obj.getIndicadorPrimarioDato());
        $("#select_indicador_secundario"+i).val(campo_marc_conf_obj.getIndicadorSecundarioDato());

        //proceso los subcampos
        var subcampo_marc_conf_obj = new subcampo_marc_conf(objetos[i]);
        var subcampos_array = campo_marc_conf_obj.getSubCamposArray();
        marc_group = 'marc_group' + i;
        
        for(var j=0; j < subcampos_array.length; j++){
        //recorro los subcampos
            
            subcampos_array[j].idCompCliente    = "id_componente_" + i + j;
            subcampos_array[j].marc_group       = marc_group;
            subcampos_array[j].posCampo         = i; //posicion del campo contenedor en MARC_OBJECT_ARRAY
            procesarObjeto(subcampos_array[j], marc_group);
        }

        MARC_OBJECT_ARRAY[i] = campo_marc_conf_obj;
    }

	//hago foco en la primer componente
	_setFoco();
    if( MODIFICAR == 0 && _NIVEL_ACTUAL == 2 ){  
    //si se esta agregando un NIVEL 2  
        _seleccionarTipoDocumentoYDeshabilitarCombo();
    }    
}

function crearBotonAyudaCampo(campo){
    var funcion = "ayudaParaCampo('" + campo + "')";
    return "<input type='button' value='?' onclick=" + funcion + ">"; 
}

function ayudaParaCampo(campo){
    alert("crear ventana con ayuda para campo " + campo);
}

function generarOpcionesParaSelect(array_options){
    var op;

    for(var i=0; i< array_options.length; i++){
        op = op + "<option value='" + array_options[i].clave + "'>" + array_options[i].valor + "</option>\n";
    }

    return op;
}

function crearSelectIndicadoresPrimarios(campo_marc_conf_obj, campo){
    var opciones_array = campo_marc_conf_obj.getIndicadoresPrimarios();
    var indicadores = "";
    if(opciones_array.length > 0){
        indicadores = "<label><select id='select_indicador_primario" + campo + "'>" + generarOpcionesParaSelect(opciones_array) + "</select></label>";
    }

    return indicadores;
}

function crearSelectIndicadoresSecundarios(campo_marc_conf_obj, campo){
    var opciones_array = campo_marc_conf_obj.getIndicadoresSecundarios();
    var indicadores = "";
    if(opciones_array.length > 0){
        indicadores = "<label><select id='select_indicador_secundario" + campo + "'>" + generarOpcionesParaSelect(opciones_array) + "</select></label>";
    }

    return indicadores;
}

/*
 * procesarObjeto
 * procesa el objeto json, para poder crear el componente adecuado al tipo de datos que vienen en el objeto.
 * @params
 * objeto, elemento que contiene toda la info necesaria.
 */
function procesarObjeto(objeto, marc_group){

    TAB_INDEX++;

//     var marc_conf_obj       = new marc_conf(objeto);
    var marc_conf_obj       = new subcampo_marc_conf(objeto);
    var vista_intra         = marc_conf_obj.getVistaIntra();
    var tipo                = marc_conf_obj.getTipo();
    var comp;
    var strComp;
    var divComp             = crearDivComponente("div"+marc_conf_obj.getIdCompCliente());
    var tiene_estructura    = marc_conf_obj.getTieneEstructura(); //falta q los niveles 1, 2, 3 mantengan esta estructura

    if(marc_conf_obj.getRepetible() == "1"){  
        vista_intra = vista_intra + "<b> (R) </b>";
    }

    if(marc_conf_obj.getObligatorio() == "1"){  
        vista_intra = vista_intra + "<b> * </b>";
    }

    if(marc_conf_obj.getTieneEstructura() == '0'){ 
        vista_intra = vista_intra + "<div class='divComponente'><input type='text' value='" + marc_conf_obj.getDato() + " (NO TIENE ESTRUCTURA)' size='55' disabled></div>";
        tiene_estructura = 0;
    }

    vista_intra =  marc_conf_obj.getCampo() + '^' + marc_conf_obj.getSubCampo() + ' - ' + vista_intra
    var divLabel = crearDivLabel(vista_intra, marc_conf_obj.getIdCompCliente());
    strComp = "<li id='LI" + marc_conf_obj.getIdCompCliente() + "' class='sub_item'> " + divLabel + divComp + "</li>";
    $("#" + marc_group).append(strComp);

    if(tiene_estructura == 1){

        switch(tipo){
            case "text":
                crearText(marc_conf_obj);
            break;
            case "combo":
                crearCombo(marc_conf_obj);
            break;
            case "texta2":
                crearTextArea(marc_conf_obj);
            break;
            case "auto": 
                crearAuto(marc_conf_obj);
            break;
            case "calendar":
                crearCalendar(marc_conf_obj);
            break;
            case "anio":
                crearTextAnio(marc_conf_obj);
            break;
        }
    
        //Se agregan clases para cuando tenga que recuperar los datos.
        if(objeto.obligatorio == "1"){
            hacerComponenteObligatoria(marc_conf_obj.getIdCompCliente());
        }

    }
}

var RULES_OPTIONS = [];

function addRules(){
//     log("add rules ????????????????: ");
     for(var i=0; i< MARC_OBJECT_ARRAY.length; i++){
    //recorro los campos
        var subcampos_array = MARC_OBJECT_ARRAY[i].getSubCamposArray();
        for(var s=0; s< subcampos_array.length; s++){
        //recorro los subcampos
            if(subcampos_array[s].rules != ""){
                create_rules_object(subcampos_array[s].rules);
//                 log("remove rules val??: " + $('#'+subcampos_array[s].getIdCompCliente()).val() + " para el id " + subcampos_array[s].getIdCompCliente());
                $('#'+subcampos_array[s].getIdCompCliente()).rules("remove");
//                 log("rules: " + subcampos_array[s].rules + " para el id " + subcampos_array[s].getIdCompCliente());
                $('#'+subcampos_array[s].getIdCompCliente()).rules("add", RULES_OPTIONS);
            }
        }
    }
}


function create_rules_object(rule){

    var rules_array = rule.split("|");    
    var rule_array;
    var clave;
    var valor;
    RULES_OPTIONS = [];

    for(i=0;i<rules_array.length;i++){
        rule_array = rules_array[i].split(":");

        clave = $.trim(rule_array[0]);
        valor = $.trim(rule_array[1]);

        switch (clave) { 
            case 'minlength': 
                RULES_OPTIONS.minlength     = valor;
                break;
            case 'maxlength': 
                RULES_OPTIONS.maxlength     = valor;
                break;
            case 'digits': 
                RULES_OPTIONS.digits        = valor;
                break;
// FIXME no se porque pero cada vez que se intenta modificar agrega esta regla y no deja modificar
//             case 'lettersonly': 
//                 RULES_OPTIONS.lettersonly   = valor;
//                 break;
            case 'alphanumeric': 
                RULES_OPTIONS.alphanumeric   = valor;
                break;
            case 'alphanumeric_total': 
                RULES_OPTIONS.alphanumeric_total   = valor;
                break;
            case 'date': 
                RULES_OPTIONS.date          = valor;
                break;
            case 'dateITA': 
                RULES_OPTIONS.dateITA       = valor;
                break;
            case 'solo_texto': 
                RULES_OPTIONS.solo_texto    = valor;
                break;
        }
    }
}

function _cambiarIdDeAutocomplete(){
	 for(var i=0; i< MARC_OBJECT_ARRAY.length; i++){
       	//si es un autocomplete, guardo el ID del input hidden
		if(MARC_OBJECT_ARRAY[i].tipo == 'auto'){	
			//si es un autocomplete, el dato es un ID y se encuentra en el hidden
			MARC_OBJECT_ARRAY[i].idCompCliente= MARC_OBJECT_ARRAY[i].idCompCliente + '_hidden';
    // FIXME esto no esta funcionando, se pierde el id de la referencia
			$('#'+MARC_OBJECT_ARRAY[i].idCompCliente).val(MARC_OBJECT_ARRAY[i].datoReferencia);
		}
    }
}

//crea el Autocomplete segun lo indicado en el parametro "referenciaTabla"
function _cearAutocompleteParaCamponente(o){

	switch(o.getReferenciaTabla()){
		case "autor": CrearAutocompleteAutores(		{IdInput: o.getIdCompCliente(), 
													IdInputHidden: o.getIdCompCliente() + '_hidden'}
									);
        break;
		case "pais": CrearAutocompletePaises(	{IdInput: o.getIdCompCliente(), 
												IdInputHidden: o.getIdCompCliente() + '_hidden' }
									);
        break;
		case "lenguaje": CrearAutocompleteLenguajes(	{IdInput: o.getIdCompCliente(), 
														IdInputHidden: o.getIdCompCliente() + '_hidden' }
									);
        break;
		case "ciudad": CrearAutocompleteCiudades(	{IdInput: o.getIdCompCliente(), 
													IdInputHidden: o.getIdCompCliente() + '_hidden' }
									);
        break;
        case "ui": CrearAutocompleteUI(   {IdInput: o.getIdCompCliente(), 
                                                    IdInputHidden: o.getIdCompCliente() + '_hidden' }
                                    );

        break;
	}
}


function generarIdComponente(){
// TODO falta gerneralo
    return '789'+TAB_INDEX;
}

function clone(id){
    var id_componente = generarIdComponente();
    var subcampo_temp = _getMARC_conf_ById(id);
    var obj;
    obj = copy(subcampo_temp);
    obj.idCompCliente = id_componente;
    procesarObjeto(obj, subcampo_temp.marc_group);
    
    //agredo el subcampo en la poscion "posCampo" del arreglo MARC_OBJECT_ARRAY, donde se encuentra el campo contenedor
    MARC_OBJECT_ARRAY[subcampo_temp.posCampo].getSubCamposArray().push(obj);
}

function cloneObj(o) {
    if(typeof(o) != 'object') return o;
    if(o == null) return o;
    
    var newO = new Object();
    
    for(var i in o) newO[i] = cloneObj(o[i]);

    return newO;
}

function crearBotonAgregarRepetible(obj){

    if(obj.getRepetible() == '1'){
        return "<input type='button' value='+' size='10' onclick=clone('"+ obj.getIdCompCliente() +"')>";
    }else{  
        return "";
    }
}

function campo_marc_conf(obj){

    this.nombre                     = obj.nombre;
    this.campo                      = obj.campo;
    this.ayuda_campo                = obj.ayuda_campo;
    this.descripcion_campo          = obj.descripcion_campo;
    this.subcampos_array            = obj.subcampos_array;
    this.repetible                  = obj.repetible;
    this.indicador_primario         = obj.indicador_primario;
    this.indicador_secundario       = obj.indicador_secundario;
    this.subcampos_array            = new Array();
    this.subcampos_hash             = new Object();
    this.indicadores_primarios      = obj.indicadores_primarios;
    this.indicadores_secundarios    = obj.indicadores_secundarios;
    this.indicador_primario_dato    = obj.indicador_primario_dato;
    this.indicador_secundario_dato  = obj.indicador_secundario_dato;


    for(var i = 0; i < obj.subcampos_array.length; i++){
        var subcampo_marc_conf_obj = new subcampo_marc_conf(obj.subcampos_array[i]);
        this.subcampos_array[i] = subcampo_marc_conf_obj;
    }

    function fGetCampo(){ return this.campo };
    function fGetNombre(){ return this.nombre };
    function fGetAyudaCampo(){ return this.ayuda_campo };
    function fGetDescripcionCampo(){ return $.trim(this.descripcion_campo) };
    function fGetSubCamposArray(){ return this.subcampos_array };
    function fGetRepetible(){ return (this.repetible) };
    function fGetIndicadorPrimario(){ return (this.indicador_primario) };
    function fGetIndicadorSecundario(){ return (this.indicador_secundario) };
    function fGetSubCamposArray(){ return (this.subcampos_array) };
    function fGetIndicadoresPrimarios(){return (this.indicadores_primarios)};
    function fGetIndicadoresSecundarios(){return (this.indicadores_secundarios)};
    function fGetIndicadorPrimarioDato(){return (this.indicador_primario_dato)};
    function fGetIndicadorSecundarioDato(){return (this.indicador_secundario_dato)};
    

    //metodos
    this.getCampo                   = fGetCampo;
    this.getNombre                  = fGetNombre;
    this.getAyudaCampo              = fGetAyudaCampo;
    this.getDescripcionCampo        = fGetDescripcionCampo;
    this.getSubCamposArray          = fGetSubCamposArray;
    this.getRepetible               = fGetRepetible;
    this.getIndicadorPrimario       = fGetIndicadorPrimario;
    this.getIndicadorSecundario     = fGetIndicadorSecundario;
    this.getSubCamposArray          = fGetSubCamposArray;
    this.getIndicadoresPrimarios    = fGetIndicadoresPrimarios;
    this.getIndicadoresSecundarios  = fGetIndicadoresSecundarios;    
    this.getIndicadorPrimarioDato   = fGetIndicadorPrimarioDato;
    this.getIndicadorSecundarioDato = fGetIndicadorSecundarioDato;

}

function subcampo_marc_conf(obj){

    this.liblibrarian = obj.liblibrarian;
    this.itemtype = obj.itemtype;
    this.campo =  obj.campo;
    this.subcampo = obj.subcampo;
    this.dato =  obj.dato;
    this.nivel = obj.nivel;
    this.rules =  obj.rules;
    this.tipo = obj.tipo;
    this.intranet_habilitado =  obj.intranet_habilitado;
    this.tiene_estructura = obj.tiene_estructura;
    this.visible = obj.visible;
    this.repetible = obj.repetible;
    this.referencia = obj.referencia;
    this.obligatorio = obj.obligatorio;
    this.datoReferencia = obj.datoReferencia;
    this.idCompCliente =  obj.idCompCliente;
    this.referenciaTabla =  obj.referenciaTabla;
    this.opciones = obj.opciones;
    this.defaultValue = obj.defaultValue;
    this.tiene_estructura = obj.tiene_estructura;
    this.ayuda_campo = obj.ayuda_campo;
    this.descripcion_subcampo = obj.descripcion_subcampo;

    function fGetIdCompCliente(){ return this.idCompCliente };
    function fGetCampo(){ return this.campo };
    function fGetSubCampo(){ return this.subcampo };
    function fGetDato(){ return this.dato };
    function fSetDato(dato){ this.dato = dato };    
    function fGetDatoReferencia(){ return $.trim(this.datoReferencia) };
    function fSetDatoReferencia(datoReferencia){ this.datoReferencia = datoReferencia };    
    function fGetTipo(){ return $.trim(this.tipo) };
    function fGetReferencia(){ return $.trim(this.referencia) };
    function fGetRepetible(){ return this.repetible };
    function fGetReferenciaTabla(){ return this.referenciaTabla };    
    function fGetOpciones(){ return this.opciones };
    function fGetDefaultValue(){ return this.defaultValue };
    function fGetTieneEstructura(){ return this.tiene_estructura };
    function fGetObligatorio(){ return this.obligatorio };
    function fGetVistaIntra(){ return $.trim(this.liblibrarian) };
    function fGetAyudaCampo(){ return $.trim(this.ayuda_campo) };
    function fGetDescripcionSubCampo(){ return $.trim(this.descripcion_subcampo) };

    //metodos
    this.getIdCompCliente           = fGetIdCompCliente;
    this.getCampo                   = fGetCampo;
    this.getSubCampo                = fGetSubCampo;
    this.getDato                    = fGetDato;
    this.setDato                    = fSetDato;
    this.getDatoReferencia          = fGetDatoReferencia;
    this.setDatoReferencia          = fSetDatoReferencia;            
    this.getTipo                    = fGetTipo;
    this.getRepetible               = fGetRepetible;
    this.getReferenciaTabla         = fGetReferenciaTabla;
    this.getReferencia              = fGetReferencia;
    this.getOpciones                = fGetOpciones;
    this.getDefaultValue            = fGetDefaultValue;
    this.getTieneEstructura         = fGetTieneEstructura;
    this.getObligatorio             = fGetObligatorio;
    this.getVistaIntra              = fGetVistaIntra;
    this.getAyudaCampo              = fGetAyudaCampo;
    this.getDescripcionSubCampo     = fGetDescripcionSubCampo;
}


function crearText(obj){
    var comp = "<input type='text' id='" + obj.getIdCompCliente() + "' value='" + obj.getDato() + "' size='55' tabindex="+TAB_INDEX+" name='" + obj.getIdCompCliente() + "'>";     
    comp = comp + crearBotonAgregarRepetible(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);
}

function newCombo(obj){
    var comp = "<select id='" + obj.getIdCompCliente() + "' name='" + obj.getIdCompCliente() + "' tabindex="+TAB_INDEX+">\n";
    comp = comp + "<option value=''>Elegir opci&oacute;n</option>\n";

    var op = "";
    var defaultValue = "";
    var opciones = obj.getOpciones();

    for(var i=0; i< opciones.length; i++){
//         if(obj.getDefaultValue() == opciones[i].clave){
        if(obj.getDatoReferencia() == opciones[i].clave){
            defaultValue =" selected='selected' ";
        }

        op = op + "<option value='" + opciones[i].clave + "'" + defaultValue + "'>" + opciones[i].valor + "</option>\n";
        defaultValue = "";
    }

    comp = comp + op + "</select>";
    
    return comp;
}


function crearCombo(obj){
    var comp = newCombo(obj);

    comp = comp + crearBotonAgregarRepetible(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);
}

function crearTextArea(obj){
// TODO falta terminar
    crearText(obj);

    var comp = "<textarea id='" + obj.getIdCompCliente() + "' name='" + obj.getIdCompCliente() + "' rows='4' tabindex="+TAB_INDEX+">" + obj.getOpciones() + "</textarea>";
    comp = comp + crearBotonAgregarRepetible(obj);

    comp = crearComponente("texta","texta"+idComp,"readonly='readonly'","");
    var boton="<input type='image' value='borrar ultima opcion' onclick='borrarEleccion("+idComp+")' src='[% themelang %]/images/sacar.png'>";
    comp = "<div style='float: left;padding-right:1%; padding-bottom: 1%;'>"+comp+"</div>";
    compText = compText+" "+boton;
    $(compText).appendTo("#"+idDiv);

    $("#div" + obj.getIdCompCliente()).append(comp);
    $("#texta"+idComp).val(objeto.valTextArea);
}

function crearHidden(obj){
    return "<input type='hidden' id='" + obj.getIdCompCliente() + "_hidden' name='" + obj.getIdCompCliente() + "' value='" + obj.getDatoReferencia() + "'>";
}

function crearAuto(obj){
    var comp = "<input type='text' id='" + obj.getIdCompCliente() + "' name='"+ obj.getIdCompCliente() +"' value='" + obj.getDato() + "' size='55' tabindex="+TAB_INDEX+">";

    comp = comp + crearBotonAgregarRepetible(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);

    _cearAutocompleteParaCamponente(obj);
    //se crea un input hidden para guardar el ID del elemento de la lista que se selecciono
    comp = crearHidden(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);
}

function crearCalendar(obj){
    var comp = "<input type='text' id='" + obj.getIdCompCliente() + "' name='" + obj.getIdCompCliente() + "' value='" + obj.getDato() + "' size='10' tabindex="+TAB_INDEX+">";

    comp = comp + crearBotonAgregarRepetible(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);

    $("#"+obj.getIdCompCliente()).datepicker({ dateFormat: 'dd/mm/yy' });
}

function crearTextAnio(obj){
    var comp = "<input type='text' id='" + obj.getIdCompCliente() + "' name='" + obj.getIdCompCliente() + "' value='" + obj.getDato() + "' size='10' tabindex="+TAB_INDEX+">";

    comp = comp + crearBotonAgregarRepetible(obj);
    $("#div" + obj.getIdCompCliente()).append(comp);
}

// Esta funcion convierte una componete segun idObj en obligatoria, agrega * a la derecha de la misma
function hacerComponenteObligatoria(idObj){
    $("#"+idObj).addClass("obligatorio");
    $("#"+idObj).addClass("required");
//     agrearAHash(HASH_RULES, idObj, "required");
    agrearAHash(HASH_MESSAGES, idObj, ESTE_CAMPO_NO_PUEDE_ESTAR_EN_BLANCO);    
}

// Esta funcion crea un divComponente con un id segun parametro idObj
function crearDivComponente(idObj){
    return "<div id='"+idObj+"' class='divComponente'></div>";
}

// Esta funcion crea un divLabel con un Label segun parametro
function crearDivLabel(label, idComp){
    return "<label for='"+ idComp +"'> " + label + " </label>";
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
		    objAH.itemtype=$("#id_tipo_doc").val(); //creo q no es necesario
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

    if (! (hayError(Messages) ) ){
        inicializar();
	    mostrarEstructuraDelNivel1();
	    mostrarInfoAltaNivel2(ID_N2);
        mostrarInfoAltaNivel3(ID_N2);
    }
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

    if (! (hayError(Messages) ) ){
	    inicializar();
	    mostrarEstructuraDelNivel2();
	    mostrarInfoAltaNivel2(ID_N2);
        mostrarInfoAltaNivel3(ID_N2);
    }
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
	var info=JSONstring.toObject(responseText);  
    var Messages= info.Message_arrayref;
    setMessages(Messages);

    if (! (hayError(Messages) ) ){
        inicializar();
        mostrarEstructuraDelNivel3();
        //acutalizo los datos de nivel 2
        mostrarInfoAltaNivel2(ID_N2);
        mostrarInfoAltaNivel3(ID_N2);
    }
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
    
    if (! (hayError(Messages) ) ){
	    inicializar();
	    mostrarEstructuraDelNivel3();
        mostrarInfoAltaNivel2(ID_N2);
        mostrarInfoAltaNivel3(ID_N2);
    }
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
    _NIVEL_ACTUAL = 1;
    updateMostrarEstructuraDelNivel1(responseText);
}

function modificarN2(id2, tipo_ejemplar){
    inicializar();
    ID_N2               = id2;
    ID_TIPO_EJEMPLAR    = tipo_ejemplar;
    objAH=new AjaxHelper(updateModificarN2);
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.showStatusIn = "centro";
    objAH.debug= true;
//     objAH.cache = true;
    objAH.tipoAccion="MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
    objAH.id = ID_N2;
    objAH.nivel = 2;
    objAH.sendToServer();
}

function updateModificarN2(responseText){
   MODIFICAR = 1;
    _NIVEL_ACTUAL = 2;
    updateMostrarEstructuraDelNivel2(responseText);
// fin prueba
}

function modificarN3(id3, tipo_ejemplar){
	inicializar();
	ID_N3               = id3;	
    ID_TIPO_EJEMPLAR    = tipo_ejemplar;
	objAH               = new AjaxHelper(updateModificarN3);
	objAH.url           = "/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
	objAH.debug         = true;
//     objAH.cache = true;
    objAH.showStatusIn  = "centro";
	objAH.tipoAccion    = "MOSTRAR_ESTRUCTURA_DEL_NIVEL_CON_DATOS";
 	objAH.id3           = ID_N3;
 	ID3_ARRAY[0]        = ID_N3;
	objAH.nivel         = 3;
	objAH.sendToServer();
}

function updateModificarN3(responseText){
	MODIFICAR = 1;
	$('#divCantEjemplares').hide();	
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
// 	mostrarInfoAltaNivel3(params.id1, params.id2);	
  mostrarInfoAltaNivel3(params.id2);  
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
//             rules: HASH_RULES,
            messages: HASH_MESSAGES,
    })});


    $("#"+formID).validate();
}
