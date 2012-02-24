[% USE HTML %]

[% IF cantidad %]

    <div class="alert alert-info">[% "Cantidad de pr&eacute;stamos realizadas:" | i18n %]<strong>[% cantidad %]</strong></div>
    
    <div class="contenedor_paginador">[% paginador %]</div>

    <div class="tablaResultadoTitulo">[% "Historial de Pr&eacute;stamos" | i18n %]</div>


    [% PERL %]
        print C4::AR::Filtros::tableHeader(   
                          id              => "tablaHistorial",
                          columns         => ['[% "T&iacute;tulo"|i18n %]','[% "Autor"|i18n %]','[% "Edici&oacute;n"|i18n %]',
                                                '[% "Pr&eacute;stamo"|i18n %]', '[% "Dev"|i18n %]',
                                             ]

                                                            
                                ) ;
    [% END %]
    <tdoby>
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
    </tdoby>
    </table>
[% ELSE %]
    <div class="alert alert-info">[% 'Ud. no tiene registrado ning&uacute;n pr&eacute;stamo.' | i18n %] </div>
[% END %]
