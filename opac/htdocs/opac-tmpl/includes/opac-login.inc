<script src="/includes/util.js"></script>
<script src="/includes/md5.js"></script>
<script src="/includes/sha1.js"></script>

[% IF RANDOM_NUMBER %]
    <script type="text/javascript">
        function enviar(){
            var nroRandom= [% RANDOM_NUMBER %];
            var username = $.trim($("#userid").val());
            var hash= b64_sha256(b64_sha256(b64_md5($("#password_plain").val()))+nroRandom);
            $("#password").val(hash);
            $("#userid").val(username);
            $("#datosAEnviar").submit();
            return true;
        }
    </script>

    <script type="text/javascript">

        $(document).ready(function() {
            //onEnter con foco en input, ejecuta la busqueda
              onEnter("password",enviar);
              $("#userid").focus();
        });

    </script>
[% END %]
<!-- Login -->
[% IF socio %]
    <h1>[% 'Mi Sesi&oacute;n' | i18n %]</h1>
    <p>
      [% socio.persona.getNombre %] ([% socio.getNro_socio %])
    </p>
    <p>
      [% PERL %]
              print C4::AR::Filtros::link_to( text    =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]",
                                              url     =>  "/cgi-bin/koha/logout.pl",
                                              title   =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]"
                      ) ;
      [% END %]
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
      <form name="datosAEnviar" method="post" action="/cgi-bin/koha/opac-main.pl" onSubmit = "enviar()">
<!-- <form id="datosAEnviar" method="post" action="/cgi-bin/koha/opac-main.pl">  -->
        <p><input type="hidden" name="remember_me" value="0" /></p>
        <fieldset>
          <p>
            <label for="userid" class="top">[% 'Usuario' | i18n %]:</label><br />
            <input type="text" name="userid" id="userid" tabindex="1" class="field" value="" />
          </p>
          <p>
            <label for="password_plain" class="top">[% 'Contrase&ntilde;a' | i18n %]:</label><br />
            <input type="password" name="password_plain" id="password_plain" tabindex="2" class="field" value="" />
            <input type="hidden" name="password" id="password" tabindex="2" class="field" value="" />
          </p>
          <p>
            <input type="checkbox" name="checkbox_1" id="checkbox_1" class="checkbox" tabindex="3" size="1" value="" />
            <label for="checkbox_1" class="right">[% 'Recordarme' | i18n %]</label>
          </p>
          <p>
            <input type="submit" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  />
<!--         <input type="button"  onclick="enviar()" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  /> -->
          </p>
          <p>
            <a href="#" id="forgotpsswd_1">[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]</a>
          </p>
        </fieldset>
      </form>
    </div>
[% END %]