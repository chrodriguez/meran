        <!-- Navigation Level 0 -->
        <div class="nav0">
          <ul>
            <li><a href="#" title="Pagina home in Italiano"><img src="[% temas %]/default/imagenes/flag_italy.gif" alt="Image description" /></a></li>
            <li><a href="#" title="Homepage auf Deutsch"><img src="[% temas %]/default/imagenes/flag_germany.gif" alt="Image description" /></a></li>
            <li><a href="#" title="Hemsidan p&aring; svenska"><img src="[% temas %]/default/imagenes/flag_sweden.gif" alt="Image description" /></a></li>
          </ul>
        </div>          

        <!-- Navigation Level 1 -->
        <div class="nav1">
          <ul>
            <li><a href="#" title="Go to Start page">Home</a></li>
            <li><a href="#" title="Get to know who we are">About</a></li>
            <li><a href="#" title="Get in touch with us">Contact</a></li>                                                                       
            <li><a href="#" title="Get an overview of website">Sitemap</a></li>
          </ul>
        </div>              
      </div>
      
      <!-- A.2 HEADER MIDDLE -->
      <div class="header-middle">    
   
        <!-- Site message -->
        <div class="sitemessage">
          <h1>[% 'Cat&aacute;logo P&uacute;blico' | i18n %] &bull; [% 'Facultad de Inform&aacute;tica' | i18n %] &bull; UNLP</h1>
          <h2>[% 'Informacion de la UI?????' | i18n %]</h2>
          <h3><a href="#">&rsaquo;&rsaquo;&nbsp;More details</a></h3>
        </div>
      </div>
      <!-- A.3 HEADER BOTTOM -->
      <div class="header-bottom">
        <!-- Navigation Level 2 (Drop-down menus) -->
        <div class="nav2">
          <!-- Navigation item -->
          <ul>
            <li><a href="/cgi-bin/koha/opac-main.pl">[% 'Inicio' | i18n %]</a></li>
          </ul>
          <!-- Navigation item -->
          <ul>
            <li><a href="#">[% 'Accesos' | i18n %]<!--[if IE 7]><!--></a><!--<![endif]-->
              <!--[if lte IE 6]><table><tr><td><![endif]-->
                <ul>
                  <li><a href="#">[% 'B&uacute;squeda Avanzada' | i18n %]</a></li>
                  <li><a href="#">[% 'Accesos' | i18n %]</a></li>
                  <li><a href="#">[% 'Accesos' | i18n %]</a></li>
                  <li><a href="#">[% 'Accesos' | i18n %]</a></li>
                  <li><a href="#">[% 'Accesos' | i18n %]</a></li>                                    
                </ul>
              <!--[if lte IE 6]></td></tr></table></a><![endif]-->
            </li>
          </ul>          

        </div>
      </div>

      <!-- A.4 HEADER BREADCRUMBS -->

      <!-- Breadcrumbs -->
      <div class="header-breadcrumbs">
      [% INCLUDE 'opac-status_links.inc' %]

      [% INCLUDE 'opac-search_form.inc' %]
      </div>
    </div>

    <!-- For alternative headers END PASTE here -->
