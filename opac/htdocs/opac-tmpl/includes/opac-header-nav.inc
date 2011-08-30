<script type="text/javascript">
	$(document).ready(function() {
	    $("#userid").attr("autocomplete","off");
        $("#iniciar_sesion").click(function(){$("#userid").focus()});
	});
</script>
[% USE HTML %]
  
      <!-- Navigation Level 0 -->
        <div class="nav0">
          [% localization_FLAGS %]
        </div>
        <!-- Navigation Level 1 -->
        <div class="nav1">
          <ul>
            <li>
                <a href="[% url_prefix %]/opac-main.pl?token=[% token %]" title="[% 'Ir a la p&aacute;gina de inicio' | i18n %]">[% 'Inicio' | i18n %]</a>
            </li>
            <li>
                <a href="[% url_prefix %]/opac-about.pl?token=[% token %]" title="[% 'Sepa qui&eacute;nes somos' | i18n %]">[% 'Acerca de' | i18n %]</a>
            </li>
            <li>
                <a href="[% url_prefix %]/opac-contact.pl?token=[% token %]" title="[% 'P&oacute;ngase en contacto con nosotros' | i18n %]">[% 'Contacto' | i18n %]</a>
            </li>
          </ul>
        </div>
      <!-- Navigation Level 1.1 -->
        <div class="nav_logged">
            
	      [% IF socio_data.usr_nro_socio %]
                  <p style="float:right;">    
                    [% HTML.escape(socio_data.usr_nombre) %]&nbsp;[% HTML.escape(socio_data.usr_apellido) %]
                  </p>
		  <p> <br> 
		    [% PERL %]
                            print C4::AR::Filtros::link_to( text    =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]",
                                                            url     =>  "[% url_prefix %]/logout.pl",
                                                            title   =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]"
                                    ) ;
                    [% END %]
		  </p>
         
              [% ELSE %]
                   [% IF !loginFailed  %]
                        <div id="drop_down_login" class="drop_down_login"> <a id="iniciar_sesion" href="login" class="signin"><span>Iniciar Sesion</span></a>
                            <fieldset id="signin_menu">
                                    <!-- ORIGINAL  <form id="datosAEnviar" method="post" action="[% url_prefix %]/opac-main.pl" onsubmit="return enviar()" autocomplete="off">-->
                                    <form method="post" id="signin" action="[% url_prefix %]/opac-main.pl" onsubmit="return enviar()">
                                          <p><input type="hidden" name="remember_me" value="0" /></p>
                                          <label for="userid">[% 'Usuario' | i18n %]</label>
                                          <input name="userid" id="userid" value="" title="username" tabindex="4" type="text">
                                          </p>
                                          <p>
                                            <label for="password_plain">[% 'Contrase&ntilde;a' | i18n %]</label>
                                            <input id="password_plain" name="" value="" title="password" tabindex="5" type="password">
                                            <input type="hidden" name="password" id="password" tabindex="2" class="field" value="" />
                                          </p>
                                          <p class="remember">
                                                <input id="signin_submit" name="cmdweblogin" value="[% 'Enviar' | i18n %]" tabindex="6" type="submit">
                                          </p>


                                          [%  IF mostrar_captcha  %]
                                              <div id=captcha>
                                                <script src="http://www.google.com/recaptcha/api/challenge?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" type="text/javascript"></script>
                                                <noscript><iframe frameborder="0" height="300" src="http://www.google.com/recaptcha/api/noscript?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" width="500"></iframe>
                                                          <textarea cols="40" name="recaptcha_challenge_field" rows="3"></textarea>
                                                          <input name="recaptcha_response_field" type="hidden" value="manual_challenge" />
                                                </noscript>
                                              </div>
                                            [% END %]

                                          <p class="forgot"> <a href="[% url_prefix %]/opac-forgot-password.pl" id="resend_password_link">[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]</a> </p>
                                          
                                </form>
                          </fieldset>
                    </div>
                 [% END %]
             [% END %]
            <!--</ul>-->
        </div>
      </div>
      <!-- A.2 HEADER MIDDLE -->
      <div class="header-middle">    
      </div>
      <!-- A.3 HEADER BOTTOM -->
      <div class="header-bottom">
        <!-- Navigation Level 2 (Drop-down menus) -->
        <div class="nav2">
          <!-- Navigation item -->
          <ul>
            <li>
                [% PERL %]
                    print C4::AR::Filtros::link_to( text    =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
                                                    url     =>  '[% url_prefix %]/opac-advanced_search.pl',
                                                    title   =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
                            ) ;
                [% END %]
            </li>
            <li>
                [% PERL %]
                    print C4::AR::Filtros::link_to( text    =>  "[% 'Estantes Virtuales' | i18n %]",
                                                    url     =>  '[% url_prefix %]/opac-estante.pl',
                                                    title   =>  "[% 'Estantes Virtuales' | i18n %]",
                            ) ;
                [% END %]
            </li>
            [% IF socio_data.usr_nro_socio %]
		            <li><a href="#">[% 'Mi cuenta' | i18n %]<!--[if IE 7]><!--></a><!--<![endif]-->
		              <!--[if lte IE 6]><table><tr><td><![endif]-->
		                <ul>
		                      <li>
		                          <a href='[% url_prefix %]/opac-prestamos_vigentes.pl?token=[% token %]'>
		                              [% 'Pr&eacute;stamos vigentes' | i18n %]
		                          </a>
		                      </li>
		                      <li>
		                          <a href='[% url_prefix %]/opac-historial_prestamos.pl?token=[% token %]'>
		                              [% 'Historial de pr&eacute;stamos' | i18n %]
		                          </a>
		                      </li>
		                      <li>
		                          <a href='[% url_prefix %]/opac-historial_reservas.pl?token=[% token %]'>
		                              [% 'Historial de reservas' | i18n %]
		                          </a>
		                      </li>
		                      <li>
		                          [% PERL %]
		                              print C4::AR::Filtros::link_to( text    =>  "[% 'Recomendaciones' | i18n %]",
		                                                              url     =>  '[% url_prefix %]/opac-recomendaciones.pl',
		                                                              title   =>  "[% 'Recomendaciones' | i18n %]",
		                                      ) ;
		                          [% END %]
		                      </li>
		                      <li>
		                          <a href='[% url_prefix %]/opac-favoritos.pl?token=[% token %]'>
		                              [% 'Mis favoritos' | i18n %]
		                          </a>
		                      </li>
                      </ul>
                  <!--[if lte IE 6]></td></tr></table></a><![endif]-->
                </li>
            [% END %]
        </div>
 
      <!-- A.4 HEADER BREADCRUMBS -->

      <!-- Breadcrumbs -->

        <div class="header-breadcrumbs">
          [% INCLUDE 'opac-search_form.inc' %]
        </div>

      </div>
        
    </div>
    <div class="msg_main_div">   
          [% IF mensaje %]      
            <h1 id="alert_msg_main">[% mensaje %]</h1>
          [% END %] 
    </div>

    <!-- For alternative headers END PASTE here -->
