 <div class="well">
                <!--<div class="resultados_consulta">[% "Ha buscado por" | i18n %]: <strong>[% HTML.escape(socio_busqueda) %]</strong></div> -->
                 [% IF cantidad %]
                          <div class="resultados_consulta">[% "La cantidad de busquedas es" | i18n %]: <strong>[% cantidad %]</strong></div>
                 [% END %]
</div>

[% IF cantidad %]
<!--                   <div class="contenedor_paginador">[% paginador %]</div>   -->
     <!--   [% PERL %]
            print C4::AR::Filtros::tableHeader(   
                              id              => "tablaResult",
                              class           => "",
                              selectAll_id    => "",
                              columns         => ['[% "Valor" | i18n %]','[% 'Campo' | i18n %]',
                                                  '[% "Usuario" | i18n %]','[% "Documento" | i18n %]',
                                                  '[% "Fecha" | i18n %]'
                                                  ]
                                                              
                                    ) ;
        [% END %]

        <tbody>      
              [% FOREACH results %]   
                <tr>
                  <td>
                      [% valor %]
                  </td>
                  <td>
                      [% campo %]
                  </td>
                  <td>
                      [% IF nro_socio %] 
                              [% nro_socio %]                 
                      [% END %]
                  </td>
                  <td>
                      [% fecha %]
                  </td>
                  <td>
                      [% PERL %]
                          print C4::AR::Filtros::link_to(   text =>     "[% nro_socio %]",
                                                            url=>"      [% url_prefix %]/usuarios/reales/datosUsuario.pl", 
                                                            params =>   ["nro_socio=[% nro_socio %]"],
                                                            title =>    "[% 'Mostrar Detalle del Usuario' | i18n %]"
                                                      );
                      [% END %]
                  </td>
               
                </tr>
             [% END %]
        </tbody>
 </table>-->
[% END %]


