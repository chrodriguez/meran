        <div class="subcontent-unit-border-green">
          <div class="round-border-topleft"></div><div class="round-border-topright"></div>
          <h1 class="green">[% 'Reservas Actuales' | i18n %]</h1>
          [% PERL %]
              print C4::AR::Filtros::link_to( text    =>  "&nbsp;[% 'Reservas asignadas' | i18n %]:",
                                              url     =>  "/cgi-bin/koha/opac-info_reservas.pl",
                                              params => ["action=detalle_asignadas"],
                                              title   =>  "[% 'Reservas asignadas' | i18n %]",
                      ) ;
          [% END %]
          &nbsp;[% reservas_asignadas_count %]<br />
          [% PERL %]
              print C4::AR::Filtros::link_to( text    =>  "&nbsp;[% 'Reservas en espera' | i18n %]:",
                                              url     =>  "/cgi-bin/koha/opac-info_reservas.pl",
                                              params => ["action=detalle_espera"],
                                              title   =>  "[% 'Reservas en espera' | i18n %]",
                      ) ;
          [% END %]
          &nbsp;[% reservas_espera_count %]<br />
          [% PERL %]
              print C4::AR::Filtros::link_to( text    =>  "&nbsp;[% 'Pr&eacute;stamos vigentes' | i18n %]:",
                                              url     =>  "/cgi-bin/koha/opac-prestamos_vigentes.pl",
                                              title   =>  "[% 'Pr&eacute;stamos vigentes' | i18n %]",
                      ) ;
          [% END %]
          &nbsp;[% prestamos_count %]<br />

      </div>