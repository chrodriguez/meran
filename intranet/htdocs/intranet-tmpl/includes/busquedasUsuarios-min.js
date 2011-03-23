var objAH;var shouldScrollUser=true;var globalSearchTemp;function ordenar(orden){objAH.sort(orden);}
function changePage(ini){objAH.changePage(ini);}
function consultarBar(filtro,doScroll){if(doScroll)
shouldScrollUser=doScroll;objAH=new AjaxHelper(updateInfoUsuariosBar);objAH.showOverlay=true;objAH.cache=true;busqueda=jQuery.trim($('#socio-bar').val());inicial='0';if(jQuery.trim(busqueda).length>0){objAH.url='/cgi-bin/koha/usuarios/reales/buscarUsuarioResult.pl';objAH.showOverlay=true;objAH.debug=true;objAH.funcion='changePage';objAH.socio=busqueda;objAH.sendToServer();}}
function consultar(filtro,doScroll){if(doScroll)
shouldScrollUser=doScroll;objAH=new AjaxHelper(updateInfoUsuarios);objAH.showOverlay=true;objAH.cache=true;busqueda=jQuery.trim($('#socio').val());inicial='0';if(filtro){inicial=filtro;busqueda=jQuery.trim(filtro);objAH.inicial=inicial;$('#socio').val(FILTRO_POR+filtro);}
else
{if(busqueda.substr(8,5).toUpperCase()=='TODOS'){busqueda=busqueda.substr(8,5);$('#socio').val(busqueda);consultar(busqueda);}
else
{if(busqueda.substr(0,6).toUpperCase()=='FILTRO'){busqueda=busqueda.substr(8,1);$('#socio').val(busqueda);consultar(busqueda);}}}
if(jQuery.trim(busqueda).length>0){objAH.url='/cgi-bin/koha/usuarios/reales/buscarUsuarioResult.pl';objAH.showOverlay=true;objAH.debug=true;objAH.funcion='changePage';objAH.socio=busqueda;objAH.sendToServer();}
else{jAlert(INGRESE_UN_DATO,USUARIOS_ALERT_TITLE);$('#socio').focus();}}
function updateInfoUsuarios(responseText){$('#result').html(responseText);zebra('datos_tabla');var idArray=[];var classes=[];idArray[0]='socio';classes[0]='nomCompleto';classes[1]='documento';classes[2]='legajo';classes[3]='tarjetaId';busqueda=jQuery.trim($('#socio').val());$("#resultBusqueda").slideUp("slow");scrollTo('result');}
function updateInfoUsuariosBar(responseText){$('#marco_contenido_datos').html("<div id='resultBusqueda'/><div id='result'/>");updateInfoUsuarios(responseText);}
function Borrar(){$('#socio').val('');}
function checkFilter(eventType){var str=$('#socio').val();if(eventType.toUpperCase()=='FOCUS'){if(str.substr(0,6).toUpperCase()=='FILTRO'){globalSearchTemp=$('#socio').val();Borrar();}}
else
{if(jQuery.trim($('#socio').val())=="")
$('#socio').val(globalSearchTemp);}}