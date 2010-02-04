<div class="main-content">
   <!-- Pagetitle -->
            [% IF content_title %]
                <h1 class="pagetitle">
                    [% content_title %]
                    <hr class="clear-contentunit" />
                </h1>
            [% END %]
        [% IF partial_template %]
          [% INCLUDE $partial_template %]
        [% END %]
</div>