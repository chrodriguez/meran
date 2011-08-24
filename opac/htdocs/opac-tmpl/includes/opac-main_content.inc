<div class="main-content" id="main_content">
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
<div id="ajax-indicator"><br /></div></div>

      