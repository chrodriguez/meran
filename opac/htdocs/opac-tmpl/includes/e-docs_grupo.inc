[% USE HTML %]

[% IF pref_e_documents %]
	[% IF cant_docs > 0 %]
	            <h1 class="orange">[% "Documentos electr&oacute;nicos" | i18n %]</h1>		    
	            <div id="lista_docs_[% id2 %]" class="lista_docs">
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
			                    </li>
			            [% END %]
			        </ul>
			    </div>
	[% END %]	
[% END %]   
		
