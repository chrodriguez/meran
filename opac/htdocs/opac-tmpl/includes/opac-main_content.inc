<div class="main-content">
   <!-- Pagetitle -->
        <h1 class="pagetitle">
            [% IF content_title %]
                [% content_title %]
            [% ELSE %]
                [% 'Si no hay titulo, que pongo?????' | i18n %]
            [% END %]
        </h1>

        <!-- Content unit - One column -->
        <h1 class="block">1 - Column types</h1>
        <div class="column1-unit">
          <h1>Here comes the title</h1>
          <h3>Monday, 20 November 2006 at 20:30 GMT, by <a href="#">SiteAdmin </a></h3>
          <p>Lorem ipsum dolor sit amet, consectetuer <a href="#">adipiscing elit</a>, sed diam nonummy nibh euismod tincidunt ut laoreet dolore <a href="#">magna aliquam</a> erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis. <a href="#">Read more &raquo;</a></p>
          <p class="details">| Posted by <a href="#">SiteAdmin </a> | Categories: <a href="#">General</a> | Comments: <a href="#">73</a> |</p>
          <h1><a href="">Heading h1 with link</a></h1>
          <h3>Heading h3</h3>
          <p>Lorem ipsum dolor sit amet, consectetuer <a href="#">adipiscing elit</a>, sed diam nonummy nibh euismod tincidunt ut laoreet dolore <a href="#">magna aliquam</a> erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis. <a href="#">Read more &raquo;</a></p>
          <p class="details">Posting details ...  </p>
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->

        [% INCLUDE $partial_template %]
        <hr class="clear-contentunit" />
      </div>