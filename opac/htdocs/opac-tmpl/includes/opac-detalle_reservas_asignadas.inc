<h2> [% 'Material para retirar' | i18n %] </h2>
<div id="detalleReservas">
    [% IF reservas_asignadas_count %]
        <table  class="tabla_datos" width="100%" border="1" class="tope" cellspacing="0" cellpadding="4" align="center" valign="top">

          <tr class="tablaResultadoTitulo">
            <th>[% "T&iacute;tulo" | i18n %]</th>
            <th>[% "Autor" | i18n %]</th>
            <th style="width: 50px;">[% "Edici&oacute;n" | i18n %]</th>
            <th>[% "Disponible desde" | i18n %]</th>
            <th>[% "Disponible hasta" | i18n %]</th> 
            <th>[% "Retira en" | i18n %]</th>
            <th>[% "Acci&oacute;n" | i18n %]</th>
          </tr>
        <!-- ESTE LOOP MUESTRA LAS RESERVAS EN ESPERA -->
            [% FOREACH reserva IN RESERVAS_ASIGNADAS %]
                <tr>
                    <td >
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
                    <td align=center >  
	                    [% IF reserva.nivel2.getEdicion %] [% reserva.nivel2.getEdicion %] [% ELSE %] - [% END %]
                    </td>
                    <td  align="center">
	                    [% IF reserva.getFecha_reserva_formateada %] 
	                        [% reserva.getFecha_reserva_formateada %]
	                    [% ELSE %]
	                        - 
	                    [% END %]
                    </td>
                    <td  align="center">
	                    [% IF reserva.getFecha_recordatorio_formateada %]
	                        <font  [% IF reserva.estaVencida %] color="red" [% END %] >[% reserva.getFecha_recordatorio_formateada %]</font>
	                    [% ELSE %]
	                        - 
	                    [% END %]
                    </td>
                
                    <td >
                        <b>[% reserva.ui.getNombre %]</b>
                    </td>
                    <td  align="center"> 
                    [% IF CirculationEnabled %]

                        [% PERL %]
                            print C4::AR::Filtros::to_Icon(   text    => "[% 'Cancelar' | i18n %]",
                                                                boton   => "icon_cancelar",
                                                                width   => "100",
                                                                onClick => "cancelarReserva([% reserva.getId_reserva %])",
                                                                title   => "[% 'Cancelar Reserva' | i18n %]",
                                                                alternClass => "botonCentradoTabla"
                                                        );
                        [% END %]


                    [% ELSE %]
                        [% "No disponible" | i18n %]
                    [% END %]
                    </td>
              </tr>
            [% END %]
        </table>
        <br>
    [% ELSE %]
        <h1> [% 'Ud. no tiene reservas asignadas.' | i18n %] </h1>
    [% END %]
</div>
