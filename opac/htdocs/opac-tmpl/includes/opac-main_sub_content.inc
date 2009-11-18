      <div class="main-subcontent">
        <!-- Subcontent unit -->
        [% INCLUDE 'opac-reservas_info.inc' %]
        <!-- Subcontent unit -->
        [% INCLUDE 'opac-sanciones_info.inc' %]

        <!-- Subcontent unit -->
        <div class="subcontent-unit-border">
          <div class="round-border-topleft"></div><div class="round-border-topright"></div>
          <h1>[% 'Datos Personales' | i18n %]</h1>

          <p>
            <img src="[% temas %]/default/imagenes/image.jpg" width="50" alt="[% 'Socio' %]" title="[% 'Imagen del socio' %]" />
                Alguna idea para este texto?
          </p>

          <h3>[% 'Apellido y Nombre' | i18n %]</h3>
          <p>Lamas, Lorenzo</p>

          <h3>[% 'Tipo y Nro. de Documento' | i18n %]</h3>
          <p>DNI: 10.111.111</p>

          <h3>[% 'Nro. de Socio' | i18n %]</h3>
          <p>26320</p>

          <h3>[% 'Direcci&oacute;n' | i18n %]</h3>
          <p>Calle null y 23, Nro. 1234 Dpto. 43 "Z"</p>

          <h3>[% 'Categor&iacute;a' | i18n %]</h3>
          <p>Estudiante</p>


          <h3>[% 'Problemas con sus datos' |  i18n %]</h3>
          <p class="right">[% 'Si alguno de sus datos es incorrecto, s&iacute;rvase a corregirlos. Gracias' | i18n %]</p>
          <ul>
            <li><a href="#">[% 'Modificar mis datos' | i18n %]</a></li>
          </ul>
        </div>