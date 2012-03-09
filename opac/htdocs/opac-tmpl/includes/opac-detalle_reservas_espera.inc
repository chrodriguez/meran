<div id="detalleReservas">
    [% IF reservas_espera_count %]
    <table class="tabla_datos tope" style="width:100%; text-align:center">
      <tr class="tablaResultadoTitulo">
        <td>
            <b>[% "Material en espera" | i18n %]</b>
        </td>
      </tr>
      <tr class="tablaResultadoTitulo" >
        <th>[% "T&iacute;tulo" | i18n %]</th>
        <th>[% "Autor" | i18n %]</th>
        <th>[% "Edici&oacute;n" | i18n %]</th>
        <th>[% "Acci&oacute;n" | i18n %]</th>
      </tr>
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
                            [% PERL %]
                                print C4::AR::Filtros::action_button(   
                                                                    button   => "btn click btn-danger",
                                                                    icon => "icon-remove icon-white",
                                                                    action => "cancelarReserva([% reserva.getId_reserva %])",
                                                                    title   => "",
                                                                    alternClass => ""
                                                            );
                            [% END %]
            [% ELSE %]
                [% "No disponible" | i18n %]
            [% END %]
        </td>
      </tr>
    [% END %]
    </table>
    <br />
[% ELSE %]
    <h1> [% 'Ud. no tiene reservas en espera.' | i18n %] </h1>
[% END %]
</div>
