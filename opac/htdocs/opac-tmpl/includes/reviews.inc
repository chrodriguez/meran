<script>
    $(document).ready(function() {
        $(function()
        {
            $('#review').wysiwyg({width: "300px",});
        });
    });
</script>

[% USE HTML %]
[% IF reviews %]
    [% FOREACH review IN reviews %]
        <div style="float:left, width=80%" >
            <pre>
                [% HTML.escape(review.getReview) %]
                <h2>[% 'Escrito por' | i18n %]:</h2> [% review.socio.persona.getApellido %], [% review.socio.persona.getNombre %] ([% review.socio.getNro_socio %])
            </pre>
            <br />
            <hr />
            <br />
        </div>
    [% END %]
[% ELSE %]
    <h1> [% 'Este ejemplar no tiene ninguna revisi&oacute;n, sea el primero en crear una!' | i18n %]</h1>
[% END %]
<br />
<br />

<form action="/cgi-bin/koha/reviews.pl" method="POST">
    <textarea id="review" name="review" class="self_review" ></textarea>
    <input type="hidden" name="token" value="[% token %]" />
    <input type="hidden" name="id2" value="[% HTML.escape(id2) %]" />
    <input type="submit" value="[% 'Enviar' | i18n %]" />
</form>