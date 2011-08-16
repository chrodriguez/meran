
      <!-- Content unit - One column -->
        <h1 class="block">[% ui.getNombre %]</h1>
        <div class="column1-unit">
          <h1>[% 'Informaci&oacute;n de Contacto' | i18n %]</h1>
          <br />
          <h3>[% 'E-mail' | i18n %]: <a href="mailto:[% ui.getEmail%]">[% ui.getEmail%]</a></h3>
          <br />
          <h3>[% 'Direcci&oacute;n' | i18n %]: [% ui.getDireccion %]</h3>
          <br />
          <h3>[% 'Tel&eacute;fono' | i18n %]: [% ui.getTelefono %]</h3>
          <p>Puede comunicarse de 8:00 a 19:00 hs.</p>
        </div>
	[% twitter_follow_button %]
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->
        [% google_map %]
