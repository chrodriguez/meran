      
[% USE HTML %]
  
      <!-- Navigation Level 0 -->
        <div class="nav0">
          [% localization_FLAGS %]
        </div>
        <!-- Navigation Level 1 -->
        <div class="nav1">
          <ul>
            <li>
                <a href="[% url_prefix %]/opac-main.pl?token=[% token %]" title="[% 'Ir a la p&aacute;gina de inicio' | i18n %]">[% 'Inicio' | i18n %]</a>
            </li>
            <li>
                <a href="[% url_prefix %]/opac-about.pl?token=[% token %]" title="[% 'Sepa qui&eacute;nes somos' | i18n %]">[% 'Acerca de' | i18n %]</a>
            </li>
            <li>
                <a href="[% url_prefix %]/opac-contact.pl?token=[% token %]" title="[% 'P&oacute;ngase en contacto con nosotros' | i18n %]">[% 'Contacto' | i18n %]</a>
            </li>
          </ul>
        </div>
      <!-- Navigation Level 1.1 -->
        <div class="nav_logged">
            <ul>

              [% IF socio_data.usr_nro_socio %]
                  <li>    
                    [% HTML.escape(socio_data.usr_nombre) %] ([% HTML.escape(socio_data.usr_nro_socio) %])
                  </li>
                  <li>  
                    [% PERL %]
                            print C4::AR::Filtros::link_to( text    =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]",
                                                            url     =>  "[% url_prefix %]/logout.pl",
                                                            title   =>  "[% 'Cerrar Sesi&oacute;n' | i18n %]"
                                    ) ;
                    [% END %]
                  </li>
              [% END %]

            </ul>
        </div>
      </div>
      <!-- A.2 HEADER MIDDLE -->
      <div class="header-middle">    
        <!-- Site message -->
        <div class="sitemessage">
          <h1>&bull; [% ui.getNombre %]</h1>
          <h2>[% ui.getDireccion %]</h2>
          <h3><a href="[% url_prefix %]/opac-ui_info.pl?token=[% token %]">&rsaquo;&rsaquo;&nbsp;[% 'M&aacute;s Informaci&oacute;n De La Unidad' | i18n %]</a></h3>
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
                                                      url     =>  "[% url_prefix %]/opac-main.pl",
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
                                                          url     =>  '[% url_prefix %]/opac-advanced_search.pl',
                                                          title   =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
                                  ) ;
                      [% END %]
                  </li>
                  [% IF !socio_data %]
                      <li><a href='[% url_prefix %]/login.pl'>[% 'Iniciar Sesi&oacute;n' | i18n %]</a></li>
                  [% ELSE %]
                      <li>
                          <a href='[% url_prefix %]/opac-prestamos_vigentes.pl?token=[% token %]'>
                              [% 'Pr&eacute;stamos vigentes' | i18n %]
                          </a>
                      </li>
                      <li>
                          <a href='[% url_prefix %]/opac-historial_prestamos.pl?token=[% token %]'>
                              [% 'Historial de pr&eacute;stamos' | i18n %]
                          </a>
                      </li>
                      <li>
                          <a href='[% url_prefix %]/opac-historial_reservas.pl?token=[% token %]'>
                              [% 'Historial de reservas' | i18n %]
                          </a>
                      </li>
                      <li>
                          [% PERL %]
                              print C4::AR::Filtros::link_to( text    =>  "[% 'Recomendaciones' | i18n %]",
                                                              url     =>  '[% url_prefix %]/opac-recomendaciones.pl',
                                                              title   =>  "[% 'Recomendaciones' | i18n %]",
                                      ) ;
                          [% END %]
                      </li>
                      <li>
                          <a href='[% url_prefix %]/opac-favoritos.pl?token=[% token %]'>
                              [% 'Mis favoritos' | i18n %]
                          </a>
                      </li>
                  [% END %]
                </ul>
              <!--[if lte IE 6]></td></tr></table></a><![endif]-->
            </li>
          </ul>          

        </div>

      <!-- A.4 HEADER BREADCRUMBS -->

      <!-- Breadcrumbs -->

        <div class="header-breadcrumbs">
          [% INCLUDE 'opac-search_form.inc' %]
        </div>

      </div>

    </div>
    <div id="mensajes"></div>

    <!-- For alternative headers END PASTE here -->
