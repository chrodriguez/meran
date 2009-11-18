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

              <fieldset>
                <legend>&nbsp;MESSAGE DETAILS&nbsp;</legend>
                <p><label for="contact_subject" class="left">Subject:</label>
                   <input type="text" name="contact_subject" id="contact_subject" class="field" value="" tabindex="4" /></p>
                <p><label for="contact_urgency" class="left">Please reply:</label>
                   <select name="contact_urgency" id="contact_urgency" class="combo">
                     <option value="choose"> Select... </option>
                     <option value="today"> Latest today </option>
                     <option value="tomorrow"> Latest tomorrow </option>
                     <option value="threedays"> Latest in 3 days </option>
                     <option value="week"> Latest in a week </option>
                     <option value="month"> Latest in a month </option></select></p>
                <p><label for="contact_message" class="left">Message:</label>
                   <textarea name="contact_message" id="contact_message" cols="45" rows="10"tabindex="5"></textarea></p>
                <p><input type="submit" name="submit" id="submit" class="button" value="Send message" tabindex="6" /></p>
              </fieldset>
            </form>
          </div>
        </div>