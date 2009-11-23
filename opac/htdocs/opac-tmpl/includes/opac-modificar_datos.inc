        <h1 class="block">[% 'Modificar sus datos personales' | i18n%]</h1>
        <div class="column1-unit">
          <div class="contactform">
            <form method="post" action="index.html">
              <fieldset>
                <legend>&nbsp;[% 'Detalle de ' | i18n %] [% socio.persona.getApellido %], [% socio.persona.getNombre %]&nbsp;</legend>

                <p><label for="contact_firstname" class="left">[% 'Nombres' |  i18n %]:</label>
                   <input type="text" name="nombre" id="nombre" class="field" value="[% socio.persona.getNombre %]" tabindex="6" /></p>
                <p><label for="apellido" class="left">[% 'Apellido/s' |  i18n %]:</label>
                   <input type="text" name="apellido" id="apellido" class="field" value="[% socio.persona.getApellido %]" tabindex="7" /></p>
                <p><label for="ciudad" class="left">[% 'Ciudad' |  i18n %]:</label>
                   <input type="text" name="ciudad" id="ciudad" class="field" value="" tabindex="8" /></p>
                <p><label for="telefono" class="left">[% 'Tel&eacute;fono' |  i18n %]:</label>
                   <input type="text" name="telefono" id="telefono" class="field" value="[% socio.persona.getTelefono %]" tabindex="12" /></p>
                <p><label for="email" class="left">[% 'E-mail' |  i18n %]:</label>
                   <input type="text" name="email" id="email" class="field" value="[% socio.persona.getEmail %]" tabindex="13" /></p>
              </fieldset>
              <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Modificar datos' |  i18n %]" tabindex="18" /></p>
            </form>
          </div>
        </div>