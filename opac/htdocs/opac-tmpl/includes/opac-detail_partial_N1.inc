<dl class="listado_sin_margen">
    [% FOREACH nivel1 %]
            [% IF liblibrarian %]
                [% IF dato %]
                <dt>[% liblibrarian %]:</dt><dd>[% dato %]</dd>
                [% END %]
            [% END %]
    [% END %]
</dl>
