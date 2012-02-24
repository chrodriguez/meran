<script type="text/javascript">

    function submitForm(form_id) {
        $('#' + form_id).submit();
    }

    [% IF external_search %]
    	[% IF cant_external_servers %]
		    var servidores 	= new Array();
		    var server_name	= {};
			var SERVER = "";   
			var numPag = 1;
			var SEARCH = "";
			var results = false;
			
			[% FOREACH server IN external_servers %] 
				servidores.push("[% server.url %]");
				server_name["[% server.url %]"] = "[% server.ui.getNombre %]";
			[% END %]
		
		
			function nextPage(){
				numPag++;
				doExternalSearches(SEARCH);
			}		
		
			function prevPage(){
				if (numPag > 1)
					numPag--;
				doExternalSearches(SEARCH);
			}		
		
			function doExternalSearches(keyword){
				$('#main_content').html("");
				startOverlay();
				SEARCH = keyword;
				
				try{
					Concurrent.Thread.create(function(){
						results = false;
						for (x=0; x<servidores.length ;x++){
							externalSearch(SEARCH,servidores[x],server_name[servidores[x]]);
							$('#main_content').append("<br />");
							$('#main_content').append("<br />");
						} 
						closeModal();
						if (results){
							if (numPag > 1)
								$('#main_content').append("<input class='js_paging' type='button' onclick='prevPage();' value= [% 'Anterior' | i18n %] /> ");
							$('#main_content').append("<input class='js_paging' type='button' onclick='nextPage();' value= [% 'Siguiente' | i18n %] /> ");
			
							$('#main_content').append("<br />");
						}else{
							$('#main_content').append("[% ' LOS SERVIDORES EXTERNOS NO DISPONEN DE MAS RESULTADOS SEGUN SU CRITERIO ' %]");
						}
					});
				}
				catch(e){}
			}
		
		 
		    function externalSearch(keyword,URL,server_name){
		
		  	    objAH                   = new AjaxHelper(updateExternalSearch);
		  	    objAH.debug             = true;
		  	    //para busquedas combinables
		  	    objAH.url               = URL;
		  	    objAH.async				= false;
		  	    objAH.keyword           = keyword;
		  	    SERVER = server_name;
		  	    //se setea la funcion para cambiar de pagina
		  	    objAH.ini          	 	= numPag;
		  	    //se envia la consulta
		  	    objAH.sendToServer();
		    }
		
		    function updateExternalSearch(responseText){
		
		        var table 	= "";
		        var cant_dc	= 0;
		    	var templates = {
		    	    tr : '<tr>#{row}</tr>',
		    	    th : '<th>#{header}</th>',
		    	    td : '<td>#{cell}</td>'
		    	};

		    	table  = '<fieldset><legend class="server_name">'+SERVER+'</legend></fieldset><table class="external_results"><thead>';
				table += '<tr>';
		        table += '<th>[% "T&iacute;tulo" | i18n %]</th>'; 
//		        table += '<th>[% "Autor" | i18n %]';
		
				table += '</tr></thead><tbody>';
		         
		        $(responseText).find('rdf\\:Description').each(function() {
		            cant_dc++;
		            
		            var marker = $(this);
		            var title       = marker.find("dc\\:title").text();
		            var creator     = marker.find("dc\\:creator").text();
		            var subject     = marker.find("dc\\:subject").text();
		            var description = marker.find("dc\\:description").text();
		            var publisher   = marker.find("dc\\:publisher").text();
		            var contributor = marker.find("dc\\:contributor").text();
		            var date        = marker.find("dc\\:date").text();
		            var type        = marker.find("dc\\:type").text();
		            var format      = marker.find("dc\\:format").text();
		            var identifier  = marker.find("dc\\:identifier").text();
		            var source      = marker.find("dc\\:source").text();
		            var language    = marker.find("dc\\:language").text();
		            var relation    = marker.find("dc\\:relation").text();
		            var coverage    = marker.find("dc\\:coverage").text();
		            var rights      = marker.find("dc\\:rights").text();
		            var url			= "<a href="+marker.attr('rdf:about')+" target='_blank'>"+title+"</a>";
		            
		            var DC_hash     = {
		            		title: title,
		            		creator: creator,
		            		subject: subject,
		            		description: description,
		            		publisher: publisher,
		            		contributor: contributor,
		            		date: date,
		            		type: type,
		            		format: format,
		            		identifier: identifier,
		            		source: source,
		            		language: language,
		            		relation: relation,
		            		coverage: coverage,
		            		rights: rights,
		            		link: url
		            }
		            table += '<tr>';
		    	    table += $.tmpl(templates.td, {cell: DC_hash.link});
		    	   // table += $.tmpl(templates.td, {cell: DC_hash.creator});
		            table += '</tr>';
		        });
		
				table += '</tbody></table>';
				if (cant_dc > 0){
					$('#main_content').append(table);
					results = true;
				}
				
				return (table);
		    }
          [% END %]
       [% END %]		    

    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>

[% USE HTML %]

[% IF show_search_details %]

        <section class="center-section-form">
            <div class="well">
                <div class="resultados_consulta">[% "Ha buscado por" | i18n %]: <strong>[% HTML.escape(buscoPor) %]</strong></div> 
            
	            [% IF cantidad %]
	                <div class="resultados_consulta">[% "Total de registros" | i18n %]: <b>[% cantidad %]</b>  en ([% timeSeg %] segundos)</div>
	            [% END %]

                [% IF !from_suggested %]
			        [% IF suggested %]
	                    <a href="#" onclick="buscarSuggested('[% suggested %]')">
	                        [% "Usted quiso decir" | i18n %] <span style="font-style: italic">[% suggested %]</span>?
	                    </a>
			        [% END %]
			    [% END %]

            </div>
        </section>    

          [% IF only_available %]
                <h2 class="advice"> [% 'Solo se muestran ejemplares disponibles.' | i18n %] <a href="[% url_todos %]">([% ' Mostrar todos' | i18n %])</a></h2>
          [% END %]


          [% IF external_search %]
	          [% IF cant_external_servers %]
	                <h2 class="advice"> [% 'Buscar en servidores externos.' | i18n %] <a href="#" onclick="doExternalSearches('[% buscoPor | html %]')">([% ' Buscar en servidores externos' | i18n %])</a></h2>
	          [% END %]
          [% END %]
[% END %]

[% IF (cantidad > 0) || ( (!from_suggested) && (suggested) )%]
    
      [% FOREACH NIVEL IN SEARCH_RESULTS %]
                <script type="text/javascript">
                    $(function(){
                        $("#rating[% NIVEL.id1 %]").children().not(":radio").hide();
                        $("#rating[% NIVEL.id1 %]").stars({
                            cancelShow: false,
                            split: 2,
                            disabled: true
                        });
                        $("#rating[% NIVEL.id1 %]").stars("select",[% NIVEL.rating %]);
                    });
                </script>
    [% END %]

    [% IF !from_suggested %]
            
            [% IF suggested %]
                    <div class="suggested_search">
                        <a href="[% url_prefix %]/opac-busquedasDB.pl?string=[% suggested | html %]&tipoAccion=[% tipoAccion | html %]&from_suggested=1&only_available=[% only_available | html %]&token=[% token | html %]">
                            [% "Usted quiso decir" | i18n %] <span style="font-style: italic">[% suggested %]</span>?
                        </a>
                    </div>
            [% END %]
    
    [% END %]
    
    [% IF cantidad > 0 %]
        	 <div class="contenedor_paginador">[% paginador %]</div>
        	
             [% PERL %]
                 print C4::AR::Filtros::tableHeader(   
                                                         id              => "tablaResult",
                                                         class           => "",
                                                         columns         => ['[% "Tipo"|i18n %]','[% "T&iacute;tulo"|i18n %]','[% "Autor"|i18n %]',
                                                                             '[% "Edici&oacute;n"|i18n %]','[% "Disponibilidad"|i18n %]', '[% "Valoraci&oacute;n" | i18n %]',
                                                                             [% IF socio_data.usr_permisos_opac %]'[% "Favoritos" | i18n %]'[% END %]
                                                                            ]
                                                         
                             ) ;
             [% END %]
             <tbody>  
                [% FOREACH NIVEL IN SEARCH_RESULTS %]
                    <tr>
	                     <td>
	                         [% IF NIVEL.portadas_grupo_cant > 0 %]
	                                 [% FOREACH portada IN NIVEL.portadas_grupo %]
	                                     [% IF loop.count < 4 %]
	                                   [% IF portada.portada_registro_big %]
	                                       <a class="fancylink" rel="group_[% grupo %]" href="/uploads/covers/[% portada.portada_registro_big %]">
	                                           <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
	                                       </a>
	                                   [% ELSE %]
	                                       [% IF portada.portada_registro_medium %]
	                                           <a class="fancylink" rel="group_[% grupo %]" href="/uploads/covers/[% portada.portada_registro_medium %]">
	                                               <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
	                                           </a>
	                                       [% ELSE %]
	                                               <img alt="cover" src="/uploads/covers/[% portada.portada_registro %]" title="Portada" />
	                                       [% END %]
	                                   [% END %]
	                                     [% END %]
	                                 [% END %]
	                         [% ELSE %]
	                               <img src="/uploads/covers/[% NIVEL.cat_ref_tipo_nivel3 %].png" 
	                                     alt="[% 'Sin Portada' | i18n %]"
	                                     title="[% 'Sin Portada' | i18n %]" />
	                         [% END %]
	                         <br />
	                         <center><div style="font-weight: bold; font-size: 10px; clear:both;" >[% NIVEL.cat_ref_tipo_nivel3_name %] </div></center>
	                     </td>

                        <td>	
                            [% IF NIVEL.titulo %]
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(NIVEL.titulo) %]",
                                                                    url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                    params =>   ["id1=[% NIVEL.id1 %]"],
                                                                    title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                ) ;
                                [% END %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>

                        <td>
                            [% IF NIVEL.nomCompleto %]
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(NIVEL.nomCompleto) %]",
                                                                    url =>      "[% url_prefix %]/opac-busquedasDB.pl", 
                                                                    params =>   ["tipoAccion=BUSQUEDA_AVANZADA","autor=[% HTML.escape(NIVEL.nomCompleto) %]"],
                                                                    title =>    "[% 'Buscar de este autor' | i18n %]"
                                                                ) ;
                                [% END %]                                
                            [% ELSE %]
                                ----------
                            [% END %]
                        </td>

                        <td>
                        [% IF NIVEL.estadoDeColeccion %]
							<span id="coleccion_[% NIVEL.id1 %]">
							<ul class="listado_sin_margen estado_coleccion">
							[% FOREACH anio IN NIVEL.estadoDeColeccion.keys.sort %]
							[% IF NIVEL.estadoDeColeccion.$anio.keys %]
							<li>
								[% IF anio != '#' %]<b>[% anio %]</b>[% END %]
								[% FOREACH volumen IN NIVEL.estadoDeColeccion.$anio.keys.sort %]
									[% IF volumen != '#' %][% volumen  %][% END %]
									(
									[% FOREACH fasciculo IN NIVEL.estadoDeColeccion.$anio.$volumen.keys.sort %]

										 [% PERL %]
											print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(fasciculo) %]",
																			url=>"[% url_prefix %]/opac-detail.pl", 
																			params =>   ["id1=[% NIVEL.id1 %]","id2=[% NIVEL.estadoDeColeccion.$anio.$volumen.$fasciculo %]"],
																			title =>    "[% 'Mostrar Detalle del Registro' | i18n %]",
																			class => 	"link_to_detail"
																		) ;
										 [% END %]
                        
									[% END %]
									)
								[% END %]
							   </li>
							[% END %]
							[% END %]
							</ul>
							</span>
							
						  <script type="text/javascript">$("#coleccion_[% NIVEL.id1 %]").expander({
							  slicePoint: 2000, 
							  widow: 10,
							  expandEffect: 'fadeIn', 
							  expandText: "<br />[% 'M&aacute;s Revistas' | i18n %]",
							  userCollapseText: '[^]'
							});
						 </script>
						 
						[% ELSE %]
							[% IF NIVEL.grupos %]
								<span id="grupos_[% NIVEL.id1 %]" class="detalle_registro_edicion">
									[% FOREACH NIVEL.grupos %]
										[% IF edicion %]
											[% edicion %] &nbsp;
										[% END %]
										[% IF loop.prev.anio_publicacion != anio_publicacion %]
											[% IF anio_publicacion %]
												([% anio_publicacion %])<br/>
											[% END %]
										[% END %]
											
									[% END %]
								</span>
						  <script type="text/javascript">$("#grupos_[% NIVEL.id1 %]").expander({
							  slicePoint: 2000, 
							  widow: 10,
							  expandEffect: 'fadeIn', 
							  expandText: "<br />[% 'M&aacute;s ediciones' | i18n %]",
							  userCollapseText: '[^]'
							});
						 </script>
							[% END %]
						[% END %]
   
                        </td>

                        <td>
                            [% IF NIVEL.disponibilidad %]
                                [% FOREACH NIVEL.disponibilidad %]
                                    <b>[% tipoPrestamo %]</b> [% cantTotal %]
                                    <div style="margin-right:4px">
                                        [% IF reservados != 0 %]
                                            [% reservados %]
                                        [% END %] 
                                        
                                        [% IF prestados != 0 %]
                                            [% prestados %]
                                        [% END %] 
                                    </div>
                                    <br />
                                [% END %]
                            [% ELSE %]
                                &nbsp;
                            [% END %]
                        </td>
                        <td class="span2">
                            [% IF NIVEL.rating > 0 %]
	                            <div class="rating">
	                                <form id="rating[% NIVEL.id1 %]" class="ratings" action="">
	                                    <div>
	                                      <input type="radio" name="rate" value="1" />
	                                      <input type="radio" name="rate" value="2" />
	                                      <input type="radio" name="rate" value="3" />
	                                      <input type="radio" name="rate" value="4" />
	                                      <input type="radio" name="rate" value="5" />
	                                      <input type="radio" name="rate" value="6" />
	                                      <input type="radio" name="rate" value="7" />
	                                      <input type="radio" name="rate" value="8" />
	                                      <input type="radio" name="rate" value="9" />
	                                      <input type="radio" name="rate" value="10" />
	                                      <input type="submit" value="Enviar" />
	                                    </div>
	                                </form>
	                                <br style="clear:both" />
	                            </div>
	                         [% ELSE %]
	                           <p> [% '----------' %]
	                         [% END %]
                        </td>
                        [% IF socio_data.usr_permisos_opac %]
	                        <td>
	                            [% IF NIVEL.esta_en_favoritos %]
				                    [% PERL %]
				                      print C4::AR::Filtros::action_button( 
				                                                      button    => "btn btn-danger click",
				                                                      action    =>  "deleteFavorite([% NIVEL.id1 %]);",
				                                                      icon      => "icon-remove icon-white",
				                                                  ) ;
				
				                    [% END %]
	                            [% ELSE %]
				                    [% PERL %]
				                      print C4::AR::Filtros::action_button( 
				                                                      button    => "btn btn-info click",
				                                                      action    => "addFavorite([% NIVEL.id1 %]);",
				                                                      icon      => "icon-star icon-white",
				                                                      popover => {text => "Agrega este registro a tu estante privado de favoritos", title => "Favoritos"},
				                                                  ) ;
				
				                    [% END %]
	                            [% END %]
	                        </td>
	                     [% END %]
                    </tr>
                [% END %]
             </tbody>
        </table>
        <div class="contenedor_paginador">[% paginador %]</div>
  	[% END %]
    <!-- FIX PARA W3C PORQUE NO SE PERMITEN SCRIPT DENTRO DE TABLAS -->
  [% ELSE %]
    
    [% IF no_content_message %]
        <div class="alert alert-info"> [% no_content_message %] </div>  
    [% ELSE %]
        <div class="alert alert-info"> [% 'Nada que mostrar.' | i18n %] </div>
    [% END %]
    <br />

	<div class="page-header">
	    <h1>Meran <small>[% 'Repetir la b&uacute;squeda con otros criterios' | i18n %]</small></h1>
	</div> 
  
    
    [% INCLUDE 'opac-advanced_search.inc' %]
[% END %]
