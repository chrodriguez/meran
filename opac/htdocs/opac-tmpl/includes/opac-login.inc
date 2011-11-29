<script type="text/javascript">
    var URL_PREFIX  = '[% url_prefix %]';
</script>

[% USE HTML %]

<!-- Login -->
[% IF !socio_data %]
     

[% IF !loginFailed  %]
		<style>
			.main-content{
			    top: 50%;
			    display: table-cell; 
			    vertical-align: middle;
			    position: absolute;
			}
		</style>
		<script>
			  function startSearch(event) {
				  if (event.target.results.length > 1) {
			          var second = event.target.results[1].utterance;
			          document.getElementById("second_best").value = second;
			        }  
			  }
			  
		</script>
        <div id="divsearchform" >
            <form id="searchform_main" action="[% url_prefix %]/opac-busquedasDB.pl" method="get" onsubmit="startOverlay();" >
                <fieldset>
                   <input type="text" id="search" name="string" value="[% search_string %]" tabindex="-1" 
                   		  x-webkit-speech onwebkitspeechchange="javascript:startSearch();" 
                   		  speech onspeechchange="javascript:startSearch();"
                   />
                   <input type="hidden" name="second_best" id="second_best">
                   <input type="submit" id="search-submit" value=""/>
                   <input type="hidden" name="tipoAccion"  value="BUSQUEDA_COMBINABLE" />
                   <input type="hidden" name="token" value="[% token %]" />
                </fieldset>
            </form>
        </div>
        
[% ELSE %]
       <p id="titulo_login_main">Ingresar a MERAN</p>
       <div class="login_main" >
   
          <form method="post" id="signin_main" action="[% url_prefix %]/opac-main.pl" onsubmit="return enviar()">
               <p>
                  <input type="hidden" name="remember_me" value="0"/>
               </p>
               <p>
                  <label for="userid">[% 'Usuario' | i18n %]</label>
                  <input name="userid" id="userid" value="[% username_input %]"" title="username" tabindex="4" type="text">
               </p>
               <p>
                  <label for="password_plain">[% 'Contrase&ntilde;a' | i18n %]</label>
                  <input id="password_plain" name="" value="" title="password" tabindex="5" type="password">
                  <input type="hidden" name="password" id="password" tabindex="2" class="field" value="" />
               </p>
               <p class="remember">
                  <input id="signin_submit_main" name="cmdweblogin" value="[% 'Enviar' | i18n %]" tabindex="6" type="submit">
               </p>

              <p class="forgot"> <a href="[% url_prefix %]/opac-forgot-password.pl" id="resend_password_link">[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]</a> </p>                                      
              
              [%  IF mostrar_captcha  %]
                  <div id=captcha>
                    <script src="http://www.google.com/recaptcha/api/challenge?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" type="text/javascript"></script>
                    <noscript><iframe frameborder="0" height="300" src="http://www.google.com/recaptcha/api/noscript?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" width="500"></iframe>
                              <textarea cols="40" name="recaptcha_challenge_field" rows="3"></textarea>
                              <input name="recaptcha_response_field" type="hidden" value="manual_challenge" />
                    </noscript>
                  </div>
                [% END %]


          </form>
                
        </div>
[% END %]

[% END %]
