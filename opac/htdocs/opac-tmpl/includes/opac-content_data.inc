        <!-- Content unit - One column -->
        <h1 class="block">[% 'Novedades de la biblioteca' | i18n %]</h1>
        <div class="column1-unit">

          [% IF !novedades %]
                  <a href="#">[% 'Sin novedades' | i18n %].</a>
          [% END %]
          [% FOREACH novedad IN novedades %]
              <h1><a href='/cgi-bin/koha/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>[% novedad.getTitulo %]</a></h1>
              <h3>[% novedad.getFechaLegible %], [% 'por ' | i18n %] <a href="#">[% novedad.getUsuario %]</a></h3>
              <p>
                  [% novedad.getResumen %]
                  <a href='/cgi-bin/koha/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>[% 'Leer m&aacute;s' | i18n %] &raquo;</a>
              </p>
              <p class="details">| 
                  [% 'Acutalizado por' | i18n %] <a href="#"> [% novedad.getUsuario %] </a> | [% 'Categor&iacute;a' | i18n %]: 
                  <a href="#">[% novedad.getCategoria %]</a> |
              </p>
          [% END %]
          
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->

        <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %] 
            <hr class="clear-contentunit" />
        </h1>
        [% INCLUDE 'opac-busquedaResult.inc' %]
