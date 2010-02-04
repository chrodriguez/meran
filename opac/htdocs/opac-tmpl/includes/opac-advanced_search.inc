        <h1 class="block">[% 'B&uacute;squeda Avanzada' | i18n %]</h1>
        <div class="column1-unit">
          <div class="contactform">
            <form method="post" action="index.html">
              <fieldset><legend>&nbsp;[% 'Complete lo necesario' | i18n %]&nbsp;</legend>
                <p>
                    <label for="contact_title" class="left">[% 'Tipo de documento' | i18n %]:</label>
                    [% combo_tipo_documento %]
                </p>
                <p>
                    <label for="contact_firstname" class="left">[% 'T&iacute;tulo' | i18n %]:</label>
                   <input type="text" name="contact_firstname" id="contact_firstname" class="field" value="" tabindex="1" />
                </p>
                <p>
                  <input type="submit" name="submit" id="submit" class="button" value="[% 'Buscar' | i18n %]" tabindex="6" />
                </p>
              </fieldset>
            </form>
          </div>
        </div>