<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--Doctype is not required - can be HTML or XHTML-->
<html>

<script src="/intranet-tmpl/blue/includes/jquery/jquery.js"></script>
<script src="/intranet-tmpl/blue/includes/json/jsonStringify.js"></script>
<script src="/intranet-tmpl/blue/includes/AjaxHelper.js"></script>
<script src="/intranet-tmpl/blue/includes/WindowHelper.js"></script>
<script src="/intranet-tmpl/blue/includes/util.js"></script>
<script src="/intranet-tmpl/blue/includes/MessageHelper.js"></script>

<head>
<noscript>
    <div class='tableMsgUser'>
        <font class='fontMsgUser'>
                <b>[% 'Su navegador no soporta o no tiene habilidato Javascript' | i18n %]</b>
        </font>
    </div>
</noscript>

<title>Koha::UNLP</title>
<link rel="stylesheet" type="text/css" href="[% themelang %]/includes/intranet.css">
<meta http-equiv="Content-Tipo" content="text/html; charset=iso-8859-1">
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

</script>

<body>


<table  width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center">

<tr id="menu" valign="top" align="center" height="16" >
<td width="100%">
[% INCLUDE   'menu.inc'  %]
</td>
</tr>
<tr>
<td align="right">  

[% IF loggedinusername %]
    	<p align="right" class="login">Ingres&oacute; como:<b> [% loggedinusername %]</b> [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]</p>
[% ELSE %]
	<p align="right" class="login"><a href=/cgi-bin/koha/opac-user.pl>Entrar a Koha</a></p>
[% END %]

[%  "INTRA" | setComboLang %]

<!--<form id="formLang" action="/cgi-bin/koha/intra-language.pl" method="POST">
	<input id="lang_server" name="lang_server" type="hidden" value="">
	<input id="url" name="url" type="hidden" value="">
	<select id="language" onChange="cambiarIdioma()">
		<option value="nl_NL">NL</option>
		<option value="es_ES">ES</option>
		<option value="en_EN">EN</option>
	</select>
</form>-->

</td></tr>
<tr valign="top">
  <td align="center" colspan="2">
  <table  width="100%"  border="0" cellspacing="0" cellpadding="0">
   <tr>
    <td width="410" ><img src="[% themelang %]/images/back/backup.png" width="410" height="61" hspace="0" vspace="0" align="top" border="0"> </td>
    <td height="61" ><img src="[% themelang %]/images/back/backupmidle.png" width="100%" height="61" hspace="0" vspace="0" align="top" border="0"></td>
    <td width="20" ><img src="[% themelang %]/images/back/backupright.png" width="20" height="61" hspace="0" vspace="0" border="0" align="top"></td>
      </tr>
</table>
        <table width="99%" height="78%" border="0" cellspacing="0" cellpadding="0" bgcolor="#f7f6f6">
	 <tr> <td width="9" class="includePNGizquierdo"></td>
	 <td>
 <table align="left" bgcolor="#f7f6f6" width="99%" height="100%" border="0" cellspacing="0" cellpadding="0" class="texto">
	 <tr valign="top"><td align="left"> 
	 
<div id="end_top"></div>