<!-- A.3 HEADER BOTTOM -->
      <div class="header-bottom">
       <div class="logo_Superior">
         
	 </div>

 <div class="tdRight">
            [% IF loggedinusername %]
                  <h2 class="login" id="login">Ingres&oacute; como:<b> [% loggedinusername %]</b> 
                           [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1 tabindex="-1">Salir</a>]
                  </h2>
            [% ELSE %]
               <p class="login">
                    <a href=/cgi-bin/koha/opac-user.pl>Entrar a Koha</a>
               </p>
            [% END %]
            [%  "INTRA" | setComboLang %]
         </div>



      <ul id="menu" tabindex="-1">
          <!-- Navigation item -->
            <li>
                [% PERL %]
                    print C4::AR::Filtros::link_to( text =>     "[% 'Inicio' | i18n %]",
                                                    url =>      "/cgi-bin/koha/mainpage.pl", 
                                                    class =>    "menu-alone-link",
                                                    title =>    "[% 'Ir al Inicio' | i18n %]"
                                                ) ;
                [% END %]
           </li>
          <!-- Navigation item -->

            <li><h3>Cat&aacute;logo</h3>
                <ul>
                  <li><h3>B&uacute;squedas</h3>
                     <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda avanzada' | i18n %]",
                                                                url =>      "/cgi-bin/koha/busquedas/filtrado.pl", 
                                                                title =>    "[% 'B&uacute;squeda avanzada' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda experta' | i18n %]",
                                                                url =>      "/cgi-bin/koha/busquedas/filtradoExperto.pl", 
                                                                title =>    "[% 'B&uacute;squeda experta' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                     </ul>
                  </li>
                  <li><h3>Cat&aacute;logo</h3>
                     <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Agregar documento' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/estructura/agregarDocumento.pl", 
                                                                title =>    "[% 'Agregar documento' | i18n %]"
                                                            ) ;
                            [% END %]                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda ejemplar' | i18n %]",
                                                                url =>      "/cgi-bin/koha/busquedas/adminEjemplares.pl", 
                                                                title =>    "[% 'B&uacute;squeda ejemplar' | i18n %]"
                                                            ) ;
                            [% END %]                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estante virtual' | i18n %]",
                                                                url =>      "/cgi-bin/koha/busquedas/estante.pl", 
                                                                title =>    "[% 'Estante virtual' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                     </ul>
                  </li>
                  <li><h3>MARC</h3>
                     <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Mapeo KOHA a MARC' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/kohaToMARC.pl", 
                                                                title =>    "[% 'Mapeo KOHA a MARC' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Servidores Z39.50' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/z3950servers.pl", 
                                                                title =>    "[% 'Servidores Z39.50' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/estructura/estructuraCatalo.pl", 
                                                                title =>    "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de documento' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/itemtypes.pl", 
                                                                title =>    "[% 'Tipos de documento' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Visualizaci&oacute;n del OPAC' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/visualizacionOPAC/visualizacionOpac.pl", 
                                                                title =>    "[% 'Visualizaci&oacute;n del OPAC' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                     </ul>
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Importaci&oacute;n' | i18n %]",
                                                                url =>      "/cgi-bin/koha/importacion.pl", 
                                                                title =>    "[% 'Importaci&oacute;n' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li><h3>Control de autoridades</h3>
					<ul>
						<li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Sin&oacute;nimos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSinonimos.pl", 
                                                                title =>    "[% 'Sin&oacute;nimos' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
						<li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Seud&oacute;nimos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSeudonimos.pl", 
                                                                title =>    "[% 'Sued&oacute;nimos' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
					</ul>
                  </li>


                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Usuarios</h3>

                <ul>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios Reales' | i18n %]",
                                                                url =>      "/cgi-bin/koha/usuarios/reales/buscarUsuario.pl", 
                                                                title =>    "[% 'Usuarios Reales' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios Potenciales' | i18n %]",
                                                                url =>      "/cgi-bin/koha/usuarios/potenciales/buscarUsuario.pl", 
                                                                title =>    "[% 'Usuarios Potenciales' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Agregar Usuarios' | i18n %]",
                                                                url =>      "/cgi-bin/koha/usuarios/reales/agregarUsuario.pl", 
                                                                title =>    "[% 'Agregar Usuarios' | i18n %]"
                                                            ) ;
                            [% END %]
                    </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Generar Carnets' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/users-cards.pl", 
                                                                title =>    "[% 'Generar Carnets' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Permisos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/permisosDB.pl", 
                                                                title =>    "[% 'Permisos' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>

                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Circulaci&oacute;n</h3>
                <ul>
				  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Circulaci&oacute;n R&aacute;pida' | i18n %]",
                                                                url =>      "/cgi-bin/koha/circ/circulacionRapida.pl", 
                                                                title =>    "[% 'Circulaci&oacute;n R&aacute;pida' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>	
			[% IF menu_preferences.showMenuItem_circ_prestamos %]
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Pr&eacute;stamos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/circ/prestamos.pl", 
                                                                title =>    "[% 'Pr&eacute;stamos' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
			[% END %]
			[% IF menu_preferences.showMenuItem_circ_devolucion_renovacion %]
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Devol. y Renov.' | i18n %]",
                                                                url =>      "/cgi-bin/koha/circ/devoluciones.pl", 
                                                                title =>    "[% 'Devol. y Renov.' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
			[% END %]
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Sanciones' | i18n %]",
                                                                url =>      "/cgi-bin/koha/circ/sanciones.pl", 
                                                                title =>    "[% 'Sanciones' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                </ul>
            </li>


          <!-- Navigation item -->
            <li><h3>Preferencias</h3>
                <ul>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Preferencias' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/preferencias.pl", 
                                                                title =>    "[% 'Preferencias' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Reportes Gene&eacute;ricos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/generic_reports.pl", 
                                                                title =>    "[% 'Reportes Gene&eacute;ricos' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Unid. de Informaci&oacute;n' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/branches.pl",
                                                                title =>    "[% 'Unid. de Informaci&oacute;n' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tablas de Referencia' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/refs.pl",
                                                                title =>    "[% 'Tablas de Referencia' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de Documento' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/itemtypes.pl",
                                                                title =>    "[% 'Tipos de Documento' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Categor&iacute;s de Usuario' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/categorie.pl",
                                                                title =>    "[% 'Categor&iacute;s de Usuario' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de Pr&eacute;stamo' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/tipos_de_prestamos.pl",
                                                                title =>    "[% 'Tipos de Pr&acute;stamo' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Valores Autorizados' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/authorised_values.pl",
                                                                title =>    "[% 'Valores Autorizados' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Admin. libre Deuda' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/adminLibreDeuda.pl",
                                                                title =>    "[% 'Admin. libre Deuda' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Feriados' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/feriados.pl",
                                                                title =>    "[% 'Feriados' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Sanciones' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/sanctions.pl",
                                                                title =>    "[% 'Sanciones' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Thesaurus' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/thesaurus.pl",
                                                                title =>    "[% 'Thesaurus' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
				<li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Admin. permisos Tablas' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/permisosTablas.pl",
                                                                title =>    "[% 'Admin. permisos Tablas' | i18n %]"
                                                            ) ;
                            [% END %]
                </li>
                <li><h3>MARC</h3>
                    <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Links KOHA - MARC DB' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/koha2marclinks.pl",
                                                                title =>    "[% 'Links KOHA - MARC DB' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estructuras de MARC' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/marctagstructure.pl",
                                                                title =>    "[% 'Estructuras de MARC' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Chequeo MARC' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/checkmarc.pl",
                                                                title =>    "[% 'Chequeo MARC' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Servidores Z39.50' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/z3950servers.pl",
                                                                title =>    "[% 'Servidores Z39.50' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                    </ul>
                </li>
                <li><h3>Herramientas</h3>
                    <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Exportaci&oacute;n' | i18n %]",
                                                                url =>      "/cgi-bin/koha/export/marc.pl",
                                                                title =>    "[% 'Exportaci&oacute;n' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Importaci&oacute;n' | i18n %]",
                                                                url =>      "/cgi-bin/koha/import/breeding.pl",
                                                                title =>    "[% 'Importaci&oacute;n' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                    </ul>
                </li>
            </ul>
        </li>

          <!-- Navigation item -->
            <li><h3>Reportes</h3>
                <ul>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Reportes gen&eacute;ricos (FALTA)' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/generic_reports.pl",
                                                                title =>    "[% 'Reportes gen&eacute;ricos (FALTA)' | i18n %]"
                                                            ) ;
                            [% END %]
                   </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Inventario' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/inventory.pl",
                                                                title =>    "[% 'Inventario' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Signatura Topogr&aacute;fica' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/inventory-sig-top.pl",
                                                                title =>    "[% 'Signatura Topogr&aacute;fica' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estantes Virtuales (FALTA DB MODEL)' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/estantes.pl",
                                                                title =>    "[% 'Estantes Virtuales (FALTA DB MODEL)' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios (PREGUNTALE A FER)' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/users.pl",
                                                                title =>    "[% 'Usuarios (PREGUNTALE A FER)' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Prest&aacute;mos no Devueltos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/prestamos.pl",
                                                                title =>    "[% 'Prest&aacute;mos no Devueltos' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Reservas' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/reservas.pl",
                                                                title =>    "[% 'Reservas' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Registro de Actividades' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/registro.pl",
                                                                title =>    "[% 'Registro de Actividades' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Registro de Circulaci&oacute;n' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/historicoCirculacion.pl",
                                                                title =>    "[% 'Registro de Circulaci&oacute;n' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Actividades Anuales' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/estadistica_Anual.pl",
                                                                title =>    "[% 'Actividades Anuales' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Generar Carnets' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/users-cards.pl",
                                                                title =>    "[% 'Generar Carnets' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Generar Etiquetas' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/book-labels.pl",
                                                                title =>    "[% 'Generar Etiquetas' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
               </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Estad&iacute;sticas</h3>
                  <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Disp. de Ejemplares' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/availability.pl",
                                                                title =>    "[% 'Disp. de Ejemplares' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Hist&oacute;rico de Pr&eacute;stamos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/historico_Prestamos.pl",
                                                                title =>    "[% 'Hist&oacute;rico de Pr&eacute;stamos' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Hist&oacute;rico de Sanciones' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/historicoSanciones.pl",
                                                                title =>    "[% 'Hist&oacute;rico de Sanciones' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estad. de Pr&eacute;stamos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/estadisticas.pl",
                                                                title =>    "[% 'Estad. de Pr&eacute;stamos' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Logueo de B&uacute;squedas' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/logueoBusqueda.pl",
                                                                title =>    "[% 'Logueo de B&uacute;squedas' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios por Categor&iacute;as' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/userEst.pl",
                                                                title =>    "[% 'Usuarios por Categor&iacute;as' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de Ejemplares' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/itemtypes.pl",
                                                                title =>    "[% 'Tipos de Ejemplares' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Niveles Bibliogr&aacute;ficos' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/levels.pl",
                                                                title =>    "[% 'Niveles Bibliogr&aacute;ficos' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Disponibilidad' | i18n %]",
                                                                url =>      "/cgi-bin/koha/reports/avail_year.pl",
                                                                title =>    "[% 'Disponibilidad' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                  </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Ayuda</h3>
              <ul>
                  <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Acerca De...' | i18n %]",
                                                                url =>      "/cgi-bin/koha/about.pl",
                                                                title =>    "[% 'Acerca De...' | i18n %]"
                                                            ) ;
                            [% END %]
                  </li>
              </ul>
            </li>
    </ul>
</div>
      <!-- A.4 HEADER BREADCRUMBS -->
