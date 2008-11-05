<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--Doctype is not required - can be HTML or XHTML-->
<html>

<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/json/jsonStringify.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/AjaxHelper.js"></script>

<head>
<title>Koha::UNLP</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name='themelang' -->/includes/intranet.css">
<meta http-equiv="Content-Tipo" content="text/html; charset=iso-8859-1">
</head>

<script language="javascript" type="text/javascript">

function swap(id,src){
	document.getElementById(id).src=src;
}

</script>

<body>


<table  width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center">

<tr id="menu" valign="top" align="center" height="16" >
<td width="100%">
<!-- TMPL_INCLUDE NAME="/menu/menu.inc" -->
</td>
</tr>
<tr>
<td align="right">  

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="right" class="login">Ingres&oacute; como:<b> <!-- TMPL_VAR NAME="loggedinusername" --></b> [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]</p>
<!-- TMPL_ELSE -->
    <p align="right" class="login"><a href=/cgi-bin/koha/opac-user.pl>Entrar a Koha</a></p>
<!-- /TMPL_IF -->

</td></tr>
<tr valign="top">
  <td align="center" colspan="2">
  <table  width="100%"  border="0" cellspacing="0" cellpadding="0">
   <tr>
    <td width="410" ><img src="<!-- TMPL_VAR name='themelang' -->/images/back/backup.png" width="410" height="61" hspace="0" vspace="0" align="top" border="0"> </td>
    <td height="61" ><img src="<!-- TMPL_VAR name='themelang' -->/images/back/backupmidle.png" width="100%" height="61" hspace="0" vspace="0" align="top" border="0"></td>
    <td width="20" ><img src="<!-- TMPL_VAR name='themelang' -->/images/back/backupright.png" width="20" height="61" hspace="0" vspace="0" border="0" align="top"></td>
      </tr>
       </table>
        <table width="100%" height="78%" border="0" cellspacing="0" cellpadding="0" bgcolor="#f7f6f6">
	 <tr> <td width="9" class="includePNGizquierdo"></td>
	 <td>
	 <table align="left" bgcolor="#f7f6f6" width="99%" height="100%" border="0" cellspacing="0" cellpadding="0" class="texto">
	 <tr valign="top"><td align="left"> 
	 
<div id="end_top"></div>