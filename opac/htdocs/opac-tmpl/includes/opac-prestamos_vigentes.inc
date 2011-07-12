[% USE HTML %]
[% IF cantidad_prestamos %]
    <div class="resultados_consulta">[% "Cantidad de pr&eacute;stamos vigentes:" | i18n %]&nbsp;[% cantidad_prestamos %]</div>

    <div class="contenedor_paginador">[% paginador %]</div>

    <table id="tablaHistorial" class="tablaHistorial tabla_datos" cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
        <tr class="tablaResultadoTitulo" >
            <th>[% "T&iacute;tulo" | i18n %]</th>
            <th>[% "Autor" | i18n %]</th>
            <th>[% "Edici&oacute;n" | i18n %]</th>
            <th>[% "Fecha de Pr&eacute;stamo" | i18n %]</th>
            <th>[% "Fecha de Vencimiento" | i18n %]</th>
        </tr>
        <!-- ESTE LOOP MUESTRA LOS PRESTAMOS -->
        [% FOREACH prestamo IN prestamos %]
            <tr>
              <td> 
                  [% IF prestamo.nivel3.nivel2.id1 %]
                      [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.nivel2.nivel1.getTitulo %]",
                                                              url =>      "[% url_prefix %]/opac-detail.pl", 
                                                              params => [ "id1=[% prestamo.nivel3.nivel2.id1 %]", ],
                                                          ) ;
                      [% END %]
                  [% ELSE %]
                      &nbsp;
                  [% END %]
                  </td>
                  <td class="autor_result click" onClick="filtrarPorAutor([% prestamos.nivel3.nivel2.nivel1.cat_autor.id %])" title="[% 'Filtrar por Autor' | i18n %]">
                      [% IF prestamo.nivel3.nivel1.getAutor %]
                          [% prestamo.nivel3.nivel1.getAutor %]
                      [% ELSE %]
                          &nbsp;
                      [% END %]
                  </td>
                  <td>
                    [% IF prestamo.nivel3.nivel2.getEdicion %] [% prestamo.nivel3.nivel2.getEdicion %] [% ELSE %] - [% END %]                  </td>
                  <td align=center>
                      [% prestamo.getFecha_prestamo_formateada %]
                  </td>
                  <td align=center>
                      [% prestamo.getFecha_vencimiento_formateada %]
                  </td>

            </tr>
        [% END %]

    </table>
[% ELSE %]
    <h1> [% 'Ud. no tiene pr&eacute;stamos vigentes.' | i18n %] </h1>

[% END %]