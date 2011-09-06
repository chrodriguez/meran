          <div class="main-subcontent" style="width:100%; float:left">
                <div style="width:100%;">
                    <h1 class="orange">[% "Informaci&oacute;n de disponibilidad" | i18n %]</h1>
                            <li class="detalle_barra_circulacion" style="float:left; margin-left: 40px;">
                                [% IF CirculationEnabled %]
                                    [% IF socio_data.usr_nro_socio %]
                                        <br />
                                        <br />                                  
                                        [% PERL %]
                                            print C4::AR::Filtros::to_Icon(   text    => "[% 'Reservar' | i18n %]",
                                                                                boton   => "icon_reservar",
                                                                                width   => "100px",
                                                                                onClick => "reservar([% id1 %],[% id2 %])",
                                                                                title   => "[% 'Reservar' | i18n %]",
                                                                        );
                                        [% END %]
                                    [% END %]
                                [% END %]
                            </li>

                    <div class="detalle_total">
                        <ul>
                            <li>
                                [% "Disponibilidad Actual Para Pr&eacute;stamo:" | i18n %] <b>[% cantParaPrestamoActual %]</b>
                            </li>
                            <li>
                                [% "Disponibilidad Actual Para Sala de Lectura:" | i18n %] <b>[% cantParaSalaActual %]</b>
                            </li>
                            <li>
                                [% "Cantidad Actual de Reservas:" | i18n %] <b>[% cantReservas %]</b>
                            </li>  
                            <li>
                                [% "Cantidad Actual de Pr&eacute;stamos:" | i18n %] <b>[% cantPrestados %]</b>
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

