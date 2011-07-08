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
	            
        });

    </script>


    
      <!-- Content unit - One column -->
        <hr class="clear-contentunit">
        <div class="column1-unit novedades_opac">
            <div id="resultNovedades"></div>
        </div>
   
        <div>
               [% INCLUDE 'opac-prestamos.inc' %]
        </div>
   
        <!-- Content unit - Two columns -->
        <br />
        <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit" />
        [% INCLUDE 'opac-busquedaResult.inc' %]
