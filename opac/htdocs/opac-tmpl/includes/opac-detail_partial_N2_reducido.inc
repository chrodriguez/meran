<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border-green" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1 class="green">[% "Detalle del Grupo" | i18n %]</h1>
        [% FOREACH nivel2 %]
            <ul class="listado_sin_margen">
                [% FOREACH nivel2_array %]
                    [% FOREACH subcampos_array %]
                            [% IF liblibrarian %]
                                [% IF dato %]
                                <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
                                [% END %]
                            [% END %]

                    [% END %] <!-- END FOREACH nivel2_array -->
                [% END %] <!-- END FOREACH subcampos_array-->
            </ul>
          [% INCLUDE 'opac-detail_partial_disponibilidad.inc'%]
        [% END %] <!-- FOREACH de nivel2 -->
      </div>
  </div>