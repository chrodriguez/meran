[% USE HTML %]

    <script type="text/javascript">

	    $(document).ready(function() {
	            actualizarTabla();
	            setInterval(actualizarTabla,[% IF timeInterval %]
							                [% timeInterval %]
							             [% ELSE %]
							                300000
							             [% END %]
							             );
                $("#ultimos_ejemplares_adq").click(function() {  $(".ultimos_ejemplares_adq").toggle(); 
                                                               });
                $(".ultimos_ejemplares_adq").hide();
	            
        });

    </script>

      <!-- Content unit - One column -->
        <div class="column1-unit novedades_opac">
            <div id="resultNovedades"></div>
        </div>
        [% IF cant_sanciones > 0 %]
              [% INCLUDE 'opac-sanciones.inc' %]
        [% END %]
        [% IF cantidad_prestamos > 0  %]
            <div class="prestamos_opac_main">
                  [% INCLUDE 'opac-prestamos.inc' %]
            </div>
        [% END %]

        [% IF reservas_asignadas_count > 0 %]
             <div class="reservas_asig_opac_main">
                  [% INCLUDE 'opac-reservas_asignadas.inc' %]
            </div>
        [% END %]

        [% IF reservas_espera_count > 0 %]
             <div class="reservas_espera_opac_main">
                  [% INCLUDE 'opac-reservas_espera.inc' %]
            </div>
        [% END %]
        
        <!-- Content unit - Two columns -->
        <br />
        [% IF (!cantidad_prestamos > 0) && (!reservas_asignadas_count  > 0) && (!reservas_espera_count > 0) && (!cant_sanciones > 0) %]
            <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
            <hr class="clear-contentunit" />
              [% INCLUDE 'opac-busquedaResult.inc' %]
        [% ELSE %]
              <h1 id="ultimos_ejemplares_adq" class="pagetitle" style="text-decoration:underline; font-size: 17px; cursor:pointer;"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
              <div class="ultimos_ejemplares_adq">
                    [% INCLUDE 'opac-busquedaResult.inc' %]
              </div>
        [% END %]