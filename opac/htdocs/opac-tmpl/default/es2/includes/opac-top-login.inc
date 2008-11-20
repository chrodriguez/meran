
<html>
<head>

<title>Biblioteca - Facultad de Ciencias Econ&oacute;micas - U.N.L.P.</title>

<script src="/opac-tmpl/default/es2/includes/jquery/jquery.js"></script>
<script src="/opac-tmpl/default/es2/includes/AjaxHelper.js"></script>
<script src="/opac-tmpl/default/es2/includes/MessageHelper.js"></script>

<link rel="stylesheet" type="text/css" href="[% themelang %]/includes/opac.css">
</head>
<script language="javascript" type="text/javascript">
function swap(id,src){
document.getElementById(id).src=src;
}

// FIXME esto esta repetido en el opac-top.inc, ver si se puede unificar
function cambiarIdioma() {
	$('#lang_server').val($('#language').val());
	$('#url').val(location.pathname);
	$('#formLang').submit();
}

</script>

<body>
<table class="tope" align="center" cellpadding=0 cellspacing=0 width="90%"  border=0> 

<tr>
[% IF loggedinusername %]
      <td align="left" valign="middle">
  &nbsp;      Ingres&oacute; como:<b> [% loggedinusername %]</b>
         <a href="/cgi-bin/koha/opac-user.pl"  onMouseOut="swap('mem','[% themelang %]/images/areamiembros.png ')" 
	onMouseOver="swap('mem','[% themelang %]/images/areamiembrosbis.png ')">
         <img src="[% themelang %]/images/areamiembros.png"  id="mem" title="Miembros" hspace=0 cspace=0 border=0 name="mem" align="absmiddle">
        </a>

  <a href="/cgi-bin/koha/opac-main.pl?logout.x=1"  onMouseOut="swap('exit','[% themelang %]/images/exit.png ')" 
	onMouseOver="swap('exit','[% themelang %]/images/exitbis.png ')">
	<img src="[% themelang %]/images/exit.png" name="exit" id="exit" title="Salir" hspace=0 cspace=0 border=0  name="exit" align="absmiddle">
  </a>
       </td>
[% ELSE %]
	[%  "OPAC" | setComboLang %]
[% END %]
</tr>
<tr><td>&nbsp; </td></tr>
<tr>
	<td align="center">
       <img src="[% themelang %]/images/banner.png" width="100%" alt="KOHA: B&uacute;squeda en Cat&aacute;logo" border=0 align="absbottom">
        </td>
</tr></form>
</table>

<table class="tope" align="center" cellpadding=0 cellspacing=0 width="90%"  border="0">
<tr align="right">
	<td> [% INCLUDE 'opac-search.inc' %]</td>
        <td >&nbsp;</td>
</tr>
</table>

<table cellpadding="0" cellspacing="0" width="90%" border="0"  class="top" align="center">
<tr><td><br></td></tr>
<tr class="tope" >  
	 <td >&nbsp;</td>

	<td class="pagetitulo">[% pagetitle %]</td>

        <td align="right" valign="middle">

[% IF hiddesearch %]
[% ELSE %]
<a href="/cgi-bin/koha/opac-search.pl"  onMouseOut="swap('cat','[% themelang %]/images/menu-catalogo.png ')" 
	onMouseOver="swap('cat','[% themelang %]/images/menu-catalogobis.png ')" >
        <img src="[% themelang %]/images/menu-catalogo.png" name="cat" id="cat" title="Buscar" hspace=0 cspace=0 border=0 
	name="menu-search" align="absbottom">
        </a>
[% END %]
<a href="/join.html"  onMouseOut="swap('join','[% themelang %]/images/menu-join.png')" 
	onMouseOver="swap('join','[% themelang %]/images/menu-joinbis.png')" >
        <img name="join" src="[% themelang %]/images/menu-join.png"
        title="Registrarse" hspace=0 vspace=0 border=0 name="menu-join" id="join" align="absbottom" ></a>

<a href="/cgi-bin/koha/opac-main.pl" onMouseOut="swap('home','[% themelang %]/images/menu-home.png ')" 
	onMouseOver="swap('home','[% themelang %]/images/menu-homebis.png ')" >
	<img src="[% themelang %]/images/menu-home.png" name="home" id="home"
	title="Inicio" hspace=0 vspace=0 border=0 name="menu-home" align="absbottom"  ></a></td>

	 <td>&nbsp; </td>
        </tr>
</table>
	
<!-------------------------MAIN BODY OF PAGE-------------------------->
