<script type="text/javascript">
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>
          <div class="main-subcontent" style="width:15%; float:left; margin: 1%">
              [% IF portada_registro %]
                  <a class="fancylink" href="/covers/[% portada_registro_big %]">
                      <img src="/covers/[% portada_registro_medium %]" title="Portada" alt="[% 'Portada del ejemplar' | i18n %]" />
                  </a>
              [% ELSE %]
                    <img src="/covers/no_image_medium.jpg" alt="[% 'Sin Portada' | i18n %]" title="[% 'Sin Portada' | i18n %]" />
              [% END %]
          </div>
          <div class="main-subcontent" style="width:80%; float:left">
                <div class="subcontent-unit-border-orange" style="width:100%;">
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
                            </li>
                        </ul>
                    </div>
                </div>
           </div>
          [% IF socio_data %]
              [% INCLUDE 'rating.inc' %]
          [% END %]
          <h3>
              <a href="/cgi-bin/koha/reviews.pl?token=[% token %]&amp;id2=[% id2 %]">
                  [% 'Revisiones' | i18n %] ([% cant_reviews %])
              </a>
          </h3>

