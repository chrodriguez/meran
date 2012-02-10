[% INCLUDE "header.inc" %]
<div class="navbar navbar-fixed-top">
    <div class="navbar-inner">
      <div class="container" style="width: auto;">
        <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </a>
        
        <div id="logo"><a href="[% url_prefix %]/mainpage.pl?token=[% token %]">[% 'MERAN' | i18n %]</a></div>
        <div class="nav-collapse">
          <ul class="nav">
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Cat&aacute;logo' | i18n %] <b class="caret"></b></a>
              <ul class="dropdown-menu">
	              <li>
	                  [% PERL %]
	                  print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda avanzada' | i18n %]",
	              									  url =>      "[% url_prefix %]/busquedas/filtrado.pl",
	                                                  title =>    "[% 'B&uacute;squeda avanzada' | i18n %]"
	                                                );
	                  [% END %]
	              </li>
				  <li>
					[% PERL %]
	                print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda Z3950' | i18n %]",
	                                                url =>      "[% url_prefix %]/z3950/filtradoZ3950.pl",
	                                                title =>    "[% 'B&uacute;squeda Z3950' | i18n %]"
												  ) ;
	                [% END %]
	              </li>
	              <li class="divider"></li>
	
	                               <li>
	                                   [% PERL %]
	                                       print C4::AR::Filtros::link_to( text =>     "[% 'Agregar documento' | i18n %]",
	                                                                       url =>      "[% url_prefix %]/catalogacion/estructura/datosDocumento.pl",
	                                                                       title =>    "[% 'Agregar documento' | i18n %]"
	                                                                   ) ;
	                                   [% END %]
	                               </li>
	                               <li>
	                                   [% PERL %]
	                                       print C4::AR::Filtros::link_to( text =>     "[% 'Estante virtual' | i18n %]",
	                                                                       url =>      "[% url_prefix %]/estantes/estante.pl",
	                                                                       title =>    "[% 'Estante virtual' | i18n %]"
	                                                                   ) ;
	                                   [% END %]
	                               </li>
	
		            <li class="divider"></li>
		                               <li>
		                                   [% PERL %]
		                                       print C4::AR::Filtros::link_to( text =>     "[% 'Adquisiciones' | i18n %]",
		                                                                       url =>      "[% url_prefix %]/catalogacion/adquisiciones.pl",
		                                                                       title =>    "[% 'Adquisiciones' | i18n %]"
		                                                                   ) ;
		                                   [% END %]
		                               </li>
					<li class="divider"></li>
	      [% IF socio_data.usr_credential_type == "superLibrarian" %]
					
                             <li>
                             [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Preferencias' | i18n %]",
                                                                url =>      "[% url_prefix %]/admin/global/catalogo_config.pl",
                                                                title =>    "[% 'Preferencias' | i18n %]"
                                                            ) ;
                             [% END %]
                             </li>
                             <li>
                             [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Generaci&oacute;n de Barcodes' | i18n %]",
                                                                url =>      "[% url_prefix %]/admin/catalogo/barcode_gen_setup.pl",
                                                                title =>    "[% 'Preferencias' | i18n %]"
                                                            ) ;
                             [% END %]
                             </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Creaci&oacute;n cat&aacute;logo' | i18n %]",
                                                                      url =>      "[% url_prefix %]/catalogacion/estructura/estructuraCatalo.pl",
                                                                      title =>    "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Visualizaci&oacute;n del OPAC' | i18n %]",
                                                                      url =>      "[% url_prefix %]/catalogacion/visualizacionOPAC/visualizacionOpac.pl",
                                                                      title =>    "[% 'Visualizaci&oacute;n del OPAC' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Visualizaci&oacute;n de INTRANET' | i18n %]",
                                                                      url =>      "[% url_prefix %]/catalogacion/visualizacionINTRA/visualizacionIntra.pl",
                                                                      title =>    "[% 'Visualizaci&oacute;n del INTRANET' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Visibilidad Campos TR' | i18n %]",
                                                                              url =>      "[% url_prefix %]/catalogacion/tablasReferencia/tablasReferencia.pl",
                                                                              title =>    "[% 'Visibilidad Campos TR' | i18n %]"
                                                                          ) ;
                                          [% END %]
                              </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-ok'></i> [% 'Control de autoridades' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/referencias/referencias.pl",
                                                                                title =>    "[% 'Control de autoridades' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
           [% END %]
	      [% IF socio_data.usr_credential_type == "superLibrarian" %]
						<li class="divider"></li>	
									
										<li>
                                           [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-download-alt'></i> [% 'Nueva Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/subirNuevaImportacion.pl",
                                                                                      title =>    "[% 'Nueva Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-download-alt'></i> [% 'Importaciones' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/importar.pl",
                                                                                      title =>    "[% 'Importaciones' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "<i class='icon-download-alt'></i> [% 'Esquemas de Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/esquemas_importacion.pl",
                                                                                      title =>    "[% 'Esquemas de Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
	                                  <li>
	                                              [% PERL %]
	                                                  print C4::AR::Filtros::link_to( text =>     "<i class='icon-share'></i> [% 'Exportar' | i18n %]",
	                                                                                  url =>      "[% url_prefix %]/herramientas/exportacion/exportar.pl",
	                                                                                  title =>    "[% 'Exportaci&oacute;n' | i18n %]"
	                                                                              ) ;
	                                              [% END %]
	                                  </li>
                              
					
			[% END %]
              </ul>
            </li>

            <li class="dropdown">
	            <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Usuarios' | i18n %] <b class="caret"></b></a>
	            <ul class="dropdown-menu">
   	      [% IF socio_data.usr_credential_type == "librarian" OR  socio_data.usr_credential_type == "superLibrarian" %]
	            
	                    <li>
	                              [% PERL %]
	                                  print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios Reales' | i18n %]",
	                                                                  url =>      "[% url_prefix %]/usuarios/reales/buscarUsuario.pl",
	                                                                  title =>    "[% 'Usuarios Reales' | i18n %]"
	                                                              ) ;
	                              [% END %]
	                    </li>
	                    <li>
	                              [% PERL %]
	                                  print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios Potenciales' | i18n %]",
	                                                                  url =>      "[% url_prefix %]/usuarios/potenciales/buscarUsuario.pl",
	                                                                  title =>    "[% 'Usuarios Potenciales' | i18n %]"
	                                                              ) ;
	                              [% END %]
	                    </li>
	                    <li>
	                              [% PERL %]
	                                  print C4::AR::Filtros::link_to( text =>     "[% 'Agregar Usuarios' | i18n %]",
	                                                                  url =>      "[% url_prefix %]/usuarios/reales/agregarUsuario.pl",
	                                                                  title =>    "[% 'Agregar Usuarios' | i18n %]"
	                                                              ) ;
	                              [% END %]
	                    </li>
	      [% END %]
	      [% IF socio_data.usr_credential_type == "superLibrarian" %]
	                    
				<li class="divider"></li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Admin. libre Deuda' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/usuarios/adminLibreDeuda.pl",
                                                                                title =>    "[% 'Admin. libre Deuda' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
          [% END %]
				</ul>
		  </li>

            <li class="dropdown">
	            <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Circulaci&oacute;n' | i18n %] <b class="caret"></b></a>
	      [% IF socio_data.usr_credential_type == "librarian" OR  socio_data.usr_credential_type == "superLibrarian" %]
	            <ul class="dropdown-menu">
                    <li>
	                    [% IF (!menu_preferences.showMenuItem_circ_prestamos) AND (!menu_preferences.showMenuItem_circ_devolucion_renovacion) %]
	                              [% PERL %]
	                                  print C4::AR::Filtros::link_to( text =>     "[% 'Pr&eacute;st., Devol., y Renov.' | i18n %]",
	                                                                  url =>      "[% url_prefix %]/circ/circulacionRapida.pl",
	                                                                  title =>    "[% 'Circulaci&oacute;n R&aacute;pida' | i18n %]"
	                                                              ) ;
	                              [% END %]
	                    [% ELSE %]
	                            [% PERL %]
	                                  print C4::AR::Filtros::link_to( text =>     "[% 'Pr&eacute;st., Devol., y Renov.' | i18n %]",
	                                                                  url =>      "[% url_prefix %]/circ/circulacionRapida.pl",
	                                                                  title =>    "[% 'Pr&eacute;stamos, Devoluciones y Renovaciones' | i18n %]"
	                                                              ) ;
	                              [% END %]
	
	                    [% END %]
                    </li>
                    [% IF menu_preferences.showMenuItem_circ_prestamos %]
                                <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "[% 'Pr&eacute;stamos' | i18n %]",
                                                                              url =>      "[% url_prefix %]/circ/prestamos.pl",
                                                                              title =>    "[% 'Pr&eacute;stamos' | i18n %]"
                                                                          ) ;
                                          [% END %]
                                </li>
                    [% END %]
                    [% IF menu_preferences.showMenuItem_circ_devolucion_renovacion %]
                                <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "[% 'Devol. y Renov.' | i18n %]",
                                                                              url =>      "[% url_prefix %]/circ/devoluciones.pl",
                                                                              title =>    "[% 'Devol. y Renov.' | i18n %]"
                                                                          ) ;
                                          [% END %]
                                </li>
                    [% END %]
                    <li>
                              [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% 'Sanciones' | i18n %]",
                                                                  url =>      "[% url_prefix %]/circ/sanciones.pl",
                                                                  title =>    "[% 'Sanciones' | i18n %]"
                                                              ) ;
                              [% END %]
                    </li>
                    <li>
                              [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% 'Reservas' | i18n %]",
                                                                  url =>      "[% url_prefix %]/circ/reservas_activas.pl",
                                                                  title =>    "[% 'Reservas' | i18n %]"
                                                              ) ;
                              [% END %]
                    </li>
                [% IF socio_data.usr_credential_type == "superLibrarian" %]
                    
                    <li class="divider"></li>

                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text  => "<i class='icon-cog'></i> [% 'Preferencias' | i18n %]",
                                                                                url   => "[% url_prefix %]/admin/global/circ_config.pl",
                                                                                title => "[% 'Preferencias' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Sanciones' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/circulacion/sanciones.pl",
                                                                                title =>    "[% 'Sanciones' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Tipos de pr&eacute;stamo' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/circulacion/tipos_de_prestamos.pl",
                                                                                title =>    "[% 'Tipos de pr&eacute;stamo' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-exclamation-sign'></i> [% 'Pr&eacute;stamos Vencidos' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/circulacion/prestamos_vencidos.pl",
                                                                                title =>    "[% 'Pr&eacute;stamos Vencidos' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
              [% END %]

                    <li class="divider"></li>
<!--                     CONSULTAS -->
				</ul>
      [% END %]

		  </li>
      </ul>
          <form class="navbar-search pull-left" action="" onsubmit="return false;">
          
		    <input type="text" id="keyword-bar" class="search-query span2" name="keyword-bar" placeholder='[% "Cat&aacute;logo" | i18n %]'>

		    <input type="text" id="socio-bar" class="search-query span2" name="socio-bar" placeholder='[% "Usuarios" | i18n %]' onkeypress="socioSearchEvent(event)">
            
          </form>
          <ul class="nav pull-right">
            <li class="divider-vertical"></li>
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">
	              [% socio_data.usr_nro_socio %]
				  <b class="caret"></b>
			  </a>
              <ul class="dropdown-menu">
                <li>
                	<a href="[% url_prefix %]/usuarios/reales/settings.pl?token=[% token %]&amp;nro_socio=[% socio_data.usr_nro_socio %]">
                		<i class="icon-cog"></i> [% "Ajustes" | i18n %]
                	</a>
                </li>
                <li class="divider"></li>
                <li><a href="[% url_prefix %]/logout.pl?token=[% token %]"><i class="icon-off"></i> [% "Salir" | i18n %]</a></li>
              </ul>
            </li>
          </ul>
      [% IF socio_data.usr_credential_type == "superLibrarian" %]
          <ul class="nav">
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">[% 'Administraci&oacute;n' | i18n %] <b class="caret"></b></a>
              <ul class="dropdown-menu">
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Preferencias' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/preferencias.pl",
                                                                                title =>    "[% 'Preferencias' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-lock'></i> [% 'M&eacute;todos de Autenticaci&oacute;n' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/auth_methods.pl",
                                                                                title =>    "[% 'Configuraci&oacute;n del Mail' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-envelope'></i> [% 'Configuraci&oacute;n del Mail' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/mail_config.pl",
                                                                                title =>    "[% 'Configuraci&oacute;n del Mail' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                                            <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Configuraci&oacute;n LDAP' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/ldap_config.pl",
                                                                                title =>    "[% 'Configuraci&oacute;n LDAP' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                </li>
                                                            <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'Configuraci&oacute;n de Estilos' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/estilos_config.pl",
                                                                                title =>    "[% 'Configuraci&oacute;n de Estilos' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "<i class='icon-flag'></i> [% 'Feriados' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/feriados.pl",
                                                                                title =>    "[% 'Feriados' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "<i class='icon-info-sign'></i> [% 'Novedades de INTRA' | i18n %]",
                                                                              url =>      "[% url_prefix %]/admin/global/novedades_intra.pl",
                                                                              title =>    "[% 'Novedades de INTRA' | i18n %]"
                                                                          ) ;
                                          [% END %]
                                </li>
                                <li>
                                             [% PERL %]
                                                 print C4::AR::Filtros::link_to( text =>     "<i class='icon-info-sign'></i> [% 'Acerca De...' | i18n %]",
                                                                                 url =>      "[% url_prefix %]/about/about.pl",
                                                                                 title =>    "[% 'Acerca De...' | i18n %]"
                                                                             ) ;
                                             [% END %]
                                </li>
	              <li class="divider"></li>
                                <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'OPAC - Novedades' | i18n %]",
                                                                              url =>      "[% url_prefix %]/admin/novedades_opac.pl",
                                                                              title =>    "[% 'Novedades de OPAC' | i18n %]"
                                                                          ) ;
                                          [% END %]
                                </li>
                                <li>
                                        [% PERL %]
                                            print C4::AR::Filtros::link_to( text =>     "<i class='icon-cog'></i> [% 'OPAC - Mensajes de Contacto' | i18n %]",
                                                                            url =>      "[% url_prefix %]/admin/mensajes_contacto.pl",
                                                                            title =>    "[% 'Mensajes de Contacto' | i18n %]"
                                                                        ) ;
                                        [% END %]
                                </li>
          </ul>
      [% END %]
          
        </div><!-- /.nav-collapse -->
      </div>
    </div><!-- /navbar-inner -->
  </div>

