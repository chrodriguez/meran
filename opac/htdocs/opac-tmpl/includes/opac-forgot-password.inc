[% USE HTML %]

<script type="text/javascript">
	var RecaptchaOptions = {
	   lang : 'es',
	};
</script>

<div class="column1-unit" style="width:50%;">
    <h1 >[% message %]</h1>
    <div class="contactform">
        <form id="datosAEnviar" method="post" action="[% url_prefix %]/opac-forgot-password.pl" onsubmit="javascript:startOverlay();" autocomplete="off">
	         <fieldset>
	           <legend>&nbsp;[% 'Ingrese sus datos de autenticaci&oacute;n' | i18n %]&nbsp;</legend>
	           <p>
	             <label for="user-id" class="top">[% 'E-mail , Usuario &oacute; DNI' | i18n %]:</label><br />
	             <input type="user-id" name="user-id" id="user-id" tabindex="1" class="field" value="" />
	           </p>
	           <p>
	             <input type="submit" name="cmdweblogin" tabindex="2" class="button" value="[% 'Enviar' | i18n %]"  />
	           </p>
	         </fieldset>
	      <script src="http://www.google.com/recaptcha/api/challenge?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" type="text/javascript"></script>
	      <noscript><iframe frameborder="0" height="300" src="http://www.google.com/recaptcha/api/noscript?k=6LehoMQSAAAAAOhylvTt_7RrPKVdll7CN0jJRdaf" width="500"></iframe><textarea cols="40" name="recaptcha_challenge_field" rows="3"></textarea><input name="recaptcha_response_field" type="hidden" value="manual_challenge" /></noscript>
        </form>
    </div>
</div>
