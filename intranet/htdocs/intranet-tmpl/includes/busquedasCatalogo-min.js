var objAH;var combinables=['titulo','autor','tipo','signatura','tipo_nivel3_id'];var noCombinables=['keyword','isbn','dictionary','codBarra','estante','tema'];var shouldScroll=true;function updateInfoBusquedas(responseText){$("#volver").hide();$("#filtrosBusqueda").slideUp('slow');$('#resultBusqueda').html(responseText);$("#resultBusqueda").slideDown("slow");zebra('datos_tabla');if(shouldScroll)
scrollTo('resultBusqueda');}
function updateInfoBusquedasBar(responseText){$('#marco_contenido_datos').html("<div id='resultBusqueda'/><div id='result'/>");updateInfoBusquedas(responseText);}
function busquedaCombinable(){var radio=$("#tipo:checked");var tipo=radio[0].value;objAH=new AjaxHelper(updateBusquedaCombinable);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH.titulo=$('#titulo').val();objAH.tipo=tipo;objAH.autor=$('#autor').val();objAH.only_available=($('#only_available').attr('checked'))?1:0;objAH.signatura=$('#signatura').val();objAH.tipo_nivel3_name=$('#tipo_nivel3_id').val();objAH.tema=$('#tema').val();objAH.codBarra=$('#codBarra').val();objAH.isbn=$('#isbn').val();objAH.viewShelfName=$('#estante').val();objAH.tipoAccion='BUSQUEDA_AVANZADA';objAH.funcion='changePage';objAH.sendToServer();}
function updateBusquedaCombinable(responseText){updateInfoBusquedas(responseText);}
function changePage(ini){objAH.changePage(ini);}
function ordenarPor(ord){objAH.sort(ord);}
function buscarBar(){objAH=new AjaxHelper(updateInfoBusquedasBar);objAH.showOverlay=true;objAH.debug=true;objAH.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH.keyword=$('#keyword-bar').val();objAH.shouldScroll=true;objAH.tipoAccion='BUSQUEDA_COMBINADA';objAH.match_mode="SPH_MATCH_ALL";objAH.funcion='changePage';if(jQuery.trim(objAH.keyword).length>0)
objAH.sendToServer();}
function buscar(doScroll){var limite_caracteres=3;var cumple_limite=true;var cumple_vacio=true;if(doScroll)
shouldScroll=doScroll;if((jQuery.trim($('#titulo').val())!='')||(jQuery.trim($('#autor').val())!='')||(jQuery.trim($('#signatura').val())!='')||(jQuery.trim($('#dictionary').val())!='')||(jQuery.trim($('#isbn').val())!='')||(jQuery.trim($('#codBarra').val())!='')||(jQuery.trim($('#tema').val())!='')||(jQuery.trim($('#estante').val())!='')){busquedaCombinable();}
else if($.trim($('#keyword').val())!=''){if((jQuery.trim($('#keyword').val())).length<limite_caracteres){cumple_limite=false;}else{busquedaPorKeyword();}}
else if((jQuery.trim($('#keyword-bar').val())!='')){if((jQuery.trim($('#keyword-bar').val())).length<limite_caracteres){cumple_limite=false;}else{buscarBar();}}
else{cumple_vacio=false;}
if(!cumple_limite){jAlert(INGRESE_AL_MENOS_TRES_CARACTERES_PARA_REALIZAR_LA_BUSQUEDA,CATALOGO_ALERT_TITLE);}else if(!cumple_vacio){jAlert(INGRESE_DATOS_PARA_LA_BUSQUEDA,CATALOGO_ALERT_TITLE)}}
function buscarSuggested(suggested){busquedaPorKeyword(suggested);if($('#keyword').val())
$('#keyword').val(suggested);else
$('#keyword-bar').val(suggested);}
function busquedaPorKeyword(suggested){var keyword="";if($('#keyword').val())
keyword=$('#keyword').val();else
keyword=$('#keyword-bar').val();keyword=keyword.replace(/\&/g,"AND");objAH=new AjaxHelper(updateBusquedaPorKeyword);objAH.showOverlay=true;objAH.debug=true;objAH.url=URL_PREFIX+'/busquedas/busquedasDB.pl';if(suggested){objAH.keyword=suggested;objAH.from_suggested=1;}else{objAH.keyword=keyword;}
objAH.match_mode=$('#match_mode').val();objAH.only_available=($('#only_available').attr('checked'))?1:0;objAH.tipoAccion='BUSQUEDA_COMBINADA';objAH.funcion='changePage';objAH.sendToServer();}
function updateBusquedaPorKeyword(responseText){updateInfoBusquedas(responseText);var keyword="";if($('#keyword').val())
keyword=$('#keyword').val();else
keyword=$('#keyword-bar').val();}
function mostrarEstantes(){objAH=new AjaxHelper(updateMostrarEstantes);objAH.showOverlay=true;objAH.debug=true;objAH.url='../estanteVirtual.pl';objAH.funcion='changePage';objAH.sendToServer();}
function updateMostrarEstantes(responseText){$("#filtrosBusqueda").slideUp('slow');$('#resultBusqueda').html(responseText);$("#resultBusqueda").slideDown("slow");zebra('tablaresultado');}
function verEstanteVirtual(shelf){objAH=new AjaxHelper(updateVerEstanteVirtual);objAH.debug=true;objAH.showOverlay=true;objAH.url='../estanteVirtualDB.pl';objAH.shelves=shelf;objAH.tipo='VER_ESTANTE';objAH.funcion='changePage';objAH.sendToServer();}
function verSubEstanteVirtual(shelf){objAH=new AjaxHelper(updateVerEstanteVirtual);objAH.debug=true;objAH.showOverlay=true;objAH.url='../estanteVirtualDB.pl';objAH.shelves=shelf;objAH.tipo='VER_SUBESTANTE';objAH.funcion='changePage';objAH.sendToServer();}
function updateVerEstanteVirtual(responseText){$('#resultBusqueda').html(responseText);zebra('tablaresultado');$("#volver").hide();$("#busqueda").slideUp('fast');$("#resultBusqueda").slideDown("fast");}
function verTema(idtema,tema){objAH=new AjaxHelper(updateInfoBusquedas);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+'/busquedas/busqueda.pl';objAH.idTema=idtema;objAH.tema=tema;objAH.funcion='changePage';objAH.sendToServer();}
function cambiarEstadoCampos(campos,clase){for(i=0;i<campos.length;i++){$('#'+campos[i]).attr('class',clase);}}
function buscarPorAutor(completo){objAH=new AjaxHelper(updateInfoBusquedas);objAH.showOverlay=true;objAH.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH.debug=true;objAH.funcion='changePage';objAH.only_available=($('#only_available').attr('checked'))?1:0;objAH.completo=completo;objAH.tipoAccion="BUSQUEDA_POR_AUTOR";objAH.sendToServer();}
function ordenar(ord){objAH.sort(ord);}
