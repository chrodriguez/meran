        <h1 class="block">6 - Contact form</h1>
        <div class="column1-unit">
          <div class="contactform">
            <form method="post" action="index.html">
              <fieldset><legend>&nbsp;CONTACT DETAILS&nbsp;</legend>
                <p><label for="contact_title" class="left">Title:</label>
                   <select name="contact_title" id="contact_title" class="combo" tabindex="5">
                     <option value="choose"> Select... </option>
                     <option value="mrs"> Mrs. </option>
                     <option value="mr"> Mr. </option>
                     <option value="dr"> Dr. </option></select></p>
                <p><label for="contact_firstname" class="left">First name:</label>
                   <input type="text" name="contact_firstname" id="contact_firstname" class="field" value="" tabindex="6" /></p>
                <p><label for="contact_familyname" class="left">Family name:</label>
                   <input type="text" name="contact_familyname" id="contact_familyname" class="field" value="" tabindex="7" /></p>
                <p><label for="contact_street" class="left">Street:</label>
                   <input type="text" name="contact_street" id="contact_street" class="field" value="" tabindex="8" /></p>
                <p><label for="contact_postalcode" class="left">Postal code:</label>
                   <input type="text" name="contact_postalcode" id="contact_postalcode" class="field" value="" tabindex="9" /></p>
                <p><label for="contact_city" class="left">City:</label>
                   <input type="text" name="contact_city" id="contact_city" class="field" value="" tabindex="10" /></p>
                <p><label for="contact_country" class="left">Country:</label>
                   <select name="contact_country" id="contact_country" class="combo" tabindex="11">
                     <option value="choose"> Select... </option>
                     <option value="Sweden"> Sweden </option>
                     <option value="United States"> United States </option>
                     <option value="China"> China </option></select></p>
                <p><label for="contact_phone" class="left">Phone:</label>
                   <input type="text" name="contact_phone" id="contact_phone" class="field" value="" tabindex="12" /></p>
                <p><label for="contact_email" class="left">Email:</label>
                   <input type="text" name="contact_email" id="contact_email" class="field" value="" tabindex="13" /></p>
                <p><label for="contact_url" class="left">Website:</label>
                   <input type="text" name="contact_url" id="contact_url" class="field" value="" tabindex="14" /></p>
              </fieldset>
              <fieldset><legend>&nbsp;MESSAGE DETAILS&nbsp;</legend>
                <p><label for="contact_subject" class="left">Subject:</label>
                   <input type="text" name="contact_subject" id="contact_subject" class="field" value="" tabindex="15" /></p>
                <p><label for="contact_urgency" class="left">Please reply:</label>
                   <select name="contact_urgency" id="contact_urgency" class="combo" tabindex="16">
                     <option value="choose"> Select... </option>
                     <option value="today"> Latest today </option>
                     <option value="tomorrow"> Latest tomorrow </option>
                     <option value="threedays"> Latest in 3 days </option>
                     <option value="week"> Latest in a week </option>
                     <option value="month"> Latest in a month </option></select></p>
                <p><label for="contact_message" class="left">Message:</label>
                   <textarea name="contact_message" id="contact_message" cols="45" rows="10" tabindex="17"></textarea></p>
                <p><input type="submit" name="submit" id="submit" class="button" value="Send message" tabindex="18" /></p>
              </fieldset>
            </form>
          </div>
        </div>