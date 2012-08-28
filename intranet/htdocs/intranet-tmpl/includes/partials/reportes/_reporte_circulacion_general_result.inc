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
                                columns         => ['[% "T&iacute;tulo" | i18n %]',
                                                    '[% "Cantidad de Usuarios" | i18n %]',
                                                    '[% "Cantidad de Renovaciones" | i18n %]',
                                                    '[% "Cantidad de Devoluciones" | i18n %]',
                                                    '[% "Cantidad de Prestamos Domiciliario" | i18n %]',

                                                    
                                                    ], 
                                order_name_function => "reporte_circ",                            
                            );
        [% END %]

        <tbody>      
            [% FOREACH res IN results %]   
              <tr>
                    <td>
                        [% res.objeto %]
                    </td>
                    <td>
                        [% res.cantidad_usuarios %]
                    </td>
                    <td>
                        [% res.cantidad_renovaciones %]
                    </td>
                    <td>
                        [% res.cantidad_devoluciones %]
                    </td>
                    <td>
                        [% res.cantidad_domiciliario %]
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