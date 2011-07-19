[% FOREACH nivel2 %]
<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border-green" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1 class="green">[% "Detalle del Grupo" | i18n %]
                        [% IF tiene_indice %]
                            [% PERL %]
                                                print C4::AR::Filtros::to_Icon(  
                                                                                    boton   => "icon_indice",
                                                                                    onClick => "mostrarIndice([% id2 %]);",
                                                                                    title   => "[% 'Ver &iacute;ndice' | i18n %]",
                                                        ) ;
                            [% END %]
                        [% END %]
        </h1>
            <ul class="listado_sin_margen"> 
                [% FOREACH nivel2_array %]
                            [% IF liblibrarian %]
                                [% IF dato %]
                                <li> [% liblibrarian %]: <strong>[% dato %]</strong></li>
                                [% END %]
                            [% END %]
                [% END %] <!-- END FOREACH subcampos_array-->
            </ul>
            <div style="display:none"><div id="indice_data[% id2 %]" style="white-space: pre;" title="[% 'Indice del grupo' | i18n %]">[% indice %]</div></div>
            
            <div style="float:left; width:100%;" >
                [% INCLUDE 'opac-detail_partial_disponibilidad.inc' %]
            </div>
        
    </div>
</div>
[% END %] <!-- FOREACH de nivel2 -->