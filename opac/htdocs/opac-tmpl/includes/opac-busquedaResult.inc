<script type="text/javascript">
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>
[% IF SEARCH_RESULTS %]
    [% IF !not_show_search_details %]
        <div class="resultados_consulta">[% "T&eacute;rmino de b&uacute;squeda:" | i18n %] [% buscoPor %]</div>
        <div class="resultados_consulta">[% "Cantidad de Registros:" | i18n %] [% cantidad %] en ([% timeSeg %] segundos)</div>

        <div class="contenedor_paginador">[% paginador %]</div>
    [% END %]

    <table id="tablaResult" class="tabla_datos" cellspacing='0' cellpadding='0' style="text-align:center; width:100%; border:1;">
            <tr class="tablaresultadoTitle" >
                <th align="center">
                    <a class="click" >[% "Im&aacute;gen" | i18n %]</a>
                </th>
                <th align="center">
                    <a class="click" onclick="ordenarPor('titulo')">[% "T&iacute;tulo" | i18n %]</a>
                </th>
                <th align="center">
                    <a class="click" onclick="ordenarPor('nomCompleto')">[% "Autor" | i18n %] </a>
                </th>
                <th align="center">
                    [% "Edici&oacute;n/A&ntilde;o" | i18n %]
                </th>
                <th align="center">
                    [% "Disponibilidad" | i18n %]
                </th>
                <th align="center">
                    [% "Valoraci&oacute;n" | i18n %]
                </th>
                <th align="center">
                    [% "Favoritos" | i18n %]
                </th>
            </tr>
    <!-- Resultados de la busqueda -->
            [% FOREACH NIVEL IN SEARCH_RESULTS %]
                <tr>
                    <td class="titulo_result">
                        [% IF NIVEL.portadas_grupo %]
                                [% FOREACH NIVEL.portadas_grupo %]
                                    [% IF portada_registro %]
                                        <a class="fancylink" rel="group" href="/covers/[% portada_registro_big %]">
                                            <img alt="cover"
                                                src="/covers/[% portada_registro %]" title="Portada" style="float:left"
                                            />
                                        </a>
                                    [% ELSE %]
                                          <a class="fancylink" href="/covers/no_image.jpg">
                                              <img src="/covers/no_image.jpg" 
                                                    alt="[% 'Sin Portada' | i18n %]"
                                                    title="[% 'Sin Portada' | i18n %]" style="float:left" 
                                              />
                                          </a>
                                    [% END %]
                                [% END %]
                        [% ELSE %]
                            [% IF NIVEL.portada_registro %]
                                [% IF NIVEL.portada_registro_big %]
                                    <a class="fancylink" rel="group" href="/covers/[% NIVEL.portada_registro_big %]">
                                        <img alt="cover" src="/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                    </a>
                                [% ELSE %]
                                    [% IF NIVEL.portada_registro_medium %]
                                        <a class="fancylink" rel="group" href="/covers/[% NIVEL.portada_registro_medium %]">
                                            <img alt="cover" src="/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                        </a>
                                    [% ELSE %]
                                            <img alt="cover" src="/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                    [% END %]
                                [% END %]
                            [% ELSE %]
                                  <img src="/covers/no_image.jpg" 
                                        alt="[% 'Sin Portada' | i18n %]"
                                        title="[% 'Sin Portada' | i18n %]" />
                            [% END %]
                        [% END %]
                    </td>
                    <td class="titulo_result">	
                        [% IF NIVEL.titulo %]
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "( [% NIVEL.hits %] ) - [% NIVEL.titulo %]",
                                                                url =>      "/cgi-bin/koha/opac-detail.pl", 
                                                                params =>   ["id1=[% NIVEL.id1 %]"],
                                                                title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                            ) ;
                            [% END %]
                        [% ELSE %]
                            &nbsp;
                        [% END %]
                    </td>

                    <td class="autor_result click" onclick="filtrarPorAutor([% NIVEL.idAutor %])" title="[% 'Filtrar por Autor' | i18n %]">
                        [% IF NIVEL.nomCompleto %]
                            [% NIVEL.nomCompleto %]
                        [% ELSE %]
                            &nbsp;
                        [% END %]
                    </td>

                    <td>
                        [% IF NIVEL.grupos %]
                            [% FOREACH NIVEL.grupos %]
                                [% IF edicion %]
                                    [% edicion %] &nbsp;
                                [% END %]
                                [% IF anio_publicacion %]
                                    ([% anio_publicacion %])
                                [% END %]
                                [% IF volume %] 
                                    t [% volume %]
                                [% END %]
                                <br />
                            [% END %]
                        [% ELSE %]
                            &nbsp;
                        [% END %]
                    </td>

                    <td>
                        [% IF NIVEL.disponibilidad %]
                            [% FOREACH NIVEL.disponibilidad %]
                                <b>[% tipoPrestamo %]</b> [% cantTotal %]
                                <br />
                                <div style="margin-right:4px">
                                    [% reservados %]
                                    <br /> 
                                    [% prestados %]
                                    <br />
                                </div>
                            [% END %]
                        [% ELSE %]
                            &nbsp;
                        [% END %]
                    </td>
                    <td>
                        <div class="rating">
                            <form id="rating[% NIVEL.id1 %]" class="ratings" action="">
                                <div>
                                  <input type="radio" name="rate" value="1" />
                                  <input type="radio" name="rate" value="2" />
                                  <input type="radio" name="rate" value="3" />
                                  <input type="radio" name="rate" value="4" />
                                  <input type="radio" name="rate" value="5" />
                                  <input type="radio" name="rate" value="6" />
                                  <input type="radio" name="rate" value="7" />
                                  <input type="radio" name="rate" value="8" />
                                  <input type="radio" name="rate" value="9" />
                                  <input type="radio" name="rate" value="10" />
                                  <input type="submit" value="Enviar" />
                                </div>
                            </form>
                            <br style="clear:both" />
                        </div>
                    </td>
                    <td class="titulo_result">
                        [% IF NIVEL.esta_en_favoritos %]
                            [% PERL %]
                                print C4::AR::Filtros::to_Icon(
                                                                    boton   => "icon_borrar",
                                                                    onclick => "deleteFavorite('[% NIVEL.id1 %]');",
                                                                    title   => "[% 'Eliminar favorito' | i18n %]",
                                                                    alternClass => "botonCentradoTabla"
                                        ) ;
                            [% END %]
                        [% ELSE %]
                            [% PERL %]
                                print C4::AR::Filtros::to_Icon(
                                                                    boton   => "icon_agregar",
                                                                    onclick => "addFavorite('[% NIVEL.id1 %]');",
                                                                    title   => "[% 'Agregar a Favoritos' | i18n %]",
                                                                    alternClass => "botonCentradoTabla"
                                        ) ;
                            [% END %]
                        [% END %]
                    </td>
                </tr>
            [% END %]
    </table>
    <br />
[% END %]
<!-- FIX PARA W3C PORQUE NO SE PERMITEN SCRIPT DENTRO DE TABLAS -->
[% FOREACH NIVEL IN SEARCH_RESULTS %]
    <script type="text/javascript">
        $(function(){
            $("#rating[% NIVEL.id1 %]").children().not(":radio").hide();
            $("#rating[% NIVEL.id1 %]").stars({
                cancelShow: false,
                split: 2,
                disabled: true,
            });
            $("#rating[% NIVEL.id1 %]").stars("select",[% NIVEL.rating %]);
        });
    </script>
[% END %]

