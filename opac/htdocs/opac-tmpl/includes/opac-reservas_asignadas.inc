[% USE HTML %]

<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1>[% "Usted tiene las siguientes reservas asignadas" | i18n %]</h1>
        <div class="detalle">
            <ul class="listado_sin_margen">
                [% FOREACH reserva IN RESERVAS_ASIGNADAS %]
                    <li>
                    [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% reserva.nivel2.nivel1.getTitulo %]",
                                                              url =>      "[% url_prefix %]/opac-detail.pl", 
                                                              params =>   ["id1=[% reserva.nivel2.nivel1.getId1 %]"],
                                                              title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                          ) ;
                    [% END %]
                    </li>
                    <li>
                    [% IF reserva.nivel2.nivel1.getAutor %]
                        [% reserva.nivel2.nivel1.getAutor %]
                    [% ELSE %]
                        &nbsp;
                    [% END %]
                    </li>
                    <li>

                        [% IF reserva.getFecha_recordatorio_formateada %]
                          <span class="[% IF reserva.estaVencida %]fecha_vencida[% ELSE %]fecha_cumple[% END %]">
                              Retirar antes del: [% reserva.getFecha_recordatorio_formateada %]
                          </span>
                        [% ELSE %]
                              - 
                        [% END %]

               
                    </li>
                    <hr  class="clear-contentunit">
                [% END %]
            </ul>
        </div>
    </div>
</div>
