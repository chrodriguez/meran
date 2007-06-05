/* Tigra Menu items structure */
var MENU_ITEMS = [
	['Inicio', '/cgi-bin/koha/mainpage.pl'],
	['Catálogo', null, null,
		['Búsqueda  Avanzada', '/cgi-bin/koha/loadmodules.pl?module=search&marc=0&type=intranet'],
		['Búsqueda MARC', '/cgi-bin/koha/loadmodules.pl?module=search&marc=1&type=intranet'],
		['Estantes Virtuales', '/cgi-bin/koha/shelves.pl?startfrom=0'],
		['Agregar Libro', '/cgi-bin/koha/loadmodules.pl?module=addbiblio&type=intranet'],
		['Mantenimiento', '/cgi-bin/koha/maint/catmaintain.pl'],
		['Importación MARC', '/cgi-bin/koha/importacionMarc.pl'],
		['Importación', '/cgi-bin/koha/importacion.pl'],
		['Adquisici&oacute;n de ejemplares', '/cgi-bin/koha/loadmodules.pl?module=acquisitions'],
                        ['Crear desc.', '/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl'],
                        ['Crear desc. (MARC)', '/cgi-bin/koha/acqui.simple/addbiblio.pl']

	],
	['Usuarios', null, null,
		['Usuarios Reales', '/cgi-bin/koha/members-home.pl'],
		['Usuarios Potenciales', '/cgi-bin/koha/members-home2.pl'],
		['Agregar Usuario', '/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=adult'],
		['Agregar Organización', '/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=organisation']
	],
           ['Adquisici&oacute;n', null, null,
                        ['Adquisici&oacute;n de ejemplares', '/cgi-bin/koha/loadmodules.pl?module=acquisitions'],
                        ['Crear desc.', '/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl'],
                        ['Crear desc. (MARC)', '/cgi-bin/koha/acqui.simple/addbiblio.pl']
                ],

	['Circulación', null, null,
		['Préstamos', '/cgi-bin/koha/circ/circulation.pl'],
		['Devol. y  Renov.', '/cgi-bin/koha/circ/returns.pl'],
		['Transferencias', '/cgi-bin/koha/circ/branchtransfers.pl'],
		['Sanciones', '/cgi-bin/koha/circ/sanctions.pl']
	],
	['Parámetros', null, null,
		['Preferencias', null, null,
			['Todos', null],
			['Unidades de información', '/cgi-bin/koha/admin/branches.pl'],
			['Fondos', '/cgi-bin/koha/admin/aqbookfund.pl'],
			['Monedas', '/cgi-bin/koha/admin/currency.pl'],
			['Tipos de documentos', '/cgi-bin/koha/admin/itemtypes.pl'],
			['Categoría de usuarios', '/cgi-bin/koha/admin/categorie.pl'],
			['Multas', '/cgi-bin/koha/admin/charges.pl'],
			['Valores autorizados', '/cgi-bin/koha/admin/authorised_values.pl'],
			['Thesaurus', '/cgi-bin/koha/admin/thesaurus.pl'],
			['Estructura de MARC', '/cgi-bin/koha/admin/marctagstructure.pl'],
			['Links Koha - MARC DB', '/cgi-bin/koha/admin/koha2marclinks.pl'],
			['Chequeo MARC', '/cgi-bin/koha/admin/checkmarc.pl'],
			['Impresoras', '/cgi-bin/koha/admin/printers.pl'],
			['Stop words', '/cgi-bin/koha/admin/stopwords.pl'],
			['Servidores Z39.50', '/cgi-bin/koha/admin/z3950servers.pl'],
			['Preferencias del sistema', '/cgi-bin/koha/admin/systempreferences.pl'],
			['Feriados', '/cgi-bin/koha/admin/feriados.pl'],
			['Sanciones', '/cgi-bin/koha/admin/sanctions.pl']
		],
		['Herramientas', null, null,
			['Exportación', '/cgi-bin/koha/export/marc.pl'],
			['Importación', '/cgi-bin/koha/import/breeding.pl']
		]
	],
	['Reportes', null, null,
		['Todos', '/cgi-bin/koha/reports-home.pl'],
		['Reporte diario (hoy)', '/cgi-bin/koha/stats.pl?time=today'],
		['Reporte diario (ayer)', '/cgi-bin/koha/stats.pl?time=yesterday'],
		['Inventario', '/cgi-bin/koha/reports/inventory.pl'],
		['Usuarios', '/cgi-bin/koha/reports/users.pl'],
		['Pr&eacute;stamos sin devolver', '/cgi-bin/koha/reports/prestamos.pl'],
		['Reservas', '/cgi-bin/koha/reports/reservas.pl'],
		['Registro de actividades', '/cgi-bin/koha/reports/registro.pl'],
		['Actividades anuales','/cgi-bin/koha/reports/estadistica_Anual.pl'],
		['Disponibilidad de Ejemplares','/cgi-bin/koha/reports/availability.pl']
	],
	['Ayuda', null, null,
		['Acerca de', '/cgi-bin/koha/about.pl']
	]
];
