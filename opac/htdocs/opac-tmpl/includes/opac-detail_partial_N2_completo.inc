[% FOREACH nivel2 %]
    [% IF nivel2_array %]
        <div class="main-subcontent" style="width:100%; float:left">
            <div class="subcontent-unit-border-green" style="width:100%;">
                <div class="round-border-topleft" style="width:90%;"></div>
                <h1 class="green">[% "Detalle del Grupo" | i18n %]</h1>
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
            </div>
        </div>
    [% END %]
    <div id="[% DivDetalle %]">
        <div class="main-subcontent" style="width:100%; float:left">
        <div class="subcontent-unit-border-orange" style="width:100%;">
            <div class="round-border-topleft" style="width:90%;"></div>
            <h1 class="orange">[% "Detalle del Ejemplar" | i18n %]</h1>
            <table id="tablaDetalleNivel" class="tablaDetalleNivel3" cellspacing=0 border="0" cellpadding=0 style="width:95%;">
                <thead>
                <tr class="bordetabla" align="center">
                    <td>[% "C&oacute;digo" | i18n %]</td>
                    <td>[% "Signatura Topogr&aacute;fica" | i18n %]</td>
                    <td>[% "Biblioteca que lo posee" | i18n %]</td>
                    <td>[% "Biblioteca de origen" | i18n %]</td>
                    <td>[% "Estado" | i18n %]</td>
                    <td>[% "Disponibilidad" | i18n %]</td>
                    <td>[% "MARC" | i18n %]</td>
                </tr>
                </thead>
                <tbody>
                    [% FOREACH nivel3 %]
                        <tr align="center">
                            <td>[% nivel3_obj.getBarcode %]</td>
                            <td>[% nivel3_obj.getSignatura_topografica %]</td>
                            <td>[% nivel3_obj.getId_ui_poseedora %]</td>   
                            <td>[% nivel3_obj.getId_ui_origen %]</td>  
                            <td>[% nivel3_obj.getEstado %]</td>
                            <td>[% nivel3_obj.getDisponibilidadObject.getNombre %]</td>
                            <td>
                                <a class="click" onClick="MARCDetail('[% id3 %]', '[% DivDetalle %]', '[% DivMARC %]');">
                                <img src="[% themelang %]/images/MARC.png" border="0" alt="[% 'Detalle MARC' | i18n %]" title="[% 'Detalle MARC' | i18n %]">
                                </a>
                            </td>
                        </tr>
                    [% END %]
                </tbody>
            </table>
            <!-- FIXME falta revisar!!!!!!!!!!! -->
            <br />
            <hr />
            <br />
          [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
          </div>
      </div>
  </div>
[% END %]