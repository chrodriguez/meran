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
	    <h1>[% 'Comentarios' | i18n %] <small> [% titulo %] [% IF nivel2_obj.getEdicion %]([% nivel2_obj.getEdicion %]) [% END %]</small></h1>
	</div>      
    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span2">
                  <a class="fancylink" rel="group" href="/uploads/covers/[% portada_registro_big %]" >
                        <img  name="cover" src="/uploads/covers/[% portada_registro_medium %]" title="Portada" style="float:left" />
                  </a>
            </div>
            

            <div class="span10">
                  [% IF socio_data.usr_permisos_opac %]

                  <form class="form-horizontal" action="[% url_prefix %]/reviews.pl" method="post">
                      <fieldset>
                      <legend> [% 'Enviar comentario ' | i18n %]</legend>
                      <section class="center-section-form ">
                          <textarea id="review" name="review" class="self_review" style="width:340px; height:90px;"></textarea><br><br>
                          <input type="hidden" name="token" value="[% token %]" />
                          <input type="hidden" name="id2" value="[% HTML.escape(id2) %]" />
                        
                                <input class="btn btn-success" type="submit" value="[% 'Enviar' | i18n %]" />
                      </section>
                      </fieldset>

<<<<<<< HEAD
                  </form>
                  [% END %]
            </div>
        </div>
  </div><br>

<fieldset>
      <legend> [% 'Comentarios realizados' | i18n %]</legend>
      [% IF reviews %]

          [% FOREACH review IN reviews %]
                  <div class="well center-section-form">
                      [% IF socio_data.usr_nro_socio != review.socio.getNro_socio %]
                          <strong>[% 'Escrito por' | i18n %]: </strong><span class="user_cite_other">[% review.socio.persona.getApellido %], [% review.socio.persona.getNombre %] ([% review.socio.getNro_socio %]) </span><br>
                      [% ELSE %]
                          <strong>[% 'Escrito por' | i18n %]: </strong><span class="user_cite">[% 'usted' | i18n %]</span><br>
                      [% END %]
                      <strong>[% 'Fecha' | i18n %]: </strong>[% review.date %]<br>
                      <strong>[% 'Mensaje' | i18n %]: </strong>[% review.getReview %]
                  
                  </div>    <br>
            
          [% END %]

      [% ELSE %]

          <div class="alert alert-info"> [% 'Esta edici&oacute;n no tiene ninguna revisi&oacute;n' | i18n %]</div>
      [% END %]
      <hr>
       
          [% PERL %]
                  print C4::AR::Filtros::action_link_button( 
                                              
                                                            button        => "btn click btn-info",
                                                            url           => "[% url_prefix %]/opac-detail.pl", 
                                                            title         => "[% ' Volver al detalle' | i18n %]",
                                                            params =>   ["id1=[% id1 %]"],
                                                            icon          => "icon-arrow-left icon-white",
                                                                                  
                                              );
          [% END %]
=======
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
>>>>>>> 48d51e6ac5bd5736580460ee9fb8b67ef4fd538a

</fieldset>
                   
