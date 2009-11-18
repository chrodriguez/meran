      <div class="main-subcontent">
        <!-- Subcontent unit -->
        [% INCLUDE 'opac-reservas_info.inc' %]
        <!-- Subcontent unit -->
        [% INCLUDE 'opac-sanciones_info.inc' %]

        <!-- Subcontent unit -->
        <div class="subcontent-unit-border">
          <div class="round-border-topleft"></div><div class="round-border-topright"></div>
          <h1>[% 'Datos Personales' | i18n %]</h1>
          <h3>Heading h3</h3>

          <h3>Paragraph text</h3>
          <p>Lorem ipsum dolor sit amet, consectetur elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>

          <h3>Bulleted list</h3>
          <ul>
            <li><a href="#">Link 1</a></li>
            <li><a href="#">Link 2</a></li>
            <li>Fact 1</li>
            <li>Fact 2</li>                            
          </ul>

          <h3>Ordered list</h3>
          <ol>
            <li><a href="#">Link 1</a></li>
            <li><a href="#">Link 2</a></li>
            <li>Fact 1</li>
            <li>Fact 2</li>                           
          </ol>

          <h3>Text orientation</h3>
          <p>Text left.</p>
          <p class="center">Text center.</p>
          <p class="right">Text right.</p>

          <h3>Image<br />(text align left)</h3>
          <p><img src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" />Here is place for text.</p>
          <p class="center"><img class="center" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" /></p>
          <p><img class="right" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" />Here is place for text.</p>

          <h3>Image<br />(text align right)</h3>
          <p class="right"><img src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" />Here is place for text.</p>
          <p class="center"><img class="center" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" /></p>
          <p class="right"><img class="right" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" />Here is place for text.</p>

          <!-- Image Links -->
          <h3>Text link</h3>
          <p><a href="#">Here is a link.</a></p>

          <!-- Image Links -->
          <h3>Image link</h3>
          <p><a href="#"><img src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" /></a>Text as in image sections above.</p>
          <p class="center"><a href="#"><img class="center" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" /></a></p>
          <p><a href="#"><img class="right" src="[% temas %]/default/imagenes/image.jpg" width="50" alt="Image description" title="Image title" /></a>Text as in image sections above.</p>     
        </div>