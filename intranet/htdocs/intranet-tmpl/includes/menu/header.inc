<script type="text/javascript" src="/intranet-tmpl/includes/busquedasCatalogo-min.js"> </script>
<script type="text/javascript" src="/intranet-tmpl/includes/busquedasUsuarios-min.js"></script>

<script language="javascript" type="text/javascript"> 

    $(document).ready(function() {
    
      onEnter('keyword-bar',buscarBar,true);
      onEnter('socio-bar',consultarBar);
      
      
      $('[placeholder]').focus(function() {
    	  var input = $(this);
    	  if (input.val() == input.attr('placeholder')) {
    	    input.val('');
    	    input.removeClass('placeholder');
    	  }
    	}).blur(function() {
    	  var input = $(this);
    	  if (input.val() == '' || input.val() == input.attr('placeholder')) {
    	    input.addClass('placeholder');
    	    input.val(input.attr('placeholder'));
    	  }
    	}).blur().parents('form').submit(function() {
    	  $(this).find('[placeholder]').each(function() {
    	    var input = $(this);
    	    if (input.val() == input.attr('placeholder')) {
    	      input.val('');
    	    }
    	  })
    	});      
      
      
      
    });

</script>

<div id="top-stuff">
        <div style="clear:both;" id="banners">
          </div>
        <div id="top-bar-outer">
          <div id="top-bar-bg"></div>
          <div id="top-bar">
            <div class="top-bar-inside">
              <div class="static-links">
  <div id="logo">
    <a href="/cgi-bin/koha/mainpage.pl" title="[% 'Inicio' | i18n %]"></a>
  </div>


  <div class="search-form" >
    <span class="glass right" onclick="buscarBar();"><i></i></span>
    <input type="text" id="keyword-bar" class="search-query" name="keyword-bar" placeholder="Buscar en el cat&aacute;logo">
  </div>

  <div id="global-nav">
    <ul>
      <li id="global-nav-profile">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
    </ul>
  </div>


  <div class="search-form" >
    <span class="glass right" onclick="consultarBar();"><i></i></span>
    <input type="text" id="socio-bar" class="search-query" name="socio-bar" placeholder="Buscar usuarios" >
  </div>


  <div id="sections"></div>
</div>
<div class="active-links">
	  <div class="loggedin" id="session">
	      <a href="#" class="profile-links">
	        <span id="profile-image">
	            <a title="[% socio_data.usr_nombre %], [% socio_data.usr_apellido %]" rel="contact" class="url" 
	               href="/cgi-bin/koha/usuarios/reales/datosUsuario.pl?token=[% token %]&amp;nro_socio=[% socio_data.usr_nro_socio %]">
	               
			      [% IF socio_data.usr_tiene_foto %]
			          <img src="[% themelang %]/pictures/[% socio_data.usr_tiene_foto %]"  
			              alt="[% socio_data.usr_nombre %], [% socio_data.usr_apellido %]"/>
			      [% ELSE %]
			            <img  src="[% temas %]/[% tema %]/imagenes/no_foto.jpg" 
			                  alt="[% 'Usuario sin foto' | i18n %]"
			                  title="[% 'Usuario sin foto' | i18n %]" />
			      [% END %]
	            </a>
	        </span>
	      </a>
	      <span id="screen-name">
		      <a href="/cgi-bin/koha/usuarios/reales/datosUsuario.pl?token=[% token %]&amp;nro_socio=[% socio_data.usr_nro_socio %]"
		        style="color:#BABABA">
		        [% socio_data.usr_nro_socio %] ([% socio_data.usr_apellido %], [% socio_data.usr_nombre %])
		      </a>
		      </span>
	    </div>
	    <span class="vr"></span>

	  <div id="global-nav">
	    <ul>
	      <li id="global-nav-profile"><a href="/cgi-bin/koha/logout.pl?token=[% token %]">[% 'Salir' | i18n %]</a></li>
	    </ul>
	  </div>
  
</div>
            </div>
          </div>
          <div id="message-drawer"></div>
        </div>
      </div>