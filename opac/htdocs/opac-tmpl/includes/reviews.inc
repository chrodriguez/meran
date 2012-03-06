<script type="text/javascript">
    $(document).ready(function() {
        $(function()
        {
            $('.fancylink').fancybox();
        });
    });
</script>

[% USE HTML %]
	<div class="page-header">
	    <h1>[% 'Revisiones ' | i18n %] <small> [% titulo %] [% IF nivel2_obj.getEdicion %]([% nivel2_obj.getEdicion %]) [% END %]</small></h1>
	</div>      
      <a class="fancylink" rel="group" href="/uploads/covers/[% portada_registro_big %]" >
      <img  name="cover" src="/uploads/covers/[% portada_registro_medium %]" title="Portada" style="float:left" />
    </a>

<section id="reviews_all">
    [% IF reviews %]
    <div class="review">
        [% FOREACH review IN reviews %]
                <div class="well">
                    [% IF socio_data.usr_nro_socio != review.socio.getNro_socio %]
                         <strong>[% 'Escrito por' | i18n %]: </strong><span class="user_cite_other">[% review.socio.persona.getApellido %], [% review.socio.persona.getNombre %] ([% review.socio.getNro_socio %]) </span><br>
                    [% ELSE %]
                        <strong>[% 'Escrito por' | i18n %]: </strong><span class="user_cite">[% 'usted' | i18n %]</span>
                    [% END %]
                    
                    <hr>
                    [% review.getReview %]
                </div>    
           
        [% END %]
      </div>
    [% ELSE %]
        <div class="alert alert-info"> [% 'Esta edici&oacute;n no tiene ninguna revisi&oacute;n' | i18n %]</div>
    [% END %]

</section>

[% IF socio_data.usr_permisos_opac %]

	<form class="form-horizontal" action="[% url_prefix %]/reviews.pl" method="post">
	  <section >
	    <fieldset>
	    <legend> [% 'Enviar comentario ' | i18n %]</legend>
	    
	        <textarea id="review" name="review" class="self_review" style="width: 88.3%;height: 150px;"></textarea>
	        <input type="hidden" name="token" value="[% token %]" />
	        <input type="hidden" name="id2" value="[% HTML.escape(id2) %]" />
	        <div class="form-actions">
	              <button class="btn btn-primary" type="submit"><i class="icon-white icon-comment"></i> [% 'Enviar comentario' | i18n %]</button>
	        </div>
	    </fieldset>
	   </section>
	</form>
[% END %]

[% PERL %]
        print C4::AR::Filtros::link_to( text =>     "[% 'Volver al detalle' | i18n %]",
                                        url =>      "[% url_prefix %]/opac-detail.pl", 
                                        params =>   ["id1=[% id1 %]"],
                                        title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                    );
[% END %]