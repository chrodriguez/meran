
<font size=2>Campos:</font>
<select size="1"  id="criteria" name="criteria">
        <option value="titulo">T&iacute;tulo</option>
        <option value="autor">Autor</option>
        <option value="tema">Tema</option>
        <option value="shelves">Estante Virtual</option>
</select>
&nbsp;&nbsp;&nbsp;

<input type="text" id="searchinc" size="25" name="searchinc">
<input name="se" id="se" onClick="searchinc('',1);" type="image" value="Buscar"  src="<!-- TMPL_VAR NAME='themelang' -->/images/menu-search.png" border="0" align="absbottom" >

<script language="javascript" type="text/javascript">

function swapa(id,src){
	document.getElementById(id).src=src;
}

se_image = new Image();
se_image.src = "<!-- TMPL_VAR NAME='themelang' -->/images/menu-search.png";
se_mouseover_image = new Image();
se_mouseover_image.src = "<!-- TMPL_VAR NAME='themelang' -->/images/menu-searchbis.png";

</script>


