<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
[% INCLUDE "message_INTRA.inc" %]
<script language="javascript" type="text/javascript">
//     <!-- variables de entorno sacadas de las preferencias del sistema -->
    token       = '[% token %]';
    imagesForJS = '[% temas %]/[% tema %]/imagenes';
    M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %] + 0;
</script>

[% IF page_sub_title %]
    <title>Meran::UNLP::[% page_sub_title %]</title>
[% ELSE %]
    <title>Meran::UNLP</title>
[% END %]

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<META HTTP-EQUIV="cache-control" content="public">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% user_theme %]/includes/completo.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% user_theme %]/includes/menu.css">
<!-- <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/[% user_theme %]/includes/completo_min.css" /> -->
<link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/fancybox-min.css" />

<!-- <link rel="stylesheet" type="text/css" href="[% temas %]/default/includes/intranetOLD.css">  -->
<!-- Estos 3 css fueron a parar a completo.css 
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/intranet.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/menu.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/jquery.alerts.css">-->

<!--Estos 7 scripts fueron concatenados a jquery/completo.js 
<script type="text/javascript" src="/includes/jquery/jquery.js"></script>
<script type="text/javascript" src="/includes/jquery/jquery.scrollTo.js"></script>
<script type="text/javascript" src="/includes/jquery/jquery.menu.js"></script>
Este tambien pero comprimido <script type="text/javascript" src="/includes/jquery/jquery.jCache.js"></script> 
Este tambien pero comprimido<script type="text/javascript" src="/includes/jquery/jquery.alerts.js"></script> -->
<!-- <script type="text/javascript" src="/includes/jquery/jquery.dataTables.js"></script> -->
<!-- Este tambien pero comprimido <script type="text/javascript" src="/includes/jquery/jquery.tooltip.js"></script> -->

<!--<script type="text/javascript" src="/includes/jquery/completo.js"></script> -->

 <!--FIXME esto no deberia estar aca, lo mandamos a donde se loguea el usuario o cambia la password 
<script type="text/javascript" src="/includes/md5.js"></script>
<script type="text/javascript" src="/includes/md5_cbc.js"></script>
<script type="text/javascript" src="/includes/sha1.js"></script>  -->
<!-- para generar la hash de la cache -->
<script type="text/javascript" src="/includes/json/jsonStringify.js"></script>

<script type="text/javascript" src="/includes/completo-intranet-top.js"></script>
<!-- FIXME falta pasar a completo -->
<script type="text/javascript" src="/includes/jquery/modal/jquery.simplemodal.js"></script>
<!-- <script type="text/javascript" src="/includes/jquery/jquery.field.min.js"></script> -->
<link media="screen" rel="stylesheet" href="/includes/jquery/modal/basic-min.css" type="text/css">

<script type="text/javascript" src="/includes/jquery/fancybox/jquery.easing.1.3.js"></script>
<script type="text/javascript" src="/includes/jquery/fancybox/jquery.fancybox-1.2.1.pack.js"></script>

<!--<script type="text/javascript" src="/includes/AjaxHelper.js"></script>
<script type="text/javascript" src="/includes/util.js"></script>
<script type="text/javascript" src="/includes/MessageHelper.js"></script>
<script type="text/javascript" src="/includes/WindowHelper.js"></script>
<script type="text/javascript" src="/includes/AutocompleteHelper.js"></script>-->

<!--   <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel="stylesheet" type="text/css"/> -->
<!--   <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script> -->
<!--  <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"></script>-->





<!-- <script src="/includes/jquery/jquery.tablednd.js"></script> -->

<script type="text/javascript" src="/includes/jquery/jquery-ui-1.8.9.custom.min.js"></script>

<!-- FIXME, esto parece que no sirve para nada, preguntar GASPO [% INCLUDE  'SmallPlugins.inc'  %] -->
<!-- Se incluyen los mensajes para la catalogacion -->

<script language="javascript" type="text/javascript">

	function swap(id,src){
	document.getElementById(id).src=src;
	}
	
	function cambiarIdioma() {
		$('#lang_server').val($('#language').val());
		$('#url').val(location.pathname);
		$('#formLang').submit();
	}


	function mainmenu(){
	
	    var options = {minWidth: 140};  
	    //$('#menu').menu();
	    
		var icons = {
            header: "ui-icon-circle-arrow-e",
            headerSelected: "ui-icon-circle-arrow-s"
        };

        $('.accordion').accordion({

            autoHeight: false,
            navigation: true,
            clearStyle: true,
            //icons: icons,
            
        });
	    
	}
	
	$(document).ready(function(){
		mainmenu();
//         registrarTooltips();
	});


</script>

</head>


<body>
  <noscript>
      <div class='tableMsgUser'>
          <font class='fontMsgUser'>
                  <b>[% 'Su navegador no soporta o no tiene habilidato Javascript' | i18n %]</b>
          </font>
      </div>
  </noscript>
  
  <div style="display: none;" id="ajax-indicator"><div><p>[% 'Cargando...' | i18n %]</p></div></div>
  <div class="container_test">
<!--  <div id="menu-container" class="main-header"> -->
  
  [% INCLUDE   'menu.inc'  %]
  
<!--  </div> -->
  
  <div id="marco_principal">
      <div id="marco_superior"></div>
  
     <div id="marco_contenido" class="contenido">
  
  
	  <div id="marco_contenido_datos" class="contenido">
	  <!--  usado como referencia por el MessageHelper -->
	  <div id="end_top">
	    [% IF mensaje %]
	        <div class="mensajes_informacion">
	            <div id="mensajes" style="opacity: 90; display: block;">
	                <div class="message_text">[% mensaje %]</div>
	            </div>
	        </div>
	    [% END %]
	  </div>

    <div id="basic-modal-content"></div>
