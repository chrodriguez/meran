[% USE HTML %]

<script type="text/javascript">    
        function enviar(){
              [% IF plainPassword == 0 %]
                  var nroRandom   = [% nroRandom %];
                  var hash        = b64_sha256(b64_sha256(b64_md5($("#password_plain").val()))+nroRandom);
                  $("#password").val(hash);
              [% ELSE %]
                  $("#password").val($("#password_plain").val());
              [% END %]
              return true;
      }
      var RecaptchaOptions = {
   
        theme : 'white',
      }

      //onEnter con foco en input, ejecuta la busqueda
      var RecaptchaOptions = {
          theme : 'blue', /* tema color blanco */
          lang : 'es' /* idioma español */
      };    

      onEnter("password",enviar);
      

</script>


<!-- Login -->
[% IF !socio_data %]
    <section class="center-section-form medium">
		<div class="page-header">
		    <h1>Meran <small>[% 'Inicio de sesi&oacute;n' | i18n %]</small></h1>
		</div>  
        <div id="signin">
          <form class="form-horizontal" method="post" id="signin_main" action="[% url_prefix %]/opac-login.pl" onsubmit="return enviar()">
                <div class="form-search">
                <div class="control-group">
                     <label class="control-label" for="username">[% 'Usuario' | i18n %]</label>
                     <div class="controls">
                          <input name="userid" id="userid" value="[% username_input %]" tabindex="4" type="text" class="input-big">
	                 </div>
                </div>
                <div class="control-group">
                     <label class="control-label" for="username">[% 'Contrase&ntilde;a' | i18n %]</label>
                     <div class="controls">
                          <input id="password_plain" name="" value="" title="password" tabindex="5" type="password" class="input-big">
                          <input type="hidden" name="password" id="password" tabindex="2" class="field" value="" />
                     </div>
                </div>
         
                
                <div class="form-actions">
                            [% PERL %]
                                  print C4::AR::Filtros::action_link_button( 
                                                                  button    => "btn btn-inverse",
                                                                  url       => "[% url_prefix %]/opac-forgot-password.pl",
                                                                  title     => "[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]",
                                                              ) ;
        
                            [% END %]
                            <button id="signin_submit_main" class="btn btn-primary" tabindex="6" type="submit">[% 'Iniciar Sesi&oacute;n' | i18n %] </button>
                                       
	              </div>
                

	              [%  IF mostrar_captcha  %]
	                  <div id=captcha>
	                    <script src="http://www.google.com/recaptcha/api/challenge?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" type="text/javascript"></script>
	                    <noscript>
                    		<iframe frameborder="0" height="300" src="http://www.google.com/recaptcha/api/noscript?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" width="500"></iframe>
                            <textarea cols="40" name="recaptcha_challenge_field" rows="3"></textarea>
                            <input name="recaptcha_response_field" type="hidden" value="manual_challenge" />
	                    </noscript>
	                  </div>
	                [% END %]
          </form>
        </div>
    </section>
[% END %]
