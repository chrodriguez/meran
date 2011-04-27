[% USE HTML %]
[% IF cant_docs %]
	<fieldset class="main">
	
	    <legend class="titulo_legend">[% "Documentos electr&oacute;nicos del grupo"| i18n %]:</legend>
	
	    <div id="lista_docs_[% id2 %]" class="lista_docs_[% id2 %]">
		    <ul>
                [% FOREACH file IN lista_docs %]	
			        <li class="item">
<!-- 		                <a href="/cgi-bin/koha/getDocument.pl?id=[% file.id %]" > [% HTML.escape(file.title) %] </a> -->
                        [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     [% HTML.escape(file.getTitle) %],
                                                            url =>      "getDocument.pl", 
                                                            params =>   ["id=[% file.getId %]"],
                                                            title =>    "[% HTML.escape(file.getTitle) %]"
                                                        ) ;
                        [% END %]
		                <img style="height: 25px; width: 25px; border: none; float:left;" src='[% temas %]/[% tema %]/imagenes/iconos/[% file.getFileType %].png' />
			        </li>
	            [% END %]
	
		    </ul>
	    </div>
	</fieldset>
[% END %]
