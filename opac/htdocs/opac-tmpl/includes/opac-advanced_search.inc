        <!--<h1 class="block">[% 'B&uacute;squeda Avanzada' | i18n %]</h1>-->
        <div class="column1-unit">
            <div class="contactform">
                <form action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
                    <fieldset>
                        <legend>&nbsp;[% 'Complete lo necesario' | i18n %]&nbsp;</legend>
                        <p>
                            <label for="contact_firstname" class="left">[% 'T&iacute;tulo' | i18n %]:</label>
                            <input type="text" name="titulo" id="titulo" class="field" tabindex="1" />
                        </p>

                        <p>
                            <label for="contact_firstname" class="left">[% 'Autor' | i18n %]:</label>
                            <input type="text" name="autor" id="autor" class="field" tabindex="1" />
                        </p>

                        <p>
                            <label for="contact_firstname" class="left">[% 'ISBN' | i18n %]:</label>
                            <input type="text" name="isbn" id="isbn" class="field" tabindex="1" />
                        </p>

                        <p>
                            <label for="contact_title" class="left">[% 'Tipo de documento' | i18n %]:</label>
                            [% combo_tipo_documento %]
                        </p>

                        <p>
                            <label for="contact_firstname" class="left">[% 'Tema' | i18n %]:</label>
                            <input type="text" name="tema" id="tema" class="field" tabindex="1" />
                        </p>

                        <p>
                            <label for="contact_firstname" class="left">[% 'Estantes Virtuales' | i18n %]:</label>
                            <input type="text" name="estantes" id="estantes" class="field" tabindex="1" />
                        </p>

                        <p>
                            <label for="only_available" class="left">[% 'S&oacute;lo Disponibles para Pr&eacute;stamo' | i18n %]:</label>
                            <input type="checkbox" name="only_available" id="only_available" class="field" tabindex="1" />
                        </p>
                        <p>
                          <input type="submit" name="submit" id="submit" class="button" value="[% 'Buscar' | i18n %]" tabindex="6" />
                        </p>
                    </fieldset>
                    <input type="hidden" name="tipoAccion" value="BUSQUEDA_AVANZADA" />
                    <input type="hidden" name="tipo" value="normal" />
                    <input type="hidden" name="token" value="[% token %]" />
                </form>
            </div>
        </div>