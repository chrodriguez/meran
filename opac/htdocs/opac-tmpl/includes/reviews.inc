<script>
    $(document).ready(function() {
        $(function()
        {
            $('#review').wysiwyg();
        });
    });
</script>

[% USE HTML %]
[% IF reviews %]
    [% FOREACH review IN reviews %]
        <div style="float:left; width:90%" class="review" >
            <br />
            <pre>
                [% review.getReview %]
                [% IF socio.getNro_socio != review.socio.getNro_socio %]
                    <h2>[% 'Escrito por' | i18n %]:</h2> [% review.socio.persona.getApellido %], [% review.socio.persona.getNombre %] ([% review.socio.getNro_socio %])
                [% ELSE %]
                    <h2>[% 'Escrito por' | i18n %]:</h2> [% 'usted' | i18n %]
                [% END %]
            </pre>
            <br />
            <hr />
        </div>
    [% END %]
[% ELSE %]
    <h1> [% 'Este ejemplar no tiene ninguna revisi&oacute;n, sea el primero en crear una!' | i18n %]</h1>
[% END %]
<br />
<br />

<form action="/cgi-bin/koha/reviews.pl" method="POST">
    <textarea id="review" name="review" class="self_review" style="width: 88.3%"></textarea>
    <input type="hidden" name="token" value="[% token %]" />
    <input type="hidden" name="id2" value="[% HTML.escape(id2) %]" />
    <input type="submit" value="[% 'Enviar' | i18n %]" />
</form>