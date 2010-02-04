    [% IF socio %]
      <div class="main-subcontent">
        <!-- Subcontent unit -->
        <div id="info_reservas"></div>
        <!-- Subcontent unit -->
        <div id="info_sanciones"></div>
            <!-- Subcontent unit -->
            <div class="subcontent-unit-border">
              <div class="round-border-topleft"></div><div class="round-border-topright"></div>
              <h1>[% 'Datos Personales' | i18n %]</h1>

              <p>
                [% IF socio_data.tieneFoto %]
                    <img width="50" height="50" src="/pictures/[% socio_data.tieneFoto %]"
                        alt="[% socio_data.persona.getNombre %], [% socio_data.persona.getApellido %]"/>
                [% ELSE %]
                      <img  width="50" height="50" src="[% temas %]/default/imagenes/no_foto.jpg" 
                            alt="[% 'Usuario sin foto' | i18n %]"
                            title="[% 'Usuario sin foto' | i18n %]" />
                [% END %]
                    Alguna idea para este texto?
              </p>

              <h3>[% 'Apellido y Nombre' | i18n %]</h3>
              <p>[% socio.persona.getApellido %], [% socio.persona.getNombre %]</p>

              <h3>[% 'Tipo y Nro. de Documento' | i18n %]</h3>
              <p>[% socio.persona.documento.getNombre %]: [% socio.persona.getNro_documento %]</p>

              <h3>[% 'Nro. de Socio' | i18n %]</h3>
              <p>[% socio.getNro_socio %]</p>

              <h3>[% 'Direcci&oacute;n' | i18n %]</h3>
              <p>[% socio.persona.getCalle %], [% socio.persona.ciudad_ref.NOMBRE %]</p>

              <h3>[% 'Categor&iacute;a' | i18n %]</h3>
              <p>[% socio.categoria.getDescription %]</p>


              <h3>[% 'Problemas con sus datos' |  i18n %]</h3>
              <p class="right">[% 'Si alguno de sus datos es incorrecto, s&iacute;rvase a corregirlos. Gracias' | i18n %]</p>
              <ul>
                <li>
                    [% PERL %]
                            print C4::AR::Filtros::link_to( text    =>  "[% 'Modificar mis datos' | i18n %]",
                                                            url     =>  "/cgi-bin/koha/modificarDatos.pl",
                                                            title   =>  "[% 'Modificar mis datos' | i18n %]",
                                    ) ;
                    [% END %]
                </li>
              </ul>
            </div>
    [% END %]
        