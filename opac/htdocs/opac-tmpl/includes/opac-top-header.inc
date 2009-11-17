    <!-- A. HEADER -->      
    <div class="header">
      <!-- A.1 HEADER TOP -->
      <div class="header-top">
        <!-- Sitelogo and sitename -->
        <a class="sitelogo" href="#" title="Go to Start page"></a>
        <div class="sitename">
          <h1><a href="index.html" title="Go to Start page">MULTIFLEX&bull;3<span style="font-weight:normal;font-size:50%;">&nbsp;update-2</span></a></h1>
          <h2>Open Source Template</h2>
        </div>
    [% INCLUDE 'opac-header-nav.inc' %]
    <!-- B. MAIN -->
    <div class="main">

      [% INCLUDE 'opac-navlink.inc' %]
      [% INCLUDE 'opac-login.inc' %]
      <h1>Search</h1>
        [% INCLUDE 'opac-search_form.inc' %]
        <h1>Heading h1</h1>
        <h2>Heading h2</h2>
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
 
      <!-- B.1 MAIN CONTENT -->