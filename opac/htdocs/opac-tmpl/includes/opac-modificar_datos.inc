[% INCLUDE 'ChangePasswordHelper.inc' %]

<script type="text/javascript">

    function checkPassword(){

        var changed = $.trim($('#actualpassword').val());
        if (changed != ''){
            var key= b64_sha256(b64_md5($('#actualpassword').val()));
            $('#actual_password').val(encriptar($('#actualpassword').val(), key));
            $('#new_password1').val(encriptar($('#newpassword1').val(), key));
            $('#new_password2').val(encriptar($('#newpassword2').val(), key));
            $('#changePassword').val(1);
        }
        return true;
    }

    $(document).ready(function() {
        CrearAutocompleteCiudades({IdInput: 'ciudad', IdInputHidden: 'id_ciudad'});
    });
</script>
        <h1 class="block">[% 'Modificar sus datos personales' | i18n%]</h1>
        <div class="column1-unit" style="width: 500px">
          <div class="contactform" style="width: 100%">
            <form method="post" action="/cgi-bin/koha/opac-userupdate.pl" onSubmit="return checkPassword()">
              <fieldset>
                <legend>&nbsp;[% 'Detalle de ' | i18n %] [% socio.persona.getApellido %], [% socio.persona.getNombre %]&nbsp;</legend>
                <p><label for="contact_firstname" class="left">[% 'Nombres' |  i18n %]:</label>
                   <input type="text" name="nombre" id="nombre" class="field" value="[% socio.persona.getNombre %]" tabindex="6" /></p>
                <p><label for="apellido" class="left">[% 'Apellido/s' |  i18n %]:</label>
                   <input type="text" name="apellido" id="apellido" class="field" value="[% socio.persona.getApellido %]" tabindex="7" /></p>
                <p><label for="ciudad" class="left">[% 'Ciudad' |  i18n %]:</label>
                   <input type="text" name="ciudad" id="ciudad" class="field" value="[% socio.persona.ciudad_ref.NOMBRE %]" tabindex="8" /></p>
                   <input type="hidden" name="id_ciudad" id="id_ciudad" class="field" value="[% socio.persona.ciudad_ref.id %]"/></p>
                <p><label for="direccion" class="left">[% 'Direcci&oacute;n' |  i18n %]:</label>
                   <input type="text" name="direccion" id="direccion" class="field" value="[% socio.persona.getCalle %]" tabindex="9" /></p>
                <p><label for="telefono" class="left">[% 'Tel&eacute;fono' |  i18n %]:</label>
                   <input type="text" name="telefono" id="telefono" class="field" value="[% socio.persona.getTelefono %]" tabindex="10" /></p>
                <p><label for="email" class="left">[% 'E-mail' |  i18n %]:</label>
                   <input type="text" name="email" id="email" class="field" value="[% socio.persona.getEmail %]" tabindex="11" /></p>
                   <input type="hidden" name="token" id="token" value="[% token %]" />
                   <!-- CAMPOS PARA CAMBIO DE PASSWORD -->
                   <input type="hidden" name="new_password1" id="new_password1" autocomplete="off">
                   <input type="hidden" name="new_password2" id="new_password2" autocomplete="off">
                   <input type="hidden" name="changePassword" id="changePassword" autocomplete="off">
                   <input type="hidden" name="actual_password" id="actual_password" autocomplete="off">
              </fieldset>
              <fieldset>
                  <legend>&nbsp;[% 'Cambio de contrase&ntilde;a' | i18n %] ([% 'Dejar en blanco para descartar' | i18n %])&nbsp;</legend>
                  <p>
                      <label for="actualpassword" class="left">[% 'Contrase&ntilde;a Actual' | i18n %]:</label>
                      <input type="password" name="actualpassword" id="actualpassword" class="field" autocomplete="off">
                  </p>
                  <p>
                      <label for="newpassword1" class="left">[% 'Nueva Contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="newpassword1" id="newpassword1" class="field" autocomplete="off">
                  </p>
                  <p>
                      <label for="newpassword2" class="left">[% 'Repetir contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="newpassword2" id="newpassword2" class="field" autocomplete="off">
                  </p>
              </fieldset>
              <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Modificar datos' |  i18n %]" tabindex="12" /></p>
            </form>
          </div>
        </div>