<div id="detallePrestamos">

[% USE HTML %]
[% IF cantidad_prestamos %]

    <div class="alert alert-info">
        [% "Cantidad de pr&eacute;stamos vigentes:" | i18n %] <strong> [% cantidad_prestamos %] </strong>
    </div>

    <div class="contenedor_paginador">[% paginador %]</div>



    <table id="tablaHistorial" class="tablaHistorial tabla_datos" cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
        <tr class="tablaResultadoTitulo" >
            <th>[% "T&iacute;tulo" | i18n %]</th>
            <th>[% "Autor" | i18n %]</th>
            <th>[% "Edici&oacute;n" | i18n %]</th>
            <th>[% "Fecha de Pr&eacute;stamo" | i18n %]</th>
            <th>[% "Fecha de Vencimiento" | i18n %]</th>
            <th>&nbsp;</th>
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

    </table>

[% ELSE %]
    <h1> [% 'Ud. no tiene pr&eacute;stamos vigentes.' | i18n %] </h1>

[% END %]

</div>
