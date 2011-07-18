[% FOREACH nivel2 %]
<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border-green" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1 class="green">[% "Detalle del Grupo" | i18n %]</h1>
        
            <ul class="listado_sin_margen"> 
                [% FOREACH nivel2_array %]
                            [% IF liblibrarian %]
                                [% IF dato %]
                                <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
                                [% END %]
                            [% END %]
                [% END %] <!-- END FOREACH subcampos_array-->
            </ul>
            <div style="float:left; width:100%;" >
                [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
            </div>
        
    </div>
</div>
[% END %] <!-- FOREACH de nivel2 -->