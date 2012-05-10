[% IF cantidad %]
    <div class="well">
        <div class="resultados_consulta">[% "La cantidad de reservas es" | i18n %]: <strong>[% cantidad %]</strong></div>
    </div>
[% END %]

[% IF cantidad %]
    <div class="contenedor_paginador">[% paginador %]</div>  
    
    [% PERL %]
            print C4::AR::Filtros::tableHeader(   
                              id              => "tablaResultCirculacion",
                              columns         => ['[% "Autor" | i18n %]','[% 'T&iacute;tulo' | i18n %]',
                                                  '[% 'Estado' | i18n %]','[% "Usuario" | i18n %]',
                                                  '[% "Categor&iacute;a" | i18n %]',
                                                  
                                                  ],
                              order           => {  'Autor'             => 'autor', 
                                                    'T&iacute;tulo'     => 'titulo',
                                                    'Estado'            => 'estado', 
                                                    'Usuario'           => 'usuario',
                                                    'Categor&iacute;a'  => 'categoria'
                                                  } ,   
                              order_name_function => "reporte_circ",                            
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
[% ELSE %]
    <div class="alert alert-info">
        [% 'No hay resultados para mostrar' | i18n  %]
    </div>

[% END %]


