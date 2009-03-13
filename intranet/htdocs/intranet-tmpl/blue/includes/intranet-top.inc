<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--Doctype is not required - can be HTML or XHTML-->
<html>

<script src="/intranet-tmpl/blue/includes/jquery/jquery.js"></script>
<script src="/intranet-tmpl/blue/includes/json/jsonStringify.js"></script>
<script src="/intranet-tmpl/blue/includes/AjaxHelper.js"></script>
<script src="/intranet-tmpl/blue/includes/WindowHelper.js"></script>
<!-- <script src="/intranet-tmpl/blue/includes/jquery/jquery-include.js"></script> -->
<script src="/intranet-tmpl/blue/includes/util.js"></script>
<script src="/intranet-tmpl/blue/includes/MessageHelper.js"></script>

<head>
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
<link rel="stylesheet" href="[% themelang %]/includes/menu/menu.css">
<script language="JavaScript" src="[% themelang %]/includes/menu/menu.js"></script>
<script language="JavaScript" src="[% themelang %]/includes/menu/menu_items.js"></script>
<script language="JavaScript" src="[% themelang %]/includes/menu/menu_tpl.js"></script>

<script language="JavaScript">
//    new menu (MENU_ITEMS, MENU_TPL);
</script>

<body>
<script type="text/javascript">
function mainmenu(){
// Oculto los submenus
// $(" #nav2 ul ").css({display: "none"});
// Defino que submenus deben estar visibles cuando se pasa el mouse por encima
$(" #nav2 li").hover(function(){
    $(this).find('li:first').slideDown(400);
    },function(){
        $(this).find('li:first').slideUp(400);
    });
}

function toggleMenu(){

    $('#nav2').toggle(400); 
}

$(document).ready(function(){
    mainmenu();
});
</script>

            

<table  width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" align="center">

<tr id="menu" valign="top" align="left" height="16" >
<td width="100%">
    [% INCLUDE   'menu.inc'  %]
</td>
</tr>
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