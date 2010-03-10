<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>
<head>
[% INCLUDE "message_INTRA.inc" %]
<script language="javascript" type="text/javascript">
//     <!-- variables de entorno sacadas de las preferencias del sistema -->
    token       = '[% token %]';
    imagesForJS = '[% temas %]/[% tema %]/imagenes';
    M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %];
</script>

[% IF page_sub_title %]
    <title>Meran::UNLP::[% page_sub_title %]</title>
[% ELSE %]
    <title>Meran::UNLP</title>
[% END %]

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<META HTTP-EQUIV="cache-control" content="public">
<!-- <link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/completo.css"> -->
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/completo_min.css"> 
<link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/fancybox.css" />

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
<!--<script type="text/javascript" src="/includes/AjaxHelper.js"></script>
<script type="text/javascript" src="/includes/util.js"></script>
<script type="text/javascript" src="/includes/MessageHelper.js"></script>
<script type="text/javascript" src="/includes/WindowHelper.js"></script>
<script type="text/javascript" src="/includes/AutocompleteHelper.js"></script>-->



<!-- <script src="/includes/jquery/jquery.tablednd.js"></script> -->



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
	    $('#menu').menu();
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
  
  
  <div id="menu-container" class="main-header">
  
  [% INCLUDE   'menu.inc'  %]
  
  </div>
  
  <div id="marco_principal">
      <div id="marco_superior"> <div>
  </div></div>
  
  <div id="marco_contenido" class="contenido">
  
  
  <div id="marco_contenido_datos" class="contenido">
      
  <!--  usado como referencia por el MessageHelper -->
  <div id="end_top"></div>
