<script type="text/javascript">
    $(function(){
        $(".ratings").children().not(":radio").hide();
        $(".ratings").stars({
            callback: function(ui, type, value)
            {
                $.post("demo1.php", {rate: value}, function(data)
                {
                    $("#ajax_response").html(data);
                });
            },
            cancelShow: false,
        });
    });
</script>


<div class="resultados_consulta">[% "T&eacute;rmino de b&uacute;squeda:" | i18n %] [% buscoPor %]</div>
<div class="resultados_consulta">[% "Cantidad de Registros:" | i18n %] [% cantidad %] en ([% timeSeg %] segundos)</div>

<div class="contenedor_paginador">[% paginador %]</div>

<table id="tablaResult" class="tabla_datos" border=1 align="center" cellspacing=0 cellpadding=0 width=100%>
    <thead>
        <tr class="tablaresultadoTitle" >
            <th align="center" width="30%">
                <a class="click" >[% "Im&aacute;gen" | i18n %]</a>
            </th>
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
            <th align="center" width="20%">
                [% "Valoraci&oacute;n" | i18n %]
            </th>
        </tr>
    </thead>
    <tbody>
<!-- Resultados de la busqueda -->
        [% FOREACH SEARCH_RESULTS %]
            <tr>
                <td class="titulo_result">
                    [% IF portada_registro %]
                        <img name="cover"  VALUE="" BORDER=0 src="/covers/[% portada_registro %]" title="Portada">
                    [% ELSE %]
                          <img src="/covers/no_image.jpg" 
                                alt="[% 'Sin Portada' | i18n %]"
                                title="[% 'Sin Portada' | i18n %]" />
                    [% END %]
                </td>
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
                <td>
                    [% INCLUDE 'rating.inc' %]
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
