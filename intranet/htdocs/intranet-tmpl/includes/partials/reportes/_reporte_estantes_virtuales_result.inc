<script type="text/javascript" src="/includes/jquery/jquery.nanoscroller.js"></script>
    
<script>
$(document).ready(function(){
     
});

function changePageBusquedas(ini){
    objAH.changePage(ini);
}
</script>

<div>
        <fieldset>
            <legend class="titulo_legend">[% nombre_estante | i18n %]</legend>
              

                  [% IF cant %]
                      [% PERL %]
                              print C4::AR::Filtros::tableHeader(   
                                              id              => "tablaResult",
                                              selectAll_id    => "",
                                              columns         => ['[% "Estante" | i18n %]','[% "Cant. de t&iacute;tulos" | i18n %]',
                                                                  '[% "Cant. de Ejemplares" | i18n %]'
                                                                ],
                                             
                                                                              
                                                ) ;
                      
                      [% END %]  
                      <tbody>
                              [% FOREACH res IN data %]
                                  <tr>
                                    
                                      <td class="titulo_result">
                                            [% res.value.nombreEstante %]
                                      </td>
                                      <td class="autor_result">
                                            [% res.value.niveles1 %]
                                      </td>
                                      <td class="autor_result">
                                            [% res.value.niveles3 %]
                                      </td>
                                  </tr>
                              [% END %]  
                      </tbody>
                  </table>

        </fieldset>
    </div>
    <div class="well">
        <div class="resultados_consulta">[% "La cantidad de subestantes" | i18n %]: <strong>[% cant %]</strong></div>             
    </div>
     <fieldset class="resultados_busqueda">
              <legend class="titulo_legend">[% "Contenido" | i18n %]</legend>

    [% IF estante.contenido %]
         

                <div id="tabla_estantes_[% estante.getId %]" class="datos_tabla_div_contenido_[% estante.getId %]">
                      [% PERL %]
                              print C4::AR::Filtros::tableHeader(   
                                              id              => "tablaResult",
                                              selectAll_id    => "",
                                              columns         => ['[% "T&iacute;tulo" | i18n %]','[% "Autor" | i18n %]',
                                                                  '[% "Lugar" | i18n %]','[% "Edic&iacute;on" | i18n %]'
                                                                ],
                                             
                                                                              
                                                ) ;
                      
                      [% END %]  
                      <tbody>
                              [% FOREACH contenido_estante IN estante.contenido %]
                                  <tr>
                                    
                                      <td class="titulo_result">
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "[% contenido_estante.nivel2.nivel1.getTitulo %]",
                                                                              url=>"[% url_prefix %]/catalogacion/estructura/detalle.pl", 
                                                                              params =>   ["id1=[% contenido_estante.nivel2.id1 %]"],
                                                                              title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                          ) ;
                                          [% END %]
                                      </td>
                                      <td class="autor_result">
                                              [% contenido_estante.nivel2.nivel1.getAutor %]
                                      </td>
                                      <td>
                                      [% contenido_estante.nivel2.getCiudadObject.getNombre %]
                                      </td>
                                      <td>
                                            [% IF contenido_estante.nivel2.getEdicion %]
                                                    [% contenido_estante.nivel2.getEdicion %] &nbsp;
                                            [% END %]
                                            [% IF contenido_estante.nivel2.getAnio_publicacion %]
                                                    ([% contenido_estante.nivel2.getAnio_publicacion %])
                                            [% END %]
                                      </td>
                                  </tr>
                              [% END %]
                          </tbody>
                      </table>
      
            </div>
    [% ELSE %]
            <div class="alert alert-info">El estante no tiene contenido</div>  
    [% END %]
  </fieldset>

    [% IF !exportar && cant %]
        <div class="form-actions" id="actions_ejemplares" style="margin-bottom: 0;">
           <td>
              [% PERL %]
                        print C4::AR::Filtros::action_set_button(    
                                button  => 'btn btn-primary',
                                title => " [% 'Exportar a PDF' | i18n %]",
                                action => 'imprimirReporte("form_reporte_estantes_virtuales");',
                                icon => "icon-white icon-inbox",
                          ) ;
              [% END %]
           </td>
        </div>       
    [% END %]
[% ELSE %]
	<div class="alert alert-info">
              [% 'No hay resultados para mostrar' | i18n  %]
  </div>
[% END %]
