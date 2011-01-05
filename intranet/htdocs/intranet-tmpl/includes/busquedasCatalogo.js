var objAH;

var combinables     = ['titulo', 'autor', 'tipo', 'signatura', 'tipo_nivel3_id'];
var noCombinables   = ['keyword', 'isbn', 'dictionary', 'codBarra', 'estante', 'tema'];
var shouldScroll    = false;

function updateInfoBusquedas(responseText){

    $("#volver").hide();
    $("#filtrosBusqueda").slideUp('slow');  
    $('#resultBusqueda').html(responseText);
    $("#resultBusqueda").slideDown("slow");
    zebra('datos_tabla');
    if (shouldScroll)
      scrollTo('resultBusqueda');
}

function busquedaCombinable(){

    objAH                   = new AjaxHelper(updateBusquedaCombinable);
    objAH.debug             = true;
    //para busquedas combinables
    objAH.url               = '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.titulo            = $('#titulo').val();
    objAH.autor             = $('#autor').val();
    objAH.signatura         = $('#signatura').val();
    objAH.tipo_nivel3_name  = $('#tipo_nivel3_id').val();
    objAH.tipoAccion        = 'BUSQUEDA_AVANZADA';
    var radio               = $("#tipo:checked");
    var tipo                = radio[0].value;
    objAH.tipo              = tipo;
    //se setea la funcion para cambiar de pagina
    objAH.funcion           = 'changePage';
    //se envia la consulta
    objAH.sendToServer();
}

function updateBusquedaCombinable(responseText){
    updateInfoBusquedas(responseText);
}

function changePage(ini){
    objAH.changePage(ini);
}

function ordenarPor(ord){
    //seteo el orden de los resultados
    objAH.sort(ord);
}


