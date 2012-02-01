    <div id="tabla_referencia">
        <fieldset class="resultados_busqueda">
            <legend class="titulo_legend trigger">[% "Detalle del esquema " | i18n %] [% esquema_title %]</legend>
                    <div class="datos_tabla_div" id="datos_tabla_div">
                        <table id="tablaResult" class="bordered-table zebra-striped" border=0 cellspacing=0 cellpadding=0>
                            <thead>
                                <tr class="titulo_tabla_resultado">
                                    <th class="click"> [% 'Campo origen' | i18n %]</th>
                                    <th class="click"> [% 'SubCampo origen' | i18n %]</th>
                                    <th class="click"> [% 'Destino' | i18n %]</th>
                                    <th class="click"> [% 'Ignorar' | i18n %]</th>
                                    <th class="click"> [% 'Eliminar' | i18n %]</th>
                                </tr>
                            </thead>
                            <tbody>
                                    [% FOREACH detalle IN esquema %]
                                        <script>var esquema = [% detalle.id %]</script>                               
                                        <tr id="esquema_[% detalle.id %]">
                                            <td class="editable" id="[% detalle.id %]___co">[% detalle.getCampoOrigen %]</td>
                                            <td class="editable" id="[% detalle.id %]___sco">[% detalle.getSubcampoOrigen %]</td>
                                            <td class="" id="[% detalle.id %]___destino">[% detalle.getDestino %]</td>
    
                                            <td class="editable_hover editable_select" id="[% detalle.id %]___ign">[% detalle.getIgnorarFront %]</td>
                                            <script>
                                                $('.editable_select').editable('[% url_prefix %]/herramientas/importacion/esquemas_importacionDB.pl', { 
                                                    data   : " {'[% 'No' | i18n %]':'[% 'No' | i18n %]','[% 'Si' | i18n %]':'[% 'Si' | i18n %]','selected':'[% 'detalle.getIgnorarFront' %]'}",
                                                    type      : 'select',
                                                    submit    : 'OK',
                                                    style   : 'display: inline',
                                                    submitdata : {token: "[% token %]", edit: '1'},
                                                    indicator : loaderPath,
            
                                               }); 
                                            </script>
                                            <td>
                                                [% PERL %]
                                                    print C4::AR::Filtros::to_Icon(  
                                                                                        boton   => "icon_cancelar",
                                                                                        onClick => "eliminarEsquemaRow('[% detalle.id %]');",
                                                                                        title   => "[% 'Eliminar' | i18n %]",
                                                                                        alternClass => "botonCentradoTabla",
                                                                                        elem => 'span',
                                                                                        style => 'float: left;',
                                                            ) ;
                                                [% END %]
                                                [% PERL %]
                                                    print C4::AR::Filtros::to_Icon( text    => "[% 'Editar Orden' | i18n %]",
                                                                                    onClick => "editarOrdenEsquema('[% detalle.id %]')",
                                                                                    boton   => "icon_edicion",
                                                                                    title   => "[% 'Editar Orden' | i18n %]",
                                                                                    
                                                                                );
                                                [% END %]
                                                [% PERL %]
                                                    print C4::AR::Filtros::to_Icon(  
                                                                                        boton   => "icon_agregar",
                                                                                        onClick => "agregarCampoAEsquema('[% detalle.id %]');",
                                                                                        title   => "[% 'Agregar campo' | i18n %]",
                                                                                        alternClass => "botonCentradoTabla",
                                                                                        elem => 'span',
                                                                                        style => 'float: left;',
                                                            ) ;
                                                [% END %]
                                            </td>
                                        
                                      </tr>
                                    [% END %]
                            </tbody>
                        </table>
                    </div>
                    [% PERL %]
                           print C4::AR::Filtros::to_Button(   text    => "[% 'Agregar campo' | i18n %]",
                                                               boton   => "boton_agregar",
                                                               onClick => "agregarCampo([% id_esquema %]);",
                                                               title   => "[% 'Agregar campo' | i18n %]",
                                   ) ;
                    [% END %]
            <div class="mensajes_informacion" style="clear:both;"> [% table_error_message %] </div>
        </fieldset>
    </div>
    <div id="add_campo_esquema_result"></div>
    <div id="tablaResultSubCampos"></div>