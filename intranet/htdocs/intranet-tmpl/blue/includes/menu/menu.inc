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
                        <li><a href="/cgi-bin/koha/busquedas/filtrado.pl?token=[% token %]">B&uacute;squeda Avanzada</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/filtradoExperto.pl?token=[% token %]">B&uacute;squeda Experta</a></li>
                     </ul>
                  </li>
                  <li><h3>Cat&aacute;logo</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/catalogacion/estructura/agregarDocumento.pl?token=[% token %]">Agregar Documento</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/adminEjemplares.pl?token=[% token %]">B&uacute;squeda Ejemplar</a></li>
                        <li><a href="/cgi-bin/koha/busquedas/estante.pl?token=[% token %]">Estante Virtual</a></li>
                     </ul>
                  </li>
                  <li><h3>MARC</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/catalogacion/kohaToMARC.pl?token=[% token %]">Mapeo KOHA a MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/z3950servers.pl?token=[% token %]">Servidores Z39.50</a></li>
                        <li><a href="/cgi-bin/koha/catalogacion/estructura/estructuraCatalo.pl?token=[% token %]">
											Creaci&oacute;n Cat&aacute;logo</a></li>
                        <li><a href="/cgi-bin/koha/admin/itemtypes.pl?token=[% token %]">Tipos de documento</a></li>
                        <li><a href="/cgi-bin/koha/catalogacion/visualizacionOPAC/visualizacionOpac.pl?token=[% token %]">Visualizaci&oacute;n del OPAC</a></li>
                     </ul>
                  </li>
                  <li><a href="/cgi-bin/koha/importacion.pl?token=[% token %]">Importaci&oacute;n</a></li>
                  <li><h3>Control de autoridades</h3>
					<ul>
						<li><a href="/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSinonimos.pl?token=[% token %]">
								Sin&oacute;nimos</a></li>
						<li><a href="/cgi-bin/koha/catalogacion/configuracion/controlAutoridades/controlAutoridadesSeudonimos.pl?token=[% token %]">
								Seun&oacute;nimos</a></li>
					</ul>
                  </li>


                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Usuarios</h3>

                <ul>
                  <li><a href="/cgi-bin/koha/usuarios/reales/buscarUsuario.pl?token=[% token %]">Usuarios Reales</a></li>
                  <li><a href="/cgi-bin/koha/usuarios/potenciales/buscarUsuario.pl?token=[% token %]">Usuarios Potenciales</a></li>
                  <li><a href="/cgi-bin/koha/usuarios/reales/agregarUsuario.pl?token=[% token %]">Agregar Usuarios</a></li>
                  <li><a href="/cgi-bin/koha/reports/users-cards.pl?token=[% token %]">Generar Carnets</a></li>
                </ul>
           
            </li>

          <!-- Navigation item -->
            <li><h3>Circulaci&oacute;n</h3>
                <ul>
				  <li><a href="/cgi-bin/koha/circ/circulacionRapida.pl?token=[% token %]">Circulaci&oacute;n R&aacute;pida</a></li>	
                  <li><a href="/cgi-bin/koha/circ/prestamos.pl?token=[% token %]">Pr&eacute;stamos</a></li>
                  <li><a href="/cgi-bin/koha/circ/devoluciones.pl?token=[% token %]">Devol. y Renov.</a></li>
                  <li><a href="/cgi-bin/koha/circ/sanciones.pl?token=[% token %]">Sanciones</a></li>
                </ul>
            </li>


          <!-- Navigation item -->
            <li><h3>Preferencias</h3>
                <ul>
                  <li><a href="/cgi-bin/koha/admin/preferencias.pl?token=[% token %]">Preferencias</a></li>
                  <li><a href="/cgi-bin/koha/admin/generic_reports.pl?token=[% token %]">Reportes Gen&eacute;ricos</a></li>
                  <li><a href="/cgi-bin/koha/admin/branches.pl?token=[% token %]">Unid. de Informaci&oacute;n</a></li>
                  <li><a href="/cgi-bin/koha/admin/refs.pl?token=[% token %]">Tablas de referencia</a></li>
                  <li><a href="/cgi-bin/koha/admin/itemtypes.pl?token=[% token %]">Tipos de documento</a></li>
                  <li><a href="/cgi-bin/koha/admin/categorie.pl?token=[% token %]">Categor&iacute;a de usuarios</a></li>
                  <li><a href="/cgi-bin/koha/admin/issuetypes.pl?token=[% token %]">Tipos de pr&acute;stamos</a></li>
                  <li><a href="/cgi-bin/koha/admin/authorised_values.pl?token=[% token %]">Valores autorizados</a></li>
                  <li><a href="/cgi-bin/koha/admin/adminLibreDeuda.pl?token=[% token %]">Admin. Libre Deuda</a></li>
                  <li><a href="/cgi-bin/koha/admin/feriados.pl?token=[% token %]">Feriados</a></li>
                  <li><a href="/cgi-bin/koha/admin/sanctions.pl?token=[% token %]">Sanciones</a></li>
                  <li><a href="/cgi-bin/koha/admin/thesaurus.pl?token=[% token %]">Thesaurus</a></li>
				  <li><a href="/cgi-bin/koha/admin/permisosTablas.pl?token=[% token %]">Admin. Permisos Tablas</a></li>
                  <li><h3>MARC</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/admin/koha2marclinks.pl?token=[% token %]">Links KOHA - MARC DB</a></li>
                        <li><a href="/cgi-bin/koha/admin/marctagstructure.pl?token=[% token %]">Estructura de MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/checkmarc.pl?token=[% token %]">Chequeo MARC</a></li>
                        <li><a href="/cgi-bin/koha/admin/z3950servers.pl?token=[% token %]">Servidores Z39.50</a></li>
                     </ul>
                  </li>
                  <li><h3>Herramientas</h3>
                     <ul>
                        <li><a href="/cgi-bin/koha/export/marc.pl?token=[% token %]">Exportaci&oacute;n</a></li>
                        <li><a href="/cgi-bin/koha/import/breeding.pl?token=[% token %]">Importaci&oacute;n</a></li>
                     </ul>
                  </li>
               </ul>
           </li>

          <!-- Navigation item -->
            <li><h3>Reportes</h3>
                <ul>
                  <li><a href="/cgi-bin/koha/reports/generic_reports.pl?token=[% token %]">Reportes Gen&eacute;ricos (FALTA) </a></li>
                  <li><a href="/cgi-bin/koha/reports/inventory.pl?token=[% token %]">Inventario</a></li>
                  <li><a href="/cgi-bin/koha/reports/inventory-sig-top.pl?token=[% token %]">Signatura topogr&aacute;fica.</a></li>
                  <li><a href="/cgi-bin/koha/reports/estantes.pl?token=[% token %]">Estantes virtuales (FALTA DB MODEL) </a></li>
                  <li><a href="/cgi-bin/koha/reports/users.pl?token=[% token %]">Usuarios (PREGUNTARLE A FER)</a></li>
                  <li><a href="/cgi-bin/koha/reports/prestamos.pl?token=[% token %]">Pr&eacute;stamos no devueltos</a></li>
                  <li><a href="/cgi-bin/koha/reports/reservas.pl?token=[% token %]">Reservas</a></li>
                  <li><a href="/cgi-bin/koha/reports/registro.pl?token=[% token %]">Registro de actividades</a></li>
                  <li><a href="/cgi-bin/koha/reports/historicoCirculacion.pl?token=[% token %]">Registro de circulaci&oacute;n</a></li>
                  <li><a href="/cgi-bin/koha/reports/estadistica_Anual.pl?token=[% token %]">Actividades anuales</a></li>
                  <li><a href="/cgi-bin/koha/reports/users-cards.pl?token=[% token %]">Generar carnets</a></li>
                  <li><a href="/cgi-bin/koha/reports/book-labels.pl?token=[% token %]">Generar etiquetas</a></li>
               </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Estad&iacute;sticas</h3>
                  <ul>    
                        <li><a href="/cgi-bin/koha/reports/availability.pl?token=[% token %]">Disp. de ejemplares</a></li>
                        <li><a href="/cgi-bin/koha/reports/historico_Prestamos.pl?token=[% token %]">Hist&oacute;rico de pr&eacute;stamos</a></li>
                        <li><a href="/cgi-bin/koha/reports/historicoSanciones.pl?token=[% token %]">Hist&oacute;rico de sanciones</a></li>
                        <li><a href="/cgi-bin/koha/reports/estadisticas.pl?token=[% token %]">Estad. de pr&eacute;stamos</a></li>
                        <li><a href="/cgi-bin/koha/reports/logueoBusqueda.pl?token=[% token %]">Logueo de b&uacute;squedas</a></li>
                        <li><a href="/cgi-bin/koha/reports/userEst.pl?token=[% token %]">Usuarios por categor&iacute;s</a></li>
                        <li><a href="/cgi-bin/koha/reports/itemtypes.pl?token=[% token %]">Tipos de ejemplares</a></li>
                        <li><a href="/cgi-bin/koha/reports/levels.pl?token=[% token %]">Niveles bibliogr&aacute;ficos</a></li>
                        <li><a href="/cgi-bin/koha/reports/avail_year.pl?token=[% token %]">Disponibilidad</a></li>
                  </ul>
            </li>

          <!-- Navigation item -->
              <li><h3>Ayuda</h3>
              <ul>
                  <li><a href="/cgi-bin/koha/about.pl?token=[% token %]">Acerca de</a></li>
              </ul>
            </li>
    </ul>
</div>
      <!-- A.4 HEADER BREADCRUMBS -->
