<script type="text/javascript" src="/intranet-tmpl/includes/adquisiciones/tabletojson.js"> </script>

[% IF cantidad %]
 <div class="well">
                <!--<div class="resultados_consulta">[% "Ha buscado por" | i18n %]: <strong>[% HTML.escape(socio_busqueda) %]</strong></div> -->
         
                          <div class="resultados_consulta">[% "La cantidad de busquedas es" | i18n %]: <strong>[% cantidad %]</strong></div>
                 
</div>
[% END %]
[% IF cantidad %]
      <div class="contenedor_paginador">[% paginador %]</div>  
     
      [% PERL %]
            print C4::AR::Filtros::tableHeader(   
                              id              => "tablaResult",
                              class           => "",
                              selectAll_id    => "",
                              columns         => ['[% "Valor" | i18n %]','[% 'Campo' | i18n %]',
                                                  '[% "Usuario" | i18n %]','[% "Fecha" | i18n %]',                
                                                  ],
                              order           => {  'Valor' =>'valor', 
                                                    'Campo' => 'campo',
                                                    'Usuario' => 'busqueda.nro_socio', 
                                                    'Fecha' => 'busqueda.fecha'  
                                                  },
                              order_name_function => "reporte_busquedas",
                              ) ;
        [% END %]

        <tbody>      
              [% FOREACH res IN results %]
                <tr>
                  <td>
                      [% res.valor %]
                  </td>
                  <td>
                      [% res.campo %]
                  </td>
                  <td>
                      [% IF nro_socio %] 
                                [% PERL %]
                                      print C4::AR::Filtros::link_to(   text =>     "[% nro_socio %]",
                                                            url=>"      [% url_prefix %]/usuarios/reales/datosUsuario.pl", 
                                                            params =>   ["nro_socio=[% nro_socio %]"],
                                                            title =>    "[% 'Mostrar Detalle del Usuario' | i18n %]"
                                                      );
                                [% END %] 
                             
                      [% ELSE %]
                                '[% "Desconocido" | i18n %]'
                               
                      [% END %]
                      
                  </td>
                  <td>
                      [% res.busqueda.fecha %]
                  </td>
                  <td>
                      
                  </td>
               
                </tr>
             [% END %]
        </tbody>
 </table>

 <div class="form-actions">
                              [% PERL %]
                                      print C4::AR::Filtros::action_set_button(    
                                                                          title           => "[% 'Exportar resultados' | i18n %]",
                                                                          button          => 'btn btn-primary',
        
                                                                          actions         => [  {title => "DOC", action=>'exportarDoc()'},
                                                                                                {title => "PDF", action=>'exportarPDF()'},
                                                                                                {title => "ODT", action=>'realizarODT()'},
                                                                                                {title => "ODS", action=>'realizarODS()'},
                                                                                              ],
                                                                          popover           => {title => "[% 'Pr&eacute;stamos' | i18n %]",
                                                                                                text => "[% 'Renovar (si aplica) o devolver ejemplares' | i18n %]" }
        
                                              ) ;
                              [% END %]
 </div>
[% ELSE %]
    <div class="alert alert-info">
              [% 'No hay resultados para mostrar' | i18n  %]
    </div>

[% END %]


