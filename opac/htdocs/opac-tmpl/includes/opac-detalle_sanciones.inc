[% IF sancion %]
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
                  [% IF sancion %]
                        [% IF sancion.ref_tipo_sancion.tipo_sancion %]
                            <li class="sancionesOPAC">
                                <h2>[% sancion.ref_tipo_prestamo_sancion.getDetalle %]</h2> &nbsp;[% "Desde el" | i18n %] [% sancion.getFecha_comienzo %] [% "hasta el" | i18n %] [% sancion.getFecha_final %]
                            </li>
                        [% END %]
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
