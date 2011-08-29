    <!-- A. HEADER -->
    <div class="header">
      <!-- A.1 HEADER TOP -->
      <div class="header-top">
        <!-- Sitelogo and sitename -->
        <a class="sitelogo" href="[% url_prefix %]/opac-main.pl?token=[% token %]" title="[% 'Ir al inicio' | i18n %]"></a>
        <div class="sitename">
          <h1><a href="[% url_prefix %]/opac-ui_info.pl?token=[% token %]" title="[% 'Informaci&oacute;n de la Biblioteca' | i18n %]">[% 'MERAN' | i18n %] &bull; 
          <span style="font-weight:normal;font-size:50%; white-space: nowrap;">&nbsp;[% ui.getNombre %]</span></a></h1>
          <h2>[% 'Cat&aacute;logo P&uacute;blico' | i18n %]</h2>
        </div>
        [% INCLUDE 'opac-header-nav.inc' %]
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