<div id="detallePrestamos">

[% USE HTML %]
[% IF cantidad_prestamos %]

    <div class="alert alert-info">
        [% "Cantidad de pr&eacute;stamos vigentes:" | i18n %] <strong> [% cantidad_prestamos %] </strong>
    </div>

    <div class="contenedor_paginador">[% paginador %]</div>

    [% PERL %]
        print C4::AR::Filtros::tableHeader(   
                          id              => "tablaPrestamos",
                          columns         => ['[% "T&iacute;tulo"|i18n %]','[% "Autor"|i18n %]','[% "Edici&oacute;n"|i18n %]',
                                                '[% "Fecha de Pr&eacute;stamo"|i18n %]', '[% "Fecha de Vencimiento"|i18n %]',
                                             ]

                                                            
                                ) ;
    [% END %]
    <tbody>
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

                  <td align=center>
                  [% IF prestamo.sePuedeRenovar %]
		    [% PERL %]
				print C4::AR::Filtros::to_Icon(     text    => "[% 'Renovar' | i18n %]",
								    boton   => "icon_renovar",                                                            
								    onClick => "renovar('[% prestamo.getId_prestamo %]');",
								    title   => "[% 'Renovar' | i18n %]",
								    alternClass => "botonCentradoTabla"
					) ;
		    [% END %]
                  [% END %]
                  </td>
            </tr>
        [% END %]
    </tbody>
    </table>

[% ELSE %]
    <div class="alert alert-info"> [% 'Ud. no tiene pr&eacute;stamos vigentes.' | i18n %] </div>

[% END %]

</div>
