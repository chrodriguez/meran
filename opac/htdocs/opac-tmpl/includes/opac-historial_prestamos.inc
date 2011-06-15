[% USE HTML %]

[% IF prestamos %]

    <div class="resultados_consulta">[% "Cantidad de pr&eacute;stamos realizadas:" | i18n %]&nbsp;[% cantidad %]</div>
    
    <div class="contenedor_paginador">[% paginador %]</div>

    <div class="tablaResultadoTitulo">[% "Historial de Pr&eacute;stamos" | i18n %]</div>

    <table id="tablaHistorial" class="tablaHistorial tabla_datos" cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
        <tr class="tablaResultadoTitulo" >
            <th>[% "T&iacute;tulo" | i18n %]</th>
            <th>[% "Autor" | i18n %]</th>
            <th>[% "Edici&oacute;n" | i18n %]</th>
            <th>[% "Pr&eacute;stamo" | i18n %]</th>
            <th>[% "Dev" | i18n %]</th>
        </tr>
        <!-- ESTE LOOP MUESTRA LOS PRESTAMOS -->
        [% FOREACH prestamo IN prestamos %]
            <tr>
            <td> 
                    [% IF prestamo.nivel3.nivel1.getId1 %]
                        [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.nivel1.getTitulo %]",
                                                                url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                params => [ "id1=[% prestamo.nivel3.nivel1.getId1 %]", ],
                                                            ) ;
                        [% END %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>
                <td class="autor_result click" onClick="filtrarPorAutor([% idAutor %])" title="[% 'Filtrar por Autor' | i18n %]">
                    [% IF prestamo.nivel3.nivel1.getAutor %]
                        [% prestamo.nivel3.nivel1.getAutor %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                </td>
                <td>
                    [% IF prestamo.nivel3.nivel2.getEdicion %]
                        [% prestamo.nivel3.nivel2.getEdicion %]
                    [% END %]
            
                    [% IF prestamo.nivel3.nivel2.getAnio_publicacion %]
                        &nbsp;([% prestamo.nivel3.nivel2.getAnio_publicacion %])
                    [% END %]
                </td>
                <td align=center>
                    [% prestamo.getFecha_prestamo_formateada %]&nbsp;
                </td>
                <td align=center>
                    [% prestamo.getFecha_devolucion_formateada %]&nbsp;
                </td>
            </tr>
        [% END %]

    </table>
[% ELSE %]
    <h1> [% 'Ud. no tiene registrado ning&uacute;n pr&eacute;stamo.' | i18n %] </h1>
[% END %]
