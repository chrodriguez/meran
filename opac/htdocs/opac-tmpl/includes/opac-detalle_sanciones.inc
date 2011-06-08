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

<!--                        [% IF sancion.ref_tipo_sancion.tipo_sancion %]-->
<!--                            <li class="sancionesOPAC">-->
<!--                                <h2>[% sancion.ref_tipo_prestamo_sancion.getDetalle %]</h2> &nbsp;[% "Desde el" | i18n %] [% sancion.getFecha_comienzo %] [% "hasta el" | i18n %] [% sancion.getFecha_final %]-->
<!--                            ->
<!--                        [% END %]-->

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
		            <b>[% "Desde el " | i18n %]</b>[% sancion.getFecha_comienzo_formateada %]<b>[% " hasta el " | i18n %]</b>[% sancion.getFecha_final_formateada %]</br>
                    <b>[% sancion.nivel3.nivel1.getAutor %]</b></br>
                    <b>[% sancion.nivel3.nivel1.getTitulo %]</b></br>
                    <b>[% sancion.nivel3.nivel2.getEdicion %]</b></br>

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
