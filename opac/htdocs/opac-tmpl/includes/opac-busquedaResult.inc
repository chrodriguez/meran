<script type="text/javascript">

	function ordenarPor(ord){
	    //seteo el orden de los resultados
	    
	}

    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>

[% IF show_search_details %]
     <div class="resultados_consulta">[% "T&eacute;rmino de b&uacute;squeda:" | i18n %] [% buscoPor %]</div>
     <br />
     <div class="resultados_consulta bold">[% "Cantidad de Registros:" | i18n %] [% cantidad %] en ([% timeSeg %] segundos)</div>
     <br />
     <div class="contenedor_paginador">[% paginador %]</div>
     <br />
     [% IF only_available %]
        <h2 class="advice"> [% ' Solo se muestran ejemplares disponibles.' | i18n %] <a href="[% url_todos %]">([% ' Mostrar todos' | i18n %])</a></h2>
     [% END %]
[% END %]


[% IF (cantidad > 0) || ( (!from_suggested) && (suggested) )%]
    [% FOREACH NIVEL IN SEARCH_RESULTS %]
        <script type="text/javascript">
            $(function(){
                $("#rating[% NIVEL.id1 %]").children().not(":radio").hide();
                $("#rating[% NIVEL.id1 %]").stars({
                    cancelShow: false,
                    split: 2,
                    disabled: true
                });
                $("#rating[% NIVEL.id1 %]").stars("select",[% NIVEL.rating %]);
            });
        </script>
    [% END %]

    [% IF SEARCH_RESULTS %]
        [% IF !from_suggested %]
            [% IF suggested %]
                    <div class="suggested_search">
                        <a href="[% url_prefix %]/opac-busquedasDB.pl?string=[% suggested %]&tipoAccion=[% tipoAccion %]&from_suggested=1&only_available=[% only_available %]&token=[% token %]">
                            [% "Usted quiso decir" | i18n %] <span style="font-style: italic">[% suggested %]</span>?
                        </a>
                    </div>
            [% END %]
        [% END %]
        <table id="tablaResult" class="tabla_datos" cellspacing='0' cellpadding='0' style="text-align:center; width:100%; border:1;">
                <tr class="tablaresultadoTitle" >
                    <th align="center">
                        [% "Im&aacute;gen" | i18n %]
                    </th>
                    <th align="center" >
                        [% "T&iacute;tulo" | i18n %]
                    </th>
                    <th align="center" >
                        [% "Autor" | i18n %]
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
                                        [% IF loop.count < 4 %]
						                    [% IF portada_registro %]
						                        <a class="fancylink" rel="group" href="/uploads/covers/[% portada_registro_big %]">
						                            <img name="cover"  VALUE="" BORDER=0 src="/uploads/covers/[% portada_registro %]" title="Portada">
						                        </a>
						                    [% ELSE %]
						                          <img src="/uploads/covers/[% NIVEL.cat_ref_tipo_nivel3 %].png" 
						                                alt="[% 'Sin Portada para' | i18n %]&nbsp;[% NIVEL.cat_ref_tipo_nivel3 %]"
						                                title="[% 'Sin Portada para' | i18n %]&nbsp;[% NIVEL.cat_ref_tipo_nivel3 %]" />
						                    [% END %]
                                        [% END %]
                                    [% END %]
                            [% ELSE %]
                                [% IF NIVEL.portada_registro %]
                                    [% IF NIVEL.portada_registro_big %]
                                        <a class="fancylink" rel="group" href="/uploads/covers/[% NIVEL.portada_registro_big %]">
                                            <img alt="cover" src="/uploads/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                        </a>
                                    [% ELSE %]
                                        [% IF NIVEL.portada_registro_medium %]
                                            <a class="fancylink" rel="group" href="/uploads/covers/[% NIVEL.portada_registro_medium %]">
                                                <img alt="cover" src="/uploads/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                            </a>
                                        [% ELSE %]
                                                <img alt="cover" src="/uploads/covers/[% NIVEL.portada_registro %]" title="Portada" />
                                        [% END %]
                                    [% END %]
                                [% ELSE %]
                                         <img src="/uploads/covers/[% NIVEL.cat_ref_tipo_nivel3 %].png" 
                                              alt="[% 'Sin Portada para' | i18n %]&nbsp;[% NIVEL.cat_ref_tipo_nivel3 %]"
                                              title="[% 'Sin Portada para' | i18n %]&nbsp;[% NIVEL.cat_ref_tipo_nivel3 %]" />
                                [% END %]
                            [% END %]
                        </td>
                        <td class="titulo_result">	
                            [% IF NIVEL.titulo %]
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% NIVEL.titulo %]",
                                                                    url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                    params =>   ["id1=[% NIVEL.id1 %]"],
                                                                    title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                ) ;
                                [% END %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>

                        <td class="autor_result" title="[% 'Autor' | i18n %]">
                            [% IF NIVEL.nomCompleto %]
                                [% NIVEL.nomCompleto %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>

                        <td>
                        <span id="grupos_[% NIVEL.id1 %]">
	                        [% FOREACH NIVEL.grupos %]
	                            [% IF edicion %]
	                                [% edicion %] &nbsp;
	                            [% END %]
	                            [% IF loop.prev.anio_publicacion != anio_publicacion %]
	                                <br />
	                                [% IF anio_publicacion %]
	                                    ([% anio_publicacion %])
	                                [% END %]
	                            [% END %]
	                                
	                        [% END %]
	                    </span>
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
                                                                        onclick => "eliminarFavorito('[% NIVEL.id1 %]');",
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
	             <script type="text/javascript">$("#grupos_[% NIVEL.id1 %]").expander({
	                  slicePoint: 2000, 
	                  widow: 10,
	                  expandEffect: 'fadeIn', 
	                  expandText: "<br />[% 'M&aacute;s ediciones' | i18n %]",
	                  userCollapseText: '[^]'
	                });
	             </script>
                    
                [% END %]
        </table>
        <br />
        <div class="contenedor_paginador">[% paginador %]</div>
    [% END %]
    <!-- FIX PARA W3C PORQUE NO SE PERMITEN SCRIPT DENTRO DE TABLAS -->
[% ELSE %]
    [% IF no_content_message %]
        <h1> [% no_content_message %] </h1>  
    [% ELSE %]
        <h1 style="margin:15px;"> [% 'Nada que mostrar.' | i18n %] </h1>
    [% END %]
    <br />
    <h1 class="pagetitle">
        [% 'Repetir la b&uacute;squeda con otros criterios' | i18n %]
    </h1>    
    
    [% INCLUDE 'opac-advanced_search.inc' %]
[% END %]