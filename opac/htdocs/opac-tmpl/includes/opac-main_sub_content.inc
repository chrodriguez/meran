 [% IF socio_data.usr_nro_socio %]
      <div class="main-subcontent">
        <!-- Subcontent unit -->
        <div id="info_reservas"></div>
        <!-- Subcontent unit -->
        <div id="info_sanciones"></div>
            <!-- Subcontent unit -->
            <div class="subcontent-unit-border">
              <div class="round-border-topleft"></div>
              <div class="round-border-topright"></div>
              <h1>[% 'Datos Personales' | i18n %]</h1>

              <div>
                [% IF socio_data.usr_tiene_foto %]
                    <img width="50" height="50" src="/uploads/pictures/[% socio_data.usr_tiene_foto %]"
                        alt="[% socio_data.usr_apellido %], [% socio_data.usr_apellido %]"/>
                [% ELSE %]
                      <img  width="50" height="50" src="[% temas %]/default/imagenes/no_foto.jpg" 
                            alt="[% 'Usuario sin foto' | i18n %]"
                            title="[% 'Usuario sin foto' | i18n %]" />
                [% END %]
                    <span style="vertical-align: middle;">[% socio_data.usr_apellido %], [% socio_data.usr_nombre %]</span>
              </div>

              <h3>[% 'Tipo y Nro. de Documento' | i18n %]</h3>
              <p>[% socio_data.usr_documento_nombre %]: [% socio_data.usr_nro_documento %]</p>

              <h3>[% 'Tarjeta de Id.' | i18n %]</h3>
              <p>[% socio_data.usr_nro_socio %]</p>

              <h3>[% 'Direcci&oacute;n' | i18n %]</h3>
              <p>[% socio_data.usr_calle %], [% socio_data.usr_ciudad_nombre %]</p>

              <h3>[% 'E-mail' | i18n %]</h3>
              <p>[% socio_data.usr_email %]</p>

              <h3>[% 'Categor&iacute;a' | i18n %]</h3>
              <p>[% socio_data.usr_categoria_desc %]</p>


              <h3>[% 'Problemas con sus datos' |  i18n %]</h3>
              <p class="right">[% 'Si alguno de sus datos es incorrecto, s&iacute;rvase a corregirlos. Gracias' | i18n %]</p>
              <ul>
                <li>
                    [% PERL %]
                            print C4::AR::Filtros::link_to( text    =>  "[% 'Modificar mis datos' | i18n %]",
                                                            url     =>  "[% url_prefix %]/modificarDatos.pl",
                                                            title   =>  "[% 'Modificar mis datos' | i18n %]",
                                    ) ;
                    [% END %]
                </li>
              </ul>
          </div>
      </div>
    [% END %]
</div> <!--  <div class="main"> en opac-top-header.inc    -->