function buscar(doScroll){
    var limite_caracteres   = 3; //tiene q ser == a lo configurado en sphinx.conf
    var cumple_limite       = true;
    var cumple_vacio        = true;

    //primero verifico las busquedas individuales
    if (doScroll)
        shouldScroll = doScroll;

    if ($.trim($('#keyword').val()) != '') {
        if ( (jQuery.trim($('#keyword').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {busquedaPorKeyword();}
    } else if (jQuery.trim($('#estante').val()) != '') {
        if ( (jQuery.trim($('#estante').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {buscarEstante();}
    } else if (jQuery.trim($('#dictionary').val()) != '') {
        if ( (jQuery.trim($('#dictionary').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {buscarPorDiccionario(ini);}
    } else if (jQuery.trim($('#codBarra').val()) != '') {
        if ( (jQuery.trim($('#codBarra').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {buscarPorCodigoBarra();}
    } else if (jQuery.trim($('#isbn').val()) != '') {
        if ( (jQuery.trim($('#isbn').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {buscarPorISBN();}
    } else if (jQuery.trim($('#tema').val()) != '') {
        if ( (jQuery.trim($('#tema').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {buscarPorTema();}
//     } else if( (jQuery.trim($('#titulo').val()) != '') || (jQuery.trim($('#autor').val()) != '') || (jQuery.trim($('#signatura').val()) != '') ){
//         if ( (jQuery.trim($('#titulo').val())).length < limite_caracteres || (jQuery.trim($('#autor').val())).length < limite_caracteres || (jQuery.trim($('#signatura').val())).length < limite_caracteres){
//             cumple_limite = false;
//         } else {busquedaCombinable();}
    } else if( (jQuery.trim($('#titulo').val()) != '') ) {
        if ( (jQuery.trim($('#titulo').val())).length < limite_caracteres ) {
            cumple_limite = false;
        } else {busquedaCombinable();}
    } else if(jQuery.trim($('#autor').val()) != '') {
        if((jQuery.trim($('#autor').val())).length < limite_caracteres ){
            cumple_limite = false;
        } else {busquedaCombinable();}
    } else if (jQuery.trim($('#signatura').val()) != '') {
         if ( (jQuery.trim($('#signatura').val())).length < limite_caracteres ) {
            cumple_limite = false;
        } else {busquedaCombinable();}
    } else {
       cumple_vacio = false;
    }

     if (!cumple_limite) {
        jAlert(INGRESE_AL_MENOS_TRES_CARACTERES_PARA_REALIZAR_LA_BUSQUEDA,CATALOGO_ALERT_TITLE);
    } else if (!cumple_vacio) {
        jAlert(INGRESE_DATOS_PARA_LA_BUSQUEDA,CATALOGO_ALERT_TITLE)
    }

}

function buscarPorTema(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.tema= $('#tema').val();
    objAH.tipoAccion    = 'BUSQUEDA_POR_TEMA';

    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

function buscarPorISBN(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.isbn= $('#isbn').val();
    objAH.tipoAccion    = 'BUSQUEDA_POR_ISBN';
    objAH.sendToServer();
}

function buscarPorDiccionario(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/diccionario.pl';
    objAH.dictionary= $('#dictionary').val();
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

function buscarPorCodigoBarra(){
    objAH               = new AjaxHelper(updateInfoBusquedas);
    objAH.debug         = true;
    objAH.url           = '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.codBarra      = $('#codBarra').val();
    objAH.tipoAccion    = 'BUSQUEDA_POR_BARCODE';
    objAH.sendToServer();
}

function buscarSuggested(suggested){
    busquedaPorKeyword(suggested);
    $('#keyword').val(suggested);
}

function busquedaPorKeyword(suggested){

    objAH=new AjaxHelper(updateBusquedaPorKeyword);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    if (suggested){
        objAH.keyword= suggested;
        objAH.from_suggested= 1;
    }else{
        objAH.keyword= $('#keyword').val();
    }
    objAH.match_mode = $('#match_mode').val();
    objAH.tipoAccion= 'BUSQUEDA_COMBINADA';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

function updateBusquedaPorKeyword(responseText){
    updateInfoBusquedas(responseText);
    var keyword = $('#keyword').val();
    $('#keyword').val(keyword);
}

function buscarEstante(){

    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/estante.pl';
    objAH.viewShelfName= $('#estante').val();
    objAH.orden= 'title';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

/******************************************Estantes**********************************************/

function mostrarEstantes(){

    objAH=new AjaxHelper(updateMostrarEstantes);
    objAH.debug= true;
    objAH.url= '../estanteVirtual.pl';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    //se envia la consulta
    objAH.sendToServer();

}

function updateMostrarEstantes(responseText){
    
//  $("#volver").hide();
    $("#filtrosBusqueda").slideUp('slow');  
    $('#resultBusqueda').html(responseText);
    $("#resultBusqueda").slideDown("slow");
    zebra('tablaresultado');
}


function verEstanteVirtual(shelf){
    
    objAH=new AjaxHelper(updateVerEstanteVirtual);
    objAH.debug= true;
    objAH.url= '../estanteVirtualDB.pl';
    objAH.shelves= shelf;
    objAH.tipo= 'VER_ESTANTE';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    //se envia la consulta
    objAH.sendToServer();
}

function verSubEstanteVirtual(shelf){
    
    objAH=new AjaxHelper(updateVerEstanteVirtual);
    objAH.debug= true;
    objAH.url= '../estanteVirtualDB.pl';
    objAH.shelves= shelf;
    objAH.tipo= 'VER_SUBESTANTE';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    //se envia la consulta
    objAH.sendToServer();

}

function updateVerEstanteVirtual(responseText){
    
    $('#resultBusqueda').html(responseText);
    zebra('tablaresultado');
    $("#volver").hide();
    $("#busqueda").slideUp('fast'); 
    $("#resultBusqueda").slideDown("fast");
}

/**************************************Fin****Estantes**********************************************/

function verTema(idtema,tema){

    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busqueda.pl';
    objAH.idTema= idtema;
    objAH.tema= tema;

    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}



function cambiarEstadoCampos(campos, clase){

    for(i=0;i<campos.length;i++){

        $('#'+campos[i]).attr('class', clase);

    }
}


function buscarPorAutor(completo){
    objAH               = new AjaxHelper(updateInfoBusquedas);
    objAH.url           = '/cgi-bin/koha/busquedas/busquedasDB.pl';
    //se setea la funcion para cambiar de pagina
    objAH.debug         = true;
    objAH.funcion       = 'changePage';
    objAH.completo      = completo;
    objAH.tipoAccion    = "BUSQUEDA_POR_AUTOR";
    objAH.sendToServer();
}

function ordenar(ord){
    //seteo el orden de los resultados
    objAH.sort(ord);
}

// FIXME DEPRECATEDDDDDDDDd
// function mostrarDetalle(id1){
//     var params="id1="+id1;
//     crearForm("/cgi-bin/koha/busquedas/detalle.pl",params);
// }
