[% USE HTML %]

<div class="column1-unit">
    <div class="contactform">
        <form id="datosAEnviar" method="post" action="/cgi-bin/koha/opac-forgot-password.pl" onsubmit="return enviar()" autocomplete="off">
          <p><input type="hidden" name="remember_me" value="0" /></p>
          <fieldset>
            <legend>&nbsp;[% 'Ingrese sus datos de autenticaci&oacute;n' | i18n %]&nbsp;</legend>
            <p>
              <label for="user-id" class="top">[% 'E-mail &oacute; Nro. de socio' | i18n %]:</label><br />
              <input type="user-id" name="user-id" id="user-id" tabindex="1" class="field" value="" />
            </p>
            <p>
              <input type="submit" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  />
            </p>
          </fieldset>
        </form>
    </div>
</div>
