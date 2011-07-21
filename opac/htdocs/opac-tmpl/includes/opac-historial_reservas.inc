[% USE HTML %]

[% IF cantidad %]
        <div class="resultados_consulta">[% "Cantidad de reservas realizadas" | i18n %]: &nbsp;[% cantidad %]</div> 
        
        <div class="contenedor_paginador">[% paginador %]</div>
        
        <table id="tablaResult" class="tabla_datos" cellspacing=0  cellpadding=0 border=0 width="100%">
            <tr class="tablaresultadoTitle" >
            
                <th>
                    [% "T&iacute;tulo" | i18n %]
                </th>
                <th>
                    [% "Autor" | i18n %]
                </th>
                <th>
                    [% "Edici&oacute;n" | i18n %]
                </th>
                <th>
                    [% "Fecha" | i18n %]
                </th>
            
            </tr>
            
            [% FOREACH reserva IN reservas %]
            <tr>
                
                <td class="titulo_result">
                    [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(reserva.nivel2.nivel1.getTitulo) %]",
                                                            url =>      "[% url_prefix %]/opac-detail.pl",
                                                            params =>   [   "id1=[% HTML.escape(reserva.nivel2.nivel1.getId1) %]"], 
                                                        ) ;
                    [% END %]
                </td>
                
                <td class="autor_result">
                    <a class="click" onClick="buscarPorAutor('[% reserva.nivel2.nivel1.getAutor %]')" title="[% 'Filtrar por Autor' | i18n %]">
                        [% reserva.nivel2.nivel1.getAutor %]
                    </a>
                </td>
                
                <td>
                    [% HTML.escape(reserva.nivel2.getEdicion) %]
                </td>
                <td>
                    &nbsp;[% reserva.getFecha_reserva_formateada %]&nbsp;
                </td>
            [% END %] <!-- FOREACH PRIMERO -->
        
        </table>
[% ELSE %]
    <div class="resultados_consulta">[% "No se han realizado reservas." | i18n %] &nbsp;[% cant %]</div>
[% END %] 