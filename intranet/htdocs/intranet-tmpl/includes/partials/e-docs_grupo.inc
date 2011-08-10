[% USE HTML %]

[% IF pref_e_documents %]
		<script type="text/javascript">
		
		function refreshPage(fileName, responseJSON){
		    
		    //$("body").html("rock");
		    jAlert(responseJSON.error,fileName);
		    
		}
		</script>
		<fieldset>
		
		    <legend class="titulo_legend trigger trigger_4_[% id2 %] click">[% "Documentos electr&oacute;nicos del grupo"| i18n %]:</legend>
		
		    <div id="lista_docs_[% id2 %]" class="lista_docs_[% id2 %]">
		        <ul>
		               [% FOREACH file IN lista_docs %] 
		                    <li class="item">
		                           [% PERL %]
		                               print C4::AR::Filtros::link_to( text =>     "[% HTML.escape(file.getTitle) %]",
		                                                               url =>      "getDocument.pl", 
		                                                               params =>   ["id=[% file.getId %]"],
		                                                               title =>    "[% HTML.escape(file.getTitle) %]"
		                                                           ) ;
		                           [% END %]
		                        <img style="height: 25px; width: 25px; border: none; float:left;" src='[% temas %]/[% user_theme_intra %]/imagenes/iconos/[% file.getIconType %].png' />
		                           [% PERL %]
		                               print C4::AR::Filtros::link_to( text =>     "(Eliminar)",
		                                                               url =>      "deleteDocument.pl", 
		                                                               params =>   ["id=[% file.getId %]","id1=[% id1 %]"],
		                                                               title =>    "Eliminar"
		                                                           ) ;
		                           [% END %]
		                    </li>
		            [% END %]
		        </ul>
			    <fieldset class="e_docs_upload_form">
			        <legend class="titulo_legend">[% 'Agregar documento' | i18n %]</legend>
				    <div id="file-uploader_[% id2 %]" class="fileUploader_catalogo">
				         <form action="[% url_prefix %]/catalogacion/estructura/uploadDocument.pl" 
				                enctype="multipart/form-data" method="post">
				               <input type="hidden" name="id2" id="id2" value="[% id2 %]" /><br />
				               <input type="hidden" name="id1" id="id1" value="[% id1 %]" /><br />
				               
				               <ul>
				                   <li class="sub_item">
						               <label for="filename">[% "T&iacute;tulo del arhivo"| i18n %]: </label>
						               <input type="text" name="filename" id="filename" /><br />
					               </li>
					               <li class="sub_item">
				                       <label for="file">[% "Arhivo"| i18n %]: </label>
						               <input type="file" name="file" id="file" />
					               </li>
					               <li class="sub_item">
					                   <input type="submit" value='[% "Enviar"| i18n %]''>
					                   <input type="reset">
					               </li>
				               </ul>
				         </form>        
				    </div>
			    </fieldset>
		    </div>
			    
            <script type="text/javascript">makeToggle('lista_docs_[% id2 %]','trigger_4_[% id2 %]',null,true);</script>
		        
		</fieldset>
[% END %]	
		
