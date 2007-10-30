
<html>
<head>

<title>Biblioteca - Facultad de Ciencias Econ&oacute;micas - U.N.L.P.</title>


<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/opac.css">
</head>
<script language="javascript" type="text/javascript">
function swap(id,src){
document.getElementById(id).src=src;
}
</script>

<body>
<table class="tope" align="center" cellpadding=0 cellspacing=0 width="90%"  border=0> 
<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
<tr><!-- TMPL_IF NAME="loggedinusername" -->
      <td align="left" valign="middle">
         <a href="/cgi-bin/koha/opac-user.pl"  onMouseOut="swap('mem','<!-- TMPL_VAR NAME='themelang' -->/images/areamiembros.png ')" onMouseOver="swap('mem','<!-- TMPL_VAR NAME='themelang' -->/images/areamiembrosbis.png ')">
         <img src="<!-- TMPL_VAR NAME='themelang' -->/images/areamiembros.png"  id="mem" title="Miembros" hspace=0 cspace=0 border=0 name="mem" align="absmiddle">
        </a>

  <a href="/cgi-bin/koha/opac-main.pl?logout.x=1"  onMouseOut="swap('exit','<!-- TMPL_VAR NAME='themelang' -->/images/exit.png ')" onMouseOver="swap('exit','<!-- TMPL_VAR NAME='themelang' -->/images/exitbis.png ')">
<img src="<!-- TMPL_VAR NAME='themelang' -->/images/exit.png" name="exit" id="exit" title="Salir" hspace=0 cspace=0 border=0  name="exit" align="absmiddle">
        </a>
       </td>
       <td align="right">&nbsp;      Ingres&oacute; como:<b> <!-- TMPL_VAR NAME="loggedinusername" --></b></td>

        <!-- /TMPL_IF -->
</tr>
<tr><td>&nbsp; </td>
<td>&nbsp;</td>
</tr>
<tr>

<table width="90%"  border="0" align="center">
        <tr>
	        <td><table width="100%"  border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td ><p><img src="<!-- TMPL_VAR NAME='themelang' -->/images/izquierda.png" width="526" height="120" title="Biblioteca, Facultad de Inform&aacute;tica"></p></td>        <td width="100%" background="<!-- TMPL_VAR NAME='themelang' -->/images/medio.png" height="120">&nbsp;</td>
		<td width="71"><p><img src="<!-- TMPL_VAR NAME='themelang' -->/images/derecha.png" width="71" height="120"></p></td>
		</tr>
		</table>
							


</tr></form>
</table>

<table class="tope" align="center" cellpadding=0 cellspacing=0 width="90%"  border="0">
<tr align="right">
	<td> <!-- TMPL_INCLUDE NAME="opac-search.inc" --></td>
        <td >&nbsp;</td>
</tr>
</table>

<table cellpadding="0" cellspacing="0" width="90%" border="0"  class="top" align="center">
<tr><td><br></td></tr>
<tr class="tope" >  
	 <td >&nbsp;</td>

	<td class="pagetitulo"><!-- TMPL_VAR Name="pagetitle" --></td>

        <td align="right" valign="middle">

<!-- TMPL_IF NAME="hiddesearch" -->
<!-- TMPL_ELSE -->
<a href="/cgi-bin/koha/opac-search.pl"  onMouseOut="swap('cat','<!-- TMPL_VAR NAME='themelang' -->/images/menu-catalogo.png ')" onMouseOver="swap('cat','<!-- TMPL_VAR NAME='themelang' -->/images/menu-catalogobis.png ')" >
        <img src="<!-- TMPL_VAR NAME='themelang' -->/images/menu-catalogo.png" name="cat" id="cat" title="Buscar" hspace=0 cspace=0 border=0 name="menu-search" align="absbottom">
        </a>
<!-- /TMPL_IF -->
<a href="<!-- TMPL_VAR NAME='themelang' -->/join.html"  onMouseOut="swap('join','<!-- TMPL_VAR NAME='themelang' -->/images/menu-join.png')" onMouseOver="swap('join','<!-- TMPL_VAR NAME='themelang' -->/images/menu-joinbis.png')" >
        <img name="join" src="<!-- TMPL_VAR NAME='themelang' -->/images/menu-join.png"
        title="Registrarse" hspace=0 vspace=0 border=0 name="menu-join" id="join" align="absbottom" ></a>

<a href="/cgi-bin/koha/opac-main.pl" onMouseOut="swap('home','<!-- TMPL_VAR NAME='themelang' -->/images/menu-home.png ')" onMouseOver="swap('home','<!-- TMPL_VAR NAME='themelang' -->/images/menu-homebis.png ')" >
	<img src="<!-- TMPL_VAR NAME='themelang' -->/images/menu-home.png" name="home" id="home"
	title="Inicio" hspace=0 vspace=0 border=0 name="menu-home" align="absbottom"  ></a></td>

       
	 <td>&nbsp; </td>
        </tr>
</table>
	
<!-------------------------MAIN BODY OF PAGE-------------------------->
