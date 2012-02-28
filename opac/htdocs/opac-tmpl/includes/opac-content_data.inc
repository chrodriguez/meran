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
	        <div class="page-header">
			    <h1>[% ui.getNombre %] <small>[% 'Ultimos ejemplares adquiridos' | i18n %]</small></h1>
			</div> 
              [% INCLUDE 'opac-busquedaResult.inc' %]
        [% ELSE %]
		        <div class="page-header">
				    <h1>[% ui.getNombre %] <small>[% 'Ultimos ejemplares adquiridos' | i18n %]</small></h1>
				</div> 
                [% INCLUDE 'opac-busquedaResult.inc' %]
        [% END %]