[% INCLUDE "header.inc" %]
<div class="menu_container" id="menu_container">
  <div id="menu" class="accordion">
         <h3 class="head"><a href="javascript:;">[% 'Cat&aacute;logo' | i18n %]</a></h3>
         <div id="seccion_catalogo">
	          <ul class="accordion">
	              <li>
	               <h4 class=""><a href="javascript:;">[% 'B&uacute;squedas' | i18n %]</a></h4>
	                   <ul>
	                    <li>
	                        [% PERL %]
	                            print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda avanzada' | i18n %]",
	                                                            url =>      "[% url_prefix %]/busquedas/filtrado.pl", 
	                                                            title =>    "[% 'B&uacute;squeda avanzada' | i18n %]"
	                                                        ) ;
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
	                  </ul>
	              </li>
	              
	              <li>
	               <h4 class=""><a href="javascript:;">[% 'Cat&aacute;logo' | i18n %]</a></h4>
	                <ul>
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
	                </ul>
	               </li>
	               
	               
	               <li>
	                <h4 class=""><a href="javascript:;">[% 'Adquisiciones' | i18n %]</a></h4>
	                <ul>
	                   <li>
	
	                       [% PERL %]
	                           print C4::AR::Filtros::link_to( text =>     "[% 'Listado de Proveedores' | i18n %]",
	                                                           url =>      "[% url_prefix %]/adquisiciones/listProveedores.pl", 
	                                                           title =>    "[% 'Listado de Proveedores' | i18n %]"
	                                                       ) ;
	                       [% END %]
	                   </li>
	                
	                   <li>
	                       [% PERL %]
	                           print C4::AR::Filtros::link_to( text =>     "[% 'Agregar Proveedor' | i18n %]",
	                                                           url =>      "[% url_prefix %]/adquisiciones/addProveedores.pl", 
	                                                           title =>    "[% 'Agregar Proveedores' | i18n %]"
	                                                       ) ;
	                       [% END %]
	                   </li>
	                   <li>
	
	                       [% PERL %]
	                           print C4::AR::Filtros::link_to( text =>     "[% 'Carga de presupuestos' | i18n %]",
	                                                           url =>      "[% url_prefix %]/adquisiciones/cargaPresupuesto.pl", 
	                                                           title =>    "[% 'Carga de presupuestos' | i18n %]"
	                                                       ) ;
	                       [% END %]
	                   </li>
                       <li>
    
                           [% PERL %]
                               print C4::AR::Filtros::link_to( text =>     "[% 'Comparar Presupuestos' | i18n %]",
                                                               url =>      "[% url_prefix %]/adquisiciones/compararPresupuestos.pl", 
                                                               title =>    "[% 'Comparar presupuestos' | i18n %]"
                                                           ) ;
                           [% END %]
                       </li>
	                   <li>
	
	                       [% PERL %]
	                           print C4::AR::Filtros::link_to( text =>     "[% 'Generar Pedido Cotizacion' | i18n %]",
	                                                           url =>      "[% url_prefix %]/adquisiciones/generatePedidoCotizacion.pl", 
	                                                           title =>    "[% 'Generar Pedido Cotizacion' | i18n %]"
	                                                       ) ;
	                       [% END %]
	                   </li>	       
	                   <li>
	
	                       [% PERL %]
	                           print C4::AR::Filtros::link_to( text =>     "[% 'Listado de Pedidos Cotizacion' | i18n %]",
	                                                           url =>      "[% url_prefix %]/adquisiciones/listPedidoCotizacion.pl", 
	                                                           title =>    "[% 'Listado de Pedidos Cotizacion' | i18n %]"
	                                                       ) ;
	                       [% END %]
	                   </li>	  	                               
	                </ul>
	             </li>
	                
	             <li>
	                 <h4 class=""><a href="javascript:;">[% 'Control de autoridades' | i18n %]</a></h4>
	                 <ul>
	                   <li>
	                                   [% PERL %]
	                                       print C4::AR::Filtros::link_to( text =>     "[% 'Sin&oacute;nimos' | i18n %]",
	                                                                       url =>      "[% url_prefix %]/catalogacion/configuracion/controlAutoridades/controlAutoridadesSinonimos.pl", 
	                                                                       title =>    "[% 'Sin&oacute;nimos' | i18n %]"
	                                                                   ) ;
	                                   [% END %]
	                               </li>
	                   <li>
	                                   [% PERL %]
	                                       print C4::AR::Filtros::link_to( text =>     "[% 'Seud&oacute;nimos' | i18n %]",
	                                                                       url =>      "[% url_prefix %]/catalogacion/configuracion/controlAutoridades/controlAutoridadesSeudonimos.pl", 
	                                                                       title =>    "[% 'Sued&oacute;nimos' | i18n %]"
	                                                                   ) ;
	                                   [% END %]
	                         </li>
	                 </ul>
	             </li>
	          </ul>
          </div> <!-- FIN CATALOGO -->

          <h3 class="head"><a href="javascript:;">[% 'Usuarios' | i18n %]</a></h3>
          <div id="seccion_usuarios">


              <ul>
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
              </ul>
          </div>
          
          
          <h3 class="head"><a href="javascript:;">[% 'Circulaci&oacute;n' | i18n %]</a></h3>
          <div id="seccion_circulacion">
	          <ul>
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
	                          print C4::AR::Filtros::link_to( text =>     "[% 'Circulaci&oacute;n R&aacute;pida' | i18n %]",
	                                                          url =>      "[% url_prefix %]/circ/circulacionRapida.pl", 
	                                                          title =>    "[% 'Circulaci&oacute;n R&aacute;pida' | i18n %]"
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
	          </ul>
	       </div>

          <h3 class="head"><a href="javascript:;">[% 'Consultas' | i18n %]</a></h3>
          <div id="seccion_consultas">
             <ul class="accordion">
                <li>
                    <h4 class="head"><a href="javascript:;">[% 'Usuarios' | i18n %]</a></h4>
	                 <ul>
			                 <li>
			                             [% PERL %]
			                                 print C4::AR::Filtros::link_to( text =>     "[% 'Generar Carnets' | i18n %]",
			                                                                 url =>      "[% url_prefix %]/reports/users-cards.pl", 
			                                                                 title =>    "[% 'Generar Carnets' | i18n %]"
			                                                             ) ;
			                             [% END %]
			                 </li>
			                 <li>
			                             [% PERL %]
			                                 print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios' | i18n %]",
			                                                                 url =>      "[% url_prefix %]/reports/usuarios.pl",
			                                                                 title =>    "[% 'Usuarios (PREGUNTALE A FER)' | i18n %]"
			                                                             ) ;
			                             [% END %]
			                 </li>
	
	                 </ul>
	            </li>
                <li>
	                <h4 class="head"><a href="javascript:;">[% 'Cat&aacute;logo' | i18n %]</a></h4>
	                <ul>
		              <li>
		                  [% PERL %]
		                      print C4::AR::Filtros::link_to( text =>     "[% 'Estantes virtuales' | i18n %]",
		                                                      url =>      "[% url_prefix %]/reports/estantes_virtuales.pl",
		                                                      title =>    "[% 'Busquedas desde OPAC' | i18n %]"
		                                                  ) ;
		                  [% END %]
		              </li>
		              <li>
		                  [% PERL %]
		                      print C4::AR::Filtros::link_to( text =>     "[% 'Busquedas desde OPAC' | i18n %]",
		                                                      url =>      "[% url_prefix %]/reports/busquedas_opac.pl",
		                                                      title =>    "[% 'Busquedas desde OPAC' | i18n %]"
		                                                  ) ;
		                  [% END %]
		              </li>
		              <li>
		                  [% PERL %]
		                      print C4::AR::Filtros::link_to( text =>     "[% 'Altas de Registro' | i18n %]",
		                                                      url =>      "[% url_prefix %]/reports/altas_registro.pl",
		                                                      title =>    "[% 'Altas de registro' | i18n %]"
		                                                  ) ;
		                  [% END %]
		              </li>
	                  <li>
	                          [% PERL %]
	                              print C4::AR::Filtros::link_to( text =>     "[% 'Inventario y Signatura' | i18n %]",
	                                                              url =>      "[% url_prefix %]/reports/inventory-sig-top.pl",
	                                                              title =>    "[% 'Inventario y Signatura' | i18n %]"
	                                                          ) ;
	                          [% END %]
	                  </li>
	                  <li>
	                          [% PERL %]
	                              print C4::AR::Filtros::link_to( text =>     "[% 'Registro de Actividades' | i18n %]",
	                                                              url =>      "[% url_prefix %]/reports/registro.pl",
	                                                              title =>    "[% 'Registro de Actividades' | i18n %]"
	                                                          ) ;
	                          [% END %]
	                  </li>
		           </ul>
		       </li>
            </ul>
       </div>
       
       <h3 class="head"><a href="javascript:;">[% 'Estad&iacute;sticas' | i18n %]</a></h3>
       <div id="seccion_estadisticas">      
	        <ul>
		          <li>
		              [% PERL %]
		                  print C4::AR::Filtros::link_to( text =>     "[% 'Colecciones' | i18n %]",
		                                                  url =>      "[% url_prefix %]/estadisticas/colecciones.pl",
		                                                  title =>    "[% 'Estad&iacute;sticas y graficos openFlashChart' | i18n %]"
		                                              ) ;
		              [% END %]
		          </li>
		          <li>
		              [% PERL %]
		                  print C4::AR::Filtros::link_to( text =>     "[% 'Estantes Virtuales' | i18n %]",
		                                                  url =>      "[% url_prefix %]/estadisticas/estantes_virtuales.pl",
		                                                  title =>    "[% 'Estad&iacute;sticas y graficos openFlashChart' | i18n %]"
		                                              ) ;
		              [% END %]
		          </li>
		          <li>
		              [% PERL %]
		                  print C4::AR::Filtros::link_to( text =>     "[% 'Consultas al OPAC' | i18n %]",
		                                                  url =>      "[% url_prefix %]/estadisticas/consultas_opac.pl",
		                                                  title =>    "[% 'Consultas al OPAC' | i18n %]"
		                                              ) ;
		              [% END %]
		          </li>
	          </ul>     
       </div>
       
       <h3 class="head"><a href="javascript:;">[% 'Administraci&oacute;n' | i18n %]</a></h3>
       <div id="seccion_administracion">        
	       <ul class="accordion">
	          <li>
	              <h4 class="head"><a href="javascript:;">[% 'Permisos' | i18n %]</a></h4>
	               <ul>
	                   <li>
	                             [% PERL %]
	                                 print C4::AR::Filtros::link_to( text =>     "[% 'Administrar Permisos' | i18n %]",
	                                                                 url =>      "[% url_prefix %]/admin/permisos/permisos.pl",
	                                                                 params =>   [],
	                                                                 title =>    "[% 'Administrar Permisos' | i18n %]"
	                                                             ) ;
	                             [% END %]
	                   </li>
                    </ul>
             </li>
            <li>
                <h4 class="menu_intermedio"><a href="javascript:;">[% 'Cat&aacute;logo' | i18n %]</a></h4>
                 <ul>
                     <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Preferencias' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/global/catalogo_config.pl", 
		                                                                    title =>    "[% 'Preferencias' | i18n %]"
		                                                                ) ;
		                                [% END %]
		             </li>
                     <li>
                         [% PERL %]
                             print C4::AR::Filtros::link_to( text =>     "[% 'Servidores Z39.50' | i18n %]",
                                                             url =>      "[% url_prefix %]/admin/catalogo/MARC/z3950servers.pl",
                                                             title =>    "[% 'Servidores Z39.50' | i18n %]"
                                                         ) ;
                         [% END %]
                     </li>
                      <li>
                          [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]",
                                                              url =>      "[% url_prefix %]/catalogacion/estructura/estructuraCatalo.pl", 
                                                              title =>    "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]"
                                                          ) ;
                          [% END %]
                      </li>
                      <li>
                          [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% 'Visualizaci&oacute;n del OPAC' | i18n %]",
                                                              url =>      "[% url_prefix %]/catalogacion/visualizacionOPAC/visualizacionOpac.pl", 
                                                              title =>    "[% 'Visualizaci&oacute;n del OPAC' | i18n %]"
                                                          ) ;
                          [% END %]
                      </li>
                      <li>
                          [% PERL %]
                              print C4::AR::Filtros::link_to( text =>     "[% 'Visualizaci&oacute;n de INTRANET' | i18n %]",
                                                              url =>      "[% url_prefix %]/catalogacion/visualizacionINTRA/visualizacionIntra.pl", 
                                                              title =>    "[% 'Visualizaci&oacute;n del OPAC' | i18n %]"
                                                          ) ;
                          [% END %]
                      </li>
                      <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Importar' | i18n %]",
                                                                      url =>      "[% url_prefix %]/herramientas/importar.pl", 
                                                                      title =>    "[% 'Importaci&oacute;n' | i18n %]"
                                                                  ) ;
                                  [% END %]
                      </li>
                      <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Exportar' | i18n %]",
                                                                      url =>      "[% url_prefix %]/herramientas/exportar.pl", 
                                                                      title =>    "[% 'Exportaci&oacute;n' | i18n %]"
                                                                  ) ;
                                  [% END %]
                      </li>
                      <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Chequeo Importaci&oacute;n' | i18n %]",
                                                                      url =>      "[% url_prefix %]/herramientas/chequeo_importacion.pl", 
                                                                      title =>    "[% 'Chequeo Importaci&oacute;n' | i18n %]"
                                                                  ) ;
                                  [% END %]
                      </li>

                  </ul>
                </li>
                    <li>
	                    <h4 class="head"><a href="javascript:;">[% 'Acomodar' | i18n %]</a></h4>
	                    <ul>
		                     <li>
		                         [% PERL %]
		                             print C4::AR::Filtros::link_to( text =>     "[% 'Mapeo KOHA a MARC' | i18n %]",
		                                                             url =>      "[% url_prefix %]/catalogacion/kohaToMARC.pl", 
		                                                             title =>    "[% 'Mapeo KOHA a MARC' | i18n %]"
		                                                         ) ;
		                         [% END %]
		                     </li>
	                     </ul>
                    </li>
                    
                   <li>
                        <h4 class="head"><a href="javascript:;">[% 'Usuarios' | i18n %]</a></h4>
		                <ul>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Admin. libre Deuda' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/usuarios/adminLibreDeuda.pl",
		                                                                    title =>    "[% 'Admin. libre Deuda' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                </ul>
	              </li>           
                   <li>
                        <h4 class="head"><a href="javascript:;">[% 'Circulaci&oacute;n' | i18n %]</a></h4>
                        <ul>
                            <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text  => "[% 'Preferencias' | i18n %]",
		                                                                    url   => "[% url_prefix %]/admin/global/circ_config.pl",
		                                                                    title => "[% 'Preferencias' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Sanciones' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/circulacion/sanciones.pl",
		                                                                    title =>    "[% 'Sanciones' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de pr&eacute;stamo' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/circulacion/tipos_de_prestamos.pl",
		                                                                    title =>    "[% 'Tipos de pr&eacute;stamo' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
                        </ul>
                  </li>           
                    
                   <li>
                        <h4 class="head"><a href="javascript:;">[% 'Consultas' | i18n %]</a></h4>
                        <ul>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Reportes Gen&eacute;ricos' | i18n %]",
		                                                                    url =>      "#", 
		                                                                    title =>    "[% 'Reportes Gen&eacute;ricos' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
                        </ul>
                  </li>           
                    
                   <li>
                        <h4 class="head"><a href="javascript:;">[% 'Global' | i18n %]</a></h4>
                        <ul>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Preferencias' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/global/preferencias.pl", 
		                                                                    title =>    "[% 'Preferencias' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Configuraci&oacute;n del Mail' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/global/mail_config.pl", 
		                                                                    title =>    "[% 'Configuraci&oacute;n del Mail' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Configuraci&oacute;n LDAP' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/global/ldap_config.pl",
		                                                                    title =>    "[% 'Configuraci&oacute;n LDAP' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    </li>
		                    		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Configuraci&oacute;n de Estilos' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/global/estilos_config.pl",
		                                                                    title =>    "[% 'Configuraci&oacute;n de Estilos' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Tablas de Referencia' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/referencias/referencias.pl",
		                                                                    title =>    "[% 'Tablas de Referencia' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
		                    <li>
		                                [% PERL %]
		                                    print C4::AR::Filtros::link_to( text =>     "[% 'Feriados' | i18n %]",
		                                                                    url =>      "[% url_prefix %]/admin/feriados.pl",
		                                                                    title =>    "[% 'Feriados' | i18n %]"
		                                                                ) ;
		                                [% END %]
		                    </li>
                            <li>
                                      [% PERL %]
                                          print C4::AR::Filtros::link_to( text =>     "[% 'Novedades de INTRA' | i18n %]",
                                                                          url =>      "[% url_prefix %]/admin/global/novedades_intra.pl",
                                                                          title =>    "[% 'Novedades de INTRA' | i18n %]"
                                                                      ) ;
                                      [% END %]
                            </li>
                        </ul>
                  </li>           
                    
                    <li>
                        <h4 class="head"><a href="javascript:;">[% 'OPAC' | i18n %]</a></h4>
                        <ul>
			                <li>
			                          [% PERL %]
			                              print C4::AR::Filtros::link_to( text =>     "[% 'Novedades de OPAC' | i18n %]",
			                                                              url =>      "[% url_prefix %]/admin/novedades_opac.pl",
			                                                              title =>    "[% 'Novedades de OPAC' | i18n %]"
			                                                          ) ;
			                          [% END %]
			                </li>
    	                    <li>
		                            [% PERL %]
		                                print C4::AR::Filtros::link_to( text =>     "[% 'Mensajes de Contacto' | i18n %]",
		                                                                url =>      "[% url_prefix %]/admin/mensajes_contacto.pl",
		                                                                title =>    "[% 'Mensajes de Contacto' | i18n %]"
		                                                            ) ;
		                            [% END %]
		                    </li>
			                
                       </ul>
                  </li>           
            </ul>
       </div>
       
       
        <h3 class="head"><a href="javascript:;">[% 'La biblioteca' | i18n %]</a></h3>
        <div id="seccion_acerca_de">
                 <ul>
                    <li>
                                 [% PERL %]
                                     print C4::AR::Filtros::link_to( text =>     "[% 'Acerca De...' | i18n %]",
                                                                     url =>      "[% url_prefix %]/about/about.pl",
                                                                     title =>    "[% 'Acerca De...' | i18n %]"
                                                                 ) ;
                                 [% END %]
                    </li>
                 </ul>
        </div>
	       
       
       
    </div> <!-- FIN MENU -->

</div>
<!-- A.4 HEADER BREADCRUMBS -->
