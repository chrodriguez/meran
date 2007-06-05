<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Circulaci&oacute;n</title>
<meta http-equiv="Content-Tipo" content="text/html; charset=iso-8859-1">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
function focusOnFirst (){
if (eval(document.forms[0])){
if  (document.forms[0].elements[0].type != 'hidden') {
  document.forms[0].elements[0].focus();
}}
<!-- TMPL_IF name="ticket_string" -->
<!-- Nahuel --->
window.open ("receipt.pl<!-- TMPL_VAR name="ticket_string" -->", "Boleta","width=600,height=400,status=no,location=no,menubar=no,personalbar=no,resizable=no,scrollbars=no");
<!-- /TMPL_IF -->

}
// end hiding -->
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
</head>
<body text="black" bgcolor="white" marginheight=0 marginwidth=0 leftmargin=0 topmargin=0 onLoad="javascript:focusOnFirst()">

<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Ingres&oacute; como: <!-- TMPL_VAR NAME="loggedinusername" --> [<a  target="_parent"  href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Entrar</a> a Koha</p>
<!-- /TMPL_IF -->
