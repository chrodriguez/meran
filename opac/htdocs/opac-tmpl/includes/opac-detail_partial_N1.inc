<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1>[% "Detalle del Registro" | i18n %]</h1>
        <div class="detalle">
            <ul class="listado_sin_margen">
                [% FOREACH nivel1 %]
                        [% IF liblibrarian %]
                            [% IF dato %]
                            <li>    [% liblibrarian %]: <strong>[% dato %]</strong></li>
                            [% END %]
                        [% END %]
                [% END %]
            </ul>
        </div>
    </div>
</div>