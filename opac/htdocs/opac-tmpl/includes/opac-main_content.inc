<div class="main-content">
   <!-- Pagetitle -->
        [% IF content_title %]
            <h1 class="pagetitle">
                [% content_title %]
            </h1>
            <hr class="clear-contentunit" />
        [% END %]
        [% IF partial_template %]
          [% INCLUDE $partial_template %]
        [% END %]
</div>