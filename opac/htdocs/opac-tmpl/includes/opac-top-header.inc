<div class="navbar navbar-fixed-top">
    <div class="navbar-inner">
      <div class="container" style="width: auto;">
        <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </a>
		[% PERL %]
                   print C4::AR::Filtros::link_to( text    =>  "[% 'MERAN' | i18n %]",
                                                    url     =>  '[% url_prefix %]/opac-main.pl',
                                                    title   =>  "[% 'Inicio' | i18n %]",
                                                    class	=> "brand",
                            ) ;
		[% END %]
        <div class="nav-collapse">
          <ul class="nav">
	            <li class="dropdown">
	              <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Cat&aacute;logo' | i18n %] <b class="caret"></b></a>
	              <ul class="dropdown-menu">
			            <li>
			                [% PERL %]
			                    print C4::AR::Filtros::link_to( text    =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
			                                                    url     =>  '[% url_prefix %]/opac-advanced_search.pl',
			                                                    title   =>  "[% 'B&uacute;squeda Avanzada' | i18n %]",
			                            ) ;
			                [% END %]
			            </li>
			            <li>
			                [% PERL %]
			                    print C4::AR::Filtros::link_to( text    =>  "[% 'Estantes Virtuales' | i18n %]",
			                                                    url     =>  '[% url_prefix %]/opac-estante.pl',
			                                                    title   =>  "[% 'Estantes Virtuales' | i18n %]",
			                            ) ;
			                [% END %]
			            </li>   
		            </ul>
	            </li>  
	            [% IF socio_data.usr_nro_socio %]
		            <li class="dropdown">
		              <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Mi cuenta' | i18n %] <b class="caret"></b></a>
		              <ul class="dropdown-menu">
		                  <li>
		                      <a href='[% url_prefix %]/opac-prestamos_vigentes.pl?token=[% token %]'>
		                          [% 'Pr&eacute;stamos vigentes' | i18n %]
		                      </a>
		                  </li>
		                  <li>
		                      <a href='[% url_prefix %]/opac-historial_prestamos.pl?token=[% token %]'>
		                          [% 'Historial de pr&eacute;stamos' | i18n %]
		                      </a>
		                  </li>
		                  <li>
		                      <a href='[% url_prefix %]/opac-historial_reservas.pl?token=[% token %]'>
		                          [% 'Historial de reservas' | i18n %]
		                      </a>
		                  </li>
		                  <li>
		                      [% PERL %]
		                          print C4::AR::Filtros::link_to( text    =>  "[% 'Recomendaciones' | i18n %]",
		                                                          url     =>  '[% url_prefix %]/opac-recomendaciones.pl',
		                                                          title   =>  "[% 'Recomendaciones' | i18n %]",
		                                  ) ;
		                      [% END %]
		                  </li>
			            <li class="divider"></li>
		                <li class="nav-header">[% 'Personal' | i18n %]</li>
		                <li>
		                    <a href='[% url_prefix %]/opac-favoritos.pl?token=[% token %]'>
		                    		[% 'Favoritos' | i18n %]
		                	</a>
						</li>	          
		         	</ul>
		          </li>     
	          [% END %]     
          </ul> 
          <form class="navbar-search pull-left" action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
              <input type="text" class="search-query span2" placeholder="[% 'Buscar' | i18n %]">
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
          </form>

          <ul class="nav pull-right">
            <li><a href="#">Link</a></li>
            <li class="divider-vertical"></li>
			[% IF socio_data.usr_nro_socio %]
	            <li class="dropdown">
		            <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% socio_data.usr_nombre %]&nbsp;[% socio_data.usr_apellido %]<b class="caret"></b></a>
		            <ul class="dropdown-menu">
		              <li><a href="#">Action</a></li>
		              <li><a href="#">Another action</a></li>
		              <li><a href="#">Something else here</a></li>
		              <li class="divider"></li>
		              <li><a href="#">Separated link</a></li>
		            </ul>
				</li>
            [% ELSE %]
            	<li class="active" ><a href="#">[% 'Iniciar sesi&oacute;n' | i18n %]</a></li>
            [% END %]
          </ul>
        </div><!-- /.nav-collapse -->
      </div>
    </div><!-- /navbar-inner -->
  </div>