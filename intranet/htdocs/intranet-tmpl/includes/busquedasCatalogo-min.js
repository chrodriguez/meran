var objAH_search;var combinables=['titulo','autor','tipo','signatura','tipo_nivel3_id'];var noCombinables=['keyword','isbn','dictionary','codBarra','estante','tema'];var shouldScroll=true;function ordenar(orden){if(orden==ORDEN){ASC=!ASC;}else{ORDEN=orden;}
buscar();}
function updateInfoBusquedas(responseText){$("#volver").hide();$('#resultBusqueda').html(responseText);closeModal();$("#resultBusqueda").slideDown("fast");if(shouldScroll)
scrollTo('resultBusqueda');}
function updateInfoBusquedasBar(responseText){clearInterval(mensajes_interval_id);$('#navBarResult').html('');$('#marco_contenido_datos').html("<div id='resultBusqueda'/><div id='result'/>");updateInfoBusquedas(responseText);$(window).unbind('scroll');}
function busquedaPorTipoDoc(){objAH_search=new AjaxHelper(updateBusquedaCombinable);objAH_search.debug=true;objAH_search.showOverlay=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH_search.only_available=($('#only_available').attr('checked'))?1:0;objAH_search.tipo_nivel3_name=$('#tipo_nivel3_id').val();objAH_search.tipoAccion='BUSQUEDA_AVANZADA';objAH_search.funcion='changePage_search';objAH_search.sendToServer();}
function busquedaCombinable(){var radio=$("#tipo:checked");var tipo=radio[0].value;objAH_search=new AjaxHelper(updateBusquedaCombinable);objAH_search.debug=true;objAH_search.showOverlay=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH_search.titulo=$('#titulo').val();objAH_search.tipo=tipo;objAH_search.autor=$('#autor').val();objAH_search.only_available=($('#only_available').attr('checked'))?1:0;objAH_search.signatura=$('#signatura').val();objAH_search.tipo_nivel3_name=$('#tipo_nivel3_id').val();objAH_search.tema=$('#tema').val();objAH_search.codBarra=$('#codBarra').val();objAH_search.isbn=$('#isbn').val();objAH_search.orden=ORDEN;objAH_search.asc=ASC;objAH_search.tipoAccion='BUSQUEDA_AVANZADA';objAH_search.funcion='changePage_search';objAH_search.sendToServer();}
function updateBusquedaCombinable(responseText){updateInfoBusquedas(responseText);}
function changePage_search(ini){objAH_search.changePage(ini);}
function buscarBar(){objAH_search=new AjaxHelper(updateInfoBusquedasBar);objAH_search.showOverlay=true;objAH_search.debug=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH_search.keyword=$('#keyword-bar').val();objAH_search.shouldScroll=true;objAH_search.tipoAccion='BUSQUEDA_COMBINADA';objAH_search.match_mode="SPH_MATCH_ALL";objAH_search.funcion='changePage_search';if(jQuery.trim(objAH_search.keyword).length>0)
objAH_search.sendToServer();}
function buscar(doScroll){var limite_caracteres=3;var cumple_limite=true;var cumple_vacio=true;if(doScroll)
shouldScroll=doScroll;if((jQuery.trim($('#titulo').val())!='')||(jQuery.trim($('#autor').val())!='')||(jQuery.trim($('#signatura').val())!='')||(jQuery.trim($('#dictionary').val())!='')||(jQuery.trim($('#isbn').val())!='')||(jQuery.trim($('#codBarra').val())!='')||(jQuery.trim($('#tema').val())!=''))
{busquedaCombinable();}
else if($.trim($('#keyword').val())!=''){if((jQuery.trim($('#keyword').val())).length<limite_caracteres){cumple_limite=false;}else{busquedaPorKeyword();}}
else if($.trim($('#estante').val())!=''){if((jQuery.trim($('#estante').val())).length<limite_caracteres){cumple_limite=false;}else{busquedaPorEstante();}}
else if($('#tipo_nivel3_id').val()!=""){busquedaCombinable();}
else{cumple_vacio=false;}
if(!cumple_limite){jAlert(INGRESE_AL_MENOS_TRES_CARACTERES_PARA_REALIZAR_LA_BUSQUEDA);}else if(!cumple_vacio){jAlert(INGRESE_DATOS_PARA_LA_BUSQUEDA)}}
function buscarSuggested(suggested){busquedaPorKeyword(suggested);if($('#keyword').val())
$('#keyword').val(suggested);else
$('#keyword-bar').val(suggested);}
function busquedaPorKeyword(suggested){var keyword="";if($('#keyword').val())
keyword=$('#keyword').val();else
keyword=$('#keyword-bar').val();keyword=keyword.replace(/\&/g,"AND");keyword=keyword.replace(/\|/g,"OR");keyword=keyword.replace(/\-/g,"NOT");objAH_search=new AjaxHelper(updateBusquedaPorKeyword);objAH_search.showOverlay=true;objAH_search.debug=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';if(suggested){objAH_search.keyword=suggested;objAH_search.from_suggested=1;}else{objAH_search.keyword=keyword;}
objAH_search.orden=ORDEN;objAH_search.asc=ASC;objAH_search.match_mode=$('#match_mode').val();objAH_search.only_available=($('#only_available').attr('checked'))?1:0;objAH_search.tipoAccion='BUSQUEDA_COMBINADA';objAH_search.funcion='changePage_search';objAH_search.sendToServer();}
function updateBusquedaPorKeyword(responseText){updateInfoBusquedas(responseText);var keyword="";if($('#keyword').val())
keyword=$('#keyword').val();else
keyword=$('#keyword-bar').val();}
function busquedaPorEstante(){objAH_search=new AjaxHelper(updateInfoBusquedas);objAH_search.showOverlay=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH_search.debug=true;objAH_search.funcion='changePage_search';objAH_search.estante=$('#estante').val();objAH_search.tipoAccion="BUSQUEDA_POR_ESTANTE";objAH_search.sendToServer();}
function verTema(idtema,tema){objAH_search=new AjaxHelper(updateInfoBusquedas);objAH_search.debug=true;objAH_search.showOverlay=true;objAH_search.url=URL_PREFIX+'/busquedas/busqueda.pl';objAH_search.idTema=idtema;objAH_search.tema=tema;objAH_search.funcion='changePage_search';objAH_search.sendToServer();}
function cambiarEstadoCampos(campos,clase){for(i=0;i<campos.length;i++){$('#'+campos[i]).attr('class',clase);}}
function buscarPorAutor(completo){objAH_search=new AjaxHelper(updateInfoBusquedas);objAH_search.showOverlay=true;objAH_search.url=URL_PREFIX+'/busquedas/busquedasDB.pl';objAH_search.debug=true;objAH_search.funcion='changePage_search';objAH_search.only_available=($('#only_available').attr('checked'))?1:0;objAH_search.completo=completo;objAH_search.tipoAccion="BUSQUEDA_POR_AUTOR";objAH_search.sendToServer();}
