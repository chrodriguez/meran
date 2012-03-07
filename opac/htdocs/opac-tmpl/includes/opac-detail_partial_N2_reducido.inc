<script type="text/javascript">
    $(document).ready(function() {
    	$('.fancylink').fancybox();
    });
</script>

[% FOREACH nivel2 %]
                [% IF nivel2_array %]
                	<section class="detalle_grupo" id="detalle_grupo_[% id2 %]">
							<div class="page-header">
							    <h1>[% nivel1_obj.getTitulo %] <small> [% edicion %]</small></h1>
							</div>                          
							<div class="well">
									  	 [% IF isbn %]
											<div class="right">
												<a id="ISBN:[% isbn %]"  style="display:none" target="_blank">
													<img src="/includes/css/gbs_preview_button1.gif" border="0" style="margin: 0"/>
												</a>
											</div>
											<script src="http://books.google.com/books?jscmd=viewapi&bibkeys=ISBN:[% isbn %]&callback=ProcessGBSBookInfo"></script>
										 [% END %]
	
	                               <div class="detalle_total">                            
			                                <div class="">
		                                        [% IF portada_registro %]
		                                            <a class="fancylink" href="/uploads/covers/[% portada_registro_big %]">
		                                                <img src="/uploads/covers/[% portada_registro_medium %]" class="book_cover" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
		                                            </a>
		                                        [% END %]
			                                </div>       
	                                        <input class="btn btn-info" disabled value="[% cat_ref_tipo_nivel3_name %]" />
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
	                  
	
											[% IF tiene_indice %]
												[% PERL %]
														print C4::AR::Filtros::action_button(  
																							button   => "btn btn-success",
																							action => "mostrarIndice([% id2 %]);",
																							icon	=> "icon-white icon-book",
																							title   => "[% 'Ver &iacute;ndice' | i18n %]",
																) ;
												[% END %]
											[% END %]
			
											[% IF indice %]
												<div id="indice_data[% id2 %]"  class="modal hide fade">
	                                                  <div class="modal-header">
														<a href="#" class="close" data-dismiss="modal">×</a>
	                                                  	<h3>[% 'Indice del grupo' | i18n %]</h3>
	                                                  </div>
	                                                  <div class="modal-body">
	                                                      <ul>
	                                                      [% FOREACH elem IN indice %]
	                                                          [% FOREACH word IN elem.split(' ') %]
	                                                              <li>[% word %]</li>
	                                                          [% END %]
	                                                      [% END %]
	                                                      </ul>
	                                                  </div>
	                                                  <div class="modal-footer"></div>
	                                          </div>
											[% END %]
											 
											[% IF esta_en_estante_virtual %]
												  <a href="[% url_prefix %]/opac-busquedasDB.pl?tipoAccion=BUSQUEDA_AVANZADA&estantes_grupo=[% id2 %]" class="contenedor_boton">
													  [% PERL %]
														 print  C4::AR::Filtros::action_button(  
																							   button   => "btn btn-inverse",
																							   title   => "[% 'Ver estantes' | i18n %]",
																		 );
													  [% END %]
												  </a>
												  <br />
										   [% END %]
										   
	                                  </div>
	                            </div>
	                            
								<div id="modal_reservar" class="modal hide fade">
							              <div class="modal-header">
							                <a href="#" class="close" data-dismiss="modal">×</a>
							                <h3>[% 'Reserva de ejemplar' | i18n %]</h3>
							              </div>
							              <div class="modal-body">
								             [% IF portada_registro %]
								             	<div class="mid-center" >
							                     	<img src="/uploads/covers/[% portada_registro_medium %]" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
								                </div>
								             [% END %]
							                
							                <p>
							                   [% 'Est&aacute; a punto de reservar un ejemplar de' | i18n %] 
							                   <h4>[% nivel1_obj.getTitulo %]</h4> [% IF edicion %]<span class="label label-info">[% edicion %]</span>[% END %]
							                </p>
							              </div>
							              <div class="modal-footer">
							                <a href="#" class="btn btn-primary" onclick="reservar([% id1 %],[% id2 %]);">[% 'Reservar' | i18n %]</a>
							              </div>
								</div>
	                		[% END %]  <!--END  IF nivel2_array -->
	
			              	[% INCLUDE 'e-docs_grupo.inc' %]
			                                        
							[% IF !preferencias.resumido %]
							    [% INCLUDE 'opac-detail_partial_N2_ejemplares.inc' %]
							[% END %]	                            

			     			[% IF disponible %]
			                   [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
			            	[% END %]
			            	
			            	
					</section>


[% END %]  <!--END FOREACH nivel2 -->
