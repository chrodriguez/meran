[% USE HTML %]

[% IF novedad.getContenido %]
    
    <fieldset>
        <legend>Detalle de la novedad <strong>[% novedad.getTitulo %]</strong></legend>

        <div>
            <dl>
                <dt>[% 'T&iacute;tulo' | i18n %]:</dt>
                <dd>[% novedad.getTitulo %]</dd>
                
                <dt>[% 'Fecha' | i18n %]:</dt>
                <dd>[% novedad.getFechaLegible %]</dd>
                
                <dt>[% 'Contenido' | i18n %]:</dt>
                <dd>[% novedad.getContenido %]</dd>
                
	            [% IF novedad.getCategoria %]
                    <dt>[% 'Categoria' | i18n %]:</dt>
                    <dd>[% novedad.getCategoria %]</dd>
                [% END %] 
	    </div>
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
[% END %]
