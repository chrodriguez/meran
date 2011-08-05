
          <div class="main-subcontent" style="width:100%; float:left">
                <div style="width:100%;">
                    <h1 class="orange">[% "Informaci&oacute;n de disponibilidad" | i18n %]</h1>
                    <div  style="width:95%;">
                        <ul>
                            <li>
                                [% "Disponibilidad Actual Para Pr&eacute;stamo:" | i18n %] <b>[% cantParaPrestamo %]</b>
                            </li>
                            <li>
                                [% "Disponibilidad Actual Para Sala de Lectura:" | i18n %] <b>[% cantParaSala %]</b>
                            </li>
                            <li>
                                [% "Cantidad Actual de Reservas:" | i18n %] <b>[% cantReservas %]</b>
                            </li>  
                            <li class="detalle_barra_circulacion">
                                  
                                [% IF CirculationEnabled %]
	                                [% IF socio_data %]
	                                    [% PERL %]
	                                        print C4::AR::Filtros::to_Icon(   text    => "[% 'Reservar' | i18n %]",
	                                                                            boton   => "icon_reservar",
	                                                                            width   => "100",
	                                                                            onClick => "reservar([% id1 %],[% id2 %])",
	                                                                            title   => "[% 'Reservar' | i18n %]"
	                                                                    );
	                                    [% END %]
	                                [% END %]
                                [% END %]
                            </li>
                        </ul>
                    </div>
                </div>
           </div>
          [% IF socio_data %]
              [% INCLUDE 'rating.inc' %]
          [% END %]
          <h3>
            [% PERL %]
                print C4::AR::Filtros::link_to( text    => "[% 'Revisiones' | i18n %] ([% cant_reviews %])",
                                                url     => "reviews.pl", 
                                                params  => ["id2=[% id2 %]"],
                                                title   => "[% 'Revisiones' | i18n %]"
                                            ) ;
            [% END %]
          </h3>

