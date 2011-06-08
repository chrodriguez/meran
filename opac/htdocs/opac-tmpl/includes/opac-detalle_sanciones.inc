[% IF sanciones %]
    <table class="tabla_datos" width="98%" align="center"  border="0" cellpadding="0" cellspacing="0" >
      <tr>
        <td valign="top">
            <table class="tabla_datos" cellpadding="0" cellspacing="0" border="0">
              <tr>
                <td>
                  <font color="red" size="3">
                    <b>[% "Ud. est&aacute; sancionado para los siguientes tipos de pr&eacute;stamo:" | i18n %]
                  </font></b>
                  <ul>
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

	                    </li>      
                    [% END %]
                  <ul>
                </td>
              </tr>
            </table>
        </td>
      </tr>
    </table>
[% ELSE %]
    <h1> [% 'Ud. no ha sido sancionado.' | i18n %]
[% END %]
