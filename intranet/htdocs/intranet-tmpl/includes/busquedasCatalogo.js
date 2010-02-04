var objAH;

var combinables= ['titulo', 'autor', 'tipo', 'signatura', 'tipo_nivel3_id'];
var noCombinables= ['keyword', 'isbn', 'dictionary', 'codBarra', 'estante', 'tema'];
var shouldScroll=false;

function updateInfoBusquedas(responseText){

    $("#volver").hide();
    $("#filtrosBusqueda").slideUp('slow');  
    $('#resultBusqueda').html(responseText);
    $("#resultBusqueda").slideDown("slow");
    zebra('datos_tabla');
    if (shouldScroll)
      scrollTo('resultBusqueda');
}

function highlightBusquedaCombinable(){
    var string = [];
    var classes = [];
    if($('#autor').val() != ''){
        classes.push('autor_result');
    }
    
    if($('#titulo').val() != ''){
        classes.push('titulo_result');
    }
    
    var combinables= ['titulo', 'autor', 'signatura'];
    highlight(classes,combinables);
}

function busquedaCombinable(){

    objAH=new AjaxHelper(updateBusquedaCombinable);
    objAH.debug= true;

    //para busquedas combinables
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.titulo=  $('#titulo').val();
    objAH.autor= $('#autor').val();
    objAH.signatura= $('#signatura').val();   
    objAH.tipo_nivel3_name= $('#tipo_nivel3_id').val();
    objAH.tipoAccion = 'BUSQUEDA_AVANZADA';    
    
    var radio= $(":checked");
    var tipo=radio[0].value;
    objAH.tipo= tipo;
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    //se envia la consulta
    objAH.sendToServer();   
}

function updateBusquedaCombinable(responseText){
    updateInfoBusquedas(responseText);
    highlightBusquedaCombinable();
}

function changePage(ini){
    objAH.changePage(ini);
}

function ordenarPor(ord){
    //seteo el orden de los resultados
    objAH.sort(ord);
}


function buscar(doScroll){
    //primero verifico las busquedas individuales
    if (doScroll)
        shouldScroll = doScroll;
    if ($.trim($('#keyword').val()) != '') {
        busquedaPorKeyword();
      }else 
        if (jQuery.trim($('#estante').val()) != '') {
            buscarEstante();
        }else 
          if (jQuery.trim($('#dictionary').val()) != '') {
              buscarPorDiccionario(ini);
          }else 
            if (jQuery.trim($('#codBarra').val()) != '') {
                buscarPorCodigoBarra();
          }else 
            if (jQuery.trim($('#isbn').val()) != '') {
                buscarPorISBN();
            }else 
              if (jQuery.trim($('#tema').val()) != '') {
                  buscarPorTema();
              }else 
                if( (jQuery.trim($('#titulo').val()) != '') || (jQuery.trim($('#autor').val()) != '') || (jQuery.trim($('#signatura').val()) != '') ){
                    busquedaCombinable();
                }else{
                  jAlert(SELECCIONE_AL_MENOS_UN_CAMPO_PARA_BUSCAR,CATALOGO_ALERT_TITLE)
                }
}

function buscarPorCodigoBarra(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busqueda.pl';
    objAH.codBarra= $('#codBarra').val();
    objAH.sendToServer();
}

function highlightbuscarPorCodigoBarra(){
    var string = [];
    var classes = [];
    string[0] = $('#codBarra').val();
    classes[0] = 'titulo_result';
    classes[1] = 'autor_result';
    highlight(classes,string);
}

function buscarPorTema(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/tema.pl';
    objAH.tema= $('#tema').val();

    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

function buscarPorISBN(){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busqueda.pl';
    objAH.isbn= $('#isbn').val();
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

function busquedaPorKeyword(){

    objAH=new AjaxHelper(updateBusquedaPorKeyword);
    objAH.debug= true;
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    objAH.keyword= $('#keyword').val();
    objAH.match_mode = $('#match_mode').val();
    objAH.tipoAccion= 'BUSQUEDA_COMBINADA';
    //se setea la funcion para cambiar de pagina
    objAH.funcion= 'changePage';
    objAH.sendToServer();
}

function updateBusquedaPorKeyword(responseText){
    updateInfoBusquedas(responseText);
    highlightBusquedaPorKeyword();
}

function highlightBusquedaPorKeyword(){
    var string = [];
    var classes = [];
    string[0] = 'keyword';
    classes[0] = 'titulo_result';
    classes[1] = 'autor_result';
    highlight(classes,string);
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


function buscarPorAutor(idAutor){
    objAH=new AjaxHelper(updateInfoBusquedas);
    objAH.url= '/cgi-bin/koha/busquedas/busquedasDB.pl';
    //se setea la funcion para cambiar de pagina
    objAH.debug= true;
    objAH.funcion= 'changePage';
    objAH.idAutor= idAutor;
    objAH.tipoAccion = "POR_AUTOR";
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
