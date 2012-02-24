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
                            <dl>
                            
	                            <dt class="inline left rightMargin">[% "Desde el: " | i18n %]</dt>
	                            <dd>[% sancion.getFecha_comienzo_formateada %]<b>[% " hasta el: " | i18n %]</b>[% sancion.getFecha_final_formateada %]</dd>
	
	                            <dt class="inline left rightMargin">[% "Autor: " | i18n %]</dt>
	                            <dd>[% sancion.nivel3.nivel1.getAutor %]</dd>
	
	                            <dt class="inline left rightMargin">[% "Titulo: " | i18n %]</dt>
	                            <dd>[% sancion.nivel3.nivel1.getTitulo %]</dd>
	
	                            <dt class="inline left rightMargin">[% "Edicion: " | i18n %]</dt>
	                            <dd>		
	                            		[% IF sancion.nivel3.nivel2.getEdicion %] 
	                                                             [% sancion.nivel3.nivel2.getEdicion %]
	                                                           [% ELSE %]
	                                                             --
	                                                           [% END %]
	                            </dd>
                            </dl>
                            <hr  class="clear-contentunit">
                        </li>      
                    
                [% END %]
	</div>
		<a href="#" class="btn btn-primary">[% "Ver sanciones" | i18n %]</a>
</div>
                