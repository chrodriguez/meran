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
            <li>
                <a href="/cgi-bin/koha/opac-main.pl?token=[% token %]" title="[% 'Ir a la p&aacute;gina de inicio' | i18n %]">[% 'Inicio' | i18n %]</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/opac-about.pl?token=[% token %]" title="[% 'Sepa qui&eacute;nes somos' | i18n %]">[% 'Acerca de' | i18n %]</a>
            </li>
            <li>
                <a href="/cgi-bin/koha/opac-contact.pl?token=[% token %]" title="[% 'P&oacute;ngase en contacto con nosotros' | i18n %]">[% 'Contacto' | i18n %]</a>
            </li>
          </ul>
        </div>
      </div>
      <!-- A.2 HEADER MIDDLE -->
      <div class="header-middle">    
        <!-- Site message -->
        <div class="sitemessage">
          <h1>&bull; [% ui.getNombre %]</h1>
          <h2>[% ui.getDireccion %]</h2>
          <h3><a href="/cgi-bin/koha/opac-ui_info.pl?token=[% token %]">&rsaquo;&rsaquo;&nbsp;[% 'M&aacute;s Informaci&oacute;n De La Unidad' | i18n %]</a></h3>
        </div>
      </div>
      <!-- A.3 HEADER BOTTOM -->
      <div class="header-bottom">
        <!-- Navigation Level 2 (Drop-down menus) -->
        <div class="nav2">
          <!-- Navigation item -->
          <ul>
              <li>
                  [% PERL %]
                      print C4::AR::Filtros::link_to( text    =>  "[% 'Inicio' | i18n %]",
                                                      url     =>  "/cgi-bin/koha/opac-main.pl",
                                                      title   =>  "[% 'Inicio' | i18n %]",
                              ) ;
                  [% END %]
              </li>
          </ul>
          <!-- Navigation item -->
          <ul>
            <li><a href="#">[% 'Accesos' | i18n %]<!--[if IE 7]><!--></a><!--<![endif]-->
              <!--[if lte IE 6]><table><tr><td><![endif]-->
                <ul>
                  <li>
                      [% PERL %]
                          print C4::AR::Filtros::link_to( text    =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
                                                          url     =>  "/cgi-bin/koha/opac-advanced_search.pl",
                                                          title   =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
                                  ) ;
                      [% END %]
                  </li>
                  [% IF !socio %]
                      <li><a href="/cgi-bin/koha/login.pl">[% 'Iniciar Sesi&oacute;n' | i18n %]</a></li>
                  [% ELSE %]
                      <li>
                          <a href="/cgi-bin/koha/opac-historial_prestamos.pl?token=[% token %]">
                              [% 'Historial de pr&eacute;stamos' | i18n %]
                          </a>
                      </li>
                      <li>
                          <a href="/cgi-bin/koha/opac-historial_reservas.pl?token=[% token %]">
                              [% 'Historial de reservas' | i18n %]
                          </a>
                      </li>
                  [% END %]
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
          <div id="mensajes"></div>
          [% INCLUDE 'opac-search_form.inc' %]
      </div>
    </div>

    <!-- For alternative headers END PASTE here -->
