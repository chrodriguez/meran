[% USE HTML %]

[% IF novedad.getContenido %]

<script type="text/javascript" language="javascript">
    $(document).ready(function() {
    
        $('.fancylink').fancybox();
    
    });
</script>
    
    <fieldset>
        <legend>Detalle de la novedad <strong>[% HTML.escape(novedad.getTitulo) %]</strong></legend>

        <div>
            <dl>
                <dt>[% 'T&iacute;tulo' | i18n %]:</dt>
                <dd>[% HTML.escape(novedad.getTitulo) %]</dd>
                
                <dt>[% 'Fecha' | i18n %]:</dt>
                <dd>[% HTML.escape(novedad.getFechaLegible) %]</dd>
                
                <dt>[% 'Contenido' | i18n %]:</dt>
                <dd>[% HTML.escape(novedad.getContenido) %]</dd>
                
	            [% IF novedad.getCategoria %]
                    <dt>[% 'Categoria' | i18n %]:</dt>
                    <dd>[% HTML.escape(novedad.getCategoria) %]</dd>
                [% END %] 
            </dl>
	    </div>
	    
        [% IF cant %]
            <div class="well">
	        
	            [% FOREACH imagen IN imagenes_hash %]
	                <a class="fancylink" rel="group" href="/opac-tmpl/uploads/novedades/[% imagen.getImageName %]">
                        <img border="0" src="/opac-tmpl/uploads/novedades/[% imagen.getImageName %]"
                              style="width: 60%; max-width: 120px;" 
                              alt="novedad_[% imagen.getIdNovedad %]"
                              title="novedad_[% imagen.getIdNovedad %]"
                        >
                    </a>
<!--	               <img src="/pictures/[% imagen.getImageName %]" alt="description" title="description" width="" height="" />-->
	            
	            [% END %]
	            
	       </div>
	        
        [% END %] 
	    
	    <div class="form-actions">
	        [% PERL %]
                print C4::AR::Filtros::action_link_button( 
                                                button          => "btn btn-primary click",
                                                url             => "[% url_prefix %]/opac-novedades.pl", 
                                                title           => "Volver al listado",
                                          ) ;

            [% END %]
	    </div>
	</fieldset>
	
[% ELSE %]
        <div class="alert alert-info">[% 'La novedad solictada no existe.' | i18n %]</div>
        <div class="form-actions">
	        [% PERL %]
                print C4::AR::Filtros::action_link_button( 
                                                button          => "btn btn-primary click",
                                                url             => "[% url_prefix %]/opac-novedades.pl", 
                                                title           => "Volver al listado",
                                          ) ;

            [% END %]
	    </div>
[% END %]
