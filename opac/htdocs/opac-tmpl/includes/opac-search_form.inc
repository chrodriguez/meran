        <div class="searchform">
          <form action="/cgi-bin/koha/opac-busquedasDB.pl" method="get">
            <fieldset>
              <input name="string" class="field"  value="[% search_string %]" />
              <input type="submit" name="button" class="button" value="[% 'OK' | i18n %]!" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
            </fieldset>
          </form>
        </div>
