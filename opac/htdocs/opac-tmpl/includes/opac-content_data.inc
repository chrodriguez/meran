[% USE HTML %]
    <div class="hero-unit" id="search-bar">
     	<h1 class="medium_font">[% 'Bienvenido ' | i18n %]<small>[% ui.getNombre %]</small></h1>
        <p>
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
		</p>

		<p>
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
		</p>
    </div>

      <!-- Example row of columns -->
      <div class="row">
	        <div class="span4" id="[% IF novedad %]last_new[% END %]">
		        [% IF novedad %]
			          <h2>[% novedad.getTitulo %]</h2>
			           <p>[% novedad.getResumen %]</p>
			          <p>
		                [% PERL %]
		                   print C4::AR::Filtros::action_link_button( 
		                                                     button         => "btn click",
		                                                     url       	=> "[% url_prefix %]/opac-novedades.pl",
		                                                     params		=> ["token=[% token %]"],
		                                                     title        => "[% 'Novedades' | i18n %] &raquo;",
		                                       ) ;
		                [% END %]
		          	  </p>
				[% ELSE %]
			          <h2>[% 'Novedades' | i18n %]</h2>
			           <p>[% 'Todav&iacute;a no se ha publicado ninguna novedad. Siempre consult&aacute; esta secci&oacute;n para enterarte de las cosas que la biblioteca tiene para decirte' | i18n %].</p>
			          <p>
				[% END %]	        
	        </div>
	        <div class="span4">
	          <h2>[% 'Ejemplares destacados' | i18n %]</h2>
	           <p>[% 'Revis&aacute; los ejemplares promovidos por la biblioteca' | i18n %].</p>
	          <p><a class="btn" href="#">[% 'Ver ejemplares' | i18n %] &raquo;</a></p>
	       </div>
	       
	        <div class="span4">
	          <h2>[% 'La biblioteca' | i18n %]</h2>
	          <p>[% ui.getNombre %]</p>
	          <p>[% ui.getTituloFormal %]</p>
	          <p>
                [% PERL %]
                   print C4::AR::Filtros::action_link_button( 
                                                     button         => "btn click",
                                                     url       	=> "[% url_prefix %]/opac-about.pl",
                                                     params		=> ["token=[% token %]"],
                                                     title        => "[% 'Acerca de' | i18n %] &raquo;",
                                       ) ;
                [% END %]
          	  </p>
	        </div>
      </div>

