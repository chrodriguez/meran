[% USE HTML %]

    <script type="text/javascript" language="javascript">
            
        function eliminarPublicacion(id_novedad){
        
            jConfirm(SEGURO_OCULTAR_NOVEDAD,OPAC_ALERT_TITLE, function(confirmStatus){
                if (confirmStatus){
                    objAH                   = new AjaxHelper(updateEliminarPublicacion);
                    objAH.showOverlay       = false;
	                objAH.debug             = true;
	                objAH.url               = URL_PREFIX+'/opac-novedadesDB.pl';
	                objAH.id_novedad        = id_novedad;
	                objAH.tipoAccion        = 'DELETE_NOVEDAD';
	                objAH.sendToServer();
                } 
            
            })
        }

        function updateEliminarPublicacion(responseText){
            actualizarTabla();
        }
        

        function actualizarTabla(){
            $("#resultNovedades").append("<img src="+imagesForJS+"/loaders/facebook_style_green.gif alt=[% 'Cargando..' | i18n %] style='border:0;' />");
            objAH               = new AjaxHelper(updateActualizarTabla);
	        objAH.debug         = true;
	        objAH.url           = URL_PREFIX+'/opac-novedadesDB.pl';
            objAH.showOverlay   = false;
	        objAH.tipoAccion    = "ACTUALIZAR_TABLA_NOVEDADES";
	        objAH.sendToServer();
        }

        function updateActualizarTabla(responseText){
            $("#resultNovedades").html(responseText);
        }

    </script>
    <script type="text/javascript" language="javascript">

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
        <hr class="clear-contentunit">
        <div class="column1-unit novedades_opac">
            <div id="resultNovedades"></div>
        </div>
        [% IF cant_sanciones > 0 %]
            <div class="sanciones_opac_main">
                  [% INCLUDE 'opac-sanciones.inc' %]
            </div>
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
              <h1 id="ultimos_ejemplares_adq" class="pagetitle" style="text-decoration:underline; font-size: 17px;"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
              <div class="ultimos_ejemplares_adq">
                    [% INCLUDE 'opac-busquedaResult.inc' %]
              </div>
        [% END %]