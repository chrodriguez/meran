<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<!--Doctype is not required - can be HTML or XHTML-->
<html>
[% INCLUDE "message_INTRA.inc" %]
<script language="javascript" type="text/javascript">
    token= '[% token %]';
    imagesForJS = '[% temas %]/[% tema %]/imagenes';
</script>

<head>
[% IF page_sub_title %]
    <title>Meran::UNLP::[% page_sub_title %]</title>
[% ELSE %]
    <title>Meran::UNLP</title>
[% END %]

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="Public" content="max-age=3153600">

<link rel="stylesheet" type="text/css" href="[% temas %]/default/includes/intranetOLD.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/intranet.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/menu.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/jquery.alerts.css">

<script src="/includes/jquery/jquery.js"></script>
<script src="/includes/jquery/jquery.scrollTo.js"></script>
<script src="/includes/jquery/jquery.menu.js"></script>
<!-- FIXME esto no deberia estar aca, solo se usa cuando se cambia la pass o cuando se loguea -->
<script src="/includes/md5.js"></script>
<script src="/includes/md5_cbc.js"></script>
<script src="/includes/sha1.js"></script>  
<!-- para generar la hash de la cache -->
<script src="/includes/jquery/jquery.jCache.js"></script>
<script src="/includes/json/jsonStringify.js"></script>
<script src="/includes/AjaxHelper.js"></script>
<script src="/includes/util.js"></script>
<script src="/includes/MessageHelper.js"></script>
<script src="/includes/WindowHelper.js"></script>
<script src="/includes/AutocompleteHelper.js"></script>
<script src="/includes/jquery/jquery.alerts.js"></script>
<script src="/includes/jquery/jquery.dataTables.js"></script>
<script src="/includes/jquery/jquery.tooltip.js"></script>

<!-- variables de entorno sacadas de las preferencias del sistema -->
<script> M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %];  </script>

</head>



<!-- <script src="/includes/jquery/jquery.tablednd.js"></script> -->

[% INCLUDE 'datePicker.inc' %]

[% INCLUDE  'AutocompleteHelper.inc'  %]

[% INCLUDE  'WindowHelper.inc'  %]

[% INCLUDE  'SmallPlugins.inc'  %]
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
