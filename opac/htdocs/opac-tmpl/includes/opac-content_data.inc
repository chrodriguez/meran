[% USE HTML %]

    <script type="text/javascript">

	    $(document).ready(function() {
        });

    </script>

    <div class="hero-unit" id="search-bar">
	[% IF !socio_data.usr_nro_socio %]
     	<h1>[% 'Bienvenido ' | i18n %]<small>[% ui.getNombre %]</small></h1>
        <br />

        <form class="" action="[% url_prefix %]/opac-busquedasDB.pl" method="get" onsubmit="startOverlay();">
            <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
            <input type="hidden" name="token" value="[% token %]" />
	        <p>
	        	<input type="text" name="string" class="input-medium search-query span90 bigInput"
                 		  x-webkit-speech onwebkitspeechchange="javascript:startSearch();" 
                   		  speech onspeechchange="javascript:startSearch();"
                   		  placeholder="[% 'Qu&eacute; necesit&aacute;s' | i18n %]?"
	        	>
	        </p>
	        
	        <p><button class="btn btn-primary btn-large" type="submit">[% 'Buscar' | i18n %]</button></p>
	    </form>
	[% ELSE %]
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
	[% END %]	
    </div>

      <!-- Example row of columns -->
      <div class="row">
	      
	        <div class="span4" id="last_new">
	          <h2>[% novedad.getTitulo %]</h2>
	           <p>[% novedad.getResumen %]</p>
	          <p><a class="btn" href="#">[% 'Novedades' | i18n %] &raquo;</a></p>
	        </div>
	        
	        <div class="span4">
	          <h2>Heading</h2>
	           <p>Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. </p>
	          <p><a class="btn" href="#">View details &raquo;</a></p>
	       </div>
	       
	        <div class="span4">
	          <h2>[% 'La biblioteca' | i18n %]</h2>
	          <p>info de la UI</p>
	          <p><a class="btn" href="#">[% 'Ver m&aacute;s' | i18n %]</a></p>
	        </div>
      </div>

