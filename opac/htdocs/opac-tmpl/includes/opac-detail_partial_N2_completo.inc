<script type="text/javascript">
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>

[% FOREACH nivel2 %]

	<div class="detalle_completo_niveles">
		<div class="main-subcontent" style="width:100%; float:left">
		    <div class="subcontent-unit-border" style="width:100%;">
		        <div class="round-border-topleft""></div>
			
			    [% IF nivel2_array %]
                    <div class="main-subcontent" style="width:100%; float:left;">
                                <h1>[% "Detalle" | i18n %]</h1>
                                <div class="cover_detalle_container">
					                    [% IF portada_registro %]
					                        <a class="fancylink" href="/uploads/covers/[% portada_registro_big %]">
					                            <img src="/uploads/covers/[% portada_registro_medium %]" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
					                        </a>
					                    [% ELSE %]
					                          <img src="/uploads/covers/[% cat_ref_tipo_nivel3 %].png" alt="[% 'Sin Portada' | i18n %]" title="[% 'Sin Portada' | i18n %]" />
					                    [% END %]
					                    <br />
	   				                    <center><div style="font-weight: bold; font-size: 10px; clear:both;" >[% cat_ref_tipo_nivel3_name %] </div></center>
	                           </div>		
                                <div class="detalle_total">	                           
	                                [% INCLUDE 'opac-detail_partial_N1.inc' %]
			                          <ul class="listado_sin_margen">
			                              [% FOREACH nivel2_array %]
			                                          [% IF liblibrarian %]
			                                              [% IF dato %]
			                                              <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
			                                              [% END %]
			                                          [% END %]
			                              [% END %] <!-- END FOREACH subcampos_array-->
			                              <br />
			                              <li> [% 'Puede solicitar m&aacute;s f&aacute;cilmente el ejemplar con' | i18n %]&nbsp;<b>[% primer_signatura %]</b></li>
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
		
			                      </div> <!-- END <div class="detalle_total">-->
				
					             [% END %]  <!--END  IF nivel2_array -->
						             <div id="[% DivDetalle %]">
										[% IF cant_nivel3 %]
									            <h1 class="orange">[% "Ejemplares" | i18n %]</h1>
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
									            <br />
									            <br />
										[% END %]

                                        [% INCLUDE 'e-docs_grupo.inc' %]
				                        [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
					                </div>
			      </div>
		   </div>
	</div>
  </div>
	<br />
	<hr class="separador-detalle-item" />
	<br />
	<br />

[% END %]  <!--END FOREACH nivel2 -->