[% USE HTML %]
    <style type="text/css" media="screen">
        .del{
		    float:right; font-weight:bold; color:#666666
		}
    </style>
    <script type="text/javascript" language="javascript">
        $(".delete").click(function(){
        
            var element     = $(this)
            var I           = element.attr("id")
            var id_novedad  = $('#del_novedad_'+I)
            
            function eliminarPublicacion(id_novedad){
                objAH                   = new AjaxHelper(updateEliminarPublicacion)
                objAH.showOverlay       = true
		        objAH.debug             = true
		        objAH.url               = 'opac-novedadesDB.pl'
		        objAH.id_novedad        = array
		        objAH.Accion            = 'DELETE_NOVEDAD'
		        objAH.sendToServer()
	        }
	
	        function updateEliminarPublicacion(responseText){
	            
	        }
        })
    </script>
    
      <!-- Content unit - One column -->
        <h1 class="pagetitle">[% 'Novedades de la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit">
        <div class="column1-unit novedades_opac">

          [% IF !novedades %]
                  <!--<span class="highlighted">[% 'Sin novedades' | i18n %].</span>-->
                  <h1>[% 'Sin novedades' | i18n %]</h1>
          [% END %]
          [% FOREACH novedad IN novedades %]
              <div class="novedad_opac" id="novedad_opac_[% novedad.getId %]">
                  <span class="del"><a href="#" class="delete" title="No mostrar esta novedad de nuevo" id="del_novedad_[% novedad.getId %]">X</a></span>
	              <h1>
	                <a href='[% url_prefix %]/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>[% novedad.getTitulo %]</a>
	              </h1>
	              <h3>
	                [% novedad.getFechaLegible %]
	              </h3>
	              <p>
	                  [% novedad.getResumen %]
	                  <a href='[% url_prefix %]/ver_novedad.pl?id=[% novedad.getId %]&amp;token=[% token %]'>
	                    [% 'Leer m&aacute;s' | i18n %] &raquo;
	                  </a>
	              </p>
              </div>
          [% END %]
          
        </div>
        <hr class="clear-contentunit" />
        <!-- Content unit - Two columns -->
        <br />
        <h1 class="pagetitle"> [% 'Ultimos ejemplares adquiridos por la biblioteca' | i18n %]</h1>
        <hr class="clear-contentunit" />
        [% INCLUDE 'opac-busquedaResult.inc' %]
