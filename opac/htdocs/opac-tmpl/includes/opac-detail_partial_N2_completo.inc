<script type="text/javascript">
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>

[% FOREACH nivel2 %]
    [% IF nivel2_array %]
        <div class="main-subcontent" style="width:100%; float:left">
            <div class="subcontent-unit-border-green" style="width:100%;">
                <div class="round-border-topleft" style="width:90%;"></div>
		        <h1 class="green">[% "Detalle del Grupo" | i18n %]</h1>
                <div class="main-subcontent" style="width:15%; float:left; margin: 1%">
                    [% IF portada_registro %]
                        <a class="fancylink" href="/uploads/covers/[% portada_registro_big %]">
                            <img src="/uploads/covers/[% portada_registro_medium %]" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
                        </a>
                    [% ELSE %]
                          <img src="/uploads/covers/no_image_medium.jpg" alt="[% 'Sin Portada' | i18n %]" title="[% 'Sin Portada' | i18n %]" />
                    [% END %]
                </div>

                <div class="main-subcontent" style="width:80%; float:left; margin: 1%">
                          <ul class="listado_sin_margen">
                              [% FOREACH nivel2_array %]
                                          [% IF liblibrarian %]
                                              [% IF dato %]
                                              <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
                                              [% END %]
                                          [% END %]
                              [% END %] <!-- END FOREACH subcampos_array-->
                          </ul>

                                [% IF tiene_indice %]
                                    [% PERL %]
                                                        print C4::AR::Filtros::to_Icon(  
                                                                                            boton   => "icon_indice",
                                                                                            onClick => "mostrarIndice([% id2 %]);",
                                                                                            title   => "[% 'Ver &iacute;ndice' | i18n %]",
                                                                ) ;
                                    [% END %]
                                [% END %]
                            [% IF indice %]
                                <div style="display:none"><div id="indice_data[% id2 %]" style="white-space: pre;" title="[% 'Indice del grupo' | i18n %]">[% indice %]</div></div>
                            [% END %]

	                        [% IF esta_en_estante_virtual %]
				  <a href="[% url_prefix %]/opac-busquedasDB.pl?tipoAccion=BUSQUEDA_AVANZADA&estantes_grupo=[% id2 %]" class="contenedor_boton">
	                            [% PERL %]
					 print  C4::AR::Filtros::to_Icon(  
	                                                       boton   => "icon_estvirtuales",
	                                                       title   => "[% 'Ver estantes virtuales en los que se encuentra' | i18n %]",
	                                 );
	                            [% END %]
				  </a>
	                        [% END %]

                  </div> <!-- END <div class="main-subcontent">-->

          </div> <!-- END <div class="subcontent-unit-border-green">-->

        </div> <!-- END <div class="main-subcontent">-->

    [% END %]  <!--END  IF nivel2_array -->

    <div id="[% DivDetalle %]">
        <div class="main-subcontent" style="width:100%; float:left">
        <div class="subcontent-unit-border-orange" style="width:100%;">
            <div class="round-border-topleft" style="width:90%;"></div>
            <h1 class="orange">[% "Detalle del Ejemplar" | i18n %]</h1>

                <div class="main-subcontent" style="width:100%; float:left; margin: 1%">
                          <ul class="listado_sin_margen">
                          [% FOREACH nivel3 %]
                              [% FOREACH nivel3_array %]
                                  [% FOREACH subcampos_array %]
                                          [% IF liblibrarian %]
                                              [% IF dato %]
                                              <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
                                              [% END %]
                                          [% END %]
                                  [% END %] <!-- END FOREACH subcampos_array-->
                              [% END %] <!-- END FOREACH nivel3_array -->
                          [% END %] <!-- END FOREACH nivel3 -->  
                          </ul>
                  </div> <!-- END <div class="main-subcontent">-->

            <table id="tablaDetalleNivel" class="tablaDetalleNivel3" cellspacing=0 border="0" cellpadding=0 style="width:95%;margin: 0 auto">
                <thead>
                <tr class="bordetabla" align="center">
                    <td>[% "C&oacute;digo" | i18n %]</td>
                    <td>[% "Signatura Topogr&aacute;fica" | i18n %]</td>
                    <td>[% "Biblioteca que lo posee" | i18n %]</td>
                    <td>[% "Biblioteca de origen" | i18n %]</td>
                    <td>[% "Estado" | i18n %]</td>
                    <td>[% "Disponibilidad" | i18n %]</td>
                    <td>[% "MARC" | i18n %]</td>
                </tr>
                </thead>
                <tbody>
                    [% FOREACH nivel3 %]
                        <tr align="center">
                            <td>[% nivel3_obj.getBarcode %]</td>
                            <td>[% nivel3_obj.getSignatura_topografica %]</td>
                            <td>[% nivel3_obj.getUiPoseedoraName %]</td>   
                            <td>[% nivel3_obj.getUiOrigenName %]</td>  
                            <td>[% nivel3_obj.getEstado %]</td>
                            <td>[% nivel3_obj.getDisponibilidadObject.getNombre %]</td>
                            <td>
                          [% PERL %]
                                  print C4::AR::Filtros::to_Icon( 
                                                                  boton         => "icon_marc",
                                                                  onClick       => "MARCDetail('[% id3 %]', '[% DivDetalle %]', '[% DivMARC %]');", 
                                                                  title         => "[% 'Detalle MARC' | i18n %]",
                                                                  alternClass   => "botonCentradoTabla",
                                                              ) ;
                          [% END %]
                            </td>
                        </tr>
                    [% END %]
                </tbody>
            </table>
            <!-- FIXME falta revisar!!!!!!!!!!! -->
            <br />
            <hr />
            <br />
          [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
          </div>
      </div>
  </div>
[% END %]  <!--END FOREACH nivel2 -->