[% USE HTML %]
[% IF cantidad %]
    <div class="resultados_consulta">[% "Cantidad de pr&eacute;stamos vigentes:" | i18n %]&nbsp;[% cantidad %]</div>

    <div class="contenedor_paginador">[% paginador %]</div>

<!--     <div class="tablaResultadoTitulo">[% "Pr&eacute;stamos" | i18n %]</div> -->

    <table id="tablaHistorial" class="tablaHistorial tabla_datos" cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
        <tr class="tablaResultadoTitulo" >
            <th>[% "T&iacute;tulo" | i18n %]</th>
            <th>[% "Autor" | i18n %]</th>
            <th>[% "Edici&oacute;n" | i18n %]</th>
            <th>[% "Pr&eacute;stamo" | i18n %]</th>
<!--             <th>[% "Dev" | i18n %]</th> -->
        </tr>
        <!-- ESTE LOOP MUESTRA LOS PRESTAMOS -->
        [% FOREACH prestamo IN prestamos %]
            <tr>
              <td> 
                  [% IF prestamo.nivel3.nivel2.id1 %]
                      [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.nivel2.nivel1.getTitulo %]",
                                                              url =>      "/cgi-bin/koha/opac-detail.pl", 
                                                              params => [ "id1=[% prestamo.nivel3.nivel2.id1 %]", ],
                                                          ) ;
                      [% END %]
                  [% ELSE %]
                      &nbsp;
                  [% END %]
                  </td>
                  <td class="autor_result click" onClick="filtrarPorAutor([% prestamos.nivel3.nivel2.nivel1.cat_autor.id %])" title="[% 'Filtrar por Autor' | i18n %]">
                      [% IF prestamo.nivel3.nivel2.nivel1.cat_autor %]
                          [% prestamo.nivel3.nivel2.nivel1.cat_autor.getCompleto %]
                      [% ELSE %]
                          &nbsp;
                      [% END %]
                  </td>
                  <td>
                      [% IF grupos %]
                          [% FOREACH grupos %]
                              [% IF edicion %]
                                  [% edicion %] &nbsp;
                              [% END %]
                              [% IF anio_publicacion %]
                                  ([% anio_publicacion %])
                              [% END %]
                              [% IF volume %] 
                                  t [% volume %]
                              [% END %]
                              <br>
                      [% END %]
                      [% ELSE %]
                          &nbsp;
                      [% END %]
                  </td>
                  <td align=center>
                      [% prestamo.getFecha_prestamo_formateada %]
                  </td>
<!--                  <td align=center>
                      [% IF prestamo.getFecha_devolucion_formateada %]
                          [% prestamo.getFecha_devolucion_formateada %]&nbsp;
                      [% ELSE %]
                          [% 'Todav&iacute;a en su poder' | i18n %]
                      [% END %]
                  </td>-->
            </tr>
        [% END %]

    </table>
[% ELSE %]
    <h1> [% 'Ud. no tiene pr&eacute;stamos vigentes.' | i18n %] </h1>

[% END %]