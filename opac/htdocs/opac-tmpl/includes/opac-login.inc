<script type="text/javascript">
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
      var RecaptchaOptions = {
   
        theme : 'white',
//         lang : 'es,   
        
      }
      
      $(document).ready(function() {


                    $(function () {
                        var $alert = $('#alert_msg_main');
                        if($alert.length)
                        {
//                             var alerttimer = window.setTimeout(function () {
//                                 $alert.trigger('click');
//                             }, 3000);
                            $alert.animate({height: $alert.css('line-height') || '50px'}, 200)
                            .click(function () {
                                window.close;
                                $alert.animate({height: '0'}, 200);
                            });
                        }
                    });


                  //onEnter con foco en input, ejecuta la busqueda
                    var RecaptchaOptions = {
                        theme : 'blue', /* tema color blanco */
                        lang : 'es' /* idioma español */
                    };    

                    onEnter("password",enviar);

                    // Add the value of "Search..." to the input field and a class of .empty
                    $("#search").val("Buscar...").addClass("empty");

                    // When you click on #search
                    $("#search").focus(function(){

                        // If the value is equal to "Search..."
                        if($(this).val() == "Buscar...") {
                            // remove all the text and the class of .empty
                            $(this).val("").removeClass("empty");;
                        }

                    });

                    // When the focus on #search is lost
                    $("#search").blur(function(){

                        // If the input field is empty
                        if($(this).val() == "") {
                            // Add the text "Search..." and a class of .empty
                            $(this).val("Buscar...").addClass("empty");
                        }

                    });

                    $("#search").focus();

      });

</script>


<!-- Login -->
[% IF !socio_data %]
        [% IF !show_navlink %]
                <br />
        [% END %]
        [% IF mensaje %]      
            <h1 id="alert_msg_main">[% mensaje %]</h1>


        [% END %]


[% IF !loginFailed  %]
        <div id="divsearchform" >
            <form id="searchform_main" action="[% url_prefix %]/opac-busquedasDB.pl" method="get" >
                <fieldset>
                   <input type="text" id="search" name="string" value="[% search_string %]" tabindex="-1"/>
                   <input type="submit" id="search-submit" value=""/>
                   <input type="hidden" name="tipoAccion"  value="BUSQUEDA_COMBINABLE" />
                   <input type="hidden" name="token" value="[% token %]" />
                </fieldset>
            </form>
        </div>
[% ELSE %]
       <p id="titulo_login_main">Ingresar a MERAN</p>
       <div class="login_main" >
   
          <form method="post" id="signin_main" action="[% url_prefix %]/opac-main.pl"  onsubmit="return enviar()">
               <p>
                  <input type="hidden" name="remember_me" value="0"/>
               </p>
               <p>
                  <label for="userid">[% 'Usuario' | i18n %]</label>
                  <input name="userid" id="userid" value="" title="username" tabindex="4" type="text">
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
