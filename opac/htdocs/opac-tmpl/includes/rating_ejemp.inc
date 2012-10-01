

[% IF rating_count %]		
		<fieldset> 
              <legend class="titulo_legend_resaltado">
                  [% "Ejemplares mas votados" | i18n %]
             </legend>
                     [% IF rating_count %]
                          [% PERL %]
                                print C4::AR::Filtros::tableHeader(   
                                            id              => "table_tablaPrestamos",
                                            class           => "",
                                            selectAll_id    => "",
                                            columns         => ['[% "T&iacute;tulo"|i18n %]','[% "Autor"|i18n %]',
                                                 				'[% "Edici&oacute;n" | i18n %]'
                                                              ]
                                                                            
                                                  ) ;
                          [% END %]
        
                        
                        <tbody>
                        [% FOREACH elem IN rating %]
                            <tr>
                                <td>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to(	text => "[% HTML.escape(elem.nivel1.getTitulo) %]",
                                                            url=>"[% url_prefix %]/opac-detail.pl", 
                                                            params =>	["id1=[% elem.nivel1.getId1 %]"],
                                                          ) ;
                                [% END %]
                                </td>
                                <td>
                                [% IF elem.nivel1.getAutor %]
                                    [% elem.nivel1.getAutor %]
                                [% ELSE %]
                                    &nbsp;
                                [% END %]
                                </td>
                                <td>  
                                [% IF elem.getEdicion %] [% elem.getEdicion %] [% ELSE %] - [% END %]
                                </td>

                                <td>
                                    [% IF prestamo.tipo.id_tipo_prestamo %]
                                            [% prestamo.tipo.getDescripcion %]
                                    [% END %]
                                </td>
                          </tr>
                      [% END %] <!-- FOREACH prestamos -->
                    </tbody>  
                      [% END %]
			</table> 
		</fieldset>
[% ELSE %]
    [% IF !promoted_count %]
        <div class="hero-unit">
              <h1>[% 'Todav&iacute;a nada!'|i18n %]</h1>
              <p>[% 'Volv&eacute; en unos d&iacute;as para ver si la Biblioteca tiene algo para vos.' | i18n %]</p>
              <p>
                  [% PERL %]
                          print C4::AR::Filtros::action_button( 
                                                          button         => "btn btn-primary",
                                                          action       => "historyBack()", 
                                                          icon         => "icon-white icon-arrow-left ",
                                                          title        => "[% 'Volver' | i18n %]",
                                                      ) ;

                  [% END %]
                </p>
        </div>    
    [% END %]
[% END %]