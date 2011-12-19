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
									<div class="rating">  
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
									   
									  	 [% IF isbn %]
											<div class="google-books">
												<a id="ISBN:[% isbn %]"  style="display:none" target="_blank">
													<img src="/includes/css/gbs_preview_button1.gif" border="0" style="margin: 0"/>
												</a>
											</div>
											<script src="http://books.google.com/books?jscmd=viewapi&bibkeys=ISBN:[% isbn %]&callback=ProcessGBSBookInfo"></script>
										 [% END %]
									</div>
                                  </div> <!-- END <div class="detalle_total">-->
                
                                 [% END %]  <!--END  IF nivel2_array -->
                                     <div id="[% DivDetalle %]">

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
