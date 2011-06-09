        <div class="searchform">
          <form action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
            <fieldset>
              <input type="text" name="string" class="field"  value="[% search_string %]" tabindex="-1"/>
              <input type="submit" name="button" class="button" value="[% 'OK' | i18n %]!" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
            </fieldset>
          </form>
        </div>
