<html>
<head>
<title>Biblioteca - Facultad de Ciencias Econ&oacute;micas - U.N.L.P.</title>

<link rel="stylesheet" type="text/css" href="[% themelang %]/includes/opac.css">

<script language="javascript" type="text/javascript">
token= '[% token %]';
</script>

<script src="/includes/jquery/jquery.js"></script>
<script src="/includes/AjaxHelper.js"></script>
<script src="/includes/MessageHelper.js"></script>
<script src="/includes/json/jsonStringify.js"></script>
<script src="/opac-tmpl/default/includes/navegador.js"></script>
<script src="/includes/jquery/jquery-highlight.js"></script>
<script src="/includes/util.js"></script>
<script src="/opac-tmpl/default/includes/opac-searchFunciones.js"></script>
<script src="/opac-tmpl/default/includes/circulacionOPAC.js"></script>
<script src="/opac-tmpl/default/includes/favoritos.js"></script>


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

</script>
<body>

<noscript>
    <div class='tableMsgUser'>
        <font class='fontMsgUser'>
                <b>[% "Su navegador no soporta o no tiene habilidato Javascript" | i18n %]</b>
        </font>
    </div>
</noscript>
<table class="tope" align="center" cellpadding=0 cellspacing=0 width="95%"  border=0> 
<tr>
[% IF loggedinusername %]
        <td align="left" valign="middle">
  	[% "&nbsp;Ingres&oacute; como:" | i18n %]<b> [% loggedinusername %]</b>
	[%  "OPAC" | setComboLang %]

	<a href="/cgi-bin/koha/opac-user.pl?token=[% token %]"  onMouseOut="swap('mem','[% themelang %]/images/areamiembros.png ')" 
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
<tr>
<tr>
<tr><td>&nbsp; </td></tr>
<tr>
	<td align="center">
	<table width="100%"  border="0">
  	<tr>
    	<td><table width="100%"  border="0" cellpadding="0" cellspacing="0">
      	<tr>
		<td align="center">
			<h4>
			<img class="banner" src="[% themelang %]/images/nuevas/banner.png" 
			title="Biblioteca, Facultad de Ciencias Econ&oacute;micas">
			</h4>
		</td>

      	</tr>
    	</table>
</td>
</tr>
</table>

<table class="tope" align="center" cellpadding=0 cellspacing=0 width="100%"  border="0">
<tr align="right">
	<td> [% INCLUDE "opac-search.inc" %]</td>
        <td >&nbsp;</td>
</tr>
</table>

<table cellpadding="0" cellspacing="0" width="100%" border="0"  class="top" align="center">
<tr><td><br></td></tr>
<tr class="tope" >  

	<td >&nbsp;</td>
	<td class="pagetitulo" valign="middle">[% pagetitle %]</td>
        <td align="right" valign="middle">

[% IF loggedinusername %]
<input type="hidden" value="" name="bookmarks" id="bookmarks">

<!-- *******************************************Favoritos************************************************* -->
<a class="click" onClick="consultarFavoritos();"
	onMouseOut="swap('pstop','[% themelang %]/images/favorito.png')" 
	onMouseOver="swap('pstop','[% themelang %]/images/favoritobis.png')">
<input id="pstop" type="image" value="publicshelf"  
src="[% themelang %]/images/favorito.png" title="Ver mis favoritos" hspace=0 cspace=0 border=0 name="pstop" align="absbottom">
</a>
<!--*******************************************************************************************************-->
[% ELSE %]
<a href="/join.html"  onMouseOut="swap('join','[% themelang %]/images/menu-join.png')" 
	onMouseOver="swap('join','[% themelang %]/images/menu-joinbis.png')" >
        <img name="join" src="[% themelang %]/images/menu-join.png"
	        title="Registrarse" hspace=0 vspace=0 border=0 name="menu-join" id="join" align="absbottom" ></a>
[% END %]	


[% IF hiddesearch %]
[% ELSE %]
<!--<a href="/cgi-bin/koha/opac-search.pl"  onMouseOut="swap('cat','[% themelang %]/images/menu-catalogo.png ')" 
	onMouseOver="swap('cat','[% themelang %]/images/menumenu.png ')" >
        <img src="[% themelang %]/images/menu-catalogo.png" name="cat" id="cat" title="Buscar" hspace=0 cspace=0 border=0 
	name="menu-search" align="absbottom">
</a>-->

    [% PERL %]
				    print C4::AR::Filtros::link_to(	text => 	"<img src='[% themelang %]/images/menu-catalogo.png' name='cat' id='cat' 
															    title='Buscar' hspace=0 cspace=0 border=0 name='menu-search' align='absbottom'>",
												    url => 		"/cgi-bin/koha/opac-search.pl", 

											    ) ;
    [% END %]
[% END %]

<!-- ********************se deshabilita hasta q se complete para la V3************************************ -->
<a class="click" onClick="consultarEstanteVirtual();"
 onMouseOut="swap('estantes','[% themelang %]/images/estantes.png ')" onMouseOver="swap('estantes','[% themelang %]/images/estantesbis.png ')" >
        <img src="[% themelang %]/images/estantes.png" name="estantes" id="estantes"
        title="Estantes Virtuales" hspace=0 vspace=0 border=0 name="menu-home" align="absbottom"  >
</a>
<!--*******************************************************************************************************-->

<!--<a href="/cgi-bin/koha/opac-main.pl" onMouseOut="swap('home','[% themelang %]/images/menu-home.png ')" 
	onMouseOver="swap('home','[% themelang %]/images/menu-homebis.png ')" >
	
</a>-->

    [% PERL %]
                    print C4::AR::Filtros::link_to( text =>     '<img src="[% themelang %]/images/menu-home.png" name="home" id="home"
                                                                 title="Inicio" hspace=0 vspace=0 border=0 name="menu-home" align="absbottom"  >',
                                                    url =>      "/cgi-bin/koha/opac-main.pl", 

                                                ) ;
    [% END %]

</td>
	 <td>&nbsp; </td>
  </tr>
</table>
	
<!-------------------------MAIN BODY OF PAGE-------------------------->
