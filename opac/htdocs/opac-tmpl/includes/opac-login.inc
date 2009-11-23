<script src="/includes/util.js"></script>
<script src="/includes/md5.js"></script>
<script src="/includes/sha1.js"></script>

<script type="text/javascript">
    function enviar(){
        var nroRandom= [% RANDOM_NUMBER %];
        
        var username = $.trim($("#userid").val());
        var hash= b64_sha256(b64_sha256(b64_md5($("#password").val()))+nroRandom);
        $("#password").val(hash);
        $("#userid").val(username);
        $("#datosAEnviar").submit();
    }
</script>

<script type="text/javascript">

    $(document).ready(function() {
        //onEnter con foco en input, ejecuta la busqueda
          onEnter("userid",enviar);
          onEnter("password",enviar);
          $("#userid").focus();
    });

</script>

<!-- Login -->
[% IF socio %]
    <h1>[% 'Mi Sesi&oacute;n' | i18n %]</h1>
    <p>
      [% socio.persona.getNombre %] ([% socio.getNro_socio %])
    </p>
    <p>
      <a href="/cgi-bin/koha/logout.pl" id="forgotpsswd_1">[% 'Cerrar Sesi&oacute;n' | i18n %]</a>
    </p>
[% ELSE %]
    <div class="round-border-topright"></div>
    [% IF show_navlink %]
        <h1>[% 'Ingresar' | i18n %]</h1>
    [% ELSE %]
            <h1 class="first">[% 'Ingresar' | i18n %]</h1>
            <br>
    [% END %]
    <div class="loginform">
      <form name="datosAEnviar" method="post" action="/cgi-bin/koha/login.pl" onSubmit = "enviar()"> 
        <p><input type="hidden" name="remember_me" value="0" /></p>
        <fieldset>
          <p>
            <label for="userid" class="top">[% 'Usuario' | i18n %]:</label><br />
            <input type="text" name="userid" id="userid" tabindex="1" class="field" value="" />
          </p>
          <p>
            <label for="password" class="top">[% 'Contrase&ntilde;a' | i18n %]:</label><br />
            <input type="password" name="password" id="password" tabindex="2" class="field" value="" />
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