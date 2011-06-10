[% INCLUDE 'ChangePasswordHelper.inc' %]

<script type="text/javascript">

    function checkPassword(){

        var changed = $.trim($('#actualpassword').val());
        if (changed != ''){
            var key= b64_sha256(b64_md5($('#actualpassword').val()));
            $('#new_password1').val(encriptar($('#newpassword1').val(), key));
            $('#new_password2').val(encriptar($('#newpassword2').val(), key));
        }
        return true;
    }

    $(document).ready(function() {
        CrearAutocompleteCiudades({IdInput: 'ciudad', IdInputHidden: 'id_ciudad'});
        $("#temas_opac").change(function() {
            $("link").attr("href","[% temas %]/"+$("#temas_opac").val()+"/includes/opac.css");
            return false;
        });
    });
</script>
    <!--    <h1 class="block">[% 'Modificar sus datos personales' | i18n%]</h1>-->
        [% IF message_info %]
            <h1 class="block error_field">[% 'Error en datos, s&iacute;rvase corregirlos' | i18n%]</h1>
        [% END %]
        <div class="column1-unit" style="width: 500px">
          <div class="contactform" style="width: 100%">
            <form method="post" action="[% url_prefix %]/opac-recover-password.pl" onSubmit="return checkPassword()">
              <fieldset>
                <legend>&nbsp;[% 'Restablecimiento de clave ' | i18n %]&nbsp;</legend>
                   <!-- CAMPOS PARA CAMBIO DE PASSWORD -->
                   <input type="hidden" name="new_password1" id="new_password1" />
                   <input type="hidden" name="new_password2" id="new_password2" />
                   <input type="hidden" name="key" id="key" value="[% key %]"/>
                  <p>
                      <label for="newpassword1" class="left">[% 'Nueva Contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="newpassword1" id="newpassword1" class="field" autocomplete="off" />
                  </p>
                  <p>
                      <label for="newpassword2" class="left">[% 'Repetir contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="newpassword2" id="newpassword2" class="field" autocomplete="off" />
                  </p>
              </fieldset>
              <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Confirme contrase&ntilde;a' |  i18n %]" tabindex="12" /></p>
            </form>
          </div>
        </div>