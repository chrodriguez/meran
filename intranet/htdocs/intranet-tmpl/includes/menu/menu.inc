<!-- A.3 HEADER BOTTOM -->
      <div class="header-bottom">
      <div class="logo_Superior">
  </div>
 <div class="idioma_y_login">
    [% IF loggedinuser %]
        <div class="user_icon">
            <div style="float:left; height:25px">
                <a title="[% socio_data.persona.getNombre %], [% socio_data.persona.getApellido %]" rel="contact" class="url" 
                    href="/cgi-bin/koha/usuarios/reales/datosUsuario.pl?token=[% token %]&nro_socio=[% socio_data.getNro_socio %]">
                    [% IF socio_data.tieneFoto %]
                        <img width="48" height="48" src="[% themelang %]/pictures/[% socio_data.tieneFoto %]" class="side_thumb photo fn" 
                            alt="[% socio_data.persona.getNombre %], [% socio_data.persona.getApellido %]"/>
                    [% ELSE %]
                          <img  width="48" height="48" src="[% temas %]/[% tema %]/imagenes/no_foto.jpg" 
                                class="side_thumb photo fn"
                                alt="[% 'Usuario sin foto' | i18n %]"
                                title="[% 'Usuario sin foto' | i18n %]" />
                    [% END %]
                </a>
            </div>
                <a title="[% socio_data.persona.getNombre %], [% socio_data.persona.getApellido %]" rel="contact"
                    href="/cgi-bin/koha/usuarios/reales/datosUsuario.pl?token=[% token %]&nro_socio=[% socio_data.getNro_socio %]">
                    <span id="me_name">[% socio_data.persona.getNombre %], [% socio_data.persona.getApellido %]</span>
                </a>
            <div class="culture_Select">
                  [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1 tabindex="-1">[% "Salir" | i18n %]</a>]
                  [%  "INTRA" | setComboLang %] 
            </div>
        </div>
    [% ELSE %]
        <p id="logout">
            <a href=/cgi-bin/koha/opac-user.pl>Entrar a Koha</a>
        </p>
    [% END %]
