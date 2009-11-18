<div class="main-content">
   <!-- Pagetitle -->
        <h1 class="pagetitle">
            [% IF content_title %]
                [% content_title %]
            [% ELSE %]
                [% 'Si no hay titulo, que pongo?????' | i18n %]
            [% END %]
        </h1>

        [% INCLUDE $partial_template %]
        <hr class="clear-contentunit" />
      </div>