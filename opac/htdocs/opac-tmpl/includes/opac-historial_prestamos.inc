[% USE HTML %]

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
    [% FOREACH prestamos %]
        <tr>
        <td> 
                [% IF id1 %]
                    [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "[% titulo | i18n %]",
                                                            url =>      "/cgi-bin/koha/opac-detail.pl", 
                                                            params => [ "id1=[% id1 %]", ],
                                                        ) ;
                    [% END %]
                [% ELSE %]
                    &nbsp;
                [% END %]
            </td>
            <td class="autor_result click" onClick="filtrarPorAutor([% idAutor %])" title="[% 'Filtrar por Autor' | i18n %]">
                [% IF nomCompleto %]
                    [% nomCompleto %]
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
                [% fecha_prestamo %]&nbsp;
            </td>
            <td align=center>
                [% fecha_devolucion %]&nbsp;
            </td>
        </tr>
    [% END %]

</table>

<a class="click" onClick="volverDesdeHistorial()">
    [% "Volver" | i18n %]
</a>