[% IF prestamos_cant %]
    
    [% USE HTML %]
    
    <fieldset> <legend class="titulo_legend_resaltado">[% "Ejemplares Prestados" | i18n %]</legend>
        <table id="table_tablaPrestamos" class="prestamosResult datos_tabla" cellspacing=0  cellpadding=0 border=0  width="100%" > 
        
            <tr valign=middle class="titulo_tabla_resultado">
        
                <th>[% "T&iacute;tulo" | i18n %]</th>
                <th>[% "Autor" | i18n %]</th>
                <th>[% "C. Barra" | i18n %]</th>
                <th>[% "Sig. Top." | i18n %]</th>
                <th>[% "Ed." | i18n %]</th>
                <th>[% "Vol." | i18n %]</th>
                <th>[% "Pr&eacute;stamo" | i18n %]</th>
                <th>[% "Vencimiento" | i18n %]</th>
                <th>[% "Tipo" | i18n %]</th>
        
            </tr>
        [% FOREACH prestamo IN PRESTAMOS %]
            <tr align="center">
        
                <td width="14%" >
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text => "[% prestamo.nivel3.nivel1.getTitulo %]",
	                                            url =>  "/cgi-bin/koha/catalogacion/estructura/detalle.pl", 
	                                            params =>   ["id1=[% prestamo.nivel3.nivel1.getId1 %]"],
	                                          ) ;
	                [% END %]
                </td>
                <td>
	                [% IF prestamo.nivel3.nivel1.getAutor %]
	                    [% prestamo.nivel3.nivel1.getAutor %]
	                [% ELSE %]
	                    &nbsp;
	                [% END %]
                </td>
        
                <td>
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.getBarcode %]",
	                                                    url =>      "/cgi-bin/koha/catalogacion/estructura/detalleEjemplar.pl", 
	                                                    params =>   ["id3=[% prestamo.getId3 %]"],
	                                                    title =>    "[% 'Detalle del Ejemplar' | i18n %]"
	                                                ) ;
	                [% END %]
                </td>
        
                <td>
                    [% IF prestamo.nivel3.getSignatura_topografica %] 
                        [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.getSignatura_topografica %]",
                                                            url =>      "/cgi-bin/koha/detalle.pl", 
                                                            params =>   ["id1=[% prestamo.nivel3.nivel1.getId1 %]"],
                                                ) ;
                        [% END %]
                    [% END %]
                </td>
        
                <td>  
                    [% IF prestamo.nivel3.nivel2.getEdicion %] [% prestamo.nivel3.nivel2.getEdicion %] [% ELSE %] - [% END %]
                </td>
        
                <td> 
	                [% IF prestamo.nivel3.nivel2.getVolumen %] t [% prestamo.nivel3.nivel2.getVolumen %] 
	                    [% IF prestamo.nivel3.nivel2.getVolumenDesc %] ([% prestamo.nivel3.nivel2.getVolumenDesc %])  [% END %] 
	                [% END %]
                </td>
                <td>
	                [% IF prestamo.getFecha_prestamo %] 
	                    [% prestamo.getFecha_prestamo_formateada %]
	                [% ELSE %]
                        - 
                    [% END %]
                </td>
        
                <td>
                    [% IF prestamo.getFecha_vencimiento %]
	                    <span class="[% IF prestamo.estaVencido %]fecha_vencida[% ELSE %]fecha_cumple[% END %]">
	                      [% prestamo.getFecha_vencimiento_formateada %]
	                    </span>
                    [% ELSE %]
                        - 
                    [% END %]
          </td>
    
          <td>
              [% IF prestamo.tipo.id_tipo_prestamo %]
                      [% prestamo.tipo.getDescripcion %]
              [% END %]
          </td>
      </tr>
        [% END %] <!-- FOREACH prestamos -->
        
     </table>
   </fieldset>
[% END %]
