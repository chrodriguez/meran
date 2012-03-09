<div class="alert alert-success">
		<blockquote>
			[% IF cantParaPrestamoActual && cantParaSalaActual%]
	        	<p>[% "Se cuenta con disponibilidad para llevar a domicilio o leer en la sala de lectura" | i18n %].</p>
			[% ELSE %]
				[% IF cantParaPrestamoActual %]
		        	<p>[% "Se cuenta con disponibilidad inmediata para llevar a domicilio" | i18n %].</p>
		        [% ELSE %]
					[% IF cantParaSalaActual %]
			        	<p>[% "Se cuenta con disponibilidad solamente para leer en la sala de lectura" | i18n %].</p>
					[% ELSE %]
						<p>[% "No existe ning&uacute;n ejemplar disponible" | i18n %].</p>
					[% END %]
				[% END %]
			[% END %]
			[% IF cantReservas && cantPrestados %]
	        	<small>[% "Tener en cuenta que existen " | i18n %] [% cantReservas%] 
        		<cite title=""> [% " y " | i18n %] [% cantPrestados %] [% "prestados" | i18n %]</cite>
	        	</small>
	        [% ELSE %]
				[% IF cantReservas %]
		        	<small>[% "Tener en cuenta que existen " | i18n %] [% cantReservas%] [% "reservas " | i18n %]
		        	</small>
		        [% ELSE %]
					[% IF cantPrestados %]
			        	<small>[% "Tener en cuenta que existen " | i18n %] [% cantPrestados%] [% "prestados" | i18n %]
			        	</small>
			        [% END %]
				[% END%]
			[% END %]	        
      	</blockquote>
			
           [% IF CirculationEnabled %]
                                   [% IF socio_data.usr_nro_socio %]                             
                                        [% PERL %]
                                            print C4::AR::Filtros::action_button(   
                                                                                button   => "btn btn-primary",
                                                                                icon   => "icon-white icon-shopping-cart",
                                                                                title   => "[% 'Reservar un ejemplar' | i18n %]",
                                                                                 action => 'showReservar("modal_reservar_[% id2 %]");',
                                                                                [% IF cantParaPrestamoActual == 0 %]
                                                                                	disabled => 1,
                                                                                      popover		=> {title=>'[% "Disponibilidad" | i18n %]',
                                                                                      					text => '[% "No hay disponibilidad para domicilio sobre esta edici&oacute;n, su reserva quedar&aacute; en espera" | i18n %].' },
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
                                                title   => " [% 'Comentarios' | i18n %] ([% cant_reviews %])",
                                                icon	=> "icon-white icon-comment",
                                            ) ;
            [% END %]
          </h3>

