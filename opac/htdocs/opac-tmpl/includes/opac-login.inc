<!-- Login -->
[% IF socio %]
    <h1>[% 'Mi Sesi&oacute;n' | i18n %]</h1>
    <p>
      <h1>[% socio.persona.getNombre %] ([% socio.getNro_socio %])</h1>
    </p>
    <p>
      <a href="#" id="forgotpsswd_1">[% 'Cerrar Sesi&oacute;n' | i18n %]</a>
    </p>
[% ELSE %]
    <h1>[% 'Ingresar' | i18n %]</h1>
    <div class="loginform">
      <form method="post" action="index.html"> 
        <p><input type="hidden" name="rememberme" value="0" /></p>
        <fieldset>
          <p>
            <label for="username_1" class="top">[% 'Usuario' | i18n %]:</label><br />
            <input type="text" name="username_1" id="username_1" tabindex="1" class="field" value="" />
          </p>
          <p>
            <label for="password_1" class="top">[% 'Contrase&ntilde;a' | i18n %]:</label><br />
            <input type="password" name="password_1" id="password_1" tabindex="2" class="field" value="" />
          </p>
          <p>
            <input type="checkbox" name="checkbox_1" id="checkbox_1" class="checkbox" tabindex="3" size="1" value="" />
            <label for="checkbox_1" class="right">[% 'Recordarme' | i18n %]</label>
          </p>
          <p>
            <input type="submit" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  />
          </p>
          <p>
            <a href="#" id="forgotpsswd_1">[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]</a>
          </p>
        </fieldset>
      </form>
    </div>
[% END %]