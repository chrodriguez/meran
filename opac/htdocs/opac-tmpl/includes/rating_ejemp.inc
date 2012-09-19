
  <script type="text/javascript">
  $(document).ready(function() {

    $('#rating_[% elem.id %]').raty({
        cancel    : true,
        cancelOff : 'cancel-off-big.png',
        cancelOn  : 'cancel-on-big.png',
        half      : true,
        size      : 24,
        starHalf  : 'star-half-big.png',
        starOff   : 'star-off-big.png',
        starOn    : 'star-on-big.png',
        score   : '[% elem.rating %]',
        readOnly: true,

      click       : function(score, evt) {

          $.ajax({
              url: '[% url_prefix %]/rating.pl',
              data: {rate: score, id2: "[% id2 %]"}, 
              type: 'POST',
              success: function (data) {
                    $("#ajax_response[% elem.id %]").html(data);
                    $("#ajax_response[% elem.id %]").show();
      
              },
              error: function (jxhr, msg, err) {
                  $('#response').append('<li style="color:red">' + msg + '</li>');
              }
          });


        }
    });

      


  });
  </script>

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
                                      <div id="rating_[% elem.id %]"></div>

                                  
                                </td>
                                <script type="text/javascript">
                  
                                    $('#rating_[% elem.id %]').raty({
                                        cancel    : true,
                                        cancelOff : 'cancel-off-big.png',
                                        cancelOn  : 'cancel-on-big.png',
                                        half      : true,

                                        score     : '[% elem.rating %]',
                                        readOnly: true,
                                    });

                               </script>

                      [% END %] <!-- FOREACH prestamos -->
                    </tbody>  
                      [% END %]

			</table> 
       </tr>
                         
		</fieldset>
[% ELSE %]
     <div class="alert alert-info"> [% 'No hay ejemplares para mostrar.' | i18n %] </div>
[% END %]