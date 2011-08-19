<script language="javascript" type="text/javascript">
    var URL_PREFIX  = '[% url_prefix %]';
</script>
<script src="/includes/util.js" type="text/javascript"></script>
<script src="/includes/md5.js" type="text/javascript"></script>
<script src="/includes/sha1.js" type="text/javascript"></script>
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
      var RecaptchaOptions = {};
      
       $(document).ready(function() {
            //onEnter con foco en input, ejecuta la busqueda
              onEnter("password",enviar);
              $("#userid").focus();
        });
</script>
<!-- Login -->
[% IF !socio_data %]
        [% IF !show_navlink %]
                <br />
        [% END %]
        [% IF mensaje %]      
            <h1>[% mensaje %]</h1>
        [% END %]

        <div class="searchform">
          <form action="[% url_prefix %]/opac-busquedasDB.pl" style="width:100px;" method="get">
            
              <input type="text" name="string" class="field"  value="[% search_string %]" tabindex="-1" style="width: 200px;" />
              <input type="submit" name="button" class="button" value="[% 'Buscar' | i18n %]" style="width: 125px;" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
   
          </form>
        </div>
       
	

        
        <div id="login" style="float:right;">
          <div class="column1-unit" style="width:122px;">
                <div class="contactform" style="width:315px;">
                    <form id="datosAEnviar" method="post" action="[% url_prefix %]/opac-main.pl" onsubmit="return enviar()" autocomplete="off">
                      <p><input type="hidden" name="remember_me" value="0" /></p>
                      <fieldset>
                        <legend>&nbsp;[% 'Ingrese sus datos de autenticaci&oacute;n' | i18n %]&nbsp;</legend>
                        <p>
                          <label for="userid" class="top">[% 'Usuario' | i18n %]:</label><br />
                          <input type="text" name="userid" id="userid" tabindex="1" class="field" value="" />
                        </p>
                        <p>
                          <label for="password_plain" class="top">[% 'Contrase&ntilde;a' | i18n %]:</label><br />
                          <input type="password" name="" id="password_plain" tabindex="2" class="field" value="" />
                          <input type="hidden" name="password" id="password" tabindex="2" class="field" value="" />
                        </p>
                        <p>
                          <input type="submit" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  />
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
                        <p>
                          [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]",
                                                              url =>      "[% url_prefix %]/opac-forgot-password.pl", 
                                                              title =>    "[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]"
                                                          ) ;
                          [% END %]
                          
                        </p>
                      </fieldset>
                    </form>
                </div>
          </div>
        </div>
[% END %]
