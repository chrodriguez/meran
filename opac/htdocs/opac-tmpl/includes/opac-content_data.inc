[% USE HTML %]
      <!-- Content unit - One column -->
        <h1 class="pagetitle">[% 'Novedades de la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit">
        <div class="column1-unit">

          [% IF !novedades %]
                  <!--<span class="highlighted">[% 'Sin novedades' | i18n %].</span>-->
                  <h1>[% 'Sin novedades' | i18n %]</h1>
          [% END %]
          [% FOREACH novedad IN novedades %]
              <h1><a href='/cgi-bin/koha/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>[% novedad.getTitulo %]</a></h1>
              <h3>[% novedad.getFechaLegible %] </h3>
              <p>
                  [% novedad.getResumen %]
                  <a href='/cgi-bin/koha/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>[% 'Leer m&aacute;s' | i18n %] &raquo;</a>
              </p>
          [% END %]
          
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->
        <br />
        <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit" />
        [% INCLUDE 'opac-busquedaResult.inc' %]
