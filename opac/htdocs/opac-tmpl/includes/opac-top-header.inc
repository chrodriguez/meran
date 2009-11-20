    <!-- A. HEADER -->
    <div class="header">
      <!-- A.1 HEADER TOP -->
      <div class="header-top">
        <!-- Sitelogo and sitename -->
        <a class="sitelogo" href="#" title="Go to Start page"></a>
        <div class="sitename">
          <h1><a href="index.html" title="Go to Start page">[% 'MERAN' | i18n %] &bull; 
          <span style="font-weight:normal;font-size:50%;">&nbsp;[% ui.getNombre %]</span></a></h1>
          <h2>[% 'Cat&aacute;logo P&uacute;blico' | i18n %]</h2>
        </div>
    [% INCLUDE 'opac-header-nav.inc' %]
    <!-- B. MAIN -->
    <div class="main">
      <div class="main-navigation">
          [% INCLUDE 'opac-navlink.inc' %]
          [% INCLUDE 'opac-login.inc' %]
          <h1>[% 'Buscar' | i18n %]:</h1>
            [% INCLUDE 'opac-search_form.inc' %]
    <!--         <h1>&nbsp;</h1> -->
          </div>
          <!-- B.1 MAIN CONTENT -->