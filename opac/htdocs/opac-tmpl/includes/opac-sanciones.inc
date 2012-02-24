[% USE HTML %]




<div class="alert alert-danger">
	<a class="close" data-dismiss="alert" href="#">×</a>
	<div class="modal-header">
		<h3>[% "Usted tiene las siguientes sanciones" | i18n %]</h3>
	</div>
	<div class="modal-body">
                [% FOREACH sancion IN sanciones %]
                      <li>
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
	</div>
		<a href="#" class="btn btn-primary">[% "Ver sanciones" | i18n %]</a>
</div>
                