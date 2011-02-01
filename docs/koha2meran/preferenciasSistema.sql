
-- Preferencias que no se utilizan más --

('acquisitions', 'simple', 'Normal, budget-based acquisitions, or Simple bibliographic-data acquisitions', 'simple|normal', 'Choice'),
('authoritysep', '--', 'the separator used in authority/thesaurus. Usually --', '10', 'free'),
('autoBarcode', 'yes', 'Barcode is auto-calculated', NULL, 'YesNo'),
('checkdigit', 'none', 'Validity checks on membership number: none or "Katipo" style checks', 'none|katipo', 'Choice'),
('marc', '0', 'Habilitar el soporte en MARC', NULL, 'YesNo'),
('marcflavour', 'MARC21', 'your MARC flavor (MARC21 or UNIMARC) used for character encoding', 'MA')
('maxoutstanding', '5', 'maximum amount withstanding to be able make reserves', NULL, 'Integer'),
'maxvirtualcopy', '7', 'Cantidad máxima de copias de un ejemplar de la biblioteca virtual dentro del período fijado por <i>virtualcopyrenew</i>.', NULL, NULL),
('maxvirtualprint', '10', 'Cantidad máxima de impresiones sobre un ejemplar de la biblioteca virtual dentro del período fijado por <i>virtualprintrenew</i>', NULL, NULL),


-- Modificaciones a la tabla --
ALTER TABLE `systempreferences` DROP PRIMARY KEY ;

ALTER TABLE `systempreferences` ADD `id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST ;

ALTER TABLE `systempreferences` ADD `categoria` VARCHAR( 255 ) NOT NULL DEFAULT 'sistema';


-- FIXME Faltan las referencias de las variables que ya existen!!!!!!!!!!

-- Nuevas preferencias --
 INSERT INTO `pref_preferencia_sistema` (`variable`, `value`, `explanation`, `options`, `type`, `categoria`) VALUES
 ( 'auto-nro_socio_from_dni', '1', 'Preferencia que configura el auto-generar de nro de socio. Si es 0, es el autogenerar *serial*, sino sera el documento.', NULL, NULL, 'sistema'),
 ( 'autoActivarPersona', '1', 'Activa por defecto un alta de una persona', NULL, 'bool', 'sistema'),
 ( 'circularDesdeDetalleDelRegistro', '1', 'se permite (=1) circular desde el detalle del registro', NULL, 'bool', 'sistema'),
 ( 'circularDesdeDetalleUsuario', '1', 'se permite (=1) circular desde el detalle del usuario', NULL, 'bool', 'sistema'),
 ( 'defaultCategoriaSocio', 'ES', 'Categoria de Socio por defecto', 'tipo_socio|description', 'referencia', 'sistema'),
 ( 'defaultDisponibilidad', '0', 'Disponibilidad por defecto', 'disponibilidad|nombre', 'referencia', 'sistema'),
 ( 'defaultissuetype', 'DO', 'Es el tipo de préstamo por defecto de la biblioteca', 'tipo_prestamo|descripcion', 'referencia', 'sistema'),
 ( 'defaultTipoDoc', 'DNI', 'Tipo de Documento de Usuario por defecto', 'tipo_documento_usr|descripcion', 'referencia', 'sistema'),
 ( 'defaultTipoNivel3', 'LIB', 'Tipo de Documento por defecto', 'tipo_ejemplar|nombre', 'referencia', 'sistema'),
 ( 'habilitar_https', '1', 'habilita https (=1) o no (=0)', NULL, 'bool', 'sistema'), 
 ( 'libreDeuda', '11111', 'variable que limita la impresion del documento de libre deuda', NULL, 'text', 'sistema'),
( 'paginas', '10', 'Cantidad de paginas que va a  mostrar el paginador.', '', 'text', 'sistema'),
        ( 'permite_cambio_password_desde_opac', '1', 'permite (=1) o no (=0) el cambio de password desde el OPAC', NULL, 'bool', 'sistema'),
      ( 'puerto_para_https', '444', 'puerto para https', NULL, 'text', 'sistema'),
    ( 'showMenuItem_circ_devolucion_renovacion', '1', 'Preferencia que configura si el menu item dado se muestra o no en el menu (1 sí ; 0 no).', NULL, 'bool', 'sistema'),
        ( 'showMenuItem_circ_prestamos', '1', 'Preferencia que configura si el menu item dado se muestra o no en el menu (1 sí ; 0 no).', NULL, 'bool', 'sistema'),
        ( 'split_by_levels', '1', 'Para mostrar en el OPAC el detalle dividido por niveles o no', NULL, NULL, 'sistema'),
        ( 'titulo_nombre_ui', 'Biblioteca - U.N.L.P.', '', NULL, 'text', 'sistema'),
       ( 'z3950_ cant_resultados', '25', 'Cantidad de resultados por servidor en una busqueda z3950 MAX para devoler todos', NULL, 'text', 'sistema'),
        ( 'longitud_barcode', '3', 'cantidad de caracteres que conforman el barcode', NULL, NULL, 'sistema'),
        ( 'limite_resultados_autocompletables', '20', 'limite de resultados a mostrar en los campos autocompletables', NULL, NULL, 'sistema'),
        ( 'perfil_opac', '1', 'Id del perfil de visualizacion para OPAC', NULL, NULL, 'sistema'),
        ( 'detalle_resumido', '1', 'Muestra el detalle desde el OPAC en forma resumida', NULL, NULL, 'sistema'),
        ( 'defaultUI', 'DEO', 'Unidad de informacion por defecto', NULL, 'text', 'sistema'),
        ( 'google_map', '', '', NULL, NULL, 'sistema'),
        ( 'tema_opac_test', 'test', 'Un tema para el OPAC', NULL, NULL, 'temas_opac'),
        ( 'tema_opac_default', 'default', 'Un tema para el OPAC', NULL, NULL, 'temas_opac'),
        ( 'tema_intra_test', 'test', 'Un tema para el INTRA', NULL, NULL, 'temas_intra'),
        ( 'tema_intra_default', 'default', 'Un tema para el INTRA', NULL, NULL, 'temas_intra'),
        ( 'tema_opac', 'default', 'El tema por defecto para OPAc', '', '', 'sistema'),
        ( 'tema_intra', 'default', 'El tema por defecto para INTRANET', NULL, NULL, 'sistema'),
        ( 'port_mail', '587', 'puerto del servidor de mail', NULL, 'text', 'sistema'),
        ( 'username_mail', 'kkohatesting@yahoo.com.ar', 'usuario de la cuenta de mail', NULL, 'text', 'sistema'),
        ( 'password_mail', 'pato123', 'password de la cuenta de mail', NULL, 'text', 'sistema'),
        ( 'smtp_server', 'smtp.live.com', 'Servidor SMTP', NULL, 'text', 'sistema'),
        ( 'smtp_metodo', 'TLS', 'Método de encriptación usado por el servidor SMTP para la autenticación', NULL, 'text', 'sistema');

