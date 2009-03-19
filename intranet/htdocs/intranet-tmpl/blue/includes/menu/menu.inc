<!-- A.3 HEADER BOTTOM -->

      <div class="header-bottom">
        <div class="tdRight">
            [% IF loggedinusername %]
                  <h2 class="login" id="login">Ingres&oacute; como:<b> [% loggedinusername %]</b> 
                           [<a target="_parent" href=/cgi-bin/koha/mainpage.pl?logout.x=1>Salir</a>]
                  </h2>
            [% ELSE %]
               <p class="login">
                    <a href=/cgi-bin/koha/opac-user.pl>Entrar a Koha</a>
               </p>
            [% END %]
            [%  "INTRA" | setComboLang %]
         </div>



<!-- FIXME FALTA i18n -->
      <ul id="menu">
          <!-- Navigation item -->
            <li><a href="/cgi-bin/koha/mainpage.pl" class="menu-alone-link">Inicio</a></li>
          
          <!-- Navigation item -->

            <li><h3>Cat&aacute;logo</h3>
                <ul>
                  <li><h3>B&uacute;squedas</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/busquedas/filtrado.pl">B&uacute;squeda Avanzada</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/filtradoExperto.pl">B&uacute;squeda Experta</a></li>
                     </ul>
                  </li>
                  <li><h3>Cat&aacute;logo</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/catalogacion/estructura/nuevo/agregarDocumento.pl">Agregar Documento</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/adminEjemplares.pl">B&uacute;squeda Ejemplar</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/estante.pl">Estante Virtual</a></li>
                     </ul>
                  </li>
                  <li><h3>MARC</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/catalogacion/kohaToMARC.pl">Mapeo KOHA a MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/z3950servers.pl">Servidores Z39.50</a></li>
                        <li><a href="/cgi-bin/koha/catalogacion/estructura/nuevo/estructuraCatalo.pl">Creaci&oacute;n Cat&aacute;logo</a></li>
                        <li><a href="/cgi-bin/koha/admin/itemtypes.pl">Tipos de documento</a></li>
                        <li><a href="/cgi-bin/koha/catalogacion/visualizacionOPAC/visualizacionOpac.pl">Visualizaci&oacute;n del OPAC</a></li>
                     </ul>
                  </li>
                  <li><a href="/cgi-bin/koha/importacion.pl">Importaci&oacute;n</a></li>
                  <li><h3>Control de autoridades</h3>
                                           <ul>
                                                <li><a href="/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSinonimos.pl">Sin&oacute;nimos</a></li>
                                                <li><a href="/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSeudonimos.pl">Seun&oacute;nimos</a></li>
                                           </ul>
                  </li>


                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Usuarios</h3>

                <ul>
                  <li><a href="/cgi-bin/koha/usuarios/reales/buscarUsuario.pl">Usuarios Reales</a></li>
                  <li><a href="/cgi-bin/koha/usuarios/potenciales/buscarUsuario.pl">Usuarios Potenciales</a></li>
                  <li><a href="/cgi-bin/koha/usuarios/reales/agregarUsuario.pl">Agregar Usuarios</a></li>
                  <li><a href="/cgi-bin/koha/reports/users-cards.pl">Generar Carnets</a></li>
                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Circulaci&oacute;n</h3>
                <ul>
                  <li><a href="/cgi-bin/koha/circ/prestamos.pl">Pr&eacute;stamos</a></li>
                  <li><a href="/cgi-bin/koha/circ/devoluciones.pl">Devol. y Renov.</a></li>
                  <li><a href="/cgi-bin/koha/circ/sanctions.pl">Sanciones</a></li>
                </ul>
            </li>


          <!-- Navigation item -->
            <li><h3>Preferencias</h3>
                <ul>
                  <li><a href="/cgi-bin/koha/admin/preferencias.pl">Preferencias</a></li>
                  <li><a href="/cgi-bin/koha/admin/generic_reports.pl">Reportes Gen&eacute;ricos</a></li>
                  <li><a href="/cgi-bin/koha/admin/branches.pl">Unid. de Informaci&oacute;n</a></li>
                  <li><a href="/cgi-bin/koha/admin/refs.pl">Tablas de referencia</a></li>
                  <li><a href="/cgi-bin/koha/admin/itemtypes.pl">Tipos de documento</a></li>
                  <li><a href="/cgi-bin/koha/admin/categorie.pl">Categor&iacute;a de usuarios</a></li>
                  <li><a href="/cgi-bin/koha/admin/issuetypes.pl">Tipos de pr&acute;stamos</a></li>
                  <li><a href="/cgi-bin/koha/admin/authorised_values.pl">Valores autorizados</a></li>
                  <li><a href="/cgi-bin/koha/admin/adminLibreDeuda.pl">Admin. Libre Deuda</a></li>
                  <li><a href="/cgi-bin/koha/admin/feriados.pl">Feriados</a></li>
                  <li><a href="/cgi-bin/koha/admin/sanctions.pl">Sanciones</a></li>
                  <li><a href="/cgi-bin/koha/admin/thesaurus.pl">Thesaurus</a></li>
                  <li><h3>MARC</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/admin/koha2marclinks.pl">Links KOHA - MARC DB</a></li>
                        <li><a href="/cgi-bin/koha/admin/marctagstructure.pl">Estructura de MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/checkmarc.pl">Chequeo MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/z3950servers.pl">Servidores Z39.50</a></li>
                     </ul>
                  </li>
                  <li><h3>Herramientas</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/export/marc.pl">Exportaci&oacute;n</a></li>
                        <li><a href="/cgi-bin/koha/import/breeding.pl">Importaci&oacute;n</a></li>
                     </ul>
                  </li>
               </ul>
           </li>

          <!-- Navigation item -->
            <li><h3>Reportes</h3>
                <ul>
                  <li><a href="/cgi-bin/koha/reports/generic_reports.pl">Reportes Gen&eacute;ricos</a></li>
                  <li><a href="/cgi-bin/koha/reports/inventory.pl">Inventario</a></li>
                  <li><a href="/cgi-bin/koha/reports/inventory-sig-top.pl">Signatura topogr&aacute;fica.</a></li>
                  <li><a href="/cgi-bin/koha/reports/estantes.pl">Estantes virtuales</a></li>
                  <li><a href="/cgi-bin/koha/reports/users.pl">Usuarios</a></li>
                  <li><a href="/cgi-bin/koha/reports/prestamos.pl">Pr&eacute;stamos no devueltos</a></li>
                  <li><a href="/cgi-bin/koha/reports/reservas.pl">Reservas</a></li>
                  <li><a href="/cgi-bin/koha/reports/registro.pl">Registro de actividades</a></li>
                  <li><a href="/cgi-bin/koha/reports/historicoCirculacion.pl">Registro de circulaci&oacute;n</a></li>
                  <li><a href="/cgi-bin/koha/reports/estadistica_Anual.pl">Actividades anuales</a></li>
                  <li><a href="/cgi-bin/koha/reports/users-cards.pl">Generar carnets</a></li>
                  <li><a href="/cgi-bin/koha/reports/book-labels.pl">Generar etiquetas</a></li>
               </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Estad&iacute;sticas</h3>
                  <ul>    
                        <li><a href="/cgi-bin/koha/reports/availability.pl">Disp. de ejemplares</a></li>
                        <li><a href="/cgi-bin/koha/reports/historico_Prestamos.pl">Hist&oacute;rico de pr&eacute;stamos</a></li>
                        <li><a href="/cgi-bin/koha/reports/historicoSanciones.pl">Hist&oacute;rico de sanciones</a></li>
                        <li><a href="/cgi-bin/koha/reports/estadisticas.pl">Estad. de pr&eacute;stamos</a></li>
                        <li><a href="/cgi-bin/koha/reports/logueoBusqueda.pl">Logueo de b&uacute;squedas</a></li>
                        <li><a href="/cgi-bin/koha/reports/userEst.pl">Usuarios por categor&iacute;s</a></li>
                        <li><a href="/cgi-bin/koha/reports/itemtypes.pl">Tipos de ejemplares</a></li>
                        <li><a href="/cgi-bin/koha/reports/levels.pl">Niveles bibliogr&aacute;ficos</a></li>
                        <li><a href="/cgi-bin/koha/reports/avail_year.pl">Disponibilidad</a></li>
                  </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Ayuda</h3>
              <ul>
                  <li><a href="/cgi-bin/koha/about.pl">Acerca de</a></li>
              </ul>
            </li>
    </ul>
</div>
      <!-- A.4 HEADER BREADCRUMBS -->
