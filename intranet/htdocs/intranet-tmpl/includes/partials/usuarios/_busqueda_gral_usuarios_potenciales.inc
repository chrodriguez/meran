<form class="form-horizontal" onsubmit="return false;">
          <div class="control-group">
              <div class="controls">
             <!--     <input id="buscar" class="textInput" type="text" value="" name="buscar">-->
                  <input id="persona" class="textInput" type=text name="persona" value="[% persona %]" onFocus="checkFilter('focus')" onBlur="checkFilter('blur')"> 
                  [% PERL %]
                      print C4::AR::Filtros::setHelpInput(
                                                          text =>"[% "Tipear el apellido, DNI o legajo del usuario. Presionar buscar." | i18n %]",
                                                            
                      );
                  [% END %]
                
              </div>
          </div>
  
          <div class="form-actions">
                      [% PERL %]
                              print C4::AR::Filtros::action_button(
                                                              button       => "btn click",
                                                              action       => "Borrar();",
                                                              icon         => "",
                                                              title        => "[% 'Limpiar' | i18n %]",
                                                          ) ;

                      [% END %]
                      [% PERL %]
                              print C4::AR::Filtros::action_button(
                                                              button       => "btn btn-primary",
                                                              action       => "buscarUsuariosPotenciales();",
                                                              icon         => "",
                                                              title        => "[% 'Buscar' | i18n %]",
                                                          ) ;

                      [% END %]
                    
                      
          </div>
</form>
