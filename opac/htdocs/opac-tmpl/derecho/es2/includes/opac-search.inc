<form action="/cgi-bin/koha/opac-searchresults.pl" method=get>
<font size=2>Campos:</font>
<select size="1"  name="criteria">
        <option value="keyword">Todos</optioni>
        <option value="title">T&iacute;tulo</option>
        <option value="author">Autor</option>
        <option value="subjectitems">Tema</option>
        <option value="shelves">Estante Virtual</option>
</select>
&nbsp;&nbsp;&nbsp;
<input type="text"  size="25" name="searchinc">

<a  onMouseOut="swap('se','<!-- TMPL_VAR NAME='themelang' -->/images/menu-search.png')" onMouseOver="swap('se','<!-- TMPL_VAR NAME='themelang' -->/images/menu-searchbis.png')" > 
<input name="se" id="se" type="image" value="Buscar"  src="<!-- TMPL_VAR NAME='themelang' -->/images/menu-search.png" border="0" align="absbottom" >
</a>
</form>
<!--<script language="javascript" type="text/javascript">-->

<script language="javascript" type="text/javascript">
function swapa(id,src){
document.getElementById(id).src=src;
}
se_image = new Image();
se_image.src = "<!-- TMPL_VAR NAME='themelang' -->/images/menu-search.png";
se_mouseover_image = new Image();
se_mouseover_image.src = "<!-- TMPL_VAR NAME='themelang' -->/images/menu-searchbis.png";

</script>


