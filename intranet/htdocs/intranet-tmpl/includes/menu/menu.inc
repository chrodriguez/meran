[% INCLUDE "header.inc" %]
<nav>
    <ul id="menu">
             <li>
                  <a href="#">[% 'Cat&aacute;logo' | i18n %]</a>
                  <ul>
                      <li>
                            <a href="#">[% 'B&uacute;squedas' | i18n %]</a></h4>
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
                            <a href="#">[% 'Cat&aacute;logo' | i18n %]</a>
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
                            <a href="javascript:;">[% 'Adquisiciones' | i18n %]</a>
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
                               <li>
                                   [% PERL %]
                                       print C4::AR::Filtros::link_to( text =>     "[% 'Recomendaciones' | i18n %]",
                                                                       url =>      "[% url_prefix %]/adquisiciones/recomendaciones.pl",
                                                                       title =>    "[% 'Estante virtual' | i18n %]"
                                                                   ) ;
                                   [% END %]
                               </li>
                            </ul>
                     </li>
                </ul>
            </li>
            <li>
                  <a href="#">[% 'Usuarios' | i18n %]</a>
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
            </li>

            <li>
                <a href="#">[% 'Circulaci&oacute;n' | i18n %]</a>
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
                  </ul>
           </li>
          <li>
                 <a href="#">[% 'Consultas' | i18n %]</a>
                 <ul>
                    <li>
							[% PERL %]
								print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios' | i18n %]",
															    url =>      "[% url_prefix %]/reports/usuarios.pl",
															    title =>    "[% 'Usuarios' | i18n %]"
							  							      );
							[% END %]
					</li>

                    <li>
							[% PERL %]
								print C4::AR::Filtros::link_to( text =>     "[% 'Circulaci&oacute;n' | i18n %]",
															    url =>      "[% url_prefix %]/reports/circulacion.pl",
															    title =>    "[% 'Circulaci&oacute;n' | i18n %]"
							  							      );
							[% END %]
					</li>

                </ul>
           </li>

           <li>
               <a href="#">[% 'Estad&iacute;sticas' | i18n %]</a>
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
           </li>

           <li>
               <a href="#">[% 'Administraci&oacute;n' | i18n %]</a>
               <ul>
                      <li>
                          <a href="#">[% 'Permisos' | i18n %]</a>
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
                        <a href="#">[% 'Cat&aacute;logo' | i18n %]</a>
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
                                print C4::AR::Filtros::link_to( text =>     "[% 'Generaci&oacute;n de Barcodes' | i18n %]",
                                                                url =>      "[% url_prefix %]/admin/catalogo/barcode_gen_setup.pl",
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
                                                                      title =>    "[% 'Visualizaci&oacute;n del INTRANET' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                          [% PERL %]
                                              print C4::AR::Filtros::link_to( text =>     "[% 'Visibilidad Campos TR' | i18n %]",
                                                                              url =>      "[% url_prefix %]/catalogacion/tablasReferencia/tablasReferencia.pl",
                                                                              title =>    "[% 'Visibilidad Campos TR' | i18n %]"
                                                                          ) ;
                                          [% END %]
                              </li>
                             <li>
                                <a href="#">[% 'Importar/Exportar' | i18n %]</a>
                                <ul>
                                  <li>
                                    <a href="#">[% 'Importaci&oacute;n' | i18n %]</a>
                                    <ul>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Nueva Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/subirNuevaImportacion.pl",
                                                                                      title =>    "[% 'Nueva Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Importaci&oacute;nes' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/importar.pl",
                                                                                      title =>    "[% 'Importaci&oacute;nes' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Esquemas de Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/esquemas_importacion.pl",
                                                                                      title =>    "[% 'Esquemas de Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                    </ul>
                                  </li>
                                  <li>
                                              [% PERL %]
                                                  print C4::AR::Filtros::link_to( text =>     "[% 'Exportar' | i18n %]",
                                                                                  url =>      "[% url_prefix %]/herramientas/exportacion/exportar.pl",
                                                                                  title =>    "[% 'Exportaci&oacute;n' | i18n %]"
                                                                              ) ;
                                              [% END %]
                                  </li>
                                </ul>
                            </li>
                          </ul>
                        </li>
                       <li>
                            <a href="#">[% 'Usuarios' | i18n %]</a>
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
                            <a href="#">[% 'Circulaci&oacute;n' | i18n %]</a>
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
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "[% 'Pr&eacute;stamos Vencidos' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/circulacion/prestamos_vencidos.pl",
                                                                                title =>    "[% 'Pr&eacute;stamos Vencidos' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                            </ul>
                      </li>

                       <li>
                            <a href="#">[% 'Global' | i18n %]</a>
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
                                                print C4::AR::Filtros::link_to( text =>     "[% 'M&eacute;todos de Autenticaci&oacute;n' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/global/auth_methods.pl",
                                                                                title =>    "[% 'Configuraci&oacute;n del Mail' | i18n %]"
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
                                                print C4::AR::Filtros::link_to( text =>     "[% 'Control de autoridades' | i18n %]",
                                                                                url =>      "[% url_prefix %]/admin/referencias/referencias.pl",
                                                                                title =>    "[% 'Control de autoridades' | i18n %]"
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
                                <li>
                                             [% PERL %]
                                                 print C4::AR::Filtros::link_to( text =>     "[% 'Acerca De...' | i18n %]",
                                                                                 url =>      "[% url_prefix %]/about/about.pl",
                                                                                 title =>    "[% 'Acerca De...' | i18n %]"
                                                                             ) ;
                                             [% END %]
                                </li>
                            </ul>
                      </li>

                        <li>
                            <a href="#">[% 'OPAC' | i18n %]</a>
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
         </li>

                                      <li>
                                <a href="#">[% 'Importar/Exportar' | i18n %]</a>
                                <ul>
                                  <li>
                                    <a href="#">[% 'Importaci&oacute;n' | i18n %]</a>
                                    <ul>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Nueva Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/subirNuevaImportacion.pl",
                                                                                      title =>    "[% 'Nueva Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Importaci&oacute;nes' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/importar.pl",
                                                                                      title =>    "[% 'Importaci&oacute;nes' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                        <li>
                                                  [% PERL %]
                                                      print C4::AR::Filtros::link_to( text =>     "[% 'Esquemas de Importaci&oacute;n' | i18n %]",
                                                                                      url =>      "[% url_prefix %]/herramientas/importacion/esquemas_importacion.pl",
                                                                                      title =>    "[% 'Esquemas de Importaci&oacute;n' | i18n %]"
                                                                                  ) ;
                                                  [% END %]
                                        </li>
                                    </ul>
                                  </li>
                                  <li>
                                              [% PERL %]
                                                  print C4::AR::Filtros::link_to( text =>     "[% 'Exportar' | i18n %]",
                                                                                  url =>      "[% url_prefix %]/herramientas/exportacion/exportar.pl",
                                                                                  title =>    "[% 'Exportaci&oacute;n' | i18n %]"
                                                                              ) ;
                                              [% END %]
                                  </li>
                                </ul>
                            </li>


    </ul>
</nav>
<!-- A.4 HEADER BREADCRUMBS -->
