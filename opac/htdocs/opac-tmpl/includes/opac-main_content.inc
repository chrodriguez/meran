<div class="main-content">
   <!-- Pagetitle -->
        <h1 class="pagetitle">
            [% IF content_title %]
                [% content_title %]
            [% ELSE %]
                [% 'Si no hay titulo, que pongo?????' | i18n %]
            [% END %]
        </h1>

        <!-- Content unit - One column -->
        <h1 class="block">1 - Column types</h1>
        <div class="column1-unit">
          <h1>Here comes the title</h1>
          <h3>Monday, 20 November 2006 at 20:30 GMT, by <a href="#">SiteAdmin </a></h3>
          <p>Lorem ipsum dolor sit amet, consectetuer <a href="#">adipiscing elit</a>, sed diam nonummy nibh euismod tincidunt ut laoreet dolore <a href="#">magna aliquam</a> erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis. <a href="#">Read more &raquo;</a></p>
          <p class="details">| Posted by <a href="#">SiteAdmin </a> | Categories: <a href="#">General</a> | Comments: <a href="#">73</a> |</p>
          <h1><a href="">Heading h1 with link</a></h1>
          <h3>Heading h3</h3>
          <p>Lorem ipsum dolor sit amet, consectetuer <a href="#">adipiscing elit</a>, sed diam nonummy nibh euismod tincidunt ut laoreet dolore <a href="#">magna aliquam</a> erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis. <a href="#">Read more &raquo;</a></p>
          <p class="details">Posting details ...  </p>
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->

        <!-- Content unit - One column -->
        <h1 class="block">3 - Tables</h1>
        <div class="column1-unit">
          <table>
            <tr><th class="top" scope="col">Heading 1</th><th class="top" scope="col">Heading 2</th><th class="top" scope="col">Heading 3</th><th class="top" scope="col">Heading 4</th></tr>
            <tr><th scope="row">Category 1</th><td>Data</td><td>Data</td><td>Data</td></tr>
            <tr><th scope="row">Category 2</th><td>Data</td><td>Data</td><td>Data</td></tr>
            <tr><th scope="row">Category 3</th><td>Data</td><td>Data</td><td>Data</td></tr>
          </table>
          <p class="caption"><strong>Table x.x.</strong> Caption</p>
        </div>          
        <hr class="clear-contentunit" />

        <h1 class="block">6 - Contact form</h1>
        <div class="column1-unit">
          <div class="contactform">
            <form method="post" action="index.html">
              <fieldset><legend>&nbsp;CONTACT DETAILS&nbsp;</legend>
                <p><label for="contact_title" class="left">Title:</label>
                   <select name="contact_title" id="contact_title" class="combo">
                     <option value="choose"> Select... </option>
                     <option value="mrs"> Mrs. </option>
                     <option value="mr"> Mr. </option>
                     <option value="dr"> Dr. </option></select></p>
                <p><label for="contact_firstname" class="left">First name:</label>
                   <input type="text" name="contact_firstname" id="contact_firstname" class="field" value="" tabindex="1" /></p>
                <p><label for="contact_familyname" class="left">Family name:</label>
                   <input type="text" name="contact_familyname" id="contact_familyname" class="field" value="" tabindex="1" /></p>
                <p><label for="contact_street" class="left">Street:</label>
                   <input type="text" name="contact_street" id="contact_street" class="field" value="" tabindex="1" /></p>
                <p><label for="contact_postalcode" class="left">Postal code:</label>
                   <input type="text" name="contact_postalcode" id="contact_postalcode" class="field" value="" tabindex="1" /></p>
                <p><label for="contact_city" class="left">City:</label>
                   <input type="text" name="contact_city" id="contact_city" class="field" value="" tabindex="1" /></p>
                <p><label for="contact_country" class="left">Country:</label>
                   <select name="contact_country" id="contact_country" class="combo">
                     <option value="choose"> Select... </option>
                     <option value="Sweden"> Sweden </option>
                     <option value="United States"> United States </option>
                     <option value="China"> China </option></select></p>
                <p><label for="contact_phone" class="left">Phone:</label>
                   <input type="text" name="contact_phone" id="contact_phone" class="field" value="" tabindex="2" /></p>
                <p><label for="contact_email" class="left">Email:</label>
                   <input type="text" name="contact_email" id="contact_email" class="field" value="" tabindex="2" /></p>
                <p><label for="contact_url" class="left">Website:</label>
                   <input type="text" name="contact_url" id="contact_url" class="field" value="" tabindex="3" /></p>
              </fieldset>
              <fieldset><legend>&nbsp;MESSAGE DETAILS&nbsp;</legend>
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
      </div>
      