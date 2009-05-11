<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--Doctype is not required - can be HTML or XHTML-->
<html>

<script language="javascript" type="text/javascript">
 token= '[% token %]';
</script>

<script src="/includes/jquery/jquery.js"></script>
<script src="/includes/jquery/jquery.menu.js"></script>
<script src="/includes/md5.js"></script> 
<!-- para generar la hash de la cache -->
<script src="/includes/jquery/jquery.jCache.js"></script> 
<script src="/includes/json/jsonStringify.js"></script>
<script src="/includes/AjaxHelper.js"></script>
<script src="/includes/util.js"></script>
<script src="/includes/MessageHelper.js"></script>
<script src="/includes/WindowHelper.js"></script>
<script src="/includes/AutocompleteHelper.js"></script>


[% INCLUDE  'AutocompleteHelper.inc'  %]

[% INCLUDE  'WindowHelper.inc'  %]
<!-- Se incluyen los mensajes para la catalogacion -->
[% INCLUDE "message_INTRA.inc" %]

<head>
<title>Koha::UNLP</title>
<link rel="stylesheet" type="text/css" href="[% themelang %]/includes/intranet.css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>

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

<table  width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center">

<tr id="menu-container" class="main-header">
<td class="main-header">
    [% INCLUDE   'menu.inc'  %]
</td>
</tr>
<tr valign="top">
  <td align="center" colspan="2">
  <table  width="100%"  border="0" cellspacing="0" cellpadding="0">
   <tr>
    <td width="410" >
		<img src="[% themelang %]/images/back/backup.png" width="410" height="61" hspace="0" vspace="0" align="top" border="0">
	</td>
    <td height="61" >
		<img src="[% themelang %]/images/back/backupmidle.png" width="100%" height="61" hspace="0" vspace="0" align="top" border="0">
	</td>
    <td width="20" >
		<img src="[% themelang %]/images/back/backupright.png" width="20" height="61" hspace="0" vspace="0" border="0" align="top">
	</td>
  </tr>
</table>
        <table width="99%" height="78%" border="0" cellspacing="0" cellpadding="0" bgcolor="#f7f6f6">
    <tr> <td width="9" class="includePNGizquierdo"></td>
    <td>
 <table align="left" bgcolor="#f7f6f6" width="99%" height="100%" border="0" cellspacing="0" cellpadding="0" class="texto">
    <tr valign="top"><td align="left"> 

<!-- usado como referencia por el MessageHelper     -->
<div id="end_top"></div>