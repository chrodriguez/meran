
[% IF reservas_espera_count %]
    <table class="tabla_datos" width="100%" border="1" class="tope" cellspacing="0" cellpadding="4" align="center">
      <tr  class="tablaResultadoTitulo">    
        <td colspan="4" align="center" borde=1>
            <b>[% "Material en espera" | i18n %]</b>
        </td>
      </tr>     
      <tr class="tablaResultadoTitulo"  >
        <th>[% "T&iacute;tulo" | i18n %]</th>
        <th>[% "Autor" | i18n %]</th>
        <th>[% "Edici&oacute;n" | i18n %]</th>
        <th>[% "Acci&oacute;n" | i18n %]</th>
      </tr>
    <!-- ESTE LOOP MUESTRA LAS RESERVAS -->
    [% FOREACH reserva IN RESERVAS_ESPERA %]
      <tr border="1">
        <td>
        <a class="click" onClick="detalleMaterialEnEspera([% reserva.nivel2.nivel1.getId1  %])" title="[% 'Mostrar Detalle' | i18n %]">
            [% reserva.nivel2.nivel1.getTitulo %]
        </a>
        </td>
        <td >
        [% IF reserva.nivel2.nivel1.getAutor %]
            <a  href="/cgi-bin/koha/opac-searchresults.pl?authorid=[% reserva.nivel2.nivel1.getAutor %]" >
            [% reserva.nivel2.nivel1.cat_autor.getCompleto %]
            </a>
        [% ELSE %]
            &nbsp;
        [% END %]
        </td>
        <td align=center > 
    [% IF reserva.nivel2.getEdicion %] [% reserva.nivel2.getEdicion %] [% ELSE %] - [% END %]
        </td>
        <td  align="center">
            [% IF CirculationEnabled %]

                    [% PERL %]
                        print C4::AR::Filtros::to_Button(   text    => "[% 'Cancelar' | i18n %]",
                                                            boton   => "boton_cancelar",
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

    <h1> [% 'Ud. no tiene reservas en espera.' | i18n %] </h1>
[% END %]