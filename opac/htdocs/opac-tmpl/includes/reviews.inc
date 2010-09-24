<script type="text/javascript">
    $(document).ready(function() {
        $(function()
        {
//             [% IF socio_data %]
                $('#review').wysiwyg();
//             [% END %]
            $('.fancylink').fancybox();
        });
    });
</script>

[% USE HTML %]
<fieldset style="float:left; width:90%; margin: 0 auto;">
    <legend> <b>[% 'Revisiones de ' | i18n %] [% titulo %]</b> </legend>
    <a class="fancylink" rel="group" href="/covers/[% portada_registro_big %]" >
      <img  name="cover" src="/covers/[% portada_registro_medium %]" title="Portada" style="float:left" />
    </a>

    [% PERL %]
        print C4::AR::Filtros::link_to( text =>     "[% 'Volver al detalle' | i18n %]",
                                        url =>      "/cgi-bin/koha/opac-detail.pl", 
                                        params =>   ["id1=[% id1 %]"],
                                        title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                    );
    [% END %]
</fieldset>
<div id="reviews_all" style="width: 100%;">
    [% IF reviews %]
        [% FOREACH review IN reviews %]
            <div class="review">
                <br />
                <p>
                    [% review.getReview %]
                    [% IF socio_data.usr_nro_socio != review.socio.getNro_socio %]
                        <h2>[% 'Escrito por' | i18n %]: <span class="user_cite_other">[% review.socio.persona.getApellido %], [% review.socio.persona.getNombre %] ([% review.socio.getNro_socio %]) </span></h2>
                    [% ELSE %]
                        <h2>[% 'Escrito por' | i18n %]: <span class="user_cite">[% 'usted' | i18n %]</span> </h2>
                    [% END %]
                </p>
                <br />
                <hr />
            </div>
        [% END %]
    [% ELSE %]
        <h1> [% 'Este ejemplar no tiene ninguna revisi&oacute;n, sea el primero en crear una!' | i18n %]</h1>
    [% END %]
    <br />
    <br />
</div>
[% IF socio_data %]
    <form action="/cgi-bin/koha/reviews.pl" method="post">
        <textarea id="review" name="review" class="self_review" style="width: 88.3%"></textarea>
        <input type="hidden" name="token" value="[% token %]" />
        <input type="hidden" name="id2" value="[% HTML.escape(id2) %]" />
        <input type="submit" value="[% 'Enviar' | i18n %]" />
    </form>
[% END %]
