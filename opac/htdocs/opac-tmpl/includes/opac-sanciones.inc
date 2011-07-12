[% USE HTML %]

<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1>[% "Usted tiene las siguientes sanciones" | i18n %]</h1>
        <div class="detalle">
            <ul class="listado_sin_margen">
                [% FOREACH sancion IN sanciones %]
                      <li class="sancionesOPAC">
                            <h2>[% sancion.ref_tipo_sancion.ref_tipo_prestamo.getDescripcion %]</h2>
                            <b>[% IF sancion.tipo_sancion %]
                                [% FOREACH ts IN sancion.ref_tipo_prestamo_sancion %] 
                                    [% ts.ref_tipo_prestamo.descripcion %]<br>
                                [% END %]
                                [% ELSE %]
                                    [% "Reserva no retirada" | i18n %]
                                [% END %]
                            </b>
                            </br>
                            <b>[% "Desde el: " | i18n %]</b>[% sancion.getFecha_comienzo_formateada %]<b>[% " hasta el: " | i18n %]</b>[% sancion.getFecha_final_formateada %]</br>
                            <b>[% "Autor: " | i18n %]</b>[% sancion.nivel3.nivel1.getAutor %]</br>
                            <b>[% "Titulo: " | i18n %]</b>[% sancion.nivel3.nivel1.getTitulo %]</br>
                            <b>[% "Edicion: " | i18n %]</b>[% IF sancion.nivel3.nivel2.getEdicion %] 
                                                             [% sancion.nivel3.nivel2.getEdicion %]
                                                           [% ELSE %]
                                                             --
                                                           [% END %]</br>
                            <hr  class="clear-contentunit">
                        </li>      
                    
                [% END %]
            </ul>
        </div>
    </div>
</div>
