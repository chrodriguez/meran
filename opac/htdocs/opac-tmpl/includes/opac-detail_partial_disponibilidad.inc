<script>
    $(document).ready(function() {
        $('.fancylink').fancybox();
    });
</script>
          <div class="main-subcontent" style="width:25%; float:left; margin: 5px">
              [% IF portada_registro %]
                  <a class="fancylink" href="/covers/[% portada_registro_big %]">
                      <img name="cover"  VALUE="" BORDER=0 src="/covers/[% portada_registro_medium %]" title="Portada">
                  </a>
              [% ELSE %]
                    <img src="/covers/no_image.jpg" 
                          alt="[% 'Sin Portada' | i18n %]"
                          title="[% 'Sin Portada' | i18n %]" />
              [% END %]
          </div>
          <div class="main-subcontent" style="width:70%; float:left">
                <div class="subcontent-unit-border-orange" style="width:100%;">
                    <h1 class="orange">[% "Informaci&oacute;n de disponibilidad" | i18n %]</h1>
                    <table  style="width:95%;">
                        <tr>
                            <td class="impar" >
                                <br>
                                [% "Disponibilidad Actual Para Pr&eacute;stamo:" | i18n %] <b>[% cantParaPrestamo %]</b><br>
                                [% "Disponibilidad Actual Para Sala de Lectura:" | i18n %] <b>[% cantParaSala %]</b><br>
                                [% "Cantidad Actual de Reservas:" | i18n %] <b>[% cantReservas %]</b><br>

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
                            </td>
                        </tr>
                    </table>
                </div>
           </div>
          [% INCLUDE 'rating.inc' %]

