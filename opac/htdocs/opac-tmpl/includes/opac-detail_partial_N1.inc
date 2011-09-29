<ul class="listado_sin_margen">
    [% FOREACH nivel1 %]
            [% IF liblibrarian %]
                [% IF dato %]
                <li>    [% liblibrarian %]: <strong>[% dato %]</strong></li>
                [% END %]
            [% END %]
    [% END %]
</ul>
