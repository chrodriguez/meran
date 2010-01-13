<script>
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>
[% IF SEARCH_RESULTS %]
    <div class="resultados_consulta">[% "T&eacute;rmino de b&uacute;squeda:" | i18n %] [% buscoPor %]</div>
    <div class="resultados_consulta">[% "Cantidad de Registros:" | i18n %] [% cantidad %] en ([% timeSeg %] segundos)</div>

    <div class="contenedor_paginador">[% paginador %]</div>

    <table id="tablaResult" class="tabla_datos" border=1 align="center" cellspacing=0 cellpadding=0 width=100%>
        <thead>
            <tr class="tablaresultadoTitle" >
                <th align="center" width="15%">
                    <a class="click" >[% "Im&aacute;gen" | i18n %]</a>
                </th>
                <th align="center" width="30%">
                    <a class="click" onClick="ordenarPor('titulo')">[% "T&iacute;tulo" | i18n %]</a>
                </th>
                <th align="center" width="20%">
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
                <th align="center" width="20%">
                    [% "Favoritos" | i18n %]
                </th>
            </tr>
        </thead>
        <tbody>
    <!-- Resultados de la busqueda -->
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
                <tr>
                    <td class="titulo_result">
                        [% IF NIVEL.portadas_grupo %]
                                [% FOREACH NIVEL.portadas_grupo %]
                                    [% IF portada_registro %]
                                        <a class="fancylink" rel="group" href="/covers/[% portada_registro_big %]">
                                            <img name="cover"  
                                                VALUE="" BORDER=0 
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
                                <img name="cover"  VALUE="" BORDER=0 src="/covers/[% NIVEL.portada_registro %]" title="Portada">
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

                    <td class="autor_result click" onClick="filtrarPorAutor([% NIVEL.idAutor %])" title="[% 'Filtrar por Autor' | i18n %]">
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
                                <br>
                            [% END %]
                        [% ELSE %]
                            &nbsp;
                        [% END %]
                    </td>

                    <td>
                        [% IF NIVEL.disponibilidad %]
                            [% FOREACH NIVEL.disponibilidad %]
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
                        <div class="rating">
                            <form id="rating[% NIVEL.id1 %]" class="ratings">
                                <input type="radio" name="rate" value="1" id="rate1" />
                                <input type="radio" name="rate" value="2" id="rate2" />
                                <input type="radio" name="rate" value="3" id="rate3" />
                                <input type="radio" name="rate" value="4" id="rate4" />
                                <input type="radio" name="rate" value="5" id="rate5" />
                                <input type="radio" name="rate" value="6" id="rate6" />
                                <input type="radio" name="rate" value="7" id="rate7" />
                                <input type="radio" name="rate" value="8" id="rate8" />
                                <input type="radio" name="rate" value="9" id="rate9" />
                                <input type="radio" name="rate" value="10" id="rate10" />
                                <input type="submit" value="Enviar" />
                            </form>
                            <br style="clear:both" />
                        </div>
                    </td>
                    <td class="titulo_result">
                        [% IF NIVEL.esta_en_favoritos %]
                            [% PERL %]
                                print C4::AR::Filtros::to_Icon(
                                                                    boton   => "icon_borrar",
                                                                    onClick => "deleteFavorite('[% NIVEL.id1 %]');",
                                                                    title   => "[% 'Eliminar favorito' | i18n %]",
                                                                    alternClass => "botonCentradoTabla"
                                        ) ;
                            [% END %]
                        [% ELSE %]
                            [% PERL %]
                                print C4::AR::Filtros::to_Icon(
                                                                    boton   => "icon_agregar",
                                                                    onClick => "addFavorite('[% NIVEL.id1 %]');",
                                                                    title   => "[% 'Agregar a Favoritos' | i18n %]",
                                                                    alternClass => "botonCentradoTabla"
                                        ) ;
                            [% END %]
                        [% END %]
                    </td>
                </tr>
            [% END %]
        </tbody>
    </table>
    <br>
[% END %]
