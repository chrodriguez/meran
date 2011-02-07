<script type="text/javascript" src="/intranet-tmpl/includes/busquedasCatalogo-min.js"> </script>
<script type="text/javascript" src="/intranet-tmpl/includes/busquedasUsuarios-min.js"></script>

<script language="javascript" type="text/javascript"> 

	$(document).ready(function() {
	
	  onEnter('keyword-bar',buscarBar,true);
	  onEnter('socio-bar',consultarBar);
	  $('#keyword-bar').focus();
	  
	});

</script>

<br /> <br /> <!-- PARA CENTRAR -->

<div id ="search-bar">
	<div id="search-bar-catalogue" class="classform">
	    <h5>[% 'B&uacute;squeda en el cat&aacute;logo' | i18n %]</h5>
	    <ul> 
		    <li class="item-bar"  >
		        <input type="text" id="keyword-bar" size="20" tabindex=1
		              title="[% 'Ingrese parte del autor, ISBN o parte del titulo' | i18n%]"
		              style="width:80%;"
		              onfocus="searchBoxFocus(this)"
		              onblur="searchesText('keyword-bar')"
		              >

		    </li>
		    <li class="item-bar" style="text-align: center;">
		        [% PERL %]
		                print C4::AR::Filtros::link_to( text    =>  "[% 'B&uacute;squeda avanzada' | i18n %]",
		                                                url     =>  "/cgi-bin/koha/busquedas/filtrado.pl",
		                                                title   =>  "[% 'B&uacute;squeda avanzada' | i18n %]"
		                        ) ;
		        [% END %]
		    </li>
		</ul>
	</div>
	<div id="search-bar-users" class="classform">
	   <h5>[% 'B&uacute;squeda de usuarios' | i18n %]</h5>
	   <ul>
        <li class="item-bar" >
            <input  id="socio-bar" type=text name="socio-bar"  
                    value="" size="20" tabindex="2" 
                    title="[% 'Ingrese parte del nombre, apellido; o DNI - Nro. de socio' | i18n%]"
                    style="width:80%;"
                    onfocus="searchBoxFocus(this)"
                    onblur="searchesText('socio-bar')"
                    >
        </li>
      </ul>
	</div>
</div>