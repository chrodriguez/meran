<div class="alert alert-success">
			<dl>
                            <dt class="inline left rightMargin">[% "Disponibilidad Actual Para Pr&eacute;stamo:" | i18n %]</dt>
                            <dd>[% cantParaPrestamoActual %]</dd>

                            <dt class="inline left rightMargin">[% "Disponibilidad Actual Para Sala de Lectura:" | i18n %]</dt>
                            <dd>[% cantParaSalaActual %]</dd>

                            <dt class="inline left rightMargin">[% "Cantidad Actual de Reservas:" | i18n %]</dt>  
                            <dd>[% cantReservas %]</dd>

                            <dt class="inline left rightMargin">[% "Cantidad Actual de Pr&eacute;stamos:" | i18n %]</dt>  
                            <dd>[% cantPrestados %]</dd>
			</dl>
		           [% IF CirculationEnabled %]
		                                   [% IF socio_data.usr_nro_socio %]                             
		                                        [% PERL %]
		                                            print C4::AR::Filtros::action_button(   
		                                                                                button   => "btn btn-primary",
		                                                                                icon   => "icon-white icon-shopping-cart",
		                                                                                title   => "[% 'Reservar un ejemplar' | i18n %]",
		                                                                                [% IF cantParaPrestamoActual == 0 %]
		                                                                                	disabled => 1,
		                                                                                      popover		=> {title=>'[% "No se puede reservar" | i18n %]',
		                                                                                      					text => '[% "No hay disponibilidad para domicilio sobre esta edici&oacute;n" | i18n %].' },
																						[% ELSE %]
			                                                                                action => "showReservar();",
		                                                                                [% END %]
		                                                                        );
		                                        [% END %]
		                                   [% END %]
		           [% END %]



</div>

          [% IF socio_data %]
              [% INCLUDE 'rating.inc' %]
          [% END %]
          <h3>
            [% PERL %]
                print C4::AR::Filtros::action_link_button(
                                                url     => "reviews.pl", 
                                                button	=> "btn btn-info",
                                                params  => ["id2=[% id2 %]"],
                                                title   => " [% 'Comentarios de la edici&oacute;n' | i18n %] ([% cant_reviews %])",
                                                icon	=> "icon-white icon-pencil",
                                            ) ;
            [% END %]
          </h3>

