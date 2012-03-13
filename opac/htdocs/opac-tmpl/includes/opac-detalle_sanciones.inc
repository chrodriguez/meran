[% IF sanciones %]
        <br> <h4>[% "Ud. est&aacute; sancionado para los siguientes tipos de pr&eacute;stamo:" | i18n %]</h4> 
         [% FOREACH sancion IN sanciones %]
              <br>
	
              <div class="alert alert-danger"> 
              <b>[% IF sancion.tipo_sancion %]
                  [% FOREACH ts IN sancion.ref_tipo_prestamo_sancion %] 
                      [% ts.ref_tipo_prestamo.descripcion %]<br>
                  [% END %]
                  [% ELSE %]
                      [% "Reserva no retirada" | i18n %]<br>
                  [% END %]
              </b><br>
              
                    <b>[% "Desde el: " | i18n %]</b>[% sancion.getFecha_comienzo_formateada %]<b>[% " hasta el: " | i18n %]</b>[% sancion.getFecha_final_formateada %]</br>
                    <b>[% "Autor: " | i18n %]</b>[% sancion.nivel3.nivel1.getAutor %]</br>
                    <b>[% "Titulo: " | i18n %]</b>[% sancion.nivel3.nivel1.getTitulo %]</br>
                    <b>[% "Edicion: " | i18n %]</b>[% IF sancion.nivel3.nivel2.getEdicion %] 
                                                    [% sancion.nivel3.nivel2.getEdicion %]
                                                  [% ELSE %]
                                                    --
                                                  [% END %]</br>
              </div>    
       
         [% END %]

[% ELSE %]
      <div class="alert alert-info">[% 'Ud. no ha sido sancionado.' | i18n %]</div>
[% END %]
