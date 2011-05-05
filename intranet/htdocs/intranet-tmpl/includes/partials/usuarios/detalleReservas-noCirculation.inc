
[% USE HTML %] 

[% IF reservas_asignadas_count %]
	
	<fieldset>
	<legend class="titulo_legend_resaltado">[% "Ejemplares Asignados" | i18n %]</legend>
	    <table id="reseravsAsignadasResult" class="reseravsAsignadasResult datos_tabla" cellspacing=0  cellpadding=0  border=0   width="100%">
	        <tr class="titulo_tabla_resultado">

	            <th>[% "T&iacute;tulo" | i18n %]</th>
	            <th>[% "Autor" | i18n %]</th>
	            <th>[% "C. Barra" | i18n %]</th>
	            <th>[% "Sig. Top." | i18n %]</th>
	            <th>[% "Ed." | i18n %]</th>
	            <!--<th>[% "Vol." | i18n %]</th> -->
	            <th>[% "Vencimiento" | i18n %]</th>
	            <th width="10%">[% "Retira en" | i18n %]</th>
	        </tr>
	    [% FOREACH reserva IN RESERVAS_ASIGNADAS %]
	        <tr align="center">
	        
	            <td width="16%">
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text =>     " [% HTML.escape(reserva.nivel2.nivel1.getTitulo) %]",
	                                                    url =>      "/cgi-bin/koha/catalogacion/estructura/detalle.pl", 
	                                                    params =>   ["id1=[% reserva.nivel2.nivel1.getId1 %]"],
	                                                ) ;
	                [% END %]
	            </td>   
	            <td>
	                [% IF reserva.nivel3.nivel1.getAutor %]
	                    [% reserva.nivel3.nivel1.getAutor %]
	                [% ELSE %]
	                    &nbsp;
	                [% END %]
	            </td>
	            <td>
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text =>     "[% reserva.nivel3.getBarcode %]",
	                                                    url =>      "/cgi-bin/koha/catalogacion/estructura/detalleEjemplar.pl", 
	                                                    params =>   ["id3=[% reserva.getId3 %]"],
	                                                    title =>    "[% 'Mostrar Detalle de Disponibilidad' | i18n %]"
	                                                ) ;
	                [% END %]
	                
	            </td>
	            <td>
	            [% IF reserva.nivel3.getSignatura_topografica %] 
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text =>     "[% reserva.nivel3.getSignatura_topografica %]",
	                                                    url =>      "/cgi-bin/koha/detalle.pl", 
	                                                    params =>   ["id1=[% reserva.nivel3.nivel1.getId1 %]"],
	                                                ) ;
	                [% END %]
	            [% END %]
	            </td>
	            <td>  
	               [% IF reserva.nivel3.nivel2.getEdicion %] [% reserva.nivel3.nivel2.getEdicion %] [% ELSE %] - [% END %]
	            </td>
	    
	            <!-- <td> 
	            [% IF reserva.nivel3.nivel2.getVolumen %] t [% reserva.nivel3.nivel2.getVolumen %] 
	                [% IF reserva.nivel3.nivel2.getVolumenDesc %] ([% reserva.nivel3.nivel2.getVolumenDesc %])  [% END %] 
	            [% END %]
	            </td> -->
	            <td>
	            [% IF reserva.getFecha_recordatorio_formateada %]
	               <font  [% IF reserva.estaVencida %] color="red" [% END %] >[% reserva.getFecha_recordatorio_formateada %]</font>
	            [% ELSE %]
	               - 
	            [% END %]
	            </td>
	            <td>
		            [% IF reserva.getId_ui %] 
		                [% reserva.ui.getNombre %]
		            [% ELSE %]
		                - 
		            [% END %]
	            </td>
	        </tr>
	    [% END %]
	    </table>
	</fieldset>
	[% END %]
	
	[% IF RESERVAS_ESPERA %]
	<fieldset>
	<legend class="titulo_legend">[% "Reservas en espera" | i18n %]</legend>
	        
	        <table class="reservasEnEsperaResult datos_tabla" cellspacing=0  cellpadding=0  border=0   width="100%">
	            <tr valign=middle class="titulo_tabla_resultado">
	                <th>[% "T&iacute;tulo" | i18n %]</th>
	                <th>[% "Autor" | i18n %]</th>
	                <th>[% "Edici&oacute;n" | i18n %]</th>
	                <!--<th>[% "Volumen" | i18n %]</th>-->
	                <th>[% "Cancelar" | i18n %]</th>
	            </tr>
	        [% FOREACH reserva IN RESERVAS_ESPERA %]
	            <tr align="center">
	            
	                <td width="10%"> 
	                [% PERL %]
	                    print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(reserva.nivel2.nivel1.getTitulo) %]",
	                                                    url =>      "/cgi-bin/koha/catalogacion/estructura/detalle.pl", 
	                                                    params =>   ["id1=[% reserva.nivel2.nivel1.getId1 %]"],
	                                                ) ;
	                [% END %]
	                </td>
	                <td>
	                    [% IF reserva.nivel2.nivel1.getAutor %]
	                        [% reserva.nivel2.nivel1.getAutor %]
	                    [% ELSE %]
	                        &nbsp;
	                    [% END %]
	                </td>
                    <td>  
	                   [% IF reserva.nivel2.getEdicion %] [% reserva.nivel2.getEdicion %] [% ELSE %] - [% END %]
                    </td>
	        
	                <!--<td> 
	                [% IF reserva.nivel3.nivel2.getVolumen %] t [% reserva.nivel3.nivel2.getVolumen %] 
	                    [% IF reserva.nivel3.nivel2.getVolumenDesc %] ([% reserva.nivel3.nivel2.getVolumenDesc %])  [% END %] 
	                [% END %]
	                </td>-->
	                <td width="10%"> 
	                   &nbsp;
	                </td>
	            </tr>
	        [% END %]
	        </table>
	</fieldset>
[% END %]
