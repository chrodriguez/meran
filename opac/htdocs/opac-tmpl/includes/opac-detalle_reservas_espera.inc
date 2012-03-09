<b>[% "Material en espera" | i18n %]</b>
<div id="detalleReservas">
    [% IF reservas_espera_count %]

        [% PERL %]
                print C4::AR::Filtros::tableHeader(   
                                  id              => "tabla_datos tope",
                                  class           => "",
                                  selectAll_id    => "",
                                  columns         => ['[% "T&iacute;tulo" | i18n %]','[% "Autor" | i18n %]',
                                                      '[% "Edici&oacute;n" | i18n %]','[% "Acci&oacute;n" | i18n %]'
                                                     ]

                                                                    
                                        ) ;
          [% END %]

    

          <tbody>
            <!-- ESTE LOOP MUESTRA LAS RESERVAS -->
            [% FOREACH reserva IN RESERVAS_ESPERA %]
              <tr>
                    <td>
                          [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "[% reserva.nivel2.nivel1.getTitulo %]",
                                                                                url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                                params =>   ["id1=[% reserva.nivel2.nivel1.getId1 %]"],
                                                                                title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                            ) ;
                          [% END %]
                    </td>

                    <td >
                          [% IF reserva.nivel2.nivel1.getAutor %]
                              [% reserva.nivel2.nivel1.getAutor %]
                              </a>
                          [% ELSE %]
                              &nbsp;
                          [% END %]
                    </td>
                    <td> 
                            [% IF reserva.nivel2.getEdicion %] [% reserva.nivel2.getEdicion %] [% ELSE %] - [% END %]
                    </td>
                    <td>
                            [% IF CirculationEnabled %]
                                    <ul>
                                            [% PERL %]
                                                print C4::AR::Filtros::action_button(   
                                                                                    button   => "btn btn-danger",
                                                                                    action => "cancelarReserva([% reserva.getId_reserva %])",
                                                                                    title   => "[% 'Cancelar Reserva' | i18n %]",
                                                                            );
                                            [% END %]
                                    </ul>

                                [% ELSE %]
                                    [% "No disponible" | i18n %]
                                [% END %]
                    </td>
             </tr>
           [% END %]
       </table>
                 
[% ELSE %]
     <div class="alert alert-info"> [% 'Ud. no tiene reservas en espera.' | i18n %] </div>
[% END %]
</div>
