<script src="/includes/util.js" type="text/javascript"></script>
<script src="/includes/md5.js" type="text/javascript"></script>
<script src="/includes/sha1.js" type="text/javascript"></script>
[% USE HTML %]
[% IF nroRandom %]
    <script type="text/javascript">
        function enviar(){
            var nroRandom= [% nroRandom %];
            var username = $.trim($("#userid").val());
            var hash= b64_sha256(b64_sha256(b64_md5($("#password_plain").val()))+nroRandom);
            $("#password").val(hash);
            $("#userid").val(username);
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
[% IF !socio_data %]
    <div class="round-border-topright"></div>
    [% IF show_navlink %]
        <h1 class="pagetitle">[% 'Ingresar' | i18n %]</h1>
        <hr class="clear-contentunit">

    [% ELSE %]
            <h1 class="pagetitle">[% 'Ingresar' | i18n %]</h1>
            <hr class="clear-contentunit">
            <br />
    [% END %]
    [% IF mensaje %]
        <h1>[% mensaje %]</h1>
    [% END %]

      <div class="column1-unit">
          <div class="contactform">
              <form id="datosAEnviar" method="post" action="/cgi-bin/koha/opac-main.pl" onsubmit="return enviar()" autocomplete="off">
                <p><input type="hidden" name="remember_me" value="0" /></p>
                <fieldset>
                  <legend>&nbsp;[% 'Ingrese sus datos de autenticaci&oacute;n' | i18n %]&nbsp;</legend>
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
                    <input type="submit" name="cmdweblogin" class="button" value="[% 'Enviar' | i18n %]"  />
                  </p>
                  <p>
                    [% PERL %]
                        print C4::AR::Filtros::link_to( text =>     "[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]",
                                                        url =>      "/cgi-bin/koha/opac-forgot-password.pl", 
                                                        title =>    "[% 'Olvid&eacute; mi contrase&ntilde;a' | i18n %]"
                                                    ) ;
                    [% END %]
                    
                  </p>
                </fieldset>
              </form>
          </div>
    </div>
[% END %]