</div>
  <div>
      <ul id="menu" tabindex="-1">
          <!-- Navigation item -->
            <li>

                <div class="menu_superior_der">
                    <div class="menu_superior_izq">
                        <h3 class="menu_superior">
                        [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "[% 'Inicio' | i18n %]",
                                                            url =>      "/cgi-bin/koha/mainpage.pl", 
                                                            class =>    "menu_superior",
                                                            title =>    "[% 'Ir al Inicio' | i18n %]"
                                                        ) ;
                        [% END %]
        </h3>
                    </div>
                </div>
           </li>
          <!-- Navigation item -->

            <li>
                <div class="menu_superior_der">
                    <div class="menu_superior_izq">
                      <h3 class="menu_superior">[% 'Cat&aacute;logo' | i18n %]</h3>
                    </div>
                </div>
                <ul>
                  <li><h3 class="menu_intermedio">[% 'B&uacute;squedas' | i18n %]</h3>
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
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'B&uacute;squeda Z3950' | i18n %]",
                                                                url =>      "/cgi-bin/koha/z3950/filtradoZ3950.pl", 
                                                                title =>    "[% 'B&uacute;squeda Z3950' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                     </ul>
                  </li>
                  <li><h3 class="menu_intermedio">[% 'Cat&aacute;logo' | i18n %]</h3>
                     <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Agregar documento' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/estructura/datosDocumento.pl", 
                                                                title =>    "[% 'Agregar documento' | i18n %]"
                                                            ) ;
                            [% END %]                        
                        </li>
                        
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estante virtual' | i18n %]",
                                                                url =>      "/cgi-bin/koha/estantes/estante.pl", 
                                                                title =>    "[% 'Estante virtual' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>

                     </ul>
                  </li>

                  <li><h3 class="menu_intermedio">[% 'Control de autoridades' | i18n %]</h3>
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
            <li>

                <div class="menu_superior_der">
                    <div class="menu_superior_izq">
                        <h3 class="menu_superior">[% 'Usuarios' | i18n %]</h3>
                    </div>
                </div>

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
                </ul>
            </li>

          <!-- Navigation item -->
            <li>
                  <div class="menu_superior_der">
                    <div class="menu_superior_izq">
                        <h3 class="menu_superior">[% 'Circulaci&oacute;n' | i18n %]</h3>
                    </div>
                  </div>
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
                  <li>
                      [% PERL %]
                          print C4::AR::Filtros::link_to( text =>     "[% 'Disp. de Ejemplares' | i18n %]",
                                                          url =>      "/cgi-bin/koha/reports/disponibilidad_ejemplares.pl",
                                                          title =>    "[% 'Disp. de Ejemplares' | i18n %]"
                                                      ) ;
                      [% END %]
                  </li>

                </ul>
            </li>

          <!-- Navigation item -->
            <li>                
                <div class="menu_superior_der">
                    <div class="menu_superior_izq">
                        <h3 class="menu_superior">[% 'Consultas' | i18n %]</h3>
                    </div>
                </div>
                <ul>
                  <li><h3 class="menu_intermedio">[% 'Reportes' | i18n %]</h3>
                    <ul>
                     <li><h3 class="menu_intermedio">[% 'Usuarios' | i18n %]</h3>
                        <ul>
                            <li>
                                      [% PERL %]
                                          print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios (PREGUNTALE A FER)' | i18n %]",
                                                                          url =>      "#",
                                                                          title =>    "[% 'Usuarios (PREGUNTALE A FER)' | i18n %]"
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
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Usuarios por Categor&iacute;as' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/reports/userEst.pl",
                                                                    title =>    "[% 'Usuarios por Categor&iacute;as' | i18n %]"
                                                                ) ;
                                [% END %]
                            </li>
                        </ul>
                    </li>
                     <li><h3 class="menu_intermedio">[% 'Cat&aacute;logo' | i18n %]</h3>
                        <ul>
                            <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Reportes gen&eacute;ricos (FALTA)' | i18n %]",
                                                                      url =>      "#",
                                                                      title =>    "[% 'Reportes gen&eacute;ricos (FALTA)' | i18n %]"
                                                                  ) ;
                                  [% END %]
                          </li>
                          <li>
                                    [% PERL %]
                                        print C4::AR::Filtros::link_to( text =>     "[% 'Inventario y Signatura' | i18n %]",
                                                                        url =>      "/cgi-bin/koha/reports/inventory-sig-top.pl",
                                                                        title =>    "[% 'Inventario y Signatura' | i18n %]"
                                                                    ) ;
                                    [% END %]
                          </li>
                          <li>
                                    [% PERL %]
                                        print C4::AR::Filtros::link_to( text =>     "[% 'Estantes Virtuales (FALTA DB MODEL)' | i18n %]",
                                                                        url =>      "#",
                                                                        title =>    "[% 'Estantes Virtuales (FALTA DB MODEL)' | i18n %]"
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
                                        print C4::AR::Filtros::link_to( text =>     "[% 'Generar Etiquetas' | i18n %]",
                                                                        url =>      "/cgi-bin/koha/reports/generarEtiquetas.pl",
                                                                        title =>    "[% 'Generar Etiquetas' | i18n %]"
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
                        </ul>
                    </li>
                     <li><h3 class="menu_intermedio">[% 'Circulaci&oacute;n' | i18n %]</h3>
                        <ul>
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
                        </ul>
                    </li>
                </ul>
              </li>
          <!-- Navigation item -->
              <li><h3 class="menu_intermedio">[% 'Estad&iacute;sticas' | i18n %]</h3>
                  <ul>
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Estad&iacute;sticas y graficos openFlashChart' | i18n %]",
                                                                url =>      "#",
                                                                title =>    "[% 'Estad&iacute;sticas y graficos openFlashChart' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                  </ul>
            </li>
          </ul>
        </li>
          <!-- Navigation item -->
            <li>
               <div class="menu_superior_der">
                  <div class="menu_superior_izq">
                      <h3 class="menu_superior">[% 'Administraci&oacute;n' | i18n %]</h3>
                  </div>
                </div>
              <ul>
                <li><h3 class="menu_intermedio">[% 'Permisos' | i18n %]</h3>
                  <ul>
                    <li>
                              [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% 'Permisos Cat&aacute;logo' | i18n %]",
                                                                  url =>      "/cgi-bin/koha/admin/permisos/permisosDB.pl",
                                                                  params =>   ["action=catalogo"],
                                                                  title =>    "[% 'Permisos Cat&aacute;logo' | i18n %]"
                                                              ) ;
                              [% END %]
                    </li>
                    <li>
                              [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% 'Permisos Circulaci&oacute;n' | i18n %]",
                                                                  url =>      "/cgi-bin/koha/admin/permisos/permisosDB.pl", 
                                                                  params =>   ["action=circulacion"],
                                                                  title =>    "[% 'Permisos Circulaci&oacute;n' | i18n %]"
                                                              ) ;
                              [% END %]
                    </li>
                    <li>
                              [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% 'Permisos Generales' | i18n %]",
                                                                  url =>      "/cgi-bin/koha/admin/permisos/permisosDB.pl", 
                                                                  params =>   ["action=general"],
                                                                  title =>    "[% 'Permisos Generales' | i18n %]"
                                                              ) ;
                              [% END %]
                    </li>
                  </ul>
                </li>


            <li>
                <li><h3 class="menu_intermedio">[% 'Cat&aacute;logo' | i18n %]</h3>
                <ul>
                      <li><h3 class="menu_intermedio">[% 'MARC' | i18n %]</h3>
                          <ul>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Links KOHA - MARC DB' | i18n %]",
                                                                      url =>      "/cgi-bin/koha/admin/catalogo/MARC/koha2marclinks.pl",
                                                                      title =>    "[% 'Links KOHA - MARC DB' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Estructuras de MARC' | i18n %]",
                                                                      url =>      "/cgi-bin/koha/admin/catalogo/MARC/marctagstructure.pl",
                                                                      title =>    "[% 'Estructuras de MARC' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Chequeo MARC' | i18n %]",
                                                                      url =>      "/cgi-bin/koha/admin/catalogo/MARC/checkmarc.pl",
                                                                      title =>    "[% 'Chequeo MARC' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                              <li>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% 'Servidores Z39.50' | i18n %]",
                                                                      url =>      "/cgi-bin/koha/admin/catalogo/MARC/z3950servers.pl",
                                                                      title =>    "[% 'Servidores Z39.50' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </li>
                            </ul>
                        </li>
                        <li><h3 class="menu_intermedio">[% 'Herramientas' | i18n %]</h3>
                            <ul>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "[% 'Importar' | i18n %]",
                                                                                url =>      "/cgi-bin/koha/herramientas/importar.pl", 
                                                                                title =>    "[% 'Importaci&oacute;n' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                                <li>
                                            [% PERL %]
                                                print C4::AR::Filtros::link_to( text =>     "[% 'Exportar' | i18n %]",
                                                                                url =>      "/cgi-bin/koha/herramientas/exportar.pl", 
                                                                                title =>    "[% 'Exportaci&oacute;n' | i18n %]"
                                                                            ) ;
                                            [% END %]
                                </li>
                            </ul>
                        </li>

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
                                print C4::AR::Filtros::link_to( text =>     "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]",
                                                                url =>      "/cgi-bin/koha/catalogacion/estructura/estructuraCatalo.pl", 
                                                                title =>    "[% 'Creaci&oacute;n cat&aacute;logo' | i18n %]"
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
                        <li>
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de Documento' | i18n %]",
                                                                url =>      "/cgi-bin/koha/admin/catalogo/tipos_de_documento.pl", 
                                                                title =>    "[% 'Tipos de Documento' | i18n %]"
                                                            ) ;
                            [% END %]
                        </li>
                  </ul>
              </li>

              <li><h3 class="menu_intermedio">[% 'Usuarios' | i18n %]</h3>
                <ul>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Admin. libre Deuda' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/usuarios/adminLibreDeuda.pl",
                                                                    title =>    "[% 'Admin. libre Deuda' | i18n %]"
                                                                ) ;
                                [% END %]
                    </li>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Categor&iacute;as de Usuario' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/usuarios/categorie.pl",
                                                                    title =>    "[% 'Categor&iacute;s de Usuario' | i18n %]"
                                                                ) ;
                                [% END %]
                    </li>
                </ul>
              </li>  

              <li><h3 class="menu_intermedio">[% 'Circulaci&oacute;n' | i18n %]</h3>
                <ul>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Sanciones' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/circulacion/sanciones.pl",
                                                                    title =>    "[% 'Sanciones' | i18n %]"
                                                                ) ;
                                [% END %]
                    </li>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Tipos de pr&eacute;stamo' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/circulacion/tipos_de_prestamos.pl",
                                                                    title =>    "[% 'Tipos de pr&eacute;stamo' | i18n %]"
                                                                ) ;
                                [% END %]
                    </li>
                </ul>
              </li>  

             <li><h3 class="menu_intermedio">[% 'Consultas' | i18n %]</h3>
                <ul>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Reportes Gene&eacute;ricos' | i18n %]",
                                                                    url =>      "#", 
                                                                    title =>    "[% 'Reportes Gene&eacute;ricos' | i18n %]"
                                                                ) ;
                                [% END %]
                    </li>
                </ul>
             </li>

               <li><h3 class="menu_intermedio">[% 'Global' | i18n %]</h3>
                  <ul>
                    <li>
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Preferencias' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/global/preferencias.pl", 
                                                                    title =>    "[% 'Preferencias' | i18n %]"
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
                                                                    url =>      "/cgi-bin/koha/admin/referencias/referencias.pl",
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
                                    print C4::AR::Filtros::link_to( text =>     "[% 'Valores Autorizados' | i18n %]",
                                                                    url =>      "/cgi-bin/koha/admin/authorised_values.pl",
                                                                    title =>    "[% 'Valores Autorizados' | i18n %]"
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

                  </ul>
                </li>
               
              </ul>
           </li>
          <!-- Navigation item -->
              <li>
                  <div class="menu_superior_der">
                      <div class="menu_superior_izq">
                          <h3 class="menu_superior">[% 'Ayuda' | i18n %]</h3>
                      </div>
                  </div>
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
</div>
      <!-- A.4 HEADER BREADCRUMBS -->