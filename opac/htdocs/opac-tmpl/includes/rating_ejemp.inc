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
                                                 				'[% "Edici&oacute;n" | i18n %]', '[% "Raiting" | i18n %]'
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
                                      <div id="rating_[% elem.nivel1.getId1 %]"></div>
                                      <script type="text/javascript">
                                          $('#rating_[% elem.nivel1.getId1 %]').raty({
                                              cancel    : true,
                                              cancelOff : 'cancel-off-big.png',
                                              cancelOn  : 'cancel-on-big.png',
                                              half      : true,

                                              score     : '[% elem.rating %]',
                                              readOnly: true,
                                          });

                                     </script>
                                </td>

                              </tr>

                             
                      [% END %]
                    </tbody>  
			     </table> 
      [% END %]
       
                         
		</fieldset>
[% ELSE %]
     <div class="alert alert-info"> [% 'No hay ejemplares para mostrar.' | i18n %] </div>
[% END %]