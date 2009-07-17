
<div class="resultados_consulta">[% "T&eacute;rmino de b&uacute;squeda:" | i18n %] [% buscoPor %]</div>
<div class="resultados_consulta">[% "Cantidad de Registros:" | i18n %] [% cantidad %] en ([% timeSeg %] segundos)</div>

<div class="contenedor_paginador">[% paginador %]</div>

<table id="tablaResult" class="tabla_datos tablaResult" border=1 align="center" cellspacing=0 cellpadding=0 width=100%>
    <thead>
        <tr class="tablaresultadoTitle" >
            [% IF nro_socio %]
                <th>
                    <a id="todos" class="click">
                        <img    src="[% temas %]/[% tema %]/imagenes/iconos/icon_check.png" 
                                title="Invertir la selecci&oacute;n" border=0>
                    </a>
                </th>
            [% END %]
            <th align="center" width="30%">
                <a class="click" onClick="ordenarPor('titulo')">[% "T&iacute;tulo" | i18n %]</a>
            </th>
            <th align="center" width="30%">
                <a class="click" onClick="ordenarPor('nomCompleto')">[% "Autor" | i18n %] </a>
            </th>
            <th align="center" width="20%">
                [% "Edici&oacute;n/A&ntilde;o" | i18n %]
            </th>
            <th align="center" width="20%">
                [% "Disponibilidad" | i18n %]
            </th>
        </tr>
    </thead>
    <tbody>
<!-- Resultados de la busqueda -->
        [% FOREACH SEARCH_RESULTS %]
            <tr>
                [% IF nro_socio %]
                    <td valign="middle" align="center">
                        <input type=checkbox name=checkbox value="[% id1 %]" 
                                id="[% id1 %]">
                    </td>
                [% END %]
                <td class="titulo_result">	
                    [% IF titulo %]
                        [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "( [% hits %] ) - [% titulo %]",
                                                            url =>      "/cgi-bin/koha/opac-detail.pl", 
                                                            params =>   ["id1=[% id1 %]"],
                                                            title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                        ) ;
                        [% END %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>

                <td class="autor_result click" onClick="filtrarPorAutor([% idAutor %])" title="[% 'Filtrar por Autor' | i18n %]">
                    [% IF nomCompleto %]
                        [% nomCompleto %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>

                <td>
                    [% IF grupos %]
                        [% FOREACH grupos %]
                            [% IF edicion %]
                                [% edicion %] &nbsp;
                            [% END %]
                            [% IF anio_publicacion %]
                                ([% anio_publicacion %])
                            [% END %]
                            [% IF volume %] 
                                t [% volume %]
                            [% END %]
                            <br>
                    [% END %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>

                <td>
                    [% IF disponibilidad %]
                        [% FOREACH disponibilidad %]
                            <b>[% tipoPrestamo %]</b> [% cantTotal %]
                            <br>
                            <div style="margin-right:4px">
                                [% reservados %]
                                <br> 
                                [% prestados %]
                                <br>
                            </div>
                        [% END %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>	
            </tr>
        [% END %]
    </tbody>
</table>
<br>

[% IF nro_socio %]
<!-- FIXME creo q no se usa mas -->
<!--    <input type="hidden" value="" name="bookmarks" id="bookmarks">
    <a  onMouseOut="swap('ps','[% themelang %]/images/favoritos.png')" 		
        onMouseOver="swap('ps','[% themelang %]/images/favoritosbis.png')">
        <input onClick="agregarAFavoritos();" name="ps" id="ps" type="image" value="publicshelf"  
               src="[% themelang %]/images/favoritos.png" border="0" title="Agregar a favoritos">
    </a>-->
[% END %]
