[% USE HTML %]
    <style type="text/css" media="screen">
        .del{
		    float:right; font-weight:bold; color:#666666
		}
    </style>
    <script type="text/javascript" language="javascript">
            
        function eliminarPublicacion(id_novedad){
            objAH                   = new AjaxHelper(updateEliminarPublicacion)
            objAH.showOverlay       = true
	        objAH.debug             = true
	        objAH.url               = 'opac-novedadesDB.pl'
	        objAH.id_novedad        = id_novedad
	        objAH.tipoAccion        = 'DELETE_NOVEDAD'
	        objAH.sendToServer()
        }

        function updateEliminarPublicacion(responseText){
            actualizarTabla()
        }
        
        $(document).ready(function() {
            actualizarTabla()
        });

        function actualizarTabla(){
            objAH               = new AjaxHelper(updateActualizarTabla)
	        objAH.debug         = true
	        objAH.url           = 'opac-novedadesDB.pl'
            objAH.showOverlay   = true
	        objAH.tipoAccion        = "ACTUALIZAR_TABLA_NOVEDADES"
	        objAH.sendToServer()
        }

        function updateActualizarTabla(responseText){
            $("#resultNovedades").html(responseText)
        }

    </script>
    
      <!-- Content unit - One column -->
        <h1 class="pagetitle">[% 'Novedades de la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit">
        <div class="column1-unit novedades_opac">
            <div id="resultNovedades"></div>
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->
        <br />
        <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit" />
        [% INCLUDE 'opac-busquedaResult.inc' %]
