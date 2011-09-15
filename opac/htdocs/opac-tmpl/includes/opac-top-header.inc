    <!-- A. HEADER -->
    <div class="header">
      <!-- A.1 HEADER TOP -->
      <div class="header-top">
        <!-- Sitelogo and sitename -->
        <a class="sitelogo" href="[% url_prefix %]/opac-ui_info.pl?token=[% token %]" title="[% 'Ir al inicio' | i18n %]"></a>
        [% INCLUDE 'opac-header-nav.inc' %]
        <div id="mensajes"></div>
        <!-- B. MAIN -->
        <div class="main">
          <div class="main-navigation">
              [% IF socio_data.usr_nro_socio %]
                  [% INCLUDE 'opac-login.inc' %]
              [% END %]
<!--              <h1>[% 'Buscar' | i18n %]:</h1>
                [% INCLUDE 'opac-search_form.inc' %]-->
        <!--         <h1>&nbsp;</h1> -->
          </div>
              <!-- B.1 MAIN CONTENT -->