

[% USE HTML %]
    
[% IF cantidad > 0 %]
             <div class="contenedor_paginador">[% paginador %]</div>
            
             [% PERL %]
                 print C4::AR::Filtros::tableHeader(   
                                                         id              => "tablaResult",
                                                         class           => "",
                                                         columns         => ['[% "Tipo"|i18n %]','[% "T&iacute;tulo"|i18n %]','[% "Autor"|i18n %]',
                                                                             '[% "Edici&oacute;n"|i18n %]','[% "Disponibilidad"|i18n %]', '[% "Valoraci&oacute;n" | i18n %]',
                                                                             [% IF socio_data.usr_permisos_opac %]'[% "Favoritos" | i18n %]'[% END %]
                                                                            ]
                                                         
                             ) ;
             [% END %]
             <tbody>  
                [% FOREACH NIVEL IN SEARCH_RESULTS %]
                    <tr>
                         <td>
                             [% IF NIVEL.portadas_grupo_cant > 0 %]
                                     [% FOREACH portada IN NIVEL.portadas_grupo %]
                                         [% IF loop.count < 4 %]
                                       [% IF portada.portada_registro_big %]
                                           <a class="fancylink" rel="group_[% grupo %]" href="/uploads/covers/[% portada.portada_registro_big %]">
                                               <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
                                           </a>
                                       [% ELSE %]
                                           [% IF portada.portada_registro_medium %]
                                               <a class="fancylink" rel="group_[% grupo %]" href="/uploads/covers/[% portada.portada_registro_medium %]">
                                                   <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
                                               </a>
                                           [% ELSE %]
                                                   <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
                                           [% END %]
                                       [% END %]
                                         [% END %]
                                     [% END %]
                             [% ELSE %]
                                   <img src="/uploads/covers/[% NIVEL.cat_ref_tipo_nivel3 %].png" 
                                         alt="[% 'Sin Portada' | i18n %]"
                                         title="[% 'Sin Portada' | i18n %]" />
                             [% END %]
                             <br />
                             <center><div style="font-weight: bold; font-size: 10px; clear:both;" >[% NIVEL.cat_ref_tipo_nivel3_name %] </div></center>
                         </td>

                        <td>    
                            [% IF NIVEL.titulo %]
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(NIVEL.titulo) %]",
                                                                    url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                    params =>   ["id1=[% NIVEL.id1 %]"],
                                                                    title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                ) ;
                                [% END %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>

                        <td>
                            [% IF NIVEL.nomCompleto %]
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(NIVEL.nomCompleto) %]",
                                                                    url =>      "[% url_prefix %]/opac-busquedasDB.pl", 
                                                                    params =>   ["tipoAccion=BUSQUEDA_AVANZADA","autor=[% HTML.escape(NIVEL.nomCompleto) %]"],
                                                                    title =>    "[% 'Buscar de este autor' | i18n %]"
                                                                ) ;
                                [% END %]                                
                            [% ELSE %]
                                ----------
                            [% END %]
                        </td>

                        <td>
                        [% IF NIVEL.estadoDeColeccion %]
                            <span id="coleccion_[% NIVEL.id1 %]">
                            <ul class="listado_sin_margen estado_coleccion">
                            [% FOREACH anio IN NIVEL.estadoDeColeccion.keys.sort %]
                            [% IF NIVEL.estadoDeColeccion.$anio.keys %]
                            <li>
                                [% IF anio != '#' %]<b>[% anio %]</b>[% END %]
                                [% FOREACH volumen IN NIVEL.estadoDeColeccion.$anio.keys.sort %]
                                    [% IF volumen != '#' %][% volumen  %][% END %]
                                    (
                                    [% FOREACH fasciculo IN NIVEL.estadoDeColeccion.$anio.$volumen.keys.sort %]

                                         [% PERL %]
                                            print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(fasciculo) %]",
                                                                            url=>"[% url_prefix %]/opac-detail.pl", 
                                                                            params =>   ["id1=[% NIVEL.id1 %]","id2=[% NIVEL.estadoDeColeccion.$anio.$volumen.$fasciculo %]"],
                                                                            title =>    "[% 'Mostrar Detalle del Registro' | i18n %]",
                                                                            class =>    "link_to_detail"
                                                                        ) ;
                                         [% END %]
                        
                                    [% END %]
                                    )
                                [% END %]
                               </li>
                            [% END %]
                            [% END %]
                            </ul>
                            </span>
                            
                          <script type="text/javascript">$("#coleccion_[% NIVEL.id1 %]").expander({
                              slicePoint: 2000, 
                              widow: 10,
                              expandEffect: 'fadeIn', 
                              expandText: "<br />[% 'M&aacute;s Revistas' | i18n %]",
                              userCollapseText: '[^]'
                            });
                         </script>
                         
                        [% ELSE %]
                            [% IF NIVEL.grupos %]
                                <span id="grupos_[% NIVEL.id1 %]" class="detalle_registro_edicion">
                                    [% FOREACH NIVEL.grupos %]
                                        [% IF edicion %]
                                            [% edicion %] &nbsp;
                                        [% END %]
                                        [% IF loop.prev.anio_publicacion != anio_publicacion %]
                                            [% IF anio_publicacion %]
                                                ([% anio_publicacion %])<br/>
                                            [% END %]
                                        [% END %]
                                            
                                    [% END %]
                                </span>
                          <script type="text/javascript">$("#grupos_[% NIVEL.id1 %]").expander({
                              slicePoint: 2000, 
                              widow: 10,
                              expandEffect: 'fadeIn', 
                              expandText: "<br />[% 'M&aacute;s ediciones' | i18n %]",
                              userCollapseText: '[^]'
                            });
                         </script>
                            [% END %]
                        [% END %]
   
                        </td>

                        <td>
                            [% IF NIVEL.disponibilidad %]
                                [% FOREACH NIVEL.disponibilidad %]
                                    <b>[% tipoPrestamo %]</b> [% cantTotal %]
                                    <div style="margin-right:4px">
                                        [% IF reservados != 0 %]
                                            [% reservados %]
                                        [% END %] 
                                        
                                        [% IF prestados != 0 %]
                                            [% prestados %]
                                        [% END %] 
                                    </div>
                                    <br />
                                [% END %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>
                        <td class="span2">
                            [% IF NIVEL.rating > 0 %]
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
                             [% ELSE %]
                               <p> [% '----------' %]
                             [% END %]
                        </td>
                        [% IF socio_data.usr_permisos_opac %]
                            <td>
                                [% IF NIVEL.esta_en_favoritos %]
                                    [% PERL %]
                                      print C4::AR::Filtros::action_button( 
                                                                      button    => "btn btn-danger click",
                                                                      action    =>  "eliminarFavorito([% NIVEL.id1 %]);",
                                                                      icon      => "icon-remove icon-white",
                                                                  ) ;
                
                                    [% END %]
                                [% ELSE %]
                                    [% PERL %]
                                      print C4::AR::Filtros::action_button( 
                                                                      button    => "btn btn-info click",
                                                                      action    => "addFavorite([% NIVEL.id1 %]);",
                                                                      icon      => "icon-heart icon-white",
                                                                      popover => {text => "Agrega este registro a tu estante privado de favoritos", title => "Favoritos"},
                                                                  ) ;
                
                                    [% END %]
                                [% END %]
                            </td>
                         [% END %]
                    </tr>
                [% END %]
             </tbody>
        </table>
        <div class="contenedor_paginador">[% paginador %]</div>
  
    <!-- FIX PARA W3C PORQUE NO SE PERMITEN SCRIPT DENTRO DE TABLAS -->
  [% ELSE %]
    
    [% IF no_content_message %]
        <div class="alert alert-info"> [% no_content_message %] </div>  
    [% ELSE %]
        <div class="alert alert-info"> [% 'Nada que mostrar.' | i18n %] </div>
    [% END %]
    <br />


[% END %]
