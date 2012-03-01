<script type="text/javascript">
    $(document).ready(function() {
       // $('.fancylink').fancybox();
    });
</script>

[% FOREACH nivel2 %]
                [% IF nivel2_array %]
                    <fieldset>
						<div class="page-header">
						    <h1>[% 'Detalle del registro' | i18n %] <small>[% nivel1_obj.getTitulo %]</small></h1>
						</div>                          
						<div class="well">
                                <div class="cover_detalle_container">
                                        [% IF portada_registro %]
                                            <a class="fancylink" href="/uploads/covers/[% portada_registro_big %]">
                                                <img src="/uploads/covers/[% portada_registro_medium %]" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
                                            </a>
                                        [% ELSE %]
                                              <img src="/uploads/covers/[% cat_ref_tipo_nivel3 %].png" alt="[% 'Sin Portada' | i18n %]" title="[% 'Sin Portada' | i18n %]" />
                                        [% END %]
                                        <br />
                                        <div style="font-weight: bold; font-size: 10px; clear:both;" >[% cat_ref_tipo_nivel3_name %] </div>
                               </div>       
                       

                               <div class="detalle_total">                            
                                    [% INCLUDE 'opac-detail_partial_N1.inc' %]
                                      <dl class="listado_sin_margen">
                                          [% FOREACH nivel2_array %]
                                                      [% IF liblibrarian %]
                                                          [% IF dato %]
                                                          <dt class="inline left rightMargin">[% liblibrarian %]:</dt><dd>[% dato %]</dd>
                                                          [% END %]
                                                      [% END %]
                                          [% END %]
                                      </dl>
                  

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
											<div style="display:none">
                                                  <div id="indice_data[% id2 %]"  title="[% 'Indice del grupo' | i18n %]">
                                                      <ul>
                                                      [% FOREACH elem IN indice %]
                                                          [% FOREACH word IN elem.split(' ') %]
                                                              <li class="li_items_indice">[% word %]</li>
                                                          [% END %]
                                                      [% END %]
                                                      </ul>
                                                  </div>
                                          </div>
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
                                  </div>
                            </div>

                		[% END %]  <!--END  IF nivel2_array -->

	              	[% INCLUDE 'e-docs_grupo.inc' %]
	                                        
	     			[% IF disponible %]
	                   [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
	            	[% END %]
	  			</fieldset> 


<div id="modal_reservar" class="modal hide fade">
              <div class="modal-header">
                <a href="#" class="close" data-dismiss="modal">×</a>
                <h3>[% 'Reserva de ejemplar' | i18n %]</h3>
              </div>
              <div class="modal-body">
                <p>One fine body…</p>
              </div>
              <div class="modal-footer">
                <a href="#" class="btn btn-primary" onclick="reservar([% id1 %],[% id2 %]);">[% 'Reservar' | i18n %]</a>
              </div>
</div>
[% END %]  <!--END FOREACH nivel2 -->
