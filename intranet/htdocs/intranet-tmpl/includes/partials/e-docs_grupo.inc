[% USE HTML %]

<link rel="stylesheet" type="text/css" href="[% temas %]/[% user_theme_intra %]/includes/fileuploader.css">

<script type="text/javascript" src="/includes/jquery/fileuploader.js"></script>


<fieldset>

    <legend class="titulo_legend">[% "Documentos electr&oacute;nicos del grupo"| i18n %]:</legend>

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
	                <img style="height: 25px; width: 25px; border: none; float:left;" src='[% temas %]/[% user_theme_intra %]/imagenes/iconos/[% file.getFileType %].png' />
		        </li>
            [% END %]

	    </ul>
    </div>
    
       <div id="file-uploader_[% id2 %]" class="fileUploader_catalogo">
        <noscript>          
            <p>[% 'Please enable JavaScript to use file uploader.' | i18n %]</p>
            <!-- or put a simple form for upload here -->
        </noscript>                          
       </div>
       <script type="text/javascript">
           var uploader = new qq.FileUploader({
               element: document.getElementById('file-uploader_[% id2 %]'),
               action: '/cgi-bin/koha/catalogacion/estructura/uploadDocument.pl',
               params: {
                   id2: '[% id2 %]',
               },
               onComplete: function(id, fileName){},
               debug: true,
           });
        </script>
</fieldset>
