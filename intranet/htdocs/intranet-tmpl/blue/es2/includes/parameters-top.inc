<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Par&aacute;metros</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<meta http-equiv="Content-Tipo" content="text/html; charset=iso-8859-1">
</head>
<body text="black" bgcolor="white" marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Ingres&oacute; como: <!-- TMPL_VAR NAME="loggedinusername" --> [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Entrar</a> a Koha</p>
<!-- /TMPL_IF -->
