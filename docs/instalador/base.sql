-- phpMyAdmin SQL Dump
-- version 3.3.7deb7
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Aug 27, 2012 at 12:05 PM
-- Server version: 5.1.63
-- PHP Version: 5.3.3-7+squeeze14

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `econo2meran`
--

-- --------------------------------------------------------

--
-- Table structure for table `adq_forma_envio`
--

CREATE TABLE IF NOT EXISTS `adq_forma_envio` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_forma_envio`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_item`
--

CREATE TABLE IF NOT EXISTS `adq_item` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(255) DEFAULT NULL,
  `precio` float NOT NULL,
  PRIMARY KEY (`id_item`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `adq_item`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_pedido_cotizacion`
--

CREATE TABLE IF NOT EXISTS `adq_pedido_cotizacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `adq_pedido_cotizacion`
--

INSERT INTO `adq_pedido_cotizacion` (`id`, `fecha`) VALUES
(1, '2011-09-13 09:12:53'),
(2, '2012-02-07 11:07:50'),
(3, '2012-02-07 12:48:18');

-- --------------------------------------------------------

--
-- Table structure for table `adq_pedido_cotizacion_detalle`
--

CREATE TABLE IF NOT EXISTS `adq_pedido_cotizacion_detalle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adq_pedido_cotizacion_id` int(11) NOT NULL,
  `cat_nivel2_id` int(11) DEFAULT NULL,
  `autor` varchar(255) DEFAULT NULL,
  `titulo` varchar(255) DEFAULT NULL,
  `lugar_publicacion` varchar(255) DEFAULT NULL,
  `editorial` varchar(255) DEFAULT NULL,
  `fecha_publicacion` date DEFAULT NULL,
  `coleccion` varchar(255) DEFAULT NULL,
  `isbn_issn` varchar(45) DEFAULT NULL,
  `cantidad_ejemplares` int(5) NOT NULL DEFAULT '1',
  `precio_unitario` float NOT NULL,
  `adq_recomendacion_detalle_id` int(11) DEFAULT NULL,
  `nro_renglon` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;


--
-- Table structure for table `adq_presupuesto`
--

CREATE TABLE IF NOT EXISTS `adq_presupuesto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `proveedor_id` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ref_estado_presupuesto_id` int(11) NOT NULL,
  `ref_pedido_cotizacion_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `adq_presupuesto`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_proveedor`
--

CREATE TABLE IF NOT EXISTS `adq_proveedor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `nro_doc` varchar(21) DEFAULT NULL,
  `razon_social` varchar(255) DEFAULT NULL,
  `cuit_cuil` int(11) NOT NULL,
  `domicilio` varchar(255) DEFAULT NULL,
  `telefono` varchar(32) DEFAULT NULL,
  `fax` varchar(32) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `activo` int(1) NOT NULL,
  `plazo_reclamo` int(11) DEFAULT NULL,
  `usr_ref_tipo_documento_id` int(11) DEFAULT NULL,
  `ref_localidad_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_adq_proveedor_usr_ref_tipo_documento1` (`usr_ref_tipo_documento_id`),
  KEY `fk_adq_proveedor_ref_localidad1` (`ref_localidad_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `adq_proveedor`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_proveedor_forma_envio`
--

CREATE TABLE IF NOT EXISTS `adq_proveedor_forma_envio` (
  `adq_forma_envio_id` int(11) NOT NULL,
  `adq_proveedor_id` int(11) NOT NULL,
  PRIMARY KEY (`adq_forma_envio_id`,`adq_proveedor_id`),
  KEY `fk_adq_proveedor_forma_envio_adq_proveedor1` (`adq_proveedor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_proveedor_forma_envio`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_proveedor_item`
--

CREATE TABLE IF NOT EXISTS `adq_proveedor_item` (
  `id_proveedor` int(11) NOT NULL,
  `id_item` int(11) NOT NULL,
  PRIMARY KEY (`id_proveedor`,`id_item`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_proveedor_item`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_proveedor_tipo_material`
--

CREATE TABLE IF NOT EXISTS `adq_proveedor_tipo_material` (
  `proveedor_id` int(11) NOT NULL,
  `tipo_material_id` int(11) NOT NULL,
  PRIMARY KEY (`proveedor_id`,`tipo_material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_proveedor_tipo_material`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_recomendacion`
--

CREATE TABLE IF NOT EXISTS `adq_recomendacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `activa` tinyint(4) NOT NULL DEFAULT '1',
  `adq_ref_tipo_recomendacion_id` int(11) NOT NULL,
  `usr_socio_id` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_adq_recomendacion_adq_ref_tipo_recomendacion1` (`adq_ref_tipo_recomendacion_id`),
  KEY `fk_adq_recomendacion_usr_socio1` (`usr_socio_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=35 ;



-- --------------------------------------------------------

--
-- Table structure for table `adq_recomendacion_detalle`
--

CREATE TABLE IF NOT EXISTS `adq_recomendacion_detalle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cat_nivel2_id` int(11) DEFAULT NULL,
  `autor` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `titulo` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `lugar_publicacion` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `editorial` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `fecha_publicacion` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `coleccion` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `isbn_issn` varchar(45) CHARACTER SET latin1 DEFAULT NULL,
  `cantidad_ejemplares` int(5) NOT NULL DEFAULT '1',
  `motivo_propuesta` text CHARACTER SET latin1 NOT NULL,
  `comentario` text CHARACTER SET latin1,
  `reserva_material` tinyint(4) NOT NULL DEFAULT '0',
  `adq_recomendacion_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_adq_recomendacion_detalle_adq_recomendacion1` (`adq_recomendacion_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;


--
-- Table structure for table `adq_ref_proveedor_moneda`
--

CREATE TABLE IF NOT EXISTS `adq_ref_proveedor_moneda` (
  `adq_ref_moneda_id` int(11) NOT NULL,
  `adq_proveedor_id` int(11) NOT NULL,
  PRIMARY KEY (`adq_ref_moneda_id`,`adq_proveedor_id`),
  KEY `fk_adq_ref_moneda_has_adq_proveedor_adq_proveedor1` (`adq_proveedor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_ref_proveedor_moneda`
--


-- --------------------------------------------------------

--
-- Table structure for table `adq_tipo_material`
--

CREATE TABLE IF NOT EXISTS `adq_tipo_material` (
  `id` int(11) NOT NULL,
  `nombre` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `adq_tipo_material`
--


-- --------------------------------------------------------

--
-- Table structure for table `background_job`
--

CREATE TABLE IF NOT EXISTS `background_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `jobID` varchar(255) CHARACTER SET latin1 NOT NULL,
  `size` int(11) NOT NULL,
  `progress` float NOT NULL,
  `status` varchar(255) CHARACTER SET latin1 NOT NULL,
  `name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `invoker` varchar(255) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `jobID` (`jobID`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;


-- --------------------------------------------------------

--
-- Table structure for table `barcode_format`
--

CREATE TABLE IF NOT EXISTS `barcode_format` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_doc` varchar(4) NOT NULL,
  `format` varchar(255) NOT NULL,
  `long` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_tipo_doc` (`id_tipo_doc`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


-- --------------------------------------------------------

--
-- Table structure for table `cat_autor`
--

CREATE TABLE IF NOT EXISTS `cat_autor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(128) NOT NULL,
  `apellido` varchar(128) NOT NULL,
  `nacionalidad` char(3) DEFAULT NULL,
  `completo` varchar(260) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`,`apellido`,`nacionalidad`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_autor`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_ayuda_marc`
--

CREATE TABLE IF NOT EXISTS `cat_ayuda_marc` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ui` int(11) NOT NULL,
  `campo` char(3) CHARACTER SET latin1 NOT NULL,
  `subcampo` char(1) CHARACTER SET latin1 NOT NULL,
  `ayuda` text CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ui` (`ui`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_ayuda_marc`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_contenido_estante`
--

CREATE TABLE IF NOT EXISTS `cat_contenido_estante` (
  `id2` int(11) NOT NULL,
  `id_estante` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_estante`,`id2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_contenido_estante`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_seudonimo_autor`
--

CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_autor` (
  `id_autor` int(11) NOT NULL,
  `id_autor_seudonimo` int(11) NOT NULL,
  PRIMARY KEY (`id_autor`,`id_autor_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_control_seudonimo_autor`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_seudonimo_editorial`
--

CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_editorial` (
  `id_editorial` int(11) NOT NULL,
  `id_editorial_seudonimo` int(11) NOT NULL,
  PRIMARY KEY (`id_editorial`,`id_editorial_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_control_seudonimo_editorial`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_seudonimo_tema`
--

CREATE TABLE IF NOT EXISTS `cat_control_seudonimo_tema` (
  `id_tema` int(11) NOT NULL,
  `id_tema_seudonimo` int(11) NOT NULL,
  PRIMARY KEY (`id_tema`,`id_tema_seudonimo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_control_seudonimo_tema`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_sinonimo_autor`
--

CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_autor` (
  `id` int(11) NOT NULL,
  `autor` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`autor`),
  KEY `autor` (`autor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_control_sinonimo_autor`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_sinonimo_editorial`
--

CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_editorial` (
  `id` int(11) NOT NULL,
  `editorial` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`editorial`),
  KEY `editorial` (`editorial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_control_sinonimo_editorial`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_control_sinonimo_tema`
--

CREATE TABLE IF NOT EXISTS `cat_control_sinonimo_tema` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tema` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`tema`),
  KEY `tema` (`tema`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_control_sinonimo_tema`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_editorial`
--

CREATE TABLE IF NOT EXISTS `cat_editorial` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `editorial` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_editorial`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_encabezado_campo_opac`
--

CREATE TABLE IF NOT EXISTS `cat_encabezado_campo_opac` (
  `idencabezado` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) DEFAULT NULL,
  `orden` int(11) NOT NULL,
  `linea` tinyint(1) NOT NULL DEFAULT '0',
  `nivel` tinyint(1) NOT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`idencabezado`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_encabezado_campo_opac`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_encabezado_item_opac`
--

CREATE TABLE IF NOT EXISTS `cat_encabezado_item_opac` (
  `idencabezado` int(11) NOT NULL DEFAULT '0',
  `itemtype` varchar(4) NOT NULL DEFAULT '',
  PRIMARY KEY (`idencabezado`,`itemtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_encabezado_item_opac`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_estante`
--

CREATE TABLE IF NOT EXISTS `cat_estante` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `estante` varchar(255) DEFAULT NULL,
  `tipo` text NOT NULL,
  `padre` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `cat_estante`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_estructura_catalogacion`
--

CREATE TABLE IF NOT EXISTS `cat_estructura_catalogacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campo` char(3) DEFAULT NULL,
  `subcampo` char(1) DEFAULT NULL,
  `itemtype` varchar(4) DEFAULT NULL,
  `liblibrarian` varchar(255) DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `referencia` tinyint(1) NOT NULL DEFAULT '0',
  `nivel` tinyint(1) NOT NULL,
  `obligatorio` tinyint(1) NOT NULL DEFAULT '0',
  `intranet_habilitado` int(11) DEFAULT '0',
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `edicion_grupal` tinyint(4) NOT NULL DEFAULT '1',
  `idinforef` int(11) DEFAULT NULL,
  `idCompCliente` varchar(255) DEFAULT NULL,
  `fijo` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'modificable = 0, No \r\nmodificable = 1',
  `repetible` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'repetible = 1 \r\n(es petible)',
  `rules` varchar(255) DEFAULT NULL,
  `grupo` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `indiceTodos` (`campo`,`subcampo`,`itemtype`),
  KEY `idinforef` (`idinforef`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=526 ;

--
-- Dumping data for table `cat_estructura_catalogacion`
--

INSERT INTO `cat_estructura_catalogacion` (`id`, `campo`, `subcampo`, `itemtype`, `liblibrarian`, `tipo`, `referencia`, `nivel`, `obligatorio`, `intranet_habilitado`, `visible`, `edicion_grupal`, `idinforef`, `idCompCliente`, `fijo`, `repetible`, `rules`, `grupo`) VALUES
(51, '245', 'a', 'ALL', 'Título', 'text', 0, 1, 1, 2, 1, 1, NULL, '1', 1, 0, 'alphanumeric_total:true', 0),
(66, '110', 'a', 'LIB', 'Autor corporativo', 'auto', 1, 1, 0, 1, 1, 1, 78, 'bf8e17616267c51064becf693e64501e', 0, 0, ' alphanumeric_total:true ', 0),
(68, '245', 'h', 'LIB', 'Medio', 'combo', 1, 2, 0, 4, 1, 1, 149, 'dbd4ba15b96cf63914351cdb163467b2', 0, 0, ' alphanumeric_total:true ', 0),
(107, '080', 'a', 'LIB', 'CDU', 'text', 0, 1, 0, 3, 1, 1, 0, 'ea0c6caa38d898989866335e1af0844e', 0, 1, ' alphanumeric_total:true ', 1),
(116, '700', 'a', 'LIB', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 12, 1, 1, 143, '496705e6cd65f25e4e41ef8f26d0027e', 0, 1, ' alphanumeric_total:true ', 10),
(120, '710', 'a', 'REV', 'Nombre de la entidad o jurisdicción', 'auto', 1, 1, 0, 16, 1, 1, 64, '538f99c8e5537a6307385edc614e65cf', 0, 1, ' alphanumeric_total:true ', 14),
(124, '245', 'b', 'LIB', 'Resto del título', 'text', 0, 1, 0, 20, 1, 1, NULL, '21f6e655816f1ac4b941bc13908197e3', 0, 1, ' alphanumeric_total:true ', 18),
(132, '650', 'a', 'LIB', 'Temas (controlado)', 'auto', 1, 1, 0, 28, 1, 1, 88, '357a2f17fd0088cb1f0e8370b62d7452', 0, 1, ' alphanumeric_total:true ', 26),
(135, '653', 'a', 'LIB', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 31, 1, 1, NULL, 'eea199e92303ba203519cd460a662188', 0, 1, ' alphanumeric_total:true ', 29),
(138, '041', 'a', 'LIB', 'Idioma', 'combo', 1, 2, 0, 9, 1, 1, 148, 'c304616fe1434ba4235a146010b98aa3', 0, 1, ' alphanumeric_total:true ', 32),
(140, '250', 'a', 'LIB', 'Edición', 'text', 0, 2, 0, 11, 1, 1, NULL, '665d8ec1b8a444dcf4d8732f09022742', 0, 1, ' alphanumeric_total:true ', 34),
(142, '300', 'a', 'LIB', 'Extensión/Páginas', 'text', 0, 2, 0, 13, 1, 1, NULL, '6982e2c38b57af9484301752acba4d44', 0, 1, ' alphanumeric_total:true ', 36),
(143, '440', 'a', 'LIB', 'Serie', 'text', 0, 2, 0, 14, 1, 1, NULL, '484e5d9090c3ba6b66ebad0c0e1150d2', 0, 1, ' alphanumeric_total:true ', 37),
(144, '440', 'p', 'LIB', 'Subserie', 'text', 0, 2, 0, 15, 1, 1, NULL, '5c9badf652343301382222dee9d8cd81', 0, 1, ' alphanumeric_total:true ', 38),
(145, '440', 'v', 'LIB', 'Número de la serie ', 'text', 0, 2, 0, 16, 1, 1, NULL, '2c1cdfad0546433f47440881acc9dc1a', 0, 1, ' alphanumeric_total:true ', 39),
(146, '500', 'a', 'LIB', 'Nota general', 'text', 0, 2, 0, 17, 1, 1, NULL, 'd92774dab9a0b65d987d0d10fcc5ee96', 0, 1, ' alphanumeric_total:true ', 40),
(152, '710', 'g', 'REV', 'Sigla', 'text', 0, 1, 0, 33, 1, 1, NULL, 'ce7d0b9c0192b1668ec7854f96366d4f', 0, 1, ' alphanumeric_total:true ', 0),
(157, '260', 'b', 'REV', 'Editor', 'text', 0, 2, 0, 10, 1, 1, NULL, '158837737c411171b07f555cf9911e09', 0, 1, ' alphanumeric_total:true ', 0),
(159, '362', 'a', 'REV', 'Fecha de inicio - cese', 'text', 0, 2, 0, 12, 1, 1, NULL, 'c1e31ba3b3372929907cdd9505868ad9', 0, 1, ' alphanumeric_total:true ', 0),
(162, '710', 'b', 'REV', 'Entidad subordinada', 'texta', 0, 1, 0, 35, 1, 1, NULL, '11238f8ecd94de929e600086aad33c5e', 0, 1, ' alphanumeric_total:true ', 0),
(166, '300', 'a', 'TES', 'Páginas', 'text', 0, 2, 0, 10, 1, 1, NULL, '52b02598a81d62f2639c1129422ed40e', 0, 1, ' digits:true ', 0),
(167, '110', 'b', 'LIB', 'Entidad subordinada', 'auto', 1, 1, 0, 33, 1, 1, 261, 'e70d29c5813261bccda451db1e131bcc', 0, 1, ' digits:true ', 0),
(170, '250', 'b', 'SEM', 'Editor', 'text', 0, 2, 0, 8, 1, 1, NULL, 'c017c66d4f430c276dd18b91e70e0c87', 0, 1, ' alphanumeric_total:true ', 0),
(173, '300', 'b', 'LIB', 'Otros detalles físicos (NR)', 'text', 0, 2, 0, 22, 1, 1, NULL, '8e7937b4a461334ac4069b343fd4be6f', 0, 1, ' alphanumeric_total:true ', 0),
(174, '300', 'c', 'LIB', 'Dimensiones (R)', 'text', 0, 2, 0, 23, 1, 1, NULL, 'a95bd9b45f6f4b63f13455acc09ea98b', 0, 1, ' alphanumeric_total:true ', 0),
(179, '240', 'a', 'REV', 'Título uniforme (NR)', 'text', 0, 1, 0, 27, 1, 1, NULL, 'c6a6287394c22748b31ccfff8f1c61d6', 0, 1, ' alphanumeric_total:true ', 0),
(181, '246', 'f', 'REV', 'Designación del volumen, número, fecha', 'text', 0, 1, 0, 29, 1, 1, NULL, '3a5781978b3aa10341d0ac52c7848f9a', 0, 1, ' alphanumeric_total:true ', 0),
(187, '310', 'b', 'REV', 'Fecha de frecuencia actual de la publicación (NR)', 'text', 0, 2, 0, 16, 1, 1, NULL, '13b3d3af3c0ed21bf82d8893b3ae2785', 0, 1, ' alphanumeric_total:true ', 0),
(190, '500', 'a', 'REV', 'Nota general (NR)', 'text', 0, 2, 0, 17, 1, 1, NULL, '8b5faa32fa5cb921206b056cc2ab12b3', 0, 1, ' alphanumeric_total:true ', 0),
(196, '100', 'b', 'LIB', 'Numeración (NR)', 'text', 0, 1, 0, 34, 1, 1, NULL, 'fd5bf619a9599f761aeb2b06e2c78794', 0, 1, ' alphanumeric_total:true ', 0),
(197, '100', 'c', 'LIB', 'Títulos y otras palabras asociadas con el nombre (R)', 'text', 0, 1, 0, 35, 1, 1, NULL, '1e93b93d6f843a21faefb43198be5a0f', 0, 1, ' alphanumeric_total:true ', 0),
(198, '100', 'd', 'LIB', 'Fecha de nacimiento y muerte', 'calendar', 0, 1, 0, 36, 1, 1, NULL, 'c2aef632843117206593b3da4b4eb2a4', 0, 1, ' dateITA:true ', 0),
(203, '250', 'a', 'FOT', 'Edición', 'text', 0, 2, 0, 4, 1, 1, NULL, '1ca43551e6b3b7ae1867b5600286b28d', 0, 1, ' alphanumeric_total:true ', 0),
(205, '260', 'b', 'FOT', 'Editor', 'text', 0, 2, 0, 6, 1, 1, NULL, 'eee370a1798db8697e8d4ddc01645289', 0, 1, ' alphanumeric_total:true ', 0),
(206, '260', 'c', 'FOT', 'Fecha', 'text', 0, 2, 0, 7, 1, 1, NULL, '3b20c6955b6abba2acdf75bd0e4eec0c', 0, 1, ' alphanumeric_total:true ', 0),
(207, '440', 'a', 'FOT', 'Serie', 'text', 0, 2, 0, 8, 1, 1, NULL, '21bbc9fb703e5091daab09a783505185', 0, 1, ' alphanumeric_total:true ', 0),
(208, '440', 'p', 'FOT', 'Subserie', 'text', 0, 2, 0, 9, 1, 1, NULL, '0926182ee4f15005e157065a66aecaea', 0, 1, ' alphanumeric_total:true ', 0),
(209, '440', 'v', 'FOT', 'Número de la serie', 'text', 0, 2, 0, 10, 1, 1, NULL, '3e8dcc89ce341656d1c90360df6c0d76', 0, 1, ' alphanumeric_total:true ', 0),
(210, '300', 'a', 'FOT', 'Descripción física', 'text', 0, 2, 0, 11, 1, 1, NULL, 'ca37509585fba624c5a6824da36022cd', 0, 1, ' alphanumeric_total:true ', 0),
(211, '500', 'a', 'FOT', 'Nota general ', 'text', 0, 2, 0, 12, 1, 1, NULL, '925becd7ae41c7e7b7300d01264f605b', 0, 1, ' alphanumeric_total:true ', 0),
(212, '773', 'd', 'FOT', 'Lugar, editor y fecha de publicación de la parte mayor', 'text', 0, 2, 0, 13, 1, 1, NULL, '6e01cf17a1e90bccafb06983dfb1ecf6', 0, 1, ' alphanumeric_total:true ', 0),
(213, '773', 'g', 'FOT', 'Ubicación de la parte', 'text', 0, 2, 0, 14, 1, 1, NULL, '9f74adedc3e487dd09fb1d40b156f896', 0, 1, ' alphanumeric_total:true ', 0),
(214, '773', 't', 'FOT', 'Título y mención de la parte mayor', 'text', 0, 2, 0, 15, 1, 1, NULL, '9f77f316a27cb3a8cec0ec3f3b11bfda', 0, 1, ' alphanumeric_total:true ', 0),
(215, '260', 'a', 'FOT', 'Lugar', 'auto', 1, 2, 0, 15, 1, 1, 150, '17780c5ea89df2b9ad8dbf66eda4015d', 0, 1, ' alphanumeric_total:true ', 0),
(216, '100', 'a', 'DCA', 'Autor', 'auto', 1, 1, 0, 18, 1, 1, 77, '8463a7ead2190cbca46501e1522d2010', 0, 1, ' alphanumeric_total:true ', 0),
(217, '260', 'a', 'DCA', 'Lugar', 'auto', 1, 2, 0, 4, 1, 1, 76, '0b3baf9f2c23e842482b50668a72af41', 0, 1, ' alphanumeric_total:true ', 0),
(218, '260', 'b', 'DCA', 'Editor', 'text', 0, 2, 0, 5, 1, 1, NULL, '08caa243955d91b91498180d13e3fa41', 0, 1, ' alphanumeric_total:true ', 0),
(219, '260', 'c', 'DCA', 'Fecha', 'calendar', 0, 2, 0, 6, 1, 1, NULL, 'e0f9c80ff3e651fc0e786681f81dbffd', 0, 1, ' alphanumeric_total:true ', 0),
(220, '300', 'a', 'DCA', 'Extensión/Páginas', 'text', 0, 2, 0, 7, 1, 1, NULL, '8db011e4e5f8cd1dda43b19724d64c36', 0, 1, ' alphanumeric_total:true ', 0),
(221, '440', 'a', 'DCA', 'Serie', 'text', 0, 2, 0, 8, 1, 1, NULL, '8e03eaab572412f997af83cb4d993e63', 0, 1, ' alphanumeric_total:true ', 0),
(222, '440', 'p', 'DCA', 'Subserie', 'text', 0, 2, 0, 9, 1, 1, NULL, '88bbd6dad17c4693455940239ab8e03c', 0, 1, ' alphanumeric_total:true ', 0),
(223, '440', 'v', 'DCA', 'Número', 'text', 0, 2, 0, 10, 1, 1, NULL, 'f7bd311eb4473e6df290689803ff1f1a', 0, 1, ' alphanumeric_total:true ', 0),
(224, '500', 'a', 'DCA', 'Nota general', 'text', 0, 2, 0, 11, 1, 1, NULL, 'b87ab2596026ff6efb3f4dedaa382cdd', 0, 1, ' alphanumeric_total:true ', 0),
(225, '700', 'b', 'LIB', 'Número asociado al nombre', 'text', 0, 1, 0, 3, 1, 1, NULL, 'd68a4311b8773c73495f6397f0dcabe8', 0, 1, ' alphanumeric_total:true ', 0),
(226, '700', 'c', 'LIB', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 2, 1, 1, NULL, '9670663cf1362fa2de186daa80b65700', 0, 1, ' alphanumeric_total:true ', 0),
(227, '700', 'd', 'LIB', 'Fecha de nacimento y muerte', 'text', 0, 1, 0, 3, 1, 1, NULL, '815574e5acfdbf4261651a3cf2c2ca16', 0, 1, ' alphanumeric_total:true ', 0),
(228, '700', 'e', 'LIB', 'Función', 'text', 0, 1, 0, 2, 1, 1, 0, '89a16936399743ab6537c00fd84de07a', 0, 1, ' alphanumeric_total:true ', 0),
(229, '773', 't', 'LIB', 'Título y mención de resp. del documento fuente', 'text', 0, 2, 0, 19, 1, 1, NULL, 'a991d2c5d6905b32db1eaa70342a8962', 0, 1, ' alphanumeric_total:true ', 0),
(230, '773', 'd', 'LIB', 'Lugar, editor y fecha (documento fuente)', 'text', 0, 2, 0, 20, 1, 1, NULL, '313e1387022292da1cf7b87cf67a293d', 0, 1, ' alphanumeric_total:true ', 0),
(231, '773', 'g', 'LIB', 'Parte relacionada (ubicación de la parte)', 'text', 0, 2, 0, 21, 1, 1, NULL, '1aeadd22f8a43c45283e79c4d12b620a', 0, 1, ' alphanumeric_total:true ', 0),
(232, '041', 'a', 'DCA', 'Idioma', 'combo', 1, 2, 0, 9, 1, 1, 110, 'ee3459db0a48b344488061909c0c96e5', 0, 1, ' alphanumeric_total:true ', 0),
(233, '650', 'a', 'DCA', 'temas (controlado)', 'auto', 1, 1, 0, 2, 1, 1, 89, 'af1cfb16220f155838b1e3d8bbac14d5', 0, 1, ' alphanumeric_total:true ', 0),
(234, '653', 'a', 'DCA', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 3, 1, 1, NULL, 'a048da02607307e067b5d1e4ca7c4bee', 0, 1, ' alphanumeric_total:true ', 0),
(235, '110', 'a', 'DCA', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 93, 'a1a1350b2f0ffb80723e603b6105eeef', 0, 1, ' alphanumeric_total:true ', 0),
(236, '110', 'b', 'DCA', 'Entidad subordinada', 'auto', 1, 1, 0, 2, 1, 1, 97, '3f953984408ceec2965c058426cf6eef', 0, 1, ' alphanumeric_total:true ', 0),
(237, '700', 'a', 'DCA', 'Autor secundario', 'auto', 1, 1, 0, 2, 1, 1, 91, 'd4a08dc643606dc1e6169762710cf116', 0, 1, ' alphanumeric_total:true ', 0),
(238, '700', 'e', 'DCA', 'Función', 'text', 0, 1, 0, 2, 1, 1, NULL, '611244f681343b56cac4e9bc0341f63f', 0, 1, ' alphanumeric_total:true ', 0),
(239, '080', 'a', 'DCA', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, 'd80534925707ab93b53f9fdb83da509f', 0, 1, ' alphanumeric_total:true ', 0),
(240, '900', 'b', 'REV', 'Nivel bibliografico', 'text', 1, 2, 0, 13, 1, 1, 238, 'ba9c2821f1553be4bb52e5cd2b24cb53', 0, 1, ' alphanumeric_total:true ', 0),
(241, '910', 'a', 'REV', 'Tipo de documento', 'combo', 1, 2, 1, 7, 1, 1, 122, '91fd6a6a083b0b1fba81f52b686d09f0', 1, 1, ' alphanumeric_total:true ', 0),
(242, '900', 'b', 'DCA', 'Nivel bibliografico', 'text', 0, 2, 0, 10, 1, 1, NULL, 'ae8bf4c011e2b889d43c2750ac1fe293', 0, 1, ' alphanumeric_total:true ', 0),
(243, '910', 'a', 'DCA', 'Tipo de documento', 'text', 0, 2, 1, 6, 1, 1, NULL, '47a1ddefee6dbd1e1d48eea3e9866459', 1, 1, ' alphanumeric_total:true ', 0),
(244, '080', 'a', 'DCD', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, '6da523b4dcff731ad8b6e04eeed6b658', 0, 1, ' alphanumeric_total:true ', 0),
(245, '100', 'a', 'DCD', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 94, '7eba44017ef8689f7d66bf860243f7d8', 0, 1, ' alphanumeric_total:true ', 0),
(248, '650', 'a', 'DCD', 'Temas (controlado)', 'auto', 1, 1, 0, 2, 1, 1, 101, '1bbf2189a2744958f7f4a5eab17b0f4a', 0, 1, ' alphanumeric_total:true ', 0),
(249, '653', 'a', 'DCD', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 2, 1, 1, NULL, 'd827b366de9a62b46f35d98fd3cca4bc', 0, 1, ' alphanumeric_total:true ', 0),
(250, '700', 'a', 'DCD', 'Autor secundario', 'auto', 1, 1, 0, 2, 1, 1, 106, '480c2a2a8f5025d4847b6f5445d53a02', 0, 1, ' alphanumeric_total:true ', 0),
(251, '700', 'e', 'DCD', 'Función', 'text', 0, 1, 0, 3, 1, 1, NULL, '2dbc9a57ba5d9b81e624585a90c0c423', 0, 1, ' alphanumeric_total:true ', 0),
(252, '110', 'a', 'DCD', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 107, 'fb0ec3bfa41a301eca2b871eeaff3ede', 0, 1, ' alphanumeric_total:true ', 0),
(253, '110', 'b', 'DCD', 'Entidad subordinada', 'auto', 1, 1, 0, 3, 1, 1, 108, 'fe5d1af48488acdf6ba5d6cfdb212b54', 0, 1, ' alphanumeric_total:true ', 0),
(254, '041', 'a', 'DCD', 'Idioma', 'combo', 1, 2, 0, 1, 1, 1, 109, '1bc8a25f686f436744d7b529c45f0dbe', 0, 1, ' alphanumeric_total:true ', 0),
(255, '260', 'a', 'DCD', 'Lugar ', 'text', 0, 2, 0, 2, 1, 1, NULL, '1912d7b1406c1e6b4db9c4f449497fbc', 0, 1, ' alphanumeric_total:true ', 0),
(256, '260', 'b', 'DCD', 'Editor', 'text', 0, 2, 0, 3, 1, 1, NULL, '0b5d0008268a956661c386eb9e028786', 0, 1, ' alphanumeric_total:true ', 0),
(257, '260', 'c', 'DCD', 'Fecha ', 'text', 0, 2, 0, 4, 1, 1, NULL, '0c38b9e0add94b98d79311245b29e5b7', 0, 1, ' alphanumeric_total:true ', 0),
(258, '300', 'a', 'DCD', 'Extensión/Páginas', 'text', 0, 2, 0, 5, 1, 1, NULL, 'b511d53be952b277e5d563a846c32c77', 0, 1, ' alphanumeric_total:true ', 0),
(259, '440', 'a', 'DCD', 'Serie', 'text', 0, 2, 0, 6, 1, 1, NULL, '36dfcca8f57a30dafc57e3247cdfd9f7', 0, 1, ' alphanumeric_total:true ', 0),
(260, '440', 'p', 'DCD', 'Subserie', 'text', 0, 2, 0, 7, 1, 1, NULL, '4d9d520745e72cd9772478d30ad2ea78', 0, 1, ' alphanumeric_total:true ', 0),
(261, '440', 'v', 'DCD', 'Número', 'text', 0, 2, 0, 8, 1, 1, NULL, '530657e9fbf30df062105db336525a91', 0, 1, ' alphanumeric_total:true ', 0),
(262, '500', 'a', 'DCD', 'Nota general ', 'text', 0, 2, 0, 9, 1, 1, NULL, '72232966314ddd76b9e8415bcf4d78aa', 0, 1, ' alphanumeric_total:true ', 0),
(263, '900', 'b', 'DCD', 'Nivel bibliografico', 'text', 0, 2, 0, 10, 1, 1, NULL, 'ad014a05d2a21cc7aa07ecd655def9e4', 0, 1, ' alphanumeric_total:true ', 0),
(264, '910', 'a', 'DCD', 'Tipo de documento', 'text', 0, 2, 1, 6, 1, 1, NULL, 'c695d0ce05cf0c87867c119192cf83f1', 1, 1, ' alphanumeric_total:true ', 0),
(265, '080', 'a', 'TES', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, '3bf5051f7db74faed5931613b905bc6e', 0, 1, ' alphanumeric_total:true ', 0),
(266, '100', 'a', 'TES', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 119, '4713353344e672c60b12476570671c33', 0, 1, ' alphanumeric_total:true ', 0),
(267, '100', 'd', 'TES', 'Fecha de nacimiento y muerte', 'calendar', 0, 1, 0, 3, 1, 1, NULL, '92035ccdf9cde6432cf59470e9b1c401', 0, 1, ' alphanumeric_total:true ', 0),
(268, '700', 'a', 'TES', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 2, 1, 1, 114, '8b182290b35d9f458c4fc58892fa3994', 0, 1, ' alphanumeric_total:true ', 0),
(269, '700', 'e', 'TES', 'Función', 'text', 0, 1, 0, 2, 1, 1, NULL, 'c9a8747e61ef069566a74ff08add9d89', 0, 1, ' alphanumeric_total:true ', 0),
(270, '650', 'a', 'TES', 'Temas (controlado)', 'auto', 1, 1, 0, 2, 1, 1, 117, '1fb052e60f604f631c3785a98df90f84', 0, 1, ' alphanumeric_total:true ', 0),
(271, '653', 'a', 'TES', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 2, 1, 1, NULL, '4b69608689208bbc715b7a8d85a2ecaf', 0, 1, ' alphanumeric_total:true ', 0),
(272, '041', 'a', 'TES', 'Idioma', 'combo', 1, 2, 0, 2, 1, 1, 118, 'd11c085eebaa452a7b4986c5f84afb8c', 0, 1, ' digits:true ', 0),
(273, '260', 'a', 'TES', 'Lugar', 'auto', 1, 2, 0, 3, 1, 1, 120, '71a869e7f105ef5f97faf75b910c9380', 0, 1, ' alphanumeric_total:true ', 0),
(274, '260', 'b', 'TES', 'Editor', 'text', 0, 2, 0, 4, 1, 1, NULL, '9048aed9af70bf2733c789850102c0cd', 0, 1, ' alphanumeric_total:true ', 0),
(275, '260', 'c', 'TES', 'Fecha ', 'calendar', 0, 2, 0, 5, 1, 1, NULL, 'de448182a028ddc62f881a64446b3acc', 0, 1, ' dateITA:true ', 0),
(277, '502', 'b', 'TES', 'Tipo de grado', 'text', 0, 2, 0, 7, 1, 1, NULL, '1e3c38d59a684a80576b7f1c9577eaf3', 0, 1, ' alphanumeric_total:true ', 0),
(278, '502', 'c', 'TES', 'Nombre de la institución otorgante', 'text', 0, 2, 0, 8, 1, 1, NULL, '4d486d99dbaba9179db32cd96df4c97c', 0, 1, ' alphanumeric_total:true ', 0),
(279, '502', 'd', 'TES', 'Año de grado otorgado', 'text', 0, 2, 0, 9, 1, 1, NULL, '05f788ded9f65c5a139a39c70993738c', 0, 1, ' alphanumeric_total:true ', 0),
(280, '260', 'a', 'REV', 'Lugar', 'auto', 1, 2, 0, 15, 1, 1, 121, '372a9f2c8015cc3242c37ec660bc83c9', 0, 1, ' alphanumeric_total:true ', 0),
(281, '246', 'a', 'REV', 'Variante del título', 'text', 0, 1, 0, 2, 1, 1, NULL, '668171c193e270880a06b6996431e774', 0, 1, ' alphanumeric_total:true ', 0),
(282, '110', 'a', 'REV', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 124, '25320613319b16f3bbeb342ee91b1303', 0, 1, ' alphanumeric_total:true ', 0),
(283, '110', 'b', 'REV', 'Entidad subordinada', 'auto', 1, 1, 0, 2, 1, 1, 126, '443efa19185b98fee8a41a86d16a6425', 0, 1, ' alphanumeric_total:true ', 0),
(285, '863', 'a', 'REV', 'Volumen', 'text', 0, 2, 0, 16, 1, 1, NULL, '98a0b279468735013be9de9504e00bd1', 0, 1, ' alphanumeric_total:true ', 0),
(286, '863', 'b', 'REV', 'Número', 'text', 0, 2, 0, 17, 1, 1, NULL, '2bbd5daf8f10feb41b49653515ba2887', 0, 1, ' alphanumeric_total:true ', 0),
(287, '863', 'i', 'REV', 'Año', 'text', 0, 2, 0, 18, 1, 1, NULL, 'b19ac05e7f553256a6a2c5e3458524fa', 0, 1, ' alphanumeric_total:true ', 0),
(288, '041', 'a', 'REV', 'Código de idioma para texto o pista de sonido o título separado (R)', 'auto', 1, 2, 0, 19, 1, 1, 128, 'f27314e050fd60b21b56f5e445a00bd0', 0, 1, ' alphanumeric_total:true ', 0),
(289, '245', 'b', 'FOT', 'Resto del título (NR)', 'text', 0, 1, 0, 2, 1, 1, NULL, '88a27b9d27a76b5cae15f7f364a2ccbd', 0, 1, ' alphanumeric_total:true ', 0),
(290, '080', 'a', 'FOT', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, '4d45d15bfdb8ac5b43da43ca392e0c17', 0, 1, ' alphanumeric_total:true ', 0),
(292, '100', 'a', 'FOT', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 159, '1c776e09f1f10160e2ed4d0bb142238d', 0, 1, ' alphanumeric_total:true ', 0),
(293, '100', 'b', 'FOT', 'Numeración (NR)', 'text', 0, 1, 0, 3, 1, 1, NULL, 'ba95a5375d025f75e91a513b8ea24363', 0, 1, ' alphanumeric_total:true ', 0),
(294, '100', 'c', 'FOT', 'Títulos y otras palabras asociadas con el nombre (R)', 'text', 0, 1, 0, 2, 1, 1, NULL, 'cf6ba23a2c275073b7dc65dda42ff824', 0, 1, ' alphanumeric_total:true ', 0),
(295, '100', 'd', 'FOT', 'Fechas asociadas con el nombre (NR)', 'text', 0, 1, 0, 2, 1, 1, NULL, 'cb248ddf055e3ed7b3b890bfe4390516', 0, 1, ' alphanumeric_total:true ', 0),
(296, '110', 'a', 'FOT', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 160, '1ed441750cc808949c1934de696db4fd', 0, 1, ' alphanumeric_total:true ', 0),
(297, '110', 'b', 'FOT', 'Entidad subordinada', 'auto', 1, 1, 0, 2, 1, 1, 161, 'c0ab88c817a47ab84787b8f8788b0c7d', 0, 1, ' alphanumeric_total:true ', 0),
(299, '650', 'a', 'FOT', 'Temas (controlados)', 'auto', 1, 1, 0, 2, 1, 1, 162, '99f7c5e12cddef20e32d2999e2f712d3', 0, 1, ' alphanumeric_total:true ', 0),
(304, '653', 'a', 'FOT', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 5, 1, 1, NULL, 'd658571aa9daa2d9a9cde07f8749a3cd', 0, 1, ' alphanumeric_total:true ', 0),
(305, '700', 'a', 'FOT', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 6, 1, 1, 163, '39f025806bbc598b0a88c4fa1ca8f96b', 0, 1, ' alphanumeric_total:true ', 0),
(306, '700', 'b', 'FOT', 'Numeración', 'text', 0, 1, 0, 7, 1, 1, NULL, 'd310f0895a17ec29759339c4122c1528', 0, 1, ' alphanumeric_total:true ', 0),
(307, '700', 'c', 'FOT', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 8, 1, 1, NULL, '023cc3e4c877ed7b55960b447139e7f6', 0, 1, ' alphanumeric_total:true ', 0),
(308, '700', 'd', 'FOT', 'Fechas de nacimiento y muerte', 'calendar', 0, 1, 0, 9, 1, 1, NULL, '5a24ccdf144188630ac81d2e7b37f2cf', 0, 1, ' alphanumeric_total:true ', 0),
(309, '700', 'e', 'FOT', 'Función', 'text', 0, 1, 0, 10, 1, 1, NULL, '69e747d0fdb1d475236ce3fe25607671', 0, 1, ' alphanumeric_total:true ', 0),
(310, '900', 'b', 'FOT', 'Nivel bibliografico', 'combo', 1, 2, 0, 13, 1, 1, 164, 'c3606946ef2b6695c127f57e0a74afc9', 0, 1, ' alphanumeric_total:true ', 0),
(311, '910', 'a', 'FOT', 'Tipo de documento', 'combo', 1, 2, 1, 7, 1, 1, 165, '2962c3f1a040d491b10c00f5000a61a7', 1, 1, ' alphanumeric_total:true ', 0),
(312, '111', 'a', 'LIB', 'Nombre de la reunión', 'text', 0, 1, 0, 2, 1, 1, NULL, '58fef3280e991934f9639da16642bf47', 0, 1, ' alphanumeric_total:true ', 0),
(315, '111', 'n', 'FOT', 'Número de la reunión', 'text', 0, 1, 0, 3, 1, 1, NULL, 'b8a2e864b55385c8cd6633ca06c7f5cd', 0, 1, ' alphanumeric_total:true ', 0),
(316, '111', 'd', 'FOT', 'Fecha de la reunión', 'calendar', 0, 1, 0, 4, 1, 1, NULL, 'cf7426063068fc4a789320bf64e2615a', 0, 1, ' alphanumeric_total:true ', 0),
(317, '111', 'c', 'FOT', 'Lugar de la reunión', 'auto', 1, 1, 0, 5, 1, 1, 132, 'a3467909c71023b93b18fe234fab1c14', 0, 1, ' alphanumeric_total:true ', 0),
(318, '111', 'n', 'LIB', 'Número de la reunión', 'text', 0, 1, 0, 2, 1, 1, NULL, '8751c2ccd2ece8da7a19c2a20a839a4a', 0, 1, ' alphanumeric_total:true ', 0),
(319, '111', 'd', 'LIB', 'Fecha de la reunión', 'calendar', 0, 1, 0, 2, 1, 1, NULL, 'f9624e8e52ab15e934897f32122d6bcd', 0, 1, ' alphanumeric_total:true ', 0),
(320, '111', 'c', 'LIB', 'Lugar de la reunión', 'auto', 1, 1, 0, 2, 1, 1, 235, '1dbd53bb10384eeb711b7bc0d0072f29', 0, 1, ' alphanumeric_total:true ', 0),
(322, '910', 'a', 'ANA', 'Tipo de documento', 'combo', 1, 2, 1, 10, 1, 1, 250, '102655d2d2e23c7ab41878e4ad9c84b2', 1, 1, ' alphanumeric_total:true ', 0),
(323, '900', 'b', 'LIB', 'Nivel bibliografico', 'combo', 1, 2, 0, 20, 1, 1, 147, '6becd17a2634cb1d4f49d1266ee62c5b', 0, 1, ' alphanumeric_total:true ', 0),
(324, '260', 'a', 'LIB', 'Lugar', 'auto', 1, 2, 0, 18, 1, 1, 151, 'a7dba4ca62f31b094ec67c065b8244c8', 0, 1, ' alphanumeric_total:true ', 0),
(325, '260', 'b', 'LIB', 'Editor', 'auto', 1, 2, 0, 19, 1, 1, 257, '632546631c044616b8b15c5eaef2c5cb', 0, 1, ' digits:true ', 0),
(326, '260', 'c', 'LIB', 'Fecha ', 'text', 0, 2, 0, 20, 1, 1, NULL, 'ede39fc9c490e561b88f7ee281dd05be', 0, 1, ' alphanumeric_total:true ', 0),
(327, '505', 'a', 'LIB', 'Nota normalizada', 'text', 0, 2, 0, 20, 1, 1, NULL, 'cfec8cf48f982f278df0bdbf9b59545d', 0, 1, ' alphanumeric_total:true ', 0),
(328, '505', 'g', 'LIB', 'Volumen', 'text', 0, 2, 0, 21, 1, 1, NULL, '8567dd350b957fd789a94fbd8cb3920d', 0, 1, ' alphanumeric_total:true ', 0),
(329, '505', 't', 'LIB', 'Descripción del volumen', 'text', 0, 2, 0, 22, 1, 1, NULL, '62bf05615bba052b98d80a16db43c3df', 0, 1, ' alphanumeric_total:true ', 0),
(330, '505', 'a', 'FOT', 'Nota normalizada', 'text', 0, 2, 0, 15, 1, 1, NULL, '8af7cd0fc50c245beb151f7430a93d5e', 0, 1, ' alphanumeric_total:true ', 0),
(331, '505', 'g', 'FOT', 'Volumen', 'text', 0, 2, 0, 16, 1, 1, NULL, '26162739dd9f296f813a62dd5d38e17c', 0, 1, ' alphanumeric_total:true ', 0),
(332, '505', 't', 'FOT', 'Descripción del volumen', 'text', 0, 2, 0, 17, 1, 1, NULL, '6e3e5eeb564b4cf2aecf9af69b678ed5', 0, 1, ' alphanumeric_total:true ', 0),
(336, '080', 'a', 'CDR', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, 'fe4f17ce80b250817068c99894928289', 0, 1, ' alphanumeric_total:true ', 0),
(337, '100', 'a', 'CDR', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 171, 'dae39828da8dbd62e18626ed2a2d6f48', 0, 1, ' alphanumeric_total:true ', 0),
(338, '100', 'b', 'CDR', 'Numeración', 'text', 0, 1, 0, 2, 1, 1, NULL, '126ad0ebeea77d744ce0a12dae1a979b', 0, 1, ' alphanumeric_total:true ', 0),
(339, '100', 'c', 'CDR', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 2, 1, 1, NULL, '0cc7aab522c7e6523d07c1d1b45657aa', 0, 1, ' alphanumeric_total:true ', 0),
(340, '100', 'd', 'CDR', 'Fechas de nacimiento y muerte', 'text', 0, 1, 0, 2, 1, 1, NULL, '7110f52963568ed12ea0f9c029cf1447', 0, 1, ' alphanumeric_total:true ', 0),
(341, '110', 'a', 'CDR', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 173, '73351c532c5991d84434bc545c9bcc17', 0, 1, ' alphanumeric_total:true ', 0),
(342, '110', 'b', 'CDR', 'Entidad subordinada', 'auto', 1, 1, 0, 2, 1, 1, 175, '2ce80d26de7b9c31cfe19421c4a3ee1f', 0, 1, ' alphanumeric_total:true ', 0),
(343, '111', 'a', 'CDR', 'Nombre de la reunión', 'text', 0, 1, 0, 2, 1, 1, NULL, '369b8fa4495d95305622b3027e5dc72f', 0, 1, ' alphanumeric_total:true ', 0),
(344, '111', 'n', 'CDR', 'Número de la reunión', 'text', 0, 1, 0, 2, 1, 1, NULL, '766b036591dcccf6acc2e109403e61de', 0, 1, ' alphanumeric_total:true ', 0),
(345, '111', 'd', 'CDR', 'Fecha de la reunión', 'text', 0, 1, 0, 3, 1, 1, NULL, 'ad00dc0ad488023138b3e63226c35d50', 0, 1, ' alphanumeric_total:true ', 0),
(346, '111', 'c', 'CDR', 'Lugar de la reunión', 'auto', 1, 1, 0, 2, 1, 1, 177, '8ff959bb9cd5a88dfd78658af8b0e8bc', 0, 1, ' alphanumeric_total:true ', 0),
(347, '245', 'b', 'CDR', 'Resto del título', 'text', 0, 1, 0, 2, 1, 1, NULL, 'b4c85997493ddebd06280867f03b8cf2', 0, 1, ' alphanumeric_total:true ', 0),
(348, '650', 'a', 'CDR', 'Temas (controlado)', 'auto', 1, 1, 0, 2, 1, 1, 211, 'af1a9cad897645f35a382aecc13a19c6', 0, 1, ' alphanumeric_total:true ', 0),
(349, '653', 'a', 'CDR', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 2, 1, 1, NULL, 'f26c6fc8c6dc6f03804039f502c27d70', 0, 1, ' alphanumeric_total:true ', 0),
(350, '700', 'a', 'CDR', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 2, 1, 1, 181, 'f33c8e1cdb5fcf61c731de2229745a46', 0, 1, ' alphanumeric_total:true ', 0),
(351, '700', 'b', 'CDR', 'Número asociado al nombre', 'text', 0, 1, 0, 2, 1, 1, NULL, 'd5eafb260bf9e46108e79a28372035d5', 0, 1, ' alphanumeric_total:true ', 0),
(352, '700', 'c', 'CDR', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 2, 1, 1, NULL, '5fdc7d5eb2ad23dd7391f89d7e600bb0', 0, 1, ' alphanumeric_total:true ', 0),
(353, '700', 'd', 'CDR', 'Fechas de nacimiento y muerte', 'text', 0, 1, 0, 2, 1, 1, NULL, '619c8da4a2d0f7c3827ad983fa49da8c', 0, 1, ' alphanumeric_total:true ', 0),
(354, '700', 'e', 'CDR', 'Función', 'text', 0, 1, 0, 2, 1, 1, NULL, '5e647d19341462a3064d17c3b1a39782', 0, 1, ' alphanumeric_total:true ', 0),
(355, '020', 'a', 'CDR', 'ISBN', 'text', 0, 2, 0, 1, 1, 1, NULL, 'fee55477650e11ec9f2fd8c33fbb6255', 0, 1, ' alphanumeric_total:true ', 0),
(356, '041', 'a', 'CDR', 'Idioma', 'combo', 1, 2, 0, 2, 1, 1, 194, 'e380b75c8f6710835714437ee55f813f', 0, 1, ' alphanumeric_total:true ', 0),
(357, '245', 'h', 'CDR', 'Medio', 'combo', 1, 2, 0, 3, 1, 1, 195, '530f094bc48c793b573de0ee5fd44922', 0, 1, ' alphanumeric_total:true ', 0),
(358, '250', 'a', 'CDR', 'Edición', 'text', 0, 2, 0, 4, 1, 1, NULL, 'd9b0fefab015a978a03dd9498cf12582', 0, 1, ' alphanumeric_total:true ', 0),
(359, '260', 'a', 'CDR', 'Lugar', 'auto', 1, 2, 0, 5, 1, 1, 193, '0f7afc48fc856bef17040062562aca13', 0, 1, ' alphanumeric_total:true ', 0),
(360, '260', 'b', 'CDR', 'Editor', 'text', 0, 2, 0, 6, 1, 1, NULL, '6998617a088c9d0e8db8b72d9a0c9068', 0, 1, ' alphanumeric_total:true ', 0),
(361, '260', 'c', 'CDR', 'Fecha ', 'text', 0, 2, 0, 7, 1, 1, NULL, '900287ea7f144b1b27da72bc5ae56b34', 0, 1, ' alphanumeric_total:true ', 0),
(362, '440', 'a', 'CDR', 'Serie', 'text', 0, 2, 0, 8, 1, 1, NULL, '12d6a978a77fb11fb08cfef18a7b1bcb', 0, 1, ' alphanumeric_total:true ', 0),
(363, '440', 'p', 'CDR', 'Subserie', 'text', 0, 2, 0, 9, 1, 1, NULL, '320848a83845e32f13906866a8bdaad5', 0, 1, ' alphanumeric_total:true ', 0),
(364, '440', 'v', 'CDR', 'Número de la serie', 'text', 0, 2, 0, 10, 1, 1, NULL, '5d1f51d6041efde46e3116712ae1ad77', 0, 1, ' alphanumeric_total:true ', 0),
(365, '500', 'a', 'CDR', 'Nota general ', 'text', 0, 2, 0, 11, 1, 1, NULL, 'c5521745452bfd70c8907ced5f644213', 0, 1, ' alphanumeric_total:true ', 0),
(366, '505', 'a', 'CDR', 'Nota normalizada', 'text', 0, 2, 0, 12, 1, 1, NULL, '1c4a7675af85cab74bc58b105dafe3a6', 0, 1, ' alphanumeric_total:true ', 0),
(367, '505', 'g', 'CDR', 'Volumen', 'text', 0, 2, 0, 13, 1, 1, NULL, 'bbe3ddf7f9d885362518fb826601257e', 0, 1, ' alphanumeric_total:true ', 0),
(368, '505', 't', 'CDR', 'Descripción del volumen', 'text', 0, 2, 0, 14, 1, 1, NULL, '5b28e9f202592c69207905f1dc611cb4', 0, 1, ' alphanumeric_total:true ', 0),
(369, '900', 'b', 'CDR', 'nivel bibliografico', 'combo', 1, 2, 0, 15, 1, 1, 186, 'ee4115f3f164b311d57315cc779631ea', 0, 1, ' alphanumeric_total:true ', 0),
(371, '910', 'a', 'CDR', 'Tipo de documento', 'combo', 1, 2, 1, 7, 1, 1, 189, 'b018ddac638c1d6af58f3e84b34238af', 1, 1, ' alphanumeric_total:true ', 0),
(372, '043', 'c', 'LIB', 'País', 'combo', 1, 2, 0, 23, 1, 1, 197, 'f719c4e32af057260f957c79460ee965', 0, 1, ' alphanumeric_total:true ', 0),
(376, '650', 'a', 'ANA', 'Temas', 'auto', 1, 1, 0, 3, 1, 1, 215, '9d3cf36046777fc75e35b60b672892af', 0, 1, ' alphanumeric_total:true ', 0),
(379, '080', 'a', 'ANA', 'CDU', 'text', 0, 1, 0, 5, 1, 1, NULL, 'b4be3602917b255fc71650c6b4502e67', 0, 1, ' alphanumeric_total:true ', 0),
(382, '653', 'a', 'ANA', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 4, 1, 1, NULL, '7c579257812de2ba5c5cf98db6986ea5', 0, 1, ' alphanumeric_total:true ', 0),
(383, '700', 'a', 'ANA', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 4, 1, 1, 207, '22997abb9e23131b7fc77a7dc37beca8', 0, 1, ' alphanumeric_total:true ', 0),
(384, '700', 'e', 'ANA', 'Función', 'text', 0, 1, 0, 4, 1, 1, NULL, '1cae00cebdc27054b19a081cfc8fbf57', 0, 1, ' alphanumeric_total:true ', 0),
(385, '041', 'a', 'ANA', 'Idioma', 'combo', 1, 2, 0, 3, 1, 1, 208, 'ecbf4343e20f8d344f71ce2c184bd914', 0, 1, ' alphanumeric_total:true ', 0),
(391, '910', 'a', 'LIB', 'Tipo de documento', 'combo', 1, 2, 1, 13, 1, 1, 212, '2ac545d0ac9af315d139d38c904cb643', 1, 1, ' alphanumeric_total:true ', 0),
(393, '245', 'b', 'ELE', 'Resto del título', 'text', 0, 1, 0, 2, 1, 1, NULL, '0e9d06e5be41c8e8dd27105d59fe9501', 0, 1, ' alphanumeric_total:true ', 0),
(394, '110', 'a', 'ELE', 'Autor corporativo', 'auto', 1, 1, 0, 2, 1, 1, 220, 'f39871f82d76920d0c9385ab34948f86', 0, 1, ' alphanumeric_total:true ', 0),
(395, '110', 'b', 'ELE', 'Entidad subordinada', 'auto', 1, 1, 0, 3, 1, 1, 221, 'ef79741a7b05365668c1c725c2d23366', 0, 1, ' alphanumeric_total:true ', 0),
(401, '111', 'a', 'ELE', 'Nombre de la reunión', 'text', 0, 1, 0, 4, 1, 1, NULL, '2711d3fa3957d4866942a68337d6d576', 0, 1, ' alphanumeric_total:true ', 0),
(402, '111', 'n', 'ELE', 'Número de la reunión', 'text', 0, 1, 0, 5, 1, 1, NULL, '07ca1e4c318bf51a536189725b440b5e', 0, 1, ' alphanumeric_total:true ', 0),
(403, '111', 'd', 'ELE', 'Fecha de la reunión', 'text', 0, 1, 0, 6, 1, 1, NULL, '2ad33665f1f45296550a46f40a14a429', 0, 1, ' alphanumeric_total:true ', 0),
(404, '111', 'c', 'ELE', 'Lugar de la reunión', 'text', 0, 1, 0, 7, 1, 1, NULL, '6776b988069fc4e96078554001654fba', 0, 1, ' alphanumeric_total:true ', 0),
(405, '650', 'a', 'ELE', 'Temas (controlado)', 'auto', 1, 1, 0, 8, 1, 1, 224, 'fb3d84dd3846f30b32b0b38976a824dd', 0, 1, ' alphanumeric_total:true ', 0),
(406, '653', 'a', 'ELE', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 9, 1, 1, NULL, 'b678e0ae292554094a72a2571c0d11c8', 0, 1, ' alphanumeric_total:true ', 0),
(407, '700', 'a', 'ELE', 'Autor secundario/Colaboradores', 'auto', 1, 1, 0, 10, 1, 1, 223, '1d72d56ab5f7e8f34ecb3c503caaa00f', 0, 1, ' alphanumeric_total:true ', 0),
(408, '700', 'e', 'ELE', 'Función', 'text', 0, 1, 0, 11, 1, 1, NULL, 'c19657299c72a0d1e60c1a16663e5f23', 0, 1, ' alphanumeric_total:true ', 0),
(409, '041', 'a', 'ELE', 'Idioma', 'combo', 1, 2, 0, 1, 1, 1, 225, 'aff5f872f3bf3df88570d547a3e4f025', 0, 1, ' alphanumeric_total:true ', 0),
(410, '043', 'c', 'ELE', 'País', 'combo', 1, 2, 0, 2, 1, 1, 226, 'a035134c45b7dc1dc6ec16dcf611eefa', 0, 1, ' alphanumeric_total:true ', 0),
(411, '245', 'h', 'ELE', 'Medio', 'combo', 1, 2, 0, 3, 1, 1, 227, '2e39bf987edb9f917e613bff3ca19490', 0, 1, ' alphanumeric_total:true ', 0),
(412, '260', 'a', 'ELE', 'Lugar ', 'auto', 1, 2, 0, 4, 1, 1, 228, 'c09a3c4b035a6faecdbcab2f4267ee44', 0, 1, ' alphanumeric_total:true ', 0),
(413, '260', 'b', 'ELE', 'Editor', 'text', 0, 2, 0, 5, 1, 1, NULL, 'c4a21e6bdb9a89450b4c14acc4209b7a', 0, 1, ' alphanumeric_total:true ', 0),
(414, '260', 'c', 'ELE', 'Fecha ', 'text', 0, 2, 0, 6, 1, 1, NULL, '4a34cdecc351107b3bee7004420ba7d6', 0, 1, ' alphanumeric_total:true ', 0),
(415, '300', 'a', 'ELE', 'Páginas', 'text', 0, 2, 0, 7, 1, 1, NULL, 'b633ef10c152201f8c5406b97cdc9019', 0, 1, ' alphanumeric_total:true ', 0),
(416, '500', 'a', 'ELE', 'Nota general ', 'text', 0, 2, 0, 8, 1, 1, NULL, 'da0c83346dc93562ac009c4b7109687a', 0, 1, ' alphanumeric_total:true ', 0),
(417, '900', 'b', 'ELE', 'nivel bibliografico', 'combo', 1, 2, 0, 9, 1, 1, 229, '04fd89e264131a605052d33b861f7dbe', 0, 1, ' alphanumeric_total:true ', 0),
(418, '910', 'a', 'ELE', 'Tipo de documento', 'combo', 1, 2, 1, 6, 1, 1, 230, 'ea8d903dc272eab3544d572778529e55', 1, 1, ' alphanumeric_total:true ', 0),
(419, '863', 'a', 'ELE', 'Volumen', 'text', 0, 2, 0, 11, 1, 1, NULL, 'f86d9bddcd633c5c517fac1a77cb96d2', 0, 1, ' alphanumeric_total:true ', 0),
(420, '863', 'b', 'ELE', 'Número', 'text', 0, 2, 0, 12, 1, 1, NULL, '89e33dc44c448e20b81d33e7722fef86', 0, 1, ' alphanumeric_total:true ', 0),
(421, '863', 'i', 'ELE', 'Año', 'text', 0, 2, 0, 13, 1, 1, NULL, 'cd1bfe2c4c741b21f14e42a71b919092', 0, 1, ' alphanumeric_total:true ', 0),
(422, '100', 'a', 'LIB', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 282, 'e6e5f6ffdaf060db3d18148da10e18c2', 0, 1, ' digits:true ', 0),
(423, '100', 'a', 'ELE', 'Autor', 'auto', 1, 1, 0, 2, 1, 1, 234, 'c80c9a9eb6ff3d2b538a0af1d25cddd6', 0, 1, ' alphanumeric_total:true ', 0),
(424, '440', 'a', 'ELE', 'Serie', 'text', 0, 2, 0, 14, 1, 1, NULL, '73adf86aa3fee78abc386e1613c114c7', 0, 1, ' alphanumeric_total:true ', 0),
(425, '440', 'p', 'ELE', 'Subserie', 'text', 0, 2, 0, 15, 1, 1, NULL, 'df4b32147a3988867ee4a5be76c98e9e', 0, 1, ' alphanumeric_total:true ', 0),
(426, '440', 'v', 'ELE', 'Número de la serie', 'text', 0, 2, 0, 16, 1, 1, NULL, 'a0bf78317d22720bf5babf1d0569448a', 0, 1, ' alphanumeric_total:true ', 0),
(427, '022', 'a', 'ELE', 'ISSN', 'text', 0, 2, 0, 17, 1, 1, NULL, 'd2b395f0c58866b3e0de362972a8ecfc', 0, 1, ' alphanumeric_total:true ', 0),
(428, '534', 'a', 'LIB', 'Nota/Versión original', 'text', 0, 1, 0, 22, 1, 1, NULL, '74381a3cd860eaec92d76a05b412dc86', 0, 1, ' alphanumeric_total:true ', 0),
(429, '210', 'a', 'REV', 'Título abreviado', 'text', 0, 1, 0, 10, 1, 1, NULL, '8dbde1bbbb84e0604527cbd6aec35fe4', 0, 1, ' alphanumeric_total:true ', 0),
(430, '222', 'a', 'REV', 'Título clave', 'text', 0, 1, 0, 11, 1, 1, NULL, '9c2d22c1f9c98ebd1e91d67ae5d7ec6c', 0, 1, ' alphanumeric_total:true ', 0),
(431, '222', 'b', 'REV', 'Calificador (cualificador)', 'text', 0, 1, 0, 12, 1, 1, NULL, 'cbd483aa663c42f17067d81fd11442d5', 0, 1, ' alphanumeric_total:true ', 0),
(432, '856', 'u', 'ELE', 'URL/URI', 'text', 0, 1, 0, 14, 1, 1, NULL, '11e47f9dc7f2434b1d40ab6a120c555f', 0, 1, ' alphanumeric_total:true ', 0),
(433, '247', 'a', 'REV', 'Título anterior', 'text', 0, 1, 0, 13, 1, 1, NULL, 'f97ec3e9e67a0c13c667883670f39f2b', 0, 1, ' alphanumeric_total:true ', 0),
(434, '247', 'f', 'REV', 'Fecha o designación secuencial ', 'text', 0, 1, 0, 14, 1, 1, NULL, '3712d44e244619fc5d02608a1b05dd2f', 0, 1, ' alphanumeric_total:true ', 0),
(435, '247', 'g', 'REV', 'Información miscelánea ', 'text', 0, 1, 0, 15, 1, 1, NULL, '7747e124b039057ba81c5673b5bf3bd7', 0, 1, ' alphanumeric_total:true ', 0),
(436, '247', 'x', 'REV', 'ISSN ', 'text', 0, 1, 0, 16, 1, 1, NULL, '47118f26e7ff622b348cfab31bc60332', 0, 1, ' alphanumeric_total:true ', 0),
(437, '321', 'a', 'REV', 'Frecuencia anterior de publicación ', 'text', 0, 1, 0, 17, 1, 1, NULL, '727c84a7597ac06669ddf6905962ad4b', 0, 1, ' alphanumeric_total:true ', 0),
(438, '321', 'b', 'REV', 'Fechas de frecuencia anterior de publicación ', 'text', 0, 1, 0, 18, 1, 1, NULL, '7f3eac03346ccdf75e320ca6b16c8359', 0, 1, ' alphanumeric_total:true ', 0),
(442, '245', 'b', 'REV', 'Resto del título', 'text', 0, 1, 0, 19, 1, 1, NULL, 'ff987e541f1901291471d8c232f7edd9', 0, 1, ' alphanumeric_total:true ', 0),
(443, '080', 'a', 'SEM', 'CDU', 'text', 0, 1, 0, 2, 1, 1, NULL, '91d48d06df795565192d01069575f2de', 0, 1, ' alphanumeric_total:true ', 0),
(444, '100', 'a', 'SEM', 'Autor', 'auto', 1, 1, 0, 3, 1, 1, 239, 'a99fa365b6d5983d71a3cb801819356e', 0, 1, ' digits:true ', 0),
(445, '100', 'b', 'SEM', 'Numeración', 'text', 0, 1, 0, 4, 1, 1, NULL, '166914d05f9914a6378f214737a8cb52', 0, 1, ' alphanumeric_total:true ', 0),
(446, '100', 'c', 'SEM', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 5, 1, 1, NULL, '73dc5edb10bb1e8cd60ccc6fa4368e4d', 0, 1, ' alphanumeric_total:true ', 0),
(447, '100', 'd', 'SEM', 'Fechas asociadas con el nombre ', 'text', 0, 1, 0, 6, 1, 1, NULL, '8b70ecb65ab8ee927985f26675747477', 0, 1, ' alphanumeric_total:true ', 0),
(448, '110', 'a', 'SEM', 'Autor corporativo', 'auto', 1, 1, 0, 7, 1, 1, 240, '8df638839079ba4812ab6ae94f359d0d', 0, 1, ' digits:true ', 0),
(449, '110', 'b', 'SEM', 'Entidad subordinada', 'auto', 1, 1, 0, 8, 1, 1, 241, '39f2a5a7fcd16932854209b13a924ce8', 0, 1, ' digits:true ', 0),
(450, '245', 'b', 'SEM', 'Resto del título', 'text', 0, 1, 0, 9, 1, 1, NULL, 'd60a65446c0e668538130f80aaa4cc83', 0, 1, ' alphanumeric_total:true ', 0),
(451, '534', 'a', 'SEM', 'Nota/Versión original ', 'text', 0, 1, 0, 10, 1, 1, NULL, '884d36c500cb795c826ca12812159ab1', 0, 1, ' alphanumeric_total:true ', 0),
(452, '650', 'a', 'SEM', 'Temas (controlado)', 'auto', 1, 1, 0, 11, 1, 1, 242, '2fb13946cc1f31e4e45f3084e9ed3280', 0, 1, ' digits:true ', 0),
(453, '653', 'a', 'SEM', 'Palabras claves (no controlado)', 'text', 0, 1, 0, 12, 1, 1, NULL, 'e2b06c23ac15e56bc2ec025b7526ae31', 0, 1, ' alphanumeric_total:true ', 0),
(454, '700', 'a', 'SEM', 'Autor secundario/Colaboradores ', 'auto', 1, 1, 0, 13, 1, 1, 243, '74c4b7004e1fa4d305cf11a99faf2922', 0, 1, ' digits:true ', 0),
(455, '700', 'b', 'SEM', 'Número asociado al nombre', 'text', 0, 1, 0, 14, 1, 1, NULL, 'd99091826b2e1d37877fe1e792bb9603', 0, 1, ' alphanumeric_total:true ', 0),
(456, '700', 'c', 'SEM', 'Títulos y otras palabras asociadas con el nombre', 'text', 0, 1, 0, 15, 1, 1, NULL, '517da7c3805c69c75b9880c4b8e7e56c', 0, 1, ' alphanumeric_total:true ', 0),
(457, '700', 'd', 'SEM', 'Fecha de nacimento y muerte ', 'text', 0, 1, 0, 16, 1, 1, NULL, '793097a29726c68c75c4a3e518e4431a', 0, 1, ' alphanumeric_total:true ', 0),
(458, '700', 'e', 'SEM', 'Función', 'text', 0, 1, 0, 17, 1, 1, NULL, '858a0c16d6b7dc1f1edc09a448b417aa', 0, 1, ' alphanumeric_total:true ', 0),
(459, '020', 'a', 'SEM', 'ISBN', 'text', 0, 2, 0, 2, 1, 1, NULL, 'd4d9baacb5d9cc48430e3fbefe585eee', 0, 1, ' alphanumeric_total:true ', 0),
(460, '041', 'a', 'SEM', 'Idioma', 'combo', 1, 2, 0, 3, 1, 1, 244, 'ea6948ee70908327ce917a87b34b8a63', 0, 1, ' digits:true ', 0),
(461, '043', 'c', 'SEM', 'País', 'combo', 1, 2, 0, 4, 1, 1, 245, '5f1b2ebfa02d2be622da1ec0ae608061', 0, 1, ' digits:true ', 0),
(462, '245', 'h', 'SEM', 'Medio', 'combo', 1, 2, 0, 5, 1, 1, 246, '11850d0845f83e1cff14c4b7c12ec7ab', 0, 1, ' digits:true ', 0),
(463, '250', 'a', 'SEM', 'Edición', 'text', 0, 2, 0, 6, 1, 1, NULL, 'eee83eccff01c1c07e040a750c8524f9', 0, 1, ' alphanumeric_total:true ', 0),
(464, '260', 'a', 'SEM', 'Lugar', 'combo', 1, 2, 0, 7, 1, 1, 247, 'ea0b29b65a9fa65495e63f183a867e0d', 0, 1, ' digits:true ', 0),
(465, '260', 'b', 'SEM', 'Editor', 'text', 0, 2, 0, 8, 1, 1, NULL, 'ee87596f741ac2b186288ddb831a2f5c', 0, 1, ' alphanumeric_total:true ', 0),
(466, '260', 'c', 'SEM', 'Fecha', 'text', 0, 2, 0, 9, 1, 1, NULL, 'e39933c43829eaa22c2dccc7d72c5295', 0, 1, ' alphanumeric_total:true ', 0),
(467, '300', 'a', 'SEM', 'Extensión/Páginas', 'text', 0, 2, 0, 10, 1, 1, NULL, 'e2e1018136580c1430cdf68d63de1ab8', 0, 1, ' alphanumeric_total:true ', 0),
(468, '300', 'b', 'SEM', 'Otros detalles físicos', 'text', 0, 2, 0, 11, 1, 1, NULL, '5877ad881a6252df97f45b0a0fcab03b', 0, 1, ' alphanumeric_total:true ', 0),
(469, '300', 'c', 'SEM', 'Dimensiones', 'text', 0, 2, 0, 12, 1, 1, NULL, '07d02141d3c2ed5dca9b4115ecbe6a29', 0, 1, ' alphanumeric_total:true ', 0),
(470, '440', 'a', 'SEM', 'Serie ', 'text', 0, 2, 0, 13, 1, 1, NULL, '0b7b5ca98dea318be167187592b30a41', 0, 1, ' alphanumeric_total:true ', 0),
(471, '440', 'p', 'SEM', 'Subserie', 'text', 0, 2, 0, 14, 1, 1, NULL, '395a42af2332534bd9408b67fb4f1cc0', 0, 1, ' alphanumeric_total:true ', 0),
(472, '440', 'v', 'SEM', 'Número de la serie', 'text', 0, 2, 0, 15, 1, 1, NULL, 'da1855e0a34a6750d37d2454a8b52b80', 0, 1, ' alphanumeric_total:true ', 0),
(473, '500', 'a', 'SEM', 'Nota general', 'text', 0, 2, 0, 16, 1, 1, NULL, 'bc4b1a400cbdf1fdbb7719167571ad49', 0, 1, ' alphanumeric_total:true ', 0),
(474, '505', 'a', 'SEM', 'Nota normalizada', 'text', 0, 2, 0, 17, 1, 1, NULL, '087c1f8614cab0b4087c02a672c5bdcd', 0, 1, ' alphanumeric_total:true ', 0),
(475, '505', 'g', 'SEM', 'Volumen', 'text', 0, 2, 0, 18, 1, 1, NULL, '674c253be860d15b7dcb27ee97ccc0c9', 0, 1, ' alphanumeric_total:true ', 0),
(476, '505', 't', 'SEM', 'Descripción del volumen', 'text', 0, 2, 0, 19, 1, 1, NULL, '684232a770f9f50ccef7cd7729a7d74c', 0, 1, ' alphanumeric_total:true ', 0),
(477, '900', 'b', 'SEM', 'nivel bibliografico', 'combo', 1, 2, 0, 20, 1, 1, 248, 'e41e64f6180b4e7da0ad8c94e0ae032b', 0, 1, ' digits:true ', 0),
(478, '910', 'a', 'SEM', 'Tipo de documento', 'combo', 1, 2, 1, 11, 1, 1, 249, '5aa574f5d26fd89864d2b7b8e66aab25', 1, 1, ' digits:true ', 0),
(479, '041', 'a', 'FOT', 'Idioma', 'combo', 1, 2, 0, 18, 1, 1, 254, '2ee1ac3fffd5d70afdc53eab8d1102be', 0, 1, ' alphanumeric_total:true ', 0),
(480, '043', 'c', 'FOT', 'País', 'combo', 1, 2, 0, 19, 1, 1, 252, '5236b2fa12e780d3fde8f8ff2f04dc7c', 0, 1, ' digits:true ', 0),
(481, '245', 'h', 'FOT', 'Medio', 'combo', 1, 2, 0, 20, 1, 1, 255, 'fe0c12a9997c97284cc15056d43df3f8', 0, 1, ' digits:true ', 0),
(482, '100', 'a', 'ANA', 'Autor', 'auto', 1, 1, 0, 7, 1, 1, 256, '473d23493d6bfb2f8d85fa74355247b6', 0, 1, ' digits:true ', 0),
(484, '856', 'u', 'REV', 'URL/URI', 'text', 0, 1, 0, 20, 1, 1, NULL, '05a718ae024fae5101977ab22da24f6d', 0, 1, ' alphanumeric_total:true ', 0),
(485, '510', 'c', 'ANA', 'Ubicación dentro de la fuente (NR)', 'text', 0, 1, 0, 8, 1, 1, NULL, 'e3ae786bdbbf4a936ce66ef3e40a0793', 0, 1, ' alphanumeric_total:true ', 0),
(495, '900', 'g', 'ALL', 'Carga', 'text', 0, 3, 0, 9, 1, 1, NULL, '5f4501dba83f2874220cc9b19cd00ef8', 0, 1, ' alphanumeric_total:true ', 0),
(496, '900', 'h', 'ALL', 'Modificación/Baja', 'text', 0, 3, 0, 10, 1, 1, NULL, 'b98dec6e4f42ed7a2b3ee327aeb64a38', 0, 1, ' alphanumeric_total:true ', 0),
(497, '900', 'i', 'ALL', 'Notas del catalogador', 'texta', 0, 3, 0, 11, 1, 1, NULL, '844feb9851dab2abf4a22217d1acd79a', 0, 1, ' alphanumeric_total:true ', 0),
(498, '900', 'j', 'ALL', 'Control de registro', 'text', 0, 3, 0, 12, 1, 1, NULL, 'c23b19ef18069b9f15a05e77e0ee2a1a', 0, 1, ' alphanumeric_total:true ', 0),
(501, '995', 'c', 'LIB', 'Unidad de Información', 'combo', 1, 3, 1, 5, 1, 1, 281, '2e9cf9c285fae2c00b1c42d5a97e8aaf', 0, 1, ' alphanumeric_total:true ', 0),
(502, '995', 'd', 'LIB', 'Unidad de Información de Origen', 'combo', 1, 3, 1, 6, 1, 1, 280, 'd9630ffad0054eba402aa75bbf853ac8', 0, 1, ' alphanumeric_total:true ', 0),
(503, '245', 'b', 'ANA', 'Resto del título (NR)', 'text', 0, 1, 0, 10, 1, 1, NULL, '422dd620757f9e370c9dc75d66663ab5', 0, 1, ' alphanumeric_total:true ', 0),
(504, '859', 'e', 'REV', 'Procedencia', 'text', 0, 2, 0, 18, 1, 1, NULL, '5d8a8db60ef23b3070e2bc84151331e2', 0, 1, ' alphanumeric_total:true ', 0),
(505, '300', 'a', 'LIB', 'Extensión (R)', 'text', 0, 1, 0, 22, 1, 1, NULL, '53a617b4db8b919682ce8b832ca5738a', 0, 1, ' alphanumeric_total:true ', 0),
(506, '500', 'a', 'TES', 'Nota general (NR)', 'text', 0, 2, 0, 9, 1, 1, NULL, '0c0f49c942b12b425287196bc85ec9b2', 0, 1, ' alphanumeric_total:true ', 0),
(507, '910', 'a', 'TES', 'Tipo de documento', 'combo', 1, 2, 1, 10, 1, 1, 275, '638d3dc0e0faf0294476d80e3af02077', 0, 1, ' digits:true ', 0),
(508, '995', 'c', 'ALL', 'Unidad de Información', 'combo', 1, 3, 1, 5, 1, 1, 276, '143935d9a7a13fa47006651f0a30c811', 0, 1, ' digits:true ', 0),
(509, '995', 'd', 'ALL', 'Unidad de Información de Origen', 'combo', 1, 3, 1, 6, 1, 1, 277, 'abae75e9d28b17a939d5987d3b32ea46', 0, 1, ' digits:true ', 0),
(510, '995', 'e', 'ALL', 'Estado', 'combo', 1, 3, 1, 7, 1, 1, 279, 'faa66bd9eed267e6fdd1e1d3a8058934', 0, 1, ' digits:true ', 0),
(511, '995', 'f', 'ALL', 'Código de Barras', 'text', 0, 3, 0, 8, 1, 1, NULL, 'b5dfe1fda14b1063f531a1ac6ba27bcc', 0, 1, ' alphanumeric_total:true ', 0),
(512, '995', 'm', 'ALL', 'Fecha de acceso', 'text', 0, 3, 0, 9, 1, 1, NULL, 'be58c5a2149fcbf70bdf9f5cca4ff7e4', 0, 1, ' alphanumeric_total:true ', 0),
(513, '995', 'o', 'ALL', 'Disponibilidad', 'combo', 1, 3, 1, 10, 1, 1, 278, 'df8af7bf6e82ca41d87359dfee68ce6b', 0, 1, ' digits:true ', 0),
(514, '995', 'p', 'ALL', 'Precio de compra', 'text', 0, 3, 0, 11, 1, 1, NULL, '993015834fea443da73123010db786d9', 0, 1, ' alphanumeric_total:true ', 0),
(515, '995', 't', 'ALL', 'Signatura Topográfica', 'text', 0, 3, 0, 12, 1, 1, NULL, 'c3cc7e32ba65d58db46d05cf769c8fcb', 0, 1, ' alphanumeric_total:true ', 0),
(516, '995', 'u', 'ALL', 'Notas del item', 'texta', 0, 3, 0, 13, 1, 1, NULL, 'ba3cc59c5b706d8d74dd997a03ff2c44', 0, 1, ' alphanumeric_total:true ', 0),
(517, '856', 'u', 'ALL', 'URL/URI', 'text', 0, 1, 0, 2, 1, 1, NULL, '69cdc1146196bce382e8468b2b8da71e', 0, 1, ' alphanumeric_total:true ', 0),
(518, '310', 'a', 'REV', 'Frecuencia', 'text', 0, 1, 0, 22, 1, 1, NULL, '52593085e471cbc2385db33b127bac3e', 0, 1, ' alphanumeric_total:true ', 0),
(519, '020', 'a', 'LIB', 'ISBN', 'text', 0, 1, 0, 24, 1, 1, NULL, '01f5c03ff814761c1608c7f51671154c', 0, 1, ' alphanumeric_total:true ', 0),
(521, '022', 'a', 'REV', 'ISSN', 'text', 0, 2, 0, 17, 1, 1, NULL, '8870936569bbcccfa2ea0bbb0184fa62', 0, 1, ' alphanumeric_total:true ', 0),
(522, '300', 'a', 'ANA', 'Páginas', 'text', 0, 1, 0, 11, 1, 1, NULL, '0a12da437ffbb62e8d5d20660166cb85', 0, 1, ' alphanumeric_total:true ', 0),
(523, '245', 'b', 'TES', 'Resto del título', 'text', 0, 1, 0, 10, 1, 1, NULL, '39ae4cb5746a5a7f774e46222108b99b', 0, 1, ' alphanumeric_total:true ', 0),
(524, '856', 'u', 'REV', 'URL', 'text', 0, 2, 0, 14, 1, 1, NULL, '6cdd459cb7caaf4c55c5178b8c5c4d56', 0, 1, ' alphanumeric_total:true ', 0),
(525, '520', 'a', 'LIB', 'Nota de resumen', 'texta', 0, 1, 0, 25, 1, 1, NULL, '2ea98806ce4e42d6659319ed75427267', 0, 1, ' alphanumeric_total:true ', 0);

-- --------------------------------------------------------

--
-- Table structure for table `cat_favoritos_opac`
--

CREATE TABLE IF NOT EXISTS `cat_favoritos_opac` (
  `nro_socio` varchar(16) NOT NULL DEFAULT '',
  `id1` int(11) NOT NULL,
  PRIMARY KEY (`nro_socio`,`id1`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_favoritos_opac`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_historico_disponibilidad`
--

CREATE TABLE IF NOT EXISTS `cat_historico_disponibilidad` (
  `id_detalle` int(11) NOT NULL AUTO_INCREMENT,
  `id3` int(11) NOT NULL,
  `detalle` varchar(30) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tipo_prestamo` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_historico_disponibilidad`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_portada_registro`
--

CREATE TABLE IF NOT EXISTS `cat_portada_registro` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `isbn` varchar(50) DEFAULT NULL,
  `small` varchar(500) DEFAULT NULL,
  `medium` varchar(500) DEFAULT NULL,
  `large` varchar(500) DEFAULT NULL,
  UNIQUE KEY `id_2` (`id`),
  UNIQUE KEY `isbn` (`isbn`),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_portada_registro`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_rating`
--

CREATE TABLE IF NOT EXISTS `cat_rating` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nro_socio` varchar(32) NOT NULL,
  `id2` int(11) NOT NULL,
  `rate` float DEFAULT NULL,
  `review` text,
  `date` varchar(20) NOT NULL,
  `review_aprobado` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nro_socio` (`nro_socio`,`id2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_rating`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_ref_tipo_nivel3`
--

CREATE TABLE IF NOT EXISTS `cat_ref_tipo_nivel3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_doc` varchar(8) DEFAULT NULL,
  `nombre` mediumtext,
  `notforloan` smallint(6) DEFAULT NULL,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  `disponible` tinyint(1) NOT NULL DEFAULT '1',
  `enable_nivel3` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_tipo_doc` (`id_tipo_doc`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=24 ;

--
-- Dumping data for table `cat_ref_tipo_nivel3`
--

INSERT INTO `cat_ref_tipo_nivel3` (`id`, `id_tipo_doc`, `nombre`, `notforloan`, `agregacion_temp`, `disponible`, `enable_nivel3`) VALUES
(1, 'LIB', 'Libro', 0, NULL, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `cat_registro_marc_n1`
--

CREATE TABLE IF NOT EXISTS `cat_registro_marc_n1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `marc_record` text NOT NULL,
  `template` char(3) NOT NULL,
  `clave_unicidad` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-----------------------------------------------------

--
-- Table structure for table `cat_registro_marc_n2`
--

CREATE TABLE IF NOT EXISTS `cat_registro_marc_n2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  `indice` text,
  `indice_file_path` varchar(255) DEFAULT NULL,
  `template` char(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id1` (`id1`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;


-- --------------------------------------------------------

--
-- Table structure for table `cat_registro_marc_n2_analitica`
--

CREATE TABLE IF NOT EXISTS `cat_registro_marc_n2_analitica` (
  `cat_registro_marc_n2_id` int(11) NOT NULL,
  `cat_registro_marc_n1_id` int(11) NOT NULL,
  PRIMARY KEY (`cat_registro_marc_n2_id`,`cat_registro_marc_n1_id`),
  UNIQUE KEY `cat_registro_marc_n2_id` (`cat_registro_marc_n2_id`,`cat_registro_marc_n1_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cat_registro_marc_n2_analitica`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_registro_marc_n2_cover`
--

CREATE TABLE IF NOT EXISTS `cat_registro_marc_n2_cover` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id2` int(11) NOT NULL,
  `image_name` varchar(256) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `id2` (`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_registro_marc_n2_cover`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_registro_marc_n3`
--

CREATE TABLE IF NOT EXISTS `cat_registro_marc_n3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `marc_record` text NOT NULL,
  `id1` int(11) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `codigo_barra` varchar(255) NOT NULL,
  `signatura` varchar(255) DEFAULT NULL,
  `template` char(3) NOT NULL,
  `id2` int(11) NOT NULL,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cat_registro_marc_n3_n1` (`id1`),
  KEY `cat_registro_marc_n3_n2` (`id2`),
  KEY `id1` (`id1`),
  KEY `id2` (`id2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_registro_marc_n3`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_tema`
--

CREATE TABLE IF NOT EXISTS `cat_tema` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` mediumtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `cat_tema`
--


-- --------------------------------------------------------

--
-- Table structure for table `cat_visualizacion_intra`
--

CREATE TABLE IF NOT EXISTS `cat_visualizacion_intra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campo` char(3) DEFAULT NULL,
  `pre` varchar(255) DEFAULT NULL,
  `inter` varchar(255) DEFAULT NULL,
  `post` varchar(255) DEFAULT NULL,
  `subcampo` char(1) DEFAULT NULL,
  `vista_intra` varchar(255) DEFAULT NULL,
  `tipo_ejemplar` char(3) DEFAULT NULL,
  `orden` int(11) NOT NULL,
  `nivel` int(1) DEFAULT NULL,
  `vista_campo` varchar(255) DEFAULT NULL,
  `orden_subcampo` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campo_2` (`campo`,`subcampo`,`tipo_ejemplar`),
  UNIQUE KEY `campo_3` (`campo`,`subcampo`,`tipo_ejemplar`,`nivel`),
  UNIQUE KEY `campo_4` (`campo`,`subcampo`,`tipo_ejemplar`,`nivel`),
  KEY `campo` (`campo`,`subcampo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=350 ;

--
-- Dumping data for table `cat_visualizacion_intra`
--

INSERT INTO `cat_visualizacion_intra` (`id`, `campo`, `pre`, `inter`, `post`, `subcampo`, `vista_intra`, `tipo_ejemplar`, `orden`, `nivel`, `vista_campo`, `orden_subcampo`) VALUES
(1, '245', NULL, NULL, NULL, 'a', 'Título', 'ALL', 188, 1, 'Titulo', 1),
(24, '245', NULL, NULL, NULL, 'b', 'Resto del título', 'ALL', 188, 1, 'Titulo', 3),
(38, '250', NULL, NULL, NULL, 'a', 'Edición', 'LIB', 38, 2, 'Edición', 0),
(39, '260', ':&nbsp;', NULL, NULL, 'b', 'Editor', 'LIB', 54, 2, 'Lugar, editor y fecha', 2),
(40, '300', NULL, NULL, NULL, 'a', 'Descripción física', 'LIB', 346, 2, 'Páginas', 0),
(41, '440', '.&nbsp;', NULL, NULL, 'p', 'Subserie', 'LIB', 216, 2, 'Serie', 2),
(42, '440', '&nbsp;;&nbsp', NULL, '', 'v', 'Número', 'LIB', 216, 2, 'Serie', 3),
(43, '500', NULL, NULL, NULL, 'a', 'Notas', 'LIB', 244, 2, 'Nota general', 0),
(54, '505', NULL, NULL, NULL, 'a', 'Nota normalizada', 'LIB', 40, 2, 'Volumen/descripción', 0),
(58, '500', NULL, NULL, NULL, 'a', 'Notas', 'REV', 244, 2, 'Nota general', 0),
(61, '041', NULL, NULL, NULL, 'a', 'Idioma', 'REV', 66, 2, 'Idioma', 2),
(65, '362', NULL, NULL, NULL, 'a', 'Situación de la publicación', 'REV', 58, 2, 'Fecha de inicio - cese', 0),
(66, '910', NULL, NULL, NULL, 'a', 'Tipo de Documento', 'REV', 251, 2, NULL, 0),
(77, '650', ' -', NULL, ' -', 'a', 'Término controlado', 'ALL', 199, 1, 'Temas', 0),
(78, '653', ' -', NULL, ' -', 'a', 'Palabras claves (no controlado)', 'ALL', 298, 1, 'Palabras claves', 1),
(86, '245', ']', NULL, ']', 'h', 'DGM', 'LIB', 188, 1, 'TÍTULO PROPIAMENTE DICHO (NR)', 2),
(88, '110', '', NULL, '', 'b', 'Entidad subordinada', 'LIB', 78, 1, 'Autor corporativo', 2),
(90, '995', '', NULL, '', 'c', 'Unidad de Información', 'LIB', 309, 3, 'Datos del Ejemplar', 88),
(91, '995', '', NULL, '', 'd', 'Unidad de Información de Origen', 'LIB', 309, 3, 'Datos del Ejemplar', 89),
(92, '995', '', NULL, '', 'e', 'Estado', 'LIB', 309, 3, 'Datos del Ejemplar', 90),
(93, '995', '', NULL, '', 'f', 'Código de Barras', 'LIB', 309, 3, 'Datos del Ejemplar', 91),
(94, '995', '', NULL, '', 'o', 'Disponibilidad', 'LIB', 309, 3, 'Datos del Ejemplar', 92),
(95, '995', '', NULL, '', 't', 'Signatura Topográfica', 'LIB', 309, 3, 'Datos del Ejemplar', 93),
(101, '210', '', NULL, '', 'a', 'Título abreviado (NR)', 'REV', 78, 1, 'Titulo abreviado', 101),
(102, '222', '', NULL, '', 'a', 'Título clave (NR)', 'REV', 101, 1, 'Título clave', 102),
(103, '222', '', NULL, '', 'b', 'Calificador (o cualificador)', 'REV', 101, 1, 'Título clave', 103),
(104, '240', '', NULL, '', 'a', 'Título uniforme (NR)', 'REV', 102, 1, 'Título uniforme', 103),
(105, '246', '', NULL, '', 'a', 'Variantes del título', 'REV', 104, 1, 'Variantes del título', 105),
(106, '246', '', NULL, '', 'f', 'Designación del volumen, número, fecha', 'REV', 104, 1, 'Variantes del título', 106),
(107, '247', '', NULL, '', 'a', 'Título anterior', 'REV', 105, 1, 'Título anterior', 107),
(108, '247', '', NULL, '', 'f', 'Fecha o designación secuencial (NR)', 'REV', 105, 1, 'Título anterior', 108),
(109, '247', '', NULL, '', 'g', 'Información miscelánea (NR)', 'REV', 105, 1, 'Título anterior', 109),
(110, '247', '', NULL, '', 'x', 'ISSN (NR)', 'REV', 105, 1, 'Título anterior', 110),
(116, '700', '', NULL, '', 'e', 'Función', 'REV', 77, 1, 'Autores secundarios/Colaboradores', 3),
(130, '321', '', NULL, '', 'a', 'Frecuencia anterior de publicación (NR)', 'REV', 116, 1, 'Frecuencia anterior', 128),
(131, '321', '', NULL, '', 'b', 'Fechas de frecuencia anterior de publicación (NR)', 'REV', 116, 1, 'Frecuencia anterior', 129),
(148, '700', '', NULL, '', 'a', 'Autor secundario/Colaborador', 'FOT', 77, 1, 'Autores secundarios/Colaboradores', 1),
(149, '250', '', NULL, '', 'a', 'Edición', 'FOT', 38, 2, 'Edición', 149),
(150, '300', '', NULL, '', 'a', 'Descripción física', 'FOT', 346, 2, 'Páginas', 150),
(151, '440', '', NULL, '', 'a', 'Serie', 'FOT', 216, 2, 'Serie', 1),
(152, '500', '', NULL, '', 'a', 'Nota general', 'FOT', 244, 2, 'Nota general', 152),
(153, '773', '', NULL, '', 'a', 'Título (documento fuente)', 'FOT', 66, 2, 'Analíticas', 153),
(154, '773', '', NULL, '', 'd', 'Lugar, editor y fecha de la parte mayor', 'FOT', 66, 2, 'Analíticas', 154),
(155, '773', '', NULL, '', 'g', 'Ubicación de la parte', 'FOT', 66, 2, 'Analíticas', 155),
(156, '773', '', NULL, '', 't', 'Título y mención de la parte mayor', 'FOT', 66, 2, 'Analíticas', 156),
(160, '300', '', NULL, '', 'a', 'Descripción física', 'DCA', 346, 2, 'Páginas', 160),
(162, '440', '', NULL, '', 'a', 'Serie', 'DCA', 216, 2, 'Serie', 161),
(164, '700', '', NULL, '', 'a', 'Autor secundario', 'TES', 77, 1, 'Autores secundarios/Colaboradores', 164),
(165, '300', '', NULL, '', 'a', 'Extensión/Páginas', 'TES', 346, 2, 'Páginas', 165),
(167, '700', '', NULL, '', 'a', 'Autor secundario/Colaboradores', 'DCA', 77, 1, 'Autores secundarios/Colaboradores', 167),
(168, '041', '', NULL, '', 'a', 'Idioma', 'DCA', 66, 2, 'Idioma', 168),
(169, '500', '', NULL, '', 'a', 'Nota general', 'DCA', 244, 2, 'Nota general', 169),
(171, '910', '', NULL, '', 'a', 'Tipo de documento', 'DCA', 251, 2, 'Tipo de documento', 171),
(172, '900', '', NULL, '', 'b', 'Nivel bibliografico', 'DCA', 250, 2, 'Nivel bibliográfico', 172),
(173, '502', '', NULL, '', 'a', 'Nota de tesis', 'TES', 192, 2, 'Nota de tesis', 173),
(174, '502', '', NULL, '', 'b', 'Tipo de grado', 'TES', 192, 2, 'Nota de tesis', 174),
(175, '502', '', NULL, '', 'c', 'Nombre de la institución otorgante', 'TES', 192, 2, 'Nota de tesis', 175),
(176, '502', '', NULL, '', 'd', 'Año de grado otorgado', 'TES', 192, 2, 'Nota de tesis', 176),
(177, '100', '', NULL, '', 'a', 'Autor', 'TES', 1, 1, 'Autor', 1),
(179, '110', '', NULL, '', 'a', 'Autor corporativo', 'REV', 78, 1, 'Autor corporativo', 1),
(180, '863', '', NULL, '', 'a', 'Volumen', 'REV', 65, 2, 'Año, Vol., Número', 2),
(181, '863', '(', NULL, ')', 'b', 'Número', 'REV', 65, 2, 'Año, Vol., Número', 3),
(182, '863', '', NULL, '', 'i', 'Año', 'REV', 65, 2, 'Año, Vol., Número', 1),
(183, '100', '', NULL, '', 'a', 'Autor', 'FOT', 1, 1, 'Autor', 181),
(184, '100', ')', NULL, ')', 'd', 'Fechas de nacimiento y muerte', 'FOT', 1, 1, 'Autor', 184),
(185, '110', '', NULL, '', 'a', 'Autor corporativo', 'FOT', 78, 1, 'Autor corporativo', 185),
(186, '110', '', NULL, '', 'b', 'Entidad subordinada', 'FOT', 78, 1, 'Autor corporativo', 186),
(187, '700', ')', NULL, ')', 'e', 'Función', 'FOT', 77, 1, 'Autores secundarios/Colaboradores', 2),
(188, '110', '', NULL, '', 'a', 'Autor corporativo', 'LIB', 78, 1, 'Autor corporativo', 1),
(189, '260', '', NULL, '', 'b', 'Editor', 'FOT', 54, 2, 'Lugar, editor y fecha', 2),
(190, '020', '', NULL, '', 'a', 'ISBN', 'FOT', 221, 2, 'ISBN', 188),
(191, '505', '', NULL, '', 'a', 'Nota normalizada', 'FOT', 40, 2, 'Volumen/descripción', 191),
(192, '250', '', NULL, '', 'a', 'Edición', 'TES', 38, 2, 'Edición', 187),
(193, '020', '', NULL, '', 'a', 'ISBN', 'TES', 221, 2, 'ISBN', 193),
(194, '500', '', NULL, '', 'a', 'Nota general', 'TES', 244, 2, 'Nota general', 194),
(195, '111', '', NULL, '', 'a', 'Nombre de la reunión', 'LIB', 195, 1, 'Congresos, conferencias, etc.', 195),
(196, '111', '', NULL, '', 'n', 'Número de la reunión', 'LIB', 195, 1, 'Congresos, conferencias, etc.', 196),
(197, '111', '', NULL, '', 'd', 'Fecha de la reunión', 'LIB', 195, 1, 'Congresos, conferencias, etc.', 197),
(198, '111', '', NULL, '', 'c', 'Lugar de la reunión', 'LIB', 195, 1, 'Congresos, conferencias, etc.', 198),
(199, '700', '-', NULL, '-', 'a', 'Autor secundario/Colaborador', 'LIB', 77, 1, 'Autores secundarios/Colaboradores', 1),
(203, '700', ')', NULL, ')', 'e', 'Función', 'LIB', 77, 1, 'Autores secundarios/Colaboradores', 5),
(204, '111', '', NULL, '', '-', 'Autor secundario/Colaborador', 'FOT', 195, 1, 'Congresos, conferencias, etc.', 200),
(205, '111', '', NULL, '', 'n', 'Número de la reunión', 'FOT', 195, 1, 'Congresos, conferencias, etc.', 201),
(206, '111', '', NULL, '', 'd', 'Fecha de la reunión', 'FOT', 195, 1, 'Congresos, conferencias, etc.', 202),
(207, '111', '', NULL, '', 'c', 'Lugar de la reunión', 'FOT', 195, 1, 'Congresos, conferencias, etc.', 203),
(208, '505', 'v.&nbsp;', NULL, '', 'g', 'Volumen', 'LIB', 40, 2, 'Volumen/descripción', 205),
(209, '505', ':&nbsp;', NULL, '', 't', 'Descripción del volumen', 'LIB', 40, 2, 'Volumen/descripción', 206),
(210, '505', '', NULL, '', 'g', 'Volumen', 'FOT', 40, 2, 'Volumen/descripción', 207),
(211, '505', '', NULL, '', 't', 'Descripción del volumen', 'FOT', 40, 2, 'Volumen/descripción', 208),
(212, '260', '', NULL, '', 'b', 'Editor', 'REV', 54, 2, 'Lugar y editor', 2),
(213, '260', ',&nbsp;', NULL, '', 'c', 'Fecha', 'LIB', 54, 2, 'Lugar, editor y fecha', 3),
(216, '043', '', NULL, '', 'c', 'País', 'LIB', 43, 2, 'País', 216),
(217, '534', '&nbsp;', NULL, '', 'a', 'Nota/versión original', 'LIB', 217, 1, 'Nota/versión original', 217),
(218, '100', '', NULL, '', 'a', 'Autor', 'ANA', 1, 1, 'Autor', 218),
(219, '440', '', NULL, '', 'v', 'Número de la serie', 'FOT', 216, 2, 'Serie', 219),
(220, '440', '', NULL, '', 'p', 'Subserie', 'FOT', 216, 2, 'Serie', 220),
(221, '440', '', NULL, '', 'a', 'Serie', 'LIB', 216, 2, 'Serie', 1),
(222, '700', '', NULL, '', 'a', 'Autor secundario/Colaboradores', 'ANA', 77, 1, 'Autores secundarios/Colaboradores', 222),
(223, '700', '', NULL, '', 'e', 'Función', 'ANA', 77, 1, 'Autores secundarios/Colaboradores', 223),
(224, '110', '', NULL, '', 'a', 'Autor corporativo', 'ANA', 78, 1, 'Autor corporativo', 223),
(225, '110', '', NULL, '', 'b', 'Entidad subordinada', 'ANA', 78, 1, 'Autor corporativo', 224),
(226, '041', '', NULL, '', 'a', 'Idioma', 'ANA', 66, 2, 'Idioma', 225),
(227, '100', '', NULL, '', 'a', 'Autor', 'ELE', 1, 1, 'Autor', 226),
(228, '110', '', NULL, '', 'a', 'Autor corporativo', 'ELE', 78, 1, 'Autor corporativo', 228),
(229, '110', '', NULL, '', 'b', 'Entidad subordinada', 'ELE', 78, 1, 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 229),
(230, '111', '.', NULL, '.', 'a', 'Nombre de la reunión', 'ELE', 195, 1, 'Congresos, conferencias, etc.', 230),
(231, '111', '', NULL, '', 'n', 'Número de la reunión', 'ELE', 195, 1, 'Congresos, conferencias, etc.', 231),
(232, '111', '', NULL, '', 'd', 'Fecha de la reunión', 'ELE', 195, 1, 'Congresos, conferencias, etc.', 232),
(233, '111', '', NULL, '', 'c', 'Lugar de la reunión', 'ELE', 195, 1, 'Congresos, conferencias, etc.', 233),
(234, '260', '', NULL, '', 'a', 'Lugar', 'ELE', 54, 2, 'Lugar, editor y fecha', 231),
(235, '260', '', NULL, '', 'b', 'Editor', 'ELE', 54, 2, 'Lugar, editor y fecha', 232),
(236, '260', '', NULL, '', 'c', 'Fecha', 'ELE', 54, 2, 'Lugar, editor y fecha', 233),
(237, '043', '', NULL, '', 'c', 'País', 'ELE', 43, 2, 'País', 234),
(239, '500', '', NULL, '', 'a', 'Nota general', 'ELE', 244, 2, 'Nota general', 235),
(240, '863', '', NULL, '', 'a', 'Volumen', 'ELE', 65, 2, 'Año, vol. y nro.', 2),
(241, '863', ')', NULL, ')', 'b', 'Número', 'ELE', 65, 2, 'Año, vol. y nro.', 3),
(242, '863', '', NULL, '', 'i', 'Año', 'ELE', 65, 2, 'Año, vol. y nro.', 1),
(243, '700', ' -', NULL, ' -', 'a', 'Autor secundario/Colaboradores', 'ELE', 77, 1, 'Autores secundarios/Colaboradores', 239),
(244, '260', '', NULL, '', 'a', 'Lugar', 'LIB', 54, 2, 'Lugar, editor y fecha', 1),
(245, '440', '', NULL, '', 'a', 'Serie', 'ELE', 216, 2, 'Serie', 245),
(246, '440', '', NULL, '', 'p', 'Subserie', 'ELE', 216, 2, 'Serie', 246),
(247, '440', '', NULL, '', 'v', 'Número de la serie', 'ELE', 216, 2, 'Serie', 247),
(248, '022', '', NULL, '', 'a', 'ISSN', 'ELE', 255, 2, 'ISSN', 248),
(249, '080', '', NULL, '', 'a', 'CDU', 'LIB', 249, 1, 'CDU', 249),
(250, '910', '', NULL, '', 'a', 'Tipo de documento', 'LIB', 251, 2, 'Tipo de documento', 250),
(251, '900', '', NULL, '', 'b', 'nivel bibliografico', 'LIB', 250, 2, 'Nivel Bibliográfico', 251),
(252, '856', '', NULL, '', 'u', 'URL/URI', 'ELE', 349, 1, 'URL/URI', 252),
(253, '020', '', NULL, '', 'a', 'ISBN', 'ELE', 221, 2, 'ISBN', 253),
(254, '300', '', NULL, '', 'a', 'Extensión/Páginas', 'ELE', 346, 2, 'Páginas', 253),
(255, '260', '', NULL, ':&nbsp;', 'a', 'Lugar', 'REV', 54, 2, 'Lugar y editor', 1),
(257, '440', ')', NULL, ')', 'a', 'Serie', 'REV', 216, 2, 'Serie', 256),
(258, '900', '', NULL, '', 'b', 'nivel bibliografico', 'REV', 250, 2, 'Nivel Bibliográfico', 258),
(262, '502', '', NULL, '', 'a', 'Nota de tesis', 'ELE', 259, 2, 'Nota de tesis', 259),
(263, '502', '', NULL, '', 'b', 'Grado', 'ELE', 260, 2, 'Nota de tesis', 260),
(264, '502', '', NULL, '', 'c', 'Institución', 'ELE', 261, 2, 'Nota de tesis', 261),
(265, '502', '', NULL, '', 'd', 'Año', 'ELE', 262, 2, 'Nota de tesis', 262),
(267, '100', '', NULL, '', 'a', 'Autor', 'SEM', 1, 1, 'Autor', 264),
(268, '110', '', NULL, '', 'a', 'Autor corporativo', 'SEM', 78, 1, 'Autor corporativo', 268),
(269, '100', ')', NULL, ')', 'd', 'Fechas de nacimiento y muerte', 'SEM', 1, 1, 'ASIENTO PRINCIPAL - NOMBRE PERSONAL (NR)', 269),
(270, '110', '', NULL, '', 'b', 'Entidad subordinada', 'SEM', 78, 1, 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 270),
(272, '080', '', NULL, '', 'a', 'CDU', 'SEM', 249, 1, 'CDU', 269),
(273, '250', '', NULL, '', 'a', 'Edición', 'SEM', 38, 2, 'Edición', 270),
(274, '505', '', NULL, '', 'a', 'Nota normalizada', 'SEM', 40, 2, 'Nota normalizada', 271),
(275, '505', '', NULL, '', 'g', 'Volumen', 'SEM', 40, 2, 'NOTA DE CONTENIDOS FORMATEADA (R)', 272),
(276, '505', '', NULL, '', 't', 'Descripción del volumen', 'SEM', 40, 2, 'NOTA DE CONTENIDOS FORMATEADA (R)', 273),
(277, '260', '', NULL, '', 'a', 'Lugar', 'SEM', 54, 2, 'Lugar, editor y fecha', 274),
(278, '260', '', NULL, '', 'b', 'Editor', 'SEM', 54, 2, 'Lugar, editor y fecha', 275),
(279, '260', '', NULL, '', 'c', 'Fecha', 'SEM', 54, 2, 'Lugar, editor y fecha', 276),
(280, '440', '', NULL, '', 'a', 'Serie', 'SEM', 216, 2, 'Serie', 277),
(281, '440', '', NULL, '', 'p', 'Subserie', 'SEM', 216, 2, 'MENCIÓN DE SERIE/ASIENTO AGREGADA - TÍTULO (R) [OBSOLETE]', 278),
(282, '440', '', NULL, '', 'v', 'Número de la serie', 'SEM', 216, 2, 'MENCIÓN DE SERIE/ASIENTO AGREGADA - TÍTULO (R) [OBSOLETE]', 279),
(283, '043', '', NULL, '', 'c', 'País', 'SEM', 43, 2, 'País', 280),
(284, '300', '', NULL, '', 'a', 'Páginas', 'SEM', 346, 2, 'Páginas', 281),
(285, '900', '', NULL, '', 'b', 'nivel bibliografico', 'SEM', 250, 2, 'Nivel Bibliográfico', 282),
(286, '500', '', NULL, '', 'a', 'Nota general', 'SEM', 244, 2, 'NOTA GENERAL (R)', 283),
(287, '910', '', NULL, '', 'a', 'Tipo de documento', 'SEM', 251, 2, 'Tipo de documento', 284),
(288, '856', '', NULL, '', 'u', 'URL/URI', 'SEM', 349, 3, 'URI/URL', 285),
(289, '995', '', NULL, '', 'c', 'Unidad de Información', 'SEM', 309, 3, 'Datos del Ejemplar', 286),
(290, '995', '', NULL, '', 'd', 'Unidad de Información de Origen', 'SEM', 309, 3, 'Datos del Ejemplar', 287),
(291, '995', '', NULL, '', 'e', 'Estado', 'SEM', 309, 3, 'Datos del Ejemplar', 288),
(292, '995', '', NULL, '', 'f', 'Código de Barras', 'SEM', 309, 3, 'Datos del Ejemplar', 289),
(293, '995', '', NULL, '', 'm', 'Fecha de acceso', 'SEM', 309, 3, 'Datos del Ejemplar', 290),
(294, '995', '', NULL, '', 'o', 'Disponibilidad', 'SEM', 309, 3, 'Datos del Ejemplar', 291),
(295, '995', '', NULL, '', 't', 'Signatura Topográfica', 'SEM', 309, 3, 'Datos del Ejemplar', 292),
(296, '995', '', NULL, '', 'u', 'Notas del item', 'SEM', 309, 3, 'Datos del Ejemplar', 293),
(298, '520', '', NULL, '', 'a', 'Nota de resumen', 'LIB', 324, 1, 'Resumen', 294),
(299, '520', '', NULL, '', 'a', 'Nota de resumen', 'ELE', 324, 1, 'Resumen', 295),
(300, '520', '', NULL, '', 'a', 'Nota de resumen', 'DCD', 324, 1, 'Resumen', 296),
(301, '520', '', NULL, '', 'a', 'Nota de resumen', 'REV', 324, 1, 'Resumen', 297),
(302, '700', ')', NULL, ')', 'e', 'Función', 'TES', 77, 1, 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE PERSONAL (R)', 298),
(303, '520', '', NULL, '', 'a', 'Nota de resumen', 'TES', 324, 1, 'Nota de resumen', 299),
(304, '700', ')', NULL, ')', 'e', 'Función', 'ELE', 77, 1, 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE PERSONAL (R)', 300),
(309, '995', '', NULL, '', 't', 'Signatura Topográfica', 'ANA', 309, 1, 'Signatura topográfica', 301),
(311, '856', '', NULL, '', 'u', 'URL/URI', 'REV', 349, 2, 'URL/URI', 311),
(312, '510', '', NULL, '', 'c', 'Ubicación dentro de la fuente (NR)', 'ANA', 333, 1, 'Ubicación dentro de la fuente', 312),
(324, '856', '', NULL, '', 'u', 'URL/URI', 'LIB', 349, 1, 'URL/URI', 313),
(333, '300', '', NULL, '', 'a', 'Páginas', 'ANA', 346, 1, 'Páginas', 318),
(334, '859', '', NULL, '', 'e', 'Procedencia', 'REV', 344, 2, 'Procedencia', 334),
(335, '856', '', NULL, '', 'u', 'URL/URI', 'ALL', 349, 1, 'URL/URI', 335),
(344, '022', '', NULL, '', 'a', 'ISSN', 'REV', 255, 2, 'ISSN', 342),
(345, '310', '', NULL, '', 'a', 'Frecuencia', 'REV', 107, 1, 'Frecuencia', 345),
(346, '020', '', NULL, '', 'a', 'ISBN', 'LIB', 221, 2, 'ISBN', 346),
(349, '100', '', NULL, '', 'a', 'Autor', 'LIB', 1, 1, 'Autor', 347);

-- --------------------------------------------------------

--
-- Table structure for table `cat_visualizacion_opac`
--

CREATE TABLE IF NOT EXISTS `cat_visualizacion_opac` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campo` char(3) DEFAULT NULL,
  `tipo_ejemplar` char(3) DEFAULT NULL,
  `pre` varchar(255) DEFAULT NULL,
  `inter` varchar(255) DEFAULT NULL,
  `post` varchar(255) DEFAULT NULL,
  `subcampo` char(1) DEFAULT NULL,
  `vista_opac` varchar(255) DEFAULT NULL,
  `vista_campo` varchar(255) NOT NULL,
  `orden` int(11) NOT NULL,
  `orden_subcampo` int(11) NOT NULL,
  `nivel` int(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campo_2` (`campo`,`tipo_ejemplar`,`subcampo`,`nivel`),
  UNIQUE KEY `campo_3` (`campo`,`subcampo`,`tipo_ejemplar`,`nivel`),
  KEY `campo` (`campo`,`subcampo`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=289 ;

--
-- Dumping data for table `cat_visualizacion_opac`
--

INSERT INTO `cat_visualizacion_opac` (`id`, `campo`, `tipo_ejemplar`, `pre`, `inter`, `post`, `subcampo`, `vista_opac`, `vista_campo`, `orden`, `orden_subcampo`, `nivel`) VALUES
(215, '245', 'ALL', NULL, NULL, NULL, 'a', 'Título', 'Título', 65, 1, 1),
(216, '245', 'ALL', NULL, NULL, NULL, 'b', 'Resto del título', 'Título', 65, 3, 1),
(217, '260', 'ALL', NULL, NULL, ' :', 'a', 'Lugar', 'Lugar, editor y fecha', 19, 1, 2),
(218, '995', 'ALL', NULL, NULL, NULL, 'd', 'Unidad de Información de Origen', ' ', 128, 0, 3),
(219, '910', 'ALL', NULL, NULL, NULL, 'a', 'Tipo de Documento', ' ', 130, 0, 2),
(220, '440', 'ALL', NULL, NULL, NULL, 'a', 'Serie', 'Serie', 46, 0, 2),
(221, '650', 'ALL', NULL, NULL, NULL, 'a', 'Tema', 'Temas', 132, 0, 1),
(222, '260', 'ALL', ':&nbsp;', NULL, ',', 'b', 'Editor', 'Lugar, editor y fecha', 19, 2, 2),
(223, '995', 'LIB', NULL, NULL, NULL, 't', 'Signatura Topográfica', ' ', 128, 0, 3),
(224, '110', 'LIB', NULL, NULL, NULL, '-', 'Autor corporativo', 'Autor corporativo', 34, 34, 1),
(225, '653', 'LIB', NULL, NULL, NULL, '-', 'Palabras claves', 'Palabras claves', 50, 36, 1),
(226, '080', 'LIB', NULL, NULL, NULL, 'a', 'CDU', 'CDU', 135, 37, 1),
(227, '250', 'LIB', NULL, NULL, NULL, 'a', 'Edición', 'Edición', 6, 39, 2),
(228, '300', 'LIB', NULL, NULL, NULL, 'a', 'Extensión/Páginas', 'Páginas', 43, 43, 2),
(229, '440', 'LIB', '.&nbsp;', NULL, ' ;', 'p', 'Subserie', 'Serie', 46, 44, 2),
(230, '440', 'LIB', '&nbsp;;&nbsp', NULL, ')', 'v', 'Número de la serie', 'Serie', 46, 45, 2),
(231, '500', 'LIB', NULL, NULL, NULL, 'a', 'Notas', 'Notas', 85, 44, 2),
(232, '111', 'LIB', NULL, NULL, NULL, 'a', 'Nombre de la reunión', 'Nombre de la reunión', 36, 48, 1),
(233, '111', 'LIB', NULL, NULL, NULL, 'n', 'Número de la reunión', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 36, 49, 1),
(234, '505', 'LIB', 'v.&nbsp;', NULL, NULL, 'g', 'Volumen', 'Volumen/Descripción', 13, 51, 2),
(235, '505', 'LIB', ':&nbsp;', NULL, NULL, 't', 'Descripción del volumen', 'Volumen/Descripción', 13, 52, 2),
(236, '110', 'CDR', NULL, NULL, NULL, 'a', 'Autor corporativo', 'Autor corporativo', 34, 53, 1),
(237, '110', 'CDR', NULL, NULL, NULL, 'b', 'Entidad subordinada', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 34, 54, 1),
(238, '653', 'CDR', NULL, NULL, NULL, 'a', 'Palabras claves', 'Palabras claves', 50, 55, 1),
(239, '245', 'LIB', NULL, NULL, NULL, 'h', 'Medio', 'TÍTULO PROPIAMENTE DICHO (NR)', 65, 60, 1),
(240, '534', 'LIB', NULL, NULL, NULL, 'a', 'Nota/versión original', 'Nota/versión original', 37, 61, 1),
(241, '022', 'ELE', NULL, NULL, NULL, 'a', 'ISSN', 'ISSN', 108, 62, 2),
(242, '700', 'ELE', NULL, NULL, NULL, 'a', 'Autor secundario/Colaboradores', 'Autores secundarios/Colaboradores', 25, 1, 1),
(243, '110', 'LEG', NULL, NULL, NULL, 'a', 'Autor corporativo', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 34, 79, 1),
(244, '110', 'LIB', NULL, NULL, NULL, 'a', 'Autor corporativo', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 34, 66, 1),
(245, '110', 'LIB', NULL, NULL, NULL, 'b', 'Entidad subordinada', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 34, 67, 1),
(246, '043', 'LIB', NULL, NULL, NULL, 'c', 'País', 'País', 42, 66, 2),
(247, '110', 'REV', NULL, NULL, NULL, 'a', 'Autor corporativo', 'Autor corporativo', 34, 86, 1),
(248, '110', 'REV', NULL, NULL, NULL, 'b', 'Entidad subordinada', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 34, 87, 1),
(249, '210', 'REV', NULL, NULL, NULL, 'a', 'Título abreviado', 'Título abreviado', 90, 88, 1),
(250, '222', 'REV', NULL, NULL, NULL, 'b', 'Calificador (cualificador)', 'Título clave', 91, 90, 1),
(251, '240', 'REV', NULL, NULL, NULL, 'a', 'Título uniforme', 'Título uniforme', 92, 91, 1),
(252, '246', 'REV', NULL, NULL, NULL, 'a', 'Variante del título', 'Variantes del título', 113, 92, 1),
(253, '100', 'ELE', NULL, NULL, NULL, 'a', 'Autor', 'Autor', 1, 93, 1),
(254, '110', 'ELE', NULL, NULL, NULL, 'a', 'Autor corporativo', 'Autor corporativo', 34, 94, 1),
(255, '653', 'ELE', NULL, NULL, NULL, 'a', 'Palabras claves (no controlado)', 'Palabras claves', 50, 95, 1),
(256, '856', 'ELE', NULL, NULL, NULL, 'u', 'URL/URI', 'URL/URI', 136, 96, 1),
(257, '043', 'ELE', NULL, NULL, NULL, 'c', 'País', 'País', 42, 97, 2),
(258, '500', 'ELE', NULL, NULL, NULL, 'a', 'Nota general', 'Nota general', 85, 98, 2),
(259, '863', 'ELE', NULL, NULL, NULL, 'i', 'Año', 'Año, vol., nro.', 19, 99, 2),
(260, '863', 'ELE', NULL, NULL, NULL, 'a', 'Volumen', 'Año, vol., nro.', 19, 100, 2),
(261, '863', 'ELE', ')', NULL, ')', 'b', 'Número', 'Año, vol., nro.', 19, 101, 2),
(262, '300', 'ELE', NULL, NULL, NULL, 'a', 'Extensión/Páginas', 'Páginas', 43, 102, 2),
(263, '310', 'REV', NULL, NULL, NULL, 'a', 'Frecuencia-Periodicidad', 'Frecuencia actual de la publicación', 13, 103, 2),
(264, '310', 'REV', NULL, NULL, NULL, 'b', 'Fecha de frecuencia actual de la publicación', 'Frecuencia actual de la publicación', 13, 104, 2),
(265, '362', 'REV', NULL, NULL, NULL, 'a', 'Fecha de inicio - cese', 'Fecha de inicio - cese', 6, 104, 2),
(266, '041', 'REV', NULL, NULL, NULL, 'a', 'Idioma', 'Idioma', 103, 106, 2),
(267, '863', 'REV', NULL, NULL, NULL, 'i', 'Año', 'Vol., nro. y año', 19, 107, 2),
(268, '863', 'REV', NULL, NULL, NULL, 'a', 'Volumen', 'Vol., nro. y año', 19, 108, 2),
(269, '863', 'REV', ')', NULL, ')', 'b', 'Número', 'Vol., nro. y año', 19, 109, 2),
(270, '022', 'REV', NULL, NULL, NULL, 'a', 'ISSN', 'ISSN', 108, 109, 2),
(271, '500', 'REV', NULL, NULL, NULL, 'a', 'Nota general', 'Nota general', 85, 111, 2),
(272, '111', 'ELE', ',', NULL, ',', 'a', 'Congresos y conferencias', 'Congresos/Conferencias', 36, 1, 1),
(273, '111', 'ELE', ',', NULL, ',', 'c', 'Lugar', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 36, 3, 1),
(274, '111', 'ELE', NULL, NULL, NULL, 'd', 'Fecha', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 36, 4, 1),
(275, '111', 'ELE', NULL, NULL, NULL, 'n', 'Número', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 36, 2, 1),
(276, '520', 'ELE', NULL, NULL, NULL, 'a', 'Resumen', 'Resumen', 120, 120, 1),
(277, '260', 'LIB', ',&nbsp;', NULL, NULL, 'c', 'Fecha', 'PUBLICACIÓN, DISTRIBUCIÓN, ETC. (PIE DE IMPRENTA) (R)', 19, 122, 2),
(278, '653', 'TES', NULL, NULL, NULL, 'a', 'Palabras claves (no controlado)', 'Palabras claves', 50, 123, 1),
(279, '520', 'TES', NULL, NULL, NULL, 'a', 'Nota de resumen', 'Resumen', 124, 124, 1),
(280, '100', 'ANA', NULL, NULL, NULL, 'a', 'Autor', 'Autor', 1, 125, 1),
(281, '653', 'ANA', NULL, NULL, NULL, 'a', 'Palabras claves (no controlado)', 'Palabras claves', 50, 126, 1),
(282, '995', 'ANA', NULL, NULL, NULL, 't', 'Signatura Topográfica', 'Ubicación', 128, 127, 1),
(283, '110', 'ANA', NULL, NULL, NULL, 'a', 'Autor corporativo', 'Autor corporativo', 34, 128, 1),
(284, '856', 'REV', NULL, NULL, NULL, 'u', 'URL/URI', 'URL/URI', 136, 129, 1),
(285, '020', 'LIB', NULL, NULL, NULL, 'a', 'ISBN', 'ISBN', 52, 130, 2),
(286, '900', 'LIB', NULL, NULL, NULL, 'b', 'Nivel bibliografico', 'Nivel Bibliográfico', 131, 131, 2),
(287, '856', 'LIB', NULL, NULL, NULL, 'u', 'URL/URI', 'URL/URI', 136, 132, 1),
(288, '856', 'ALL', NULL, NULL, NULL, 'u', 'URL/URI', 'URL/URI', 136, 134, 1);

-- --------------------------------------------------------

--
-- Table structure for table `circ_prestamo`
--

CREATE TABLE IF NOT EXISTS `circ_prestamo` (
  `id_prestamo` int(11) NOT NULL AUTO_INCREMENT,
  `id3` int(11) NOT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  `tipo_prestamo` char(2) DEFAULT NULL,
  `fecha_prestamo` varchar(20) NOT NULL,
  `id_ui_origen` char(4) NOT NULL,
  `id_ui_prestamo` char(4) NOT NULL,
  `fecha_devolucion` varchar(20) DEFAULT NULL,
  `fecha_ultima_renovacion` varchar(20) DEFAULT NULL,
  `renovaciones` tinyint(4) DEFAULT NULL,
  `cant_recordatorio_via_mail` int(11) NOT NULL DEFAULT '0',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_prestamo`),
  UNIQUE KEY `id3_2` (`id3`,`nro_socio`),
  KEY `issuesitemidx` (`id3`),
  KEY `bordate` (`timestamp`),
  KEY `id3` (`id3`),
  KEY `nro_socio` (`nro_socio`),
  KEY `tipo_prestamo` (`tipo_prestamo`),
  KEY `fecha_prestamo` (`fecha_prestamo`),
  KEY `fecha_devolucion` (`fecha_devolucion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `circ_prestamo`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_prestamo_vencido_temp`
--

CREATE TABLE IF NOT EXISTS `circ_prestamo_vencido_temp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_prestamo` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `circ_prestamo_vencido_temp`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_ref_tipo_prestamo`
--

CREATE TABLE IF NOT EXISTS `circ_ref_tipo_prestamo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tipo_prestamo` char(4) DEFAULT NULL,
  `descripcion` text,
  `codigo_disponibilidad` varchar(255) NOT NULL DEFAULT 'CIRC0000',
  `prestamos` int(11) NOT NULL DEFAULT '0',
  `dias_prestamo` int(11) NOT NULL DEFAULT '0',
  `renovaciones` int(11) NOT NULL DEFAULT '0',
  `dias_renovacion` tinyint(3) NOT NULL DEFAULT '0',
  `dias_antes_renovacion` tinyint(10) NOT NULL DEFAULT '0',
  `habilitado` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `circ_ref_tipo_prestamo`
--

INSERT INTO `circ_ref_tipo_prestamo` (`id`, `id_tipo_prestamo`, `descripcion`, `codigo_disponibilidad`, `prestamos`, `dias_prestamo`, `renovaciones`, `dias_renovacion`, `dias_antes_renovacion`, `habilitado`) VALUES
(1, 'DO', 'Domiciliario', 'CIRC0000', 3, 14, 2, 14, 3, 1);

-- --------------------------------------------------------

--
-- Table structure for table `circ_regla_sancion`
--

CREATE TABLE IF NOT EXISTS `circ_regla_sancion` (
  `regla_sancion` int(11) NOT NULL AUTO_INCREMENT,
  `dias_sancion` int(11) NOT NULL DEFAULT '0',
  `dias_demora` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`regla_sancion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `circ_regla_sancion`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_regla_tipo_sancion`
--

CREATE TABLE IF NOT EXISTS `circ_regla_tipo_sancion` (
  `tipo_sancion` int(11) NOT NULL DEFAULT '0',
  `regla_sancion` int(11) NOT NULL DEFAULT '0',
  `orden` int(11) NOT NULL DEFAULT '1',
  `cantidad` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`tipo_sancion`,`regla_sancion`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `circ_regla_tipo_sancion`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_reserva`
--

CREATE TABLE IF NOT EXISTS `circ_reserva` (
  `id2` int(11) NOT NULL,
  `id3` int(11) DEFAULT NULL,
  `id_reserva` int(11) NOT NULL AUTO_INCREMENT,
  `nro_socio` varchar(16) DEFAULT NULL,
  `fecha_reserva` varchar(20) DEFAULT NULL,
  `estado` char(1) DEFAULT NULL,
  `id_ui` varchar(4) NOT NULL,
  `fecha_notificacion` varchar(20) DEFAULT NULL,
  `fecha_recordatorio` varchar(20) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_reserva`),
  KEY `id2` (`id2`),
  KEY `id3` (`id3`),
  KEY `nro_socio` (`nro_socio`),
  KEY `estado` (`estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `circ_reserva`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_sancion`
--

CREATE TABLE IF NOT EXISTS `circ_sancion` (
  `id_sancion` int(11) NOT NULL AUTO_INCREMENT,
  `tipo_sancion` int(11) DEFAULT '0',
  `id_reserva` int(11) DEFAULT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  `fecha_comienzo` date NOT NULL DEFAULT '0000-00-00',
  `fecha_final` date NOT NULL DEFAULT '0000-00-00',
  `dias_sancion` int(11) DEFAULT '0',
  `id3` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_sancion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `circ_sancion`
--


-- --------------------------------------------------------

--
-- Table structure for table `circ_tipo_prestamo_sancion`
--

CREATE TABLE IF NOT EXISTS `circ_tipo_prestamo_sancion` (
  `tipo_sancion` int(11) NOT NULL DEFAULT '0',
  `tipo_prestamo` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`tipo_sancion`,`tipo_prestamo`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `circ_tipo_prestamo_sancion`
--

INSERT INTO `circ_tipo_prestamo_sancion` (`tipo_sancion`, `tipo_prestamo`) VALUES
(1, 'DO'),
(1, 'ES'),
(1, 'FO'),
(1, 'IN'),
(1, 'SA'),
(1, 'VE'),
(2, 'DO'),
(2, 'ES'),
(2, 'FO'),
(2, 'IN'),
(2, 'VE'),
(3, 'DO'),
(3, 'ES'),
(3, 'FO'),
(3, 'IN'),
(3, 'SA'),
(3, 'VE'),
(4, 'DO'),
(4, 'ES'),
(4, 'FO'),
(4, 'IN'),
(4, 'SA'),
(4, 'VE'),
(5, 'DO'),
(5, 'ES'),
(5, 'FO'),
(5, 'IN'),
(5, 'SA'),
(5, 'VE'),
(6, 'DO'),
(6, 'ES'),
(6, 'FO'),
(6, 'IN'),
(6, 'SA'),
(6, 'VE'),
(7, 'DO'),
(7, 'ES'),
(7, 'FO'),
(7, 'IN'),
(7, 'PI'),
(7, 'SE'),
(7, 'VE'),
(8, 'DO'),
(8, 'ES'),
(8, 'FO'),
(8, 'IN'),
(8, 'SA'),
(8, 'VE'),
(9, 'DO'),
(9, 'ES'),
(9, 'FO'),
(9, 'IN'),
(9, 'SA'),
(9, 'VE'),
(10, 'DO'),
(10, 'ES'),
(10, 'FO'),
(10, 'IN'),
(10, 'SA'),
(10, 'VE'),
(11, 'DO'),
(11, 'ES'),
(11, 'FO'),
(11, 'IN'),
(11, 'PI'),
(11, 'VE'),
(12, 'DO'),
(12, 'ES'),
(12, 'FO'),
(12, 'IN'),
(12, 'SA'),
(12, 'VE'),
(13, 'DO'),
(13, 'ES'),
(13, 'FO'),
(13, 'IN'),
(13, 'VE'),
(14, 'DO'),
(14, 'ES'),
(14, 'FO'),
(14, 'IN'),
(14, 'PI'),
(14, 'VE'),
(15, 'DO'),
(15, 'ES'),
(15, 'FO'),
(15, 'IN'),
(15, 'PI'),
(15, 'SA'),
(15, 'VE'),
(16, 'DO'),
(16, 'ES'),
(16, 'FO'),
(16, 'IN'),
(16, 'PI'),
(16, 'SA'),
(16, 'VE'),
(17, 'DO'),
(17, 'ES'),
(17, 'FO'),
(17, 'IN'),
(17, 'SA'),
(17, 'VE'),
(18, 'DO'),
(18, 'ES'),
(18, 'FO'),
(18, 'IN'),
(18, 'SA'),
(18, 'VE'),
(19, 'DO'),
(19, 'ES'),
(19, 'FO'),
(19, 'IN'),
(19, 'PI'),
(19, 'SA'),
(19, 'VE'),
(20, 'DO'),
(20, 'ES'),
(20, 'FO'),
(20, 'IN'),
(20, 'SA'),
(20, 'VE'),
(21, 'DO'),
(21, 'ES'),
(21, 'FO'),
(21, 'IN'),
(21, 'SA'),
(21, 'SE'),
(21, 'VE'),
(22, 'DO'),
(22, 'ES'),
(22, 'FO'),
(22, 'IN'),
(22, 'PI'),
(22, 'SA'),
(22, 'VE'),
(23, 'DO'),
(23, 'ES'),
(23, 'FO'),
(23, 'IN'),
(23, 'SA'),
(23, 'VE'),
(24, 'DO'),
(24, 'ES'),
(24, 'FO'),
(24, 'IN'),
(24, 'SA'),
(24, 'VE'),
(25, 'DO'),
(25, 'ES'),
(25, 'FO'),
(25, 'IN'),
(25, 'SA'),
(25, 'VE'),
(26, 'DO'),
(26, 'ES'),
(26, 'FO'),
(26, 'IN'),
(26, 'SA'),
(26, 'VE'),
(27, 'DO'),
(27, 'ES'),
(27, 'FO'),
(27, 'IN'),
(27, 'SA'),
(27, 'VE'),
(28, 'DO'),
(28, 'ES'),
(28, 'FO'),
(28, 'IN'),
(28, 'PI'),
(28, 'SA'),
(28, 'VE'),
(29, 'DO'),
(29, 'ES'),
(29, 'FO'),
(29, 'IN'),
(29, 'PI'),
(29, 'SA'),
(29, 'VE'),
(30, 'DO'),
(30, 'ES'),
(30, 'FO'),
(30, 'SA'),
(30, 'VE'),
(31, 'DO'),
(31, 'ES'),
(31, 'FO'),
(31, 'IN'),
(31, 'PI'),
(31, 'VE'),
(32, 'DO'),
(32, 'ES'),
(32, 'FO'),
(32, 'IN'),
(32, 'SA'),
(32, 'VE'),
(33, 'DO'),
(33, 'ES'),
(33, 'FO'),
(33, 'IN'),
(33, 'PI'),
(33, 'SA'),
(33, 'VE'),
(34, 'DO'),
(34, 'ES'),
(34, 'FO'),
(34, 'IN'),
(34, 'SA'),
(34, 'VE'),
(35, 'DO'),
(35, 'ES'),
(35, 'FO'),
(35, 'IN'),
(35, 'SA'),
(35, 'VE'),
(36, 'DO'),
(36, 'ES'),
(36, 'FO'),
(36, 'IN'),
(36, 'PI'),
(36, 'SA'),
(36, 'VE'),
(37, 'DO'),
(37, 'ES'),
(37, 'FO'),
(37, 'IN'),
(37, 'VE'),
(38, 'DO'),
(38, 'ES'),
(38, 'FO'),
(38, 'IN'),
(38, 'SA'),
(38, 'VE'),
(39, 'DO'),
(39, 'ES'),
(39, 'FO'),
(39, 'IN'),
(39, 'SA'),
(39, 'VE'),
(40, 'DO'),
(40, 'ES'),
(40, 'FO'),
(40, 'IN'),
(40, 'SA'),
(40, 'VE'),
(41, 'DO'),
(41, 'ES'),
(41, 'FO'),
(41, 'IN'),
(41, 'SA'),
(41, 'VE'),
(42, 'DO'),
(42, 'ES'),
(42, 'FO'),
(42, 'IN'),
(42, 'SA'),
(42, 'VE'),
(43, 'DO'),
(43, 'ES'),
(43, 'FO'),
(43, 'IN'),
(43, 'SE'),
(43, 'VE'),
(47, 'DO'),
(47, 'ES'),
(47, 'FO'),
(47, 'IN'),
(47, 'PI'),
(47, 'SE'),
(47, 'VE'),
(48, 'DO'),
(49, 'DO'),
(49, 'ES'),
(49, 'FO'),
(49, 'IN'),
(49, 'PI'),
(49, 'SE'),
(49, 'VE'),
(51, 'DO'),
(51, 'ES'),
(51, 'IN'),
(51, 'PI'),
(51, 'VE'),
(52, 'DO'),
(52, 'ES'),
(52, 'FO'),
(52, 'IN'),
(52, 'PI'),
(52, 'VE'),
(54, 'DO'),
(54, 'ES'),
(54, 'FO'),
(54, 'IN'),
(54, 'PI'),
(54, 'VE'),
(56, 'DO'),
(56, 'ES'),
(56, 'FO'),
(56, 'IN'),
(56, 'PI'),
(56, 'VE'),
(57, 'DO'),
(58, 'DO'),
(58, 'ES'),
(58, 'IN'),
(58, 'PI'),
(58, 'VE'),
(62, 'DO'),
(62, 'ES'),
(62, 'IN'),
(62, 'PI'),
(62, 'VE'),
(63, 'DO'),
(63, 'ES'),
(63, 'IN'),
(63, 'PI'),
(63, 'VE'),
(64, 'DO'),
(64, 'ES'),
(64, 'IN'),
(64, 'PI'),
(64, 'VE'),
(69, 'SE');

-- --------------------------------------------------------

--
-- Table structure for table `circ_tipo_sancion`
--

CREATE TABLE IF NOT EXISTS `circ_tipo_sancion` (
  `tipo_sancion` int(11) NOT NULL AUTO_INCREMENT,
  `categoria_socio` char(2) DEFAULT NULL,
  `tipo_prestamo` char(2) DEFAULT NULL,
  PRIMARY KEY (`tipo_sancion`),
  UNIQUE KEY `categoryissuecode` (`categoria_socio`,`tipo_prestamo`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=74 ;

--
-- Dumping data for table `circ_tipo_sancion`
--

INSERT INTO `circ_tipo_sancion` (`tipo_sancion`, `categoria_socio`, `tipo_prestamo`) VALUES
(1, 'ES', 'DO'),
(2, 'DO', 'DO'),
(3, 'DO', 'SA'),
(4, 'DO', 'FO'),
(5, 'ES', 'FO'),
(6, 'ND', 'FO'),
(7, 'ND', 'DO'),
(8, 'ND', 'SA'),
(9, 'ND', 'ES'),
(10, 'IN', 'ES'),
(11, 'EG', 'DO'),
(12, 'DO', 'ES'),
(13, 'IN', 'DO'),
(14, 'PG', 'DO'),
(15, 'ES', 'SA'),
(16, 'EG', 'SA'),
(17, 'IN', 'SA'),
(18, 'PG', 'SA'),
(19, 'ES', 'ES'),
(20, 'DO', 'VE'),
(21, 'ES', 'VE'),
(22, 'EG', 'VE'),
(23, 'EG', 'ES'),
(24, 'EG', 'FO'),
(25, 'IN', 'VE'),
(26, 'IN', 'FO'),
(27, 'ND', 'VE'),
(28, 'PG', 'VE'),
(29, 'PG', 'ES'),
(30, 'PG', 'FO'),
(31, 'ES', 'IN'),
(32, 'DO', 'IN'),
(33, 'EG', 'IN'),
(34, 'IN', 'IN'),
(35, 'ND', 'IN'),
(36, 'PG', 'IN'),
(37, 'EX', 'DO'),
(38, 'EX', 'VE'),
(39, 'EX', 'IN'),
(40, 'EX', 'ES'),
(41, 'EX', 'FO'),
(42, 'EX', 'SA'),
(43, 'IB', 'DO'),
(44, 'BI', 'SA'),
(45, 'BB', 'SA'),
(46, 'BB', 'IN'),
(47, 'BI', 'DO'),
(48, 'BI', 'PI'),
(49, 'BI', 'VE'),
(50, 'BB', 'DO'),
(51, 'ES', 'RE'),
(52, 'ND', 'RE'),
(53, 'IN', 'RE'),
(54, 'EG', 'RE'),
(55, 'EX', 'RE'),
(56, 'PG', 'RE'),
(57, 'ES', 'PI'),
(58, 'PG', 'PI'),
(59, 'PG', 'SE'),
(60, 'EX', 'SE'),
(61, 'EX', 'PI'),
(62, 'EG', 'PI'),
(63, 'BI', 'ES'),
(64, 'BI', 'IN'),
(65, '', 'DO'),
(66, 'BB', 'FO'),
(67, 'BB', 'PI'),
(68, 'IN', 'PI'),
(69, 'ES', 'SE'),
(70, 'ES', 'BI'),
(71, 'IN', 'PG'),
(72, 'PI', 'ES'),
(73, 'PI', 'BI');

-- --------------------------------------------------------

--
-- Table structure for table `contacto`
--

CREATE TABLE IF NOT EXISTS `contacto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trato` varchar(255) DEFAULT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `codigo_postal` varchar(255) DEFAULT NULL,
  `ciudad` varchar(255) DEFAULT NULL,
  `pais` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `asunto` varchar(255) DEFAULT NULL,
  `mensaje` text NOT NULL,
  `leido` int(11) NOT NULL DEFAULT '0',
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `respondido` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `contacto`
--


-- --------------------------------------------------------

--
-- Table structure for table `e_document`
--

CREATE TABLE IF NOT EXISTS `e_document` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `id2` int(11) NOT NULL,
  `file_type` varchar(64) NOT NULL DEFAULT 'pdf',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `e_document`
--


-- --------------------------------------------------------

--
-- Table structure for table `imagenes_novedades_opac`
--

CREATE TABLE IF NOT EXISTS `imagenes_novedades_opac` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `id_novedad` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `image_name` (`image_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `imagenes_novedades_opac`
--


-- --------------------------------------------------------

--
-- Table structure for table `indice_busqueda`
--

CREATE TABLE IF NOT EXISTS `indice_busqueda` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` text,
  `autor` text,
  `string` text NOT NULL,
  `marc_record` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `string` (`string`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `indice_busqueda`
--


-- --------------------------------------------------------

--
-- Table structure for table `io_importacion_iso`
--

CREATE TABLE IF NOT EXISTS `io_importacion_iso` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_importacion_esquema` int(11) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `archivo` varchar(255) DEFAULT NULL,
  `formato` varchar(255) NOT NULL,
  `comentario` varchar(255) DEFAULT NULL,
  `estado` char(1) DEFAULT NULL,
  `fecha_upload` varchar(20) NOT NULL,
  `fecha_import` varchar(20) DEFAULT NULL,
  `campo_identificacion` varchar(255) DEFAULT NULL,
  `campo_relacion` varchar(255) DEFAULT NULL,
  `cant_registros_n1` int(11) DEFAULT NULL,
  `cant_registros_n2` int(11) DEFAULT NULL,
  `cant_registros_n3` int(11) DEFAULT NULL,
  `cant_desconocidos` int(11) NOT NULL,
  `accion_general` varchar(255) DEFAULT NULL,
  `accion_sinmatcheo` varchar(255) DEFAULT NULL,
  `accion_item` varchar(255) DEFAULT NULL,
  `accion_barcode` varchar(255) DEFAULT NULL,
  `reglas_matcheo` mediumtext,
  `jobID` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `io_importacion_iso`
--


-- --------------------------------------------------------

--
-- Table structure for table `io_importacion_iso_esquema`
--

CREATE TABLE IF NOT EXISTS `io_importacion_iso_esquema` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `io_importacion_iso_esquema`
--


-- --------------------------------------------------------

--
-- Table structure for table `io_importacion_iso_esquema_detalle`
--

CREATE TABLE IF NOT EXISTS `io_importacion_iso_esquema_detalle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_importacion_esquema` int(11) NOT NULL,
  `campo_origen` char(3) NOT NULL,
  `subcampo_origen` char(1) NOT NULL,
  `campo_destino` char(3) CHARACTER SET latin1 DEFAULT NULL,
  `subcampo_destino` char(1) CHARACTER SET latin1 DEFAULT NULL,
  `nivel` int(11) DEFAULT NULL,
  `ignorar` int(11) NOT NULL DEFAULT '0',
  `orden` int(11) DEFAULT '0',
  `separador` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campo_origen` (`campo_origen`,`id_importacion_esquema`,`subcampo_origen`,`campo_destino`,`subcampo_destino`,`orden`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `io_importacion_iso_esquema_detalle`
--


-- --------------------------------------------------------

--
-- Table structure for table `io_importacion_iso_registro`
--

CREATE TABLE IF NOT EXISTS `io_importacion_iso_registro` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_importacion_iso` int(11) NOT NULL,
  `type` varchar(25) DEFAULT NULL,
  `estado` varchar(25) DEFAULT NULL,
  `detalle` text,
  `matching` varchar(255) DEFAULT '0',
  `id_matching` int(11) DEFAULT NULL,
  `identificacion` varchar(255) DEFAULT NULL,
  `relacion` varchar(255) DEFAULT NULL,
  `id1` int(11) DEFAULT NULL,
  `id2` int(11) DEFAULT NULL,
  `id3` int(11) DEFAULT NULL,
  `marc_record` mediumtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `io_importacion_iso_registro`
--


-- --------------------------------------------------------

--
-- Table structure for table `logoEtiquetas`
--

CREATE TABLE IF NOT EXISTS `logoEtiquetas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(256) CHARACTER SET latin1 NOT NULL,
  `imagenPath` varchar(255) CHARACTER SET latin1 NOT NULL,
  `ancho` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `alto` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `logoEtiquetas`
--


-- --------------------------------------------------------

--
-- Table structure for table `logoUI`
--

CREATE TABLE IF NOT EXISTS `logoUI` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(256) CHARACTER SET latin1 NOT NULL,
  `imagenPath` varchar(255) CHARACTER SET latin1 NOT NULL,
  `ancho` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `alto` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `logoUI`
--

INSERT INTO `logoUI` (`id`, `nombre`, `imagenPath`, `ancho`, `alto`) VALUES
(2, 'MERA-UI', 'MERA-UI.png', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `perm_catalogo`
--

CREATE TABLE IF NOT EXISTS `perm_catalogo` (
  `ui` varchar(4) DEFAULT NULL,
  `tipo_documento` varchar(4) DEFAULT NULL,
  `datos_nivel1` varbinary(8) NOT NULL DEFAULT '00000',
  `datos_nivel2` varbinary(8) NOT NULL DEFAULT '00000',
  `datos_nivel3` varbinary(8) NOT NULL DEFAULT '00000',
  `estantes_virtuales` varbinary(8) NOT NULL DEFAULT '00000',
  `estructura_catalogacion_n1` varbinary(8) NOT NULL DEFAULT '00000',
  `estructura_catalogacion_n2` varbinary(8) NOT NULL DEFAULT '00000',
  `estructura_catalogacion_n3` varbinary(8) NOT NULL DEFAULT '00000',
  `tablas_de_refencia` varbinary(8) NOT NULL DEFAULT '00000',
  `control_de_autoridades` varbinary(8) NOT NULL DEFAULT '00000',
  `usuarios` varchar(8) DEFAULT NULL,
  `sistema` varchar(8) DEFAULT NULL,
  `undefined` varchar(8) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_persona` int(11) unsigned NOT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_persona` (`ui`,`tipo_documento`,`nro_socio`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=55966 ;

--
-- Dumping data for table `perm_catalogo`
--

INSERT INTO `perm_catalogo` (`ui`, `tipo_documento`, `datos_nivel1`, `datos_nivel2`, `datos_nivel3`, `estantes_virtuales`, `estructura_catalogacion_n1`, `estructura_catalogacion_n2`, `estructura_catalogacion_n3`, `tablas_de_refencia`, `control_de_autoridades`, `usuarios`, `sistema`, `undefined`, `id`, `id_persona`, `nro_socio`) VALUES
('MERA', 'LIB', '00000001', '00000001', '00010000', '00001111', '00000001', '00000001', '00000001', '00000001', '00000001', '00001111', '00000001', '00001111', 1, 21, 'meranadmin'),
('MERA', 'ALL', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', '00010000', 6598, 0, 'meranadmin');

-- --------------------------------------------------------

--
-- Table structure for table `perm_circulacion`
--

CREATE TABLE IF NOT EXISTS `perm_circulacion` (
  `nro_socio` varchar(16) NOT NULL DEFAULT '',
  `ui` varchar(4) NOT NULL DEFAULT '',
  `tipo_documento` varchar(4) NOT NULL DEFAULT '',
  `catalogo` varbinary(8) NOT NULL,
  `prestamos` varbinary(8) NOT NULL,
  `circ_opac` varbinary(8) NOT NULL DEFAULT '00000000',
  `circ_prestar` varchar(8) NOT NULL,
  `circ_renovar` varchar(8) NOT NULL,
  `circ_sanciones` varchar(8) NOT NULL,
  `circ_devolver` varchar(8) NOT NULL,
  PRIMARY KEY (`nro_socio`,`ui`,`tipo_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `perm_circulacion`
--

INSERT INTO `perm_circulacion` (`nro_socio`, `ui`, `tipo_documento`, `catalogo`, `prestamos`, `circ_opac`, `circ_prestar`, `circ_renovar`, `circ_sanciones`, `circ_devolver`) VALUES
('meranadmin', 'MERA', 'ALL', '', '00010000', '00010000', '11111111', '11111111', '11111111', '11111111');

-- --------------------------------------------------------

--
-- Table structure for table `perm_general`
--

CREATE TABLE IF NOT EXISTS `perm_general` (
  `nro_socio` varchar(16) NOT NULL DEFAULT '',
  `ui` varchar(4) NOT NULL DEFAULT '',
  `tipo_documento` varchar(4) NOT NULL DEFAULT '',
  `preferencias` varbinary(8) NOT NULL,
  `reportes` varbinary(8) NOT NULL DEFAULT '00000000',
  `permisos` varbinary(8) NOT NULL DEFAULT '00000000',
  `adq_opac` varbinary(8) NOT NULL DEFAULT '00000000',
  `adq_intra` varbinary(8) NOT NULL DEFAULT '00000000',
  PRIMARY KEY (`nro_socio`,`ui`,`tipo_documento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `perm_general`
--

INSERT INTO `perm_general` (`nro_socio`, `ui`, `tipo_documento`, `preferencias`, `reportes`, `permisos`, `adq_opac`, `adq_intra`) VALUES
('meranadmin', 'MERA', 'ALL', '00010000', '00010000', '00010000', '00010000', '00010000'),
('meranadmin', 'MERA', 'ANY', '', '00001111', '00001111', '00000000', '00000000');

-- --------------------------------------------------------

--
-- Table structure for table `portada_opac`
--

CREATE TABLE IF NOT EXISTS `portada_opac` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_path` varchar(255) NOT NULL,
  `footer` text,
  `footer_title` varchar(64) DEFAULT NULL,
  `orden` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `portada_opac`
--


-- --------------------------------------------------------

--
-- Table structure for table `pref_about`
--

CREATE TABLE IF NOT EXISTS `pref_about` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `pref_about`
--

INSERT INTO `pref_about` (`id`, `descripcion`) VALUES
(1, 'Biblioteca de Prueba - Meran - LINTI - Facultad de Informática - UNLP');

-- --------------------------------------------------------

--
-- Table structure for table `pref_estructura_campo_marc`
--

CREATE TABLE IF NOT EXISTS `pref_estructura_campo_marc` (
  `campo` char(3) NOT NULL DEFAULT '',
  `liblibrarian` char(255) DEFAULT NULL,
  `libopac` char(255) DEFAULT NULL,
  `repeatable` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `descripcion` varchar(255) DEFAULT NULL,
  `indicador_primario` varchar(255) DEFAULT NULL,
  `indicador_secundario` varchar(255) DEFAULT NULL,
  `nivel` int(11) NOT NULL,
  PRIMARY KEY (`campo`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pref_estructura_campo_marc`
--

INSERT INTO `pref_estructura_campo_marc` (`campo`, `liblibrarian`, `libopac`, `repeatable`, `mandatory`, `descripcion`, `indicador_primario`, `indicador_secundario`, `nivel`) VALUES
('010', 'NÚMERO DE CONTROL DE LA BIBLIOTECA DEL CONGRESO (NR)', 'NÚMERO DE CONTROL DE LA BIBLIOTECA DEL CONGRESO (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('011', 'NÚMERO DE CONTROL VINCULANTE DE LA BIBLIOTECA DEL CONGRESO (NR) [OBSOLETE]', 'NÚMERO DE CONTROL VINCULANTE DE LA BIBLIOTECA DEL CONGRESO (NR) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('013', 'INFORMACIÓN DE CONTROL DE PATENTES (R)', 'INFORMACIÓN DE CONTROL DE PATENTES (R)', 1, 0, '', 'No definido', 'No definido', 0),
('015', 'NÚMERO DE LA BIBLIOGRAFÍA NACIONAL (R)', 'NÚMERO DE LA BIBLIOGRAFÍA NACIONAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('016', 'NÚMERO DE CONTROL DE LA AGENCIA NACIONAL BIBLIOGRÁFICA (R)', 'NÚMERO DE CONTROL DE LA AGENCIA NACIONAL BIBLIOGRÁFICA (R)', 1, 0, '', 'Agencia nacional bibliográfica', 'No definido', 0),
('017', 'NÚMERO DE DEPÓSITO LEGAL O DERECHOS DE AUTOR (R)', 'NÚMERO DE DEPÓSITO LEGAL O DERECHOS DE AUTOR (R)', 1, 0, '', 'No definido', 'Controlador de la constante de despliegue', 0),
('018', 'ARTÍCULO REGISTRADO-CÓDIGO DE PAGO (NR)', 'ARTÍCULO REGISTRADO-CÓDIGO DE PAGO (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('020', 'NÚMERO INTERNACIONAL NORMALIZADO PARA LIBROS (ISBN) (R)', 'NÚMERO INTERNACIONAL NORMALIZADO PARA LIBROS (ISBN) (R)', 1, 0, '', 'No definido', 'No definido', 0),
('022', 'NÚMERO INTERNACIONAL NORMALIZADO PARA PUBLICACIONES SERIADAS (ISSN) (R)', 'NÚMERO INTERNACIONAL NORMALIZADO PARA PUBLICACIONES SERIADAS (ISSN) (R)', 1, 0, '', 'Nivel de interés internacional', 'No definido', 0),
('023', 'STANDARD FILM NUMBER   [DELETED]', 'STANDARD FILM NUMBER   [DELETED]', 1, 0, '', '', '', 0),
('024', 'OTROS IDENTIFICADORES NORMALIZADOS (R)', 'OTROS IDENTIFICADORES NORMALIZADOS (R)', 1, 0, '', 'Tipo de número o código estandarizado', 'Designación de diferencia', 0),
('025', 'NÚMERO DE ADQUISICIÓN EN EL EXTRANJERO (R)', 'NÚMERO DE ADQUISICIÓN EN EL EXTRANJERO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('027', 'NÚMERO NORMALIZADO DE INFORME TÉCNICO (R)', 'NÚMERO NORMALIZADO DE INFORME TÉCNICO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('028', 'NÚMERO DE EDITOR (R)', 'NÚMERO DE EDITOR (R)', 1, 0, '', 'Tipo de número del editor', 'Nota/controlador de asiento adicional del título', 0),
('030', 'INDICADOR CODEN (R)', 'INDICADOR CODEN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('032', 'NÚMERO DE REGISTRO POSTAL (R)', 'NÚMERO DE REGISTRO POSTAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('033', 'FECHA/HORA Y LUGAR DE UN EVENTO (R)', 'FECHA/HORA Y LUGAR DE UN EVENTO (R)', 1, 0, '', 'Tipo de fecha en el subcampo $a', 'Tipo de eventos', 0),
('034', 'DATOS MATEMÁTICOS CARTOGRÁFICOS CODIFICADOS (R)', 'DATOS MATEMÁTICOS CARTOGRÁFICOS CODIFICADOS (R)', 1, 0, '', 'Tipos de escala', 'Tipo de anillo', 0),
('035', 'NÚMERO DE CONTROL DEL SISTEMA (R)', 'NÚMERO DE CONTROL DEL SISTEMA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('036', 'NÚMERO DE ESTUDIO ORIGINAL PARA LOS ARCHIVOS DE DATOS (NR)', 'NÚMERO DE ESTUDIO ORIGINAL PARA LOS ARCHIVOS DE DATOS (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('037', 'FUENTE DE ADQUISICIÓN (R)', 'FUENTE DE ADQUISICIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('039', 'LEVEL OF biblioGRAPHIC CONTROL AND CODING DETAIL [OBSOLETE]', 'LEVEL OF biblioGRAPHIC CONTROL AND CODING DETAIL [OBSOLETE]', 1, 0, '', '', '', 0),
('040', 'FUENTE DE CATALOGACIÓN (NR)', 'FUENTE DE CATALOGACIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('041', 'CÓDIGO DE IDIOMA (R)', 'CÓDIGO DE IDIOMA (R)', 1, 0, '', 'Indicador de traducción', 'Fuente del código', 0),
('042', 'CÓDIGO DE AUTENTICACIÓN (NR)', 'CÓDIGO DE AUTENTICACIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('043', 'CÓDIGO DE ÁREA GEOGRÁFICA (NR)', 'CÓDIGO DE ÁREA GEOGRÁFICA (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('044', 'CÓDIGO DE ENTIDAD DEL PAÍS DE PUBLICACIÓN/PRODUCCIÓN (NR)', 'CÓDIGO DE ENTIDAD DEL PAÍS DE PUBLICACIÓN/PRODUCCIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('045', 'PERÍODO CRONOLÓGICO DEL CONTENIDO (NR)', 'PERÍODO CRONOLÓGICO DEL CONTENIDO (NR)', 0, 0, '', 'Tipo de período cronológico en los subcampos $b o $c', 'No definido', 0),
('046', 'CÓDIGO ESPECIAL DE FECHAS (R)', 'CÓDIGO ESPECIAL DE FECHAS (R)', 1, 0, '', 'No definido', 'No definido', 0),
('047', 'CÓDIGO DE FORMA DE LA COMPOSICIÓN MUSICAL (R)', 'CÓDIGO DE FORMA DE LA COMPOSICIÓN MUSICAL (R)', 1, 0, '', 'No definido', 'Fuente del código', 0),
('048', 'NÚMERO DE INSTRUMENTOS MUSICALES O CÓDIGO DE VOCES (R)', 'NÚMERO DE INSTRUMENTOS MUSICALES O CÓDIGO DE VOCES (R)', 1, 0, '', 'No definido', 'Fuente del código', 0),
('050', 'NÚMERO DE UBICACIÓN EN LA BIBLIOTECA DEL CONGRESO (R)', 'NÚMERO DE UBICACIÓN EN LA BIBLIOTECA DEL CONGRESO (R)', 1, 0, '', 'Existencia en la LC', 'Fuente del número de ubicación', 0),
('051', 'MENCIÓN DE LA BIBLIOTECA DEL CONGRESO SOBRE COPIAS, EDICIONES Y SEPARATAS (R)', 'MENCIÓN DE LA BIBLIOTECA DEL CONGRESO SOBRE COPIAS, EDICIONES Y SEPARATAS (R)', 1, 0, '', 'No definido', 'No definido', 0),
('052', 'CLASIFICACIÓN GEOGRÁFICA (R)', 'CLASIFICACIÓN GEOGRÁFICA (R)', 1, 0, '', 'Fuente del código', 'No definido', 0),
('055', 'NÚMEROS DE CLASIFICACIÓN ASIGNADOS EN CANADÁ (R)', 'NÚMEROS DE CLASIFICACIÓN ASIGNADOS EN CANADÁ (R)', 1, 0, '', 'Existe en la colección de la LAC', 'Tipo, integridad, fuente del número de ubicación/clase', 0),
('060', 'NÚMERO DE UBICACIÓN EN LA BIBLIOTECA NACIONAL DE MEDICINA (R)', 'NÚMERO DE UBICACIÓN EN LA BIBLIOTECA NACIONAL DE MEDICINA (R)', 1, 0, '', 'Existencia en la NML', 'Fuente del número de ubicación', 0),
('061', 'MENCIÓN SOBRE COPIAS DE LA BIBLIOTECA NACIONAL DE MEDICINA (R)', 'MENCIÓN SOBRE COPIAS DE LA BIBLIOTECA NACIONAL DE MEDICINA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('066', 'CONJUNTO DE CARACTERES PRESENTES (NR)', 'CONJUNTO DE CARACTERES PRESENTES (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('070', 'NÚMERO DE UBICACIÓN DE LA Biblioteca Nacional de Agricultura de los Estados Unidos (R)', 'NÚMERO DE UBICACIÓN DE LA Biblioteca Nacional de Agricultura de los Estados Unidos (R)', 1, 0, '', 'Existencia en la colección NAL', 'No definido', 0),
('071', 'MENCIÓN SOBRE COPIAS DE LA Biblioteca Nacional de Agricultura de los Estados Unidos (R)', 'MENCIÓN SOBRE COPIAS DE LA Biblioteca Nacional de Agricultura de los Estados Unidos (R)', 1, 0, '', 'No definido', 'No definido', 0),
('072', 'CÓDIGO DE CATEGORIA TEMÁTICA (R)', 'CÓDIGO DE CATEGORIA TEMÁTICA (R)', 1, 0, '', 'No definido', 'Fuente especificada en el subcampo $2', 0),
('074', 'NÚMERO DE ÍTEM DE GPO (R)', 'NÚMERO DE ÍTEM DE GPO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('080', 'NÚMERO DE CLASIFICACIÓN DECIMAL UNIVERSAL (R)', 'NÚMERO DE CLASIFICACIÓN DECIMAL UNIVERSAL (R)', 1, 0, '', 'Tipo de edición', 'No definido', 0),
('082', 'NÚMERO DE CLASIFICACIÓN DECIMAL DEWEY (R)', 'NÚMERO DE CLASIFICACIÓN DECIMAL DEWEY (R)', 1, 0, '', 'Tipo de edición', 'Fuente del número', 0),
('084', 'OTRO NÚMERO DE CLASIFICACIÓN (R)', 'OTRO NÚMERO DE CLASIFICACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('086', 'NÚMERO DE CLASIFICACION PARA DOCUMENTOS GUBERNAMENTALES (R)', 'NÚMERO DE CLASIFICACION PARA DOCUMENTOS GUBERNAMENTALES (R)', 1, 0, '', 'Fuente del número', 'No definido', 0),
('088', 'NÚMERO DE REPORTE (R)', 'NÚMERO DE REPORTE (R)', 1, 0, '', 'No definido', 'No definido', 0),
('090', 'UBICACIÓN EN ESTANTE (AM)[OBSOLETE]', 'UBICACIÓN EN ESTANTE (AM)[OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('091', 'MICROFILM SHELF LOCATION (AM) [OBSOLETE]', 'MICROFILM SHELF LOCATION (AM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('100', 'ASIENTO PRINCIPAL - NOMBRE PERSONAL (NR)', 'ASIENTO PRINCIPAL - NOMBRE PERSONAL (NR)', 0, 0, '', 'Tipo de nombre personal como asiento principal', 'No definido', 0),
('110', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 'ASIENTO PRINCIPAL - AUTOR CORPORATIVO (NR)', 0, 0, '', 'Tipo del nombre del autor corporativo como asiento principal', 'No definido', 0),
('111', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 'ASIENTO PRINCIPAL - NOMBRE DE LA REUNIÓN (NR)', 0, 0, '', 'Tipo del nombre de la reunión como asiento principal', 'No definido', 0),
('130', 'ASIENTO PRINCIPAL - TÍTULO UNIFORME (NR)', 'ASIENTO PRINCIPAL - TÍTULO UNIFORME (NR)', 0, 0, '', 'Caracteres que no se alfabetizan', 'No definido', 0),
('210', 'TÍTULO ABREVIADO - PUBLICACIÓN SERIADA (R)', 'TÍTULO ABREVIADO - PUBLICACIÓN SERIADA (R)', 1, 0, '', 'Asiento adicional del título', 'Tipo', 0),
('211', 'TÍTULO ABREVIADO O ACRÓNIMO (R) [OBSOLETE]', 'TÍTULO ABREVIADO O ACRÓNIMO (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Asiento adicional del título', 'Caracteres que no se alfabetizan', 0),
('212', 'VARIANT ACCESS Título (R) [OBSOLETE]', 'VARIANT ACCESS Título (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Asiento adicional del título', 'No definido', 0),
('214', 'AUGMENTED Título (R) [OBSOLETE]', 'AUGMENTED Título (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Asiento adicional del título', 'Caracteres que no se alfabetizan', 0),
('222', 'TÍTULO CLAVE (R)', 'TÍTULO CLAVE (R)', 1, 0, '', 'No definido', 'Caracteres que no se alfabetizan', 0),
('240', 'TÍTULO UNIFORME (NR)', 'TÍTULO UNIFORME (NR)', 0, 0, '', 'Título uniforme que se imprime o despliega', 'Caracteres que no se alfabetizan', 0),
('241', 'ROMANIZED Título (BK AM CF MP MU VM) (NR) [OBSOLETE]', 'ROMANIZED Título (BK AM CF MP MU VM) (NR) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Asiento adicional del título', 'Caracteres que no se alfabetizan', 0),
('242', 'TRADUCCIÓN DEL TÍTULO POR LA AGENCIA CATALOGADORA (R)', 'TRADUCCIÓN DEL TÍTULO POR LA AGENCIA CATALOGADORA (R)', 1, 0, '', 'Asiento adicional del título', 'Caracteres que no se alfabetizan', 0),
('243', 'TÍTULO UNIFORME COLECTIVO (NR)', 'TÍTULO UNIFORME COLECTIVO (NR)', 0, 0, '', 'Título uniforme que se imprime o despliega', 'Caracteres que no se alfabetizan', 0),
('245', 'TÍTULO PROPIAMENTE DICHO (NR)', 'TÍTULO PROPIAMENTE DICHO (NR)', 0, 0, '', 'Asiento adicional del título', 'Caracteres que no se alfabetizan', 0),
('246', 'VARIACIONES EN EL TÍTULO O TÍTULOS PARALELOS (R)', 'VARIACIONES EN EL TÍTULO O TÍTULOS PARALELOS (R)', 1, 0, '', 'Control de la nota y el asiento adicional del título', 'Tipo de título', 0),
('247', 'TÍTULO ANTERIOR (R)', 'TÍTULO ANTERIOR (R)', 1, 0, '', 'Asiento adicional del título', 'Controlador de nota', 0),
('250', 'MENCIÓN DE EDICIÓN (NR)', 'MENCIÓN DE EDICIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('254', 'MENCIÓN DE PRESENTACIÓN MUSICAL (NR)', 'MENCIÓN DE PRESENTACIÓN MUSICAL (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('255', 'DATOS MATEMÁTICOS CARTOGRÁFICOS (R)', 'DATOS MATEMÁTICOS CARTOGRÁFICOS (R)', 1, 0, '', 'No definido', 'No definido', 0),
('256', 'CARACTERÍSTICAS DE ARCHIVO INFORMÁTICO (NR)', 'CARACTERÍSTICAS DE ARCHIVO INFORMÁTICO (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('257', 'PAÍS DE LA ENTIDAD QUE PRODUCE (R)', 'PAÍS DE LA ENTIDAD QUE PRODUCE (R)', 1, 0, '', 'No definido', 'No definido', 0),
('260', 'PUBLICACIÓN, DISTRIBUCIÓN, ETC. (PIE DE IMPRENTA) (R)', 'PUBLICACIÓN, DISTRIBUCIÓN, ETC. (PIE DE IMPRENTA) (R)', 1, 0, '', 'Secuencia de declaraciones de publicación', 'No definido', 0),
('261', 'MENCIÓN DE PIE DE IMPRENTA PARA PELÍCULAS (Pre-AACR 1 Revised) (NR) [LOCAL]', 'MENCIÓN DE PIE DE IMPRENTA PARA PELÍCULAS (Pre-AACR 1 Revised) (NR) [LOCAL]', 0, 0, '', 'No definido', 'No definido', 0),
('262', 'MENCIÓN DE PIE DE IMPRENTA PARA GRABACIONES DE SONIDO (Pre-AACR 2) (NR) [LOCAL]', 'MENCIÓN DE PIE DE IMPRENTA PARA GRABACIONES DE SONIDO (Pre-AACR 2) (NR) [LOCAL]', 0, 0, '', 'No definido', 'No definido', 0),
('263', 'FECHA DE PUBLICACIÓN ESTIMADA (NR)', 'FECHA DE PUBLICACIÓN ESTIMADA (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('265', 'SOURCE FOR ACQUISITION/SUBSCRIPTION ADDRESS (NR) [OBSOLETE]', 'SOURCE FOR ACQUISITION/SUBSCRIPTION ADDRESS (NR) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('270', 'DIRECCIÓN (R)', 'DIRECCIÓN (R)', 1, 0, '', 'Nivel', 'Tipo de dirección', 0),
('300', 'DESCRIPCIÓN FÍSICA (R)', 'DESCRIPCIÓN FÍSICA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('301', 'PHYSICAL DESCRIPTION FOR FILMS (PRE-AACR 2) (VM) [OBSOLETE]', 'PHYSICAL DESCRIPTION FOR FILMS (PRE-AACR 2) (VM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('302', 'PAGE OR ITEM COUNT (BK AM) [OBSOLETE]', 'PAGE OR ITEM COUNT (BK AM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('303', 'UNIT COUNT (AM) [OBSOLETE]', 'UNIT COUNT (AM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('304', 'LINEAR FOOTAGE (AM) [OBSOLETE]', 'LINEAR FOOTAGE (AM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('305', 'PHYSICAL DESCRIPTION FOR SOUND RECORDINGS (Pre-AACR 2) (MU) [OBSOLETE]', 'PHYSICAL DESCRIPTION FOR SOUND RECORDINGS (Pre-AACR 2) (MU) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('306', 'DURACIÓN (NR)', 'DURACIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('307', 'HORAS, ETC. (R)', 'HORAS, ETC. (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('308', 'PHYSICAL DESCRIPTION FOR FILMS (ARCHIVAL) (VM) [OBSOLETE]', 'PHYSICAL DESCRIPTION FOR FILMS (ARCHIVAL) (VM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('310', 'FRECUENCIA ACTUAL DE LA PUBLICACIÓN (NR)', 'FRECUENCIA ACTUAL DE LA PUBLICACIÓN (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('315', 'FREQUENCY (NR) (CF MP) [OBSOLETE]', 'FREQUENCY (NR) (CF MP) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('321', 'FRECUENCIA ANTERIOR DE PUBLICACIÓN (R)', 'FRECUENCIA ANTERIOR DE PUBLICACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('340', 'MEDIO FÍSICO (R)', 'MEDIO FÍSICO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('342', 'DATOS DE REFERENCIA GEOESPACIAL (R)', 'DATOS DE REFERENCIA GEOESPACIAL (R)', 1, 0, '', 'Dimensión de referencia geoespacial', 'Método de referencia geoespacial', 0),
('343', 'DATOS DE COORDENADAS DEL PLANO (R)', 'DATOS DE COORDENADAS DEL PLANO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('350', 'PRICE (NR) (BK AM CF MU VM SE) [OBSOLETE]', 'PRICE (NR) (BK AM CF MU VM SE) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('351', 'ORGANIZACIÓN Y ARREGLO DE LOS MATERIALES (R)', 'ORGANIZACIÓN Y ARREGLO DE LOS MATERIALES (R)', 1, 0, '', 'No definido', 'No definido', 0),
('352', 'REPRESENTACIÓN GRÁFICA DIGITAL (R)', 'REPRESENTACIÓN GRÁFICA DIGITAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('355', 'CONTROL DE CLASIFICACIÓN DE SEGURIDAD (R)', 'CONTROL DE CLASIFICACIÓN DE SEGURIDAD (R)', 1, 0, '', 'Elemento controlado', 'No definido', 0),
('357', 'CONTROL DEL CREADOR SOBRE LA DISEMINACION (NR)', 'CONTROL DEL CREADOR SOBRE LA DISEMINACION (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('359', 'RENTAL PRICE (VM)  [OBSOLETE]', 'RENTAL PRICE (VM)  [OBSOLETE]', 1, 0, '', '', '', 0),
('362', 'FECHAS DE PUBLICACIÓN Y/O DESIGNACIÓN SECUENCIAL (R)', 'FECHAS DE PUBLICACIÓN Y/O DESIGNACIÓN SECUENCIAL (R)', 1, 0, '', 'Formato de fecha', 'No definido', 0),
('400', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE PERSONAL (R) [US-LOCAL]', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE PERSONAL (R) [US-LOCAL]', 0, 0, '', 'Tipo de elemento de asiento de nombre personal', 'Pronombre representa asiento principal', 0),
('410', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE CORPORATIVO (R) [US-LOCAL]', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE CORPORATIVO (R) [US-LOCAL]', 0, 0, '', 'Tipo de elemento de asiento de nombre corporativo', 'Pronombre representa asiento principal', 0),
('411', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE DE REUNIÓN (R) [US-LOCAL]', 'MENCIÓN DE SERIE/ASIENTO SECUNDARIO - NOMBRE DE REUNIÓN (R) [US-LOCAL]', 0, 0, '', 'Tipo de elemento de asiento del nombre de la reunión', 'Pronombre representa asiento principal', 0),
('440', 'MENCIÓN DE SERIE/ASIENTO AGREGADA - TÍTULO (R) [OBSOLETE]', 'MENCIÓN DE SERIE/ASIENTO AGREGADA - TÍTULO (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'Caracteres que no se alfabetizan', 0),
('490', 'MENCIÓN DE SERIE (R)', 'MENCIÓN DE SERIE (R)', 1, 0, '', 'Especifica si la serie está asentada', 'No definido', 0),
('500', 'NOTA GENERAL (R)', 'NOTA GENERAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('501', 'NOTA DE CON (R)', 'NOTA DE CON (R)', 1, 0, '', 'No definido', 'No definido', 0),
('502', 'NOTA DE TESIS (R)', 'NOTA DE TESIS (R)', 1, 0, '', 'No definido', 'No definido', 0),
('503', 'BIBLIOGRAPHIC Historia Nota (R) (BK CF MU) [OBSOLETE]', 'BIBLIOGRAPHIC Historia Nota (R) (BK CF MU) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('504', 'NOTA DE BIBLIOGRAFÍA, ETC. (R)', 'NOTA DE BIBLIOGRAFÍA, ETC. (R)', 1, 0, '', 'No definido', 'No definido', 0),
('505', 'NOTA DE CONTENIDOS FORMATEADA (R)', 'NOTA DE CONTENIDOS FORMATEADA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'Nivel de la designación del contenido', 0),
('506', 'NOTA SOBRE RESTRICCIÓN DE ACCESO (R)', 'NOTA SOBRE RESTRICCIÓN DE ACCESO (R)', 1, 0, '', 'Restriction', 'No definido', 0),
('507', 'NOTA DE ESCALA PARA MATERIALES GRÁFICOS (NR)', 'NOTA DE ESCALA PARA MATERIALES GRÁFICOS (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('508', 'NOTA SOBRE LOS CRÉDITOS DE CREACIÓN/PRODUCCIÓN (R)', 'NOTA SOBRE LOS CRÉDITOS DE CREACIÓN/PRODUCCIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('510', 'NOTA DE CITACIÓN/REFERENCIA (R)', 'NOTA DE CITACIÓN/REFERENCIA (R)', 1, 0, '', 'Cobertura/localización dentro de la fuente', 'No definido', 0),
('511', 'NOTA DE PARTICIPANTE O INTÉRPRETE (R)', 'NOTA DE PARTICIPANTE O INTÉRPRETE (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('512', 'EARLIER OR LATER VOLUMES SEPARATELY CATALOGED Nota (SE) (R) [OBSOLETE]', 'EARLIER OR LATER VOLUMES SEPARATELY CATALOGED Nota (SE) (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('513', 'NOTA SOBRE EL TIPO DE REPORTE Y PERÍODO CUBIERTO (R)', 'NOTA SOBRE EL TIPO DE REPORTE Y PERÍODO CUBIERTO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('514', 'NOTA SOBRE LA CALIDAD DE LOS DATOS (NR)', 'NOTA SOBRE LA CALIDAD DE LOS DATOS (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('515', 'NOTA SOBRE LAS PARTICULARIDADES EN LA NUMERACIÓN (R)', 'NOTA SOBRE LAS PARTICULARIDADES EN LA NUMERACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('516', 'NOTA DE TIPO DE ARCHIVO O DATOS DE COMPUTADORA (R)', 'NOTA DE TIPO DE ARCHIVO O DATOS DE COMPUTADORA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('517', 'CATEGORIES OF FILMS Nota (ARCHIVAL) (VM) (NR) [OBSOLETE]', 'CATEGORIES OF FILMS Nota (ARCHIVAL) (VM) (NR) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Fiction specification', 'No definido', 0),
('518', 'NOTA DE FECHA/HORA Y LUGAR DE UN ACONTECIMIENTO (R)', 'NOTA DE FECHA/HORA Y LUGAR DE UN ACONTECIMIENTO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('520', 'RESUMEN, ETC. (R)', 'RESUMEN, ETC. (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('521', 'NOTA DE AUDIENCIA (R)', 'NOTA DE AUDIENCIA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('522', 'NOTA DE COBERTURA GEOGRÁFICA (R)', 'NOTA DE COBERTURA GEOGRÁFICA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('523', 'TIME PERIOD OF CONTENT Nota (NR) (CF) [OBSOLETE]', 'TIME PERIOD OF CONTENT Nota (NR) (CF) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('524', 'NOTA SOBRE CITACIÓN PREFERIDA DE LOS MATERIALES DESCRITOS (R)', 'NOTA SOBRE CITACIÓN PREFERIDA DE LOS MATERIALES DESCRITOS (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('525', 'NOTA DE SUPLEMENTO (R)', 'NOTA DE SUPLEMENTO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('526', 'NOTA DE INFORMACIÓN SOBRE PROGRAMA DE ESTUDIOS (R)', 'NOTA DE INFORMACIÓN SOBRE PROGRAMA DE ESTUDIOS (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('527', 'CENSORSHIP Nota (VM) (R) [OBSOLETE]', 'CENSORSHIP Nota (VM) (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('530', 'NOTA SOBRE DISPONIBILIDAD DEL MATERIAL EN OTRO FORMATO (R)', 'NOTA SOBRE DISPONIBILIDAD DEL MATERIAL EN OTRO FORMATO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('533', 'NOTA SOBRE REPRODUCCIÓN (R)', 'NOTA SOBRE REPRODUCCIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('534', 'NOTA SOBRE VERSIÓN ORIGINAL (R)', 'NOTA SOBRE VERSIÓN ORIGINAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('535', 'NOTA SOBRE LA UBICACIÓN DE ORIGINALES O DUPLICADOS (R)', 'NOTA SOBRE LA UBICACIÓN DE ORIGINALES O DUPLICADOS (R)', 1, 0, '', 'Información adicional sobre el custodio', 'No definido', 0),
('536', 'NOTA DE INFORMACION SOBRE FINANCIAMIENTO (R)', 'NOTA DE INFORMACION SOBRE FINANCIAMIENTO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('537', 'SOURCE OF DATA Nota (NR) (CF) [OBSOLETE]', 'SOURCE OF DATA Nota (NR) (CF) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Controlador de la constante de despliegue', 'No definido', 0),
('538', 'NOTA SOBRE DETALLES DEL SISTEMA (R)', 'NOTA SOBRE DETALLES DEL SISTEMA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('540', 'NOTA SOBRE LOS TÉRMINOS QUE GOBIERNAN EL USO Y LA REPRODUCCIÓN DE UN ÍTEM (R)', 'NOTA SOBRE LOS TÉRMINOS QUE GOBIERNAN EL USO Y LA REPRODUCCIÓN DE UN ÍTEM (R)', 1, 0, '', 'No definido', 'No definido', 0),
('541', 'NOTA SOBRE LA FUENTE INMEDIATA DE ADQUISICIÓN (R)', 'NOTA SOBRE LA FUENTE INMEDIATA DE ADQUISICIÓN (R)', 1, 0, '', 'Privacidad', 'No definido', 0),
('543', 'SOLICITATION INFORMATION NOTE (AM)  [OBSOLETE]', 'SOLICITATION INFORMATION NOTE (AM)  [OBSOLETE]', 1, 0, '', '', '', 0),
('544', 'NOTA SOBRE LA UBICACIÓN DE OTROS MATERIALES ARCHIVARIOS (R)', 'NOTA SOBRE LA UBICACIÓN DE OTROS MATERIALES ARCHIVARIOS (R)', 1, 0, '', 'Relación', 'No definido', 0),
('545', 'NOTA SOBRE DATOS BIOGRÁFICOS O HISTÓRICOS (R)', 'NOTA SOBRE DATOS BIOGRÁFICOS O HISTÓRICOS (R)', 1, 0, '', 'Tipo de datos', 'No definido', 0),
('546', 'NOTA DE IDIOMA (R)', 'NOTA DE IDIOMA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('547', 'NOTA COMPLEJA SOBRE TÍTULO ANTERIOR (R)', 'NOTA COMPLEJA SOBRE TÍTULO ANTERIOR (R)', 1, 0, '', 'No definido', 'No definido', 0),
('550', 'NOTA SOBRE ENTIDAD EMISORA DE LA PUBLICACIÓN (R)', 'NOTA SOBRE ENTIDAD EMISORA DE LA PUBLICACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('552', 'NOTA INFORMATIVA SOBRE LA ENTIDAD Y ATRIBUTO (R)', 'NOTA INFORMATIVA SOBRE LA ENTIDAD Y ATRIBUTO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('555', 'NOTA SOBRE ÍNDICE ACUMULATIVO/AYUDAS DE BÚSQUEDA (R)', 'NOTA SOBRE ÍNDICE ACUMULATIVO/AYUDAS DE BÚSQUEDA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('556', 'NOTA INFORMATIVA SOBRE DOCUMENTACIÓN (R)', 'NOTA INFORMATIVA SOBRE DOCUMENTACIÓN (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('561', 'NOTA HISTÓRICA SOBRE DUEÑOS Y CUSTODIOS (R)', 'NOTA HISTÓRICA SOBRE DUEÑOS Y CUSTODIOS (R)', 1, 0, '', 'Privacidad', 'No definido', 0),
('562', 'NOTA SOBRE IDENTIFICACIÓN DE COPIA Y VERSIÓN (R)', 'NOTA SOBRE IDENTIFICACIÓN DE COPIA Y VERSIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('565', 'NOTA DE LAS CARACTERÍSTICAS DE ARCHIVOS DE CASOS (R)', 'NOTA DE LAS CARACTERÍSTICAS DE ARCHIVOS DE CASOS (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('567', 'NOTA SOBRE METODOLOGÍA (R)', 'NOTA SOBRE METODOLOGÍA (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('570', 'EDITOR Nota (SE) (R) [OBSOLETE]', 'EDITOR Nota (SE) (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('580', 'NOTA COMPLEJA DE ENLACES DE ASIENTOS (R)', 'NOTA COMPLEJA DE ENLACES DE ASIENTOS (R)', 1, 0, '', 'No definido', 'No definido', 0),
('581', 'NOTA SOBRE PUBLICACIONES SOBRE EL MATERIAL DESCRITO (R)', 'NOTA SOBRE PUBLICACIONES SOBRE EL MATERIAL DESCRITO (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('582', 'RELATED COMPUTER FILES Nota (R) (CF) [OBSOLETE]', 'RELATED COMPUTER FILES Nota (R) (CF) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Controlador de la constante de despliegue', 'No definido', 0),
('583', 'NOTA DE ACCIÓN TOMADA (R)', 'NOTA DE ACCIÓN TOMADA (R)', 1, 0, '', 'Privacidad', 'No definido', 0),
('584', 'NOTA SOBRE ACUMULACIONES Y FRECUENCIA DE USO (R)', 'NOTA SOBRE ACUMULACIONES Y FRECUENCIA DE USO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('585', 'NOTA SOBRE EXPOSICIONES (R)', 'NOTA SOBRE EXPOSICIONES (R)', 1, 0, '', 'No definido', 'No definido', 0),
('586', 'NOTA SOBRE PREMIOS (R)', 'NOTA SOBRE PREMIOS (R)', 1, 0, '', 'Controlador de la constante de despliegue', 'No definido', 0),
('590', 'RECEIPT DATE Nota (VM) [OBSOLETE]', 'RECEIPT DATE Nota (VM) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('600', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE PERSONAL (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE PERSONAL (R)', 1, 0, '', 'Tipo de nombre personal', 'Tesauro', 0),
('610', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE CORPORATIVOS (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE CORPORATIVOS (R)', 1, 0, '', 'Tipo de nombre corporativo', 'Tesauro', 0),
('611', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE DE REUNIÓN (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE DE REUNIÓN (R)', 1, 0, '', 'Tipo de nombre de reunión', 'Tesauro', 0),
('630', 'ASIENTO SECUNDARIO DE MATERIA - TÍTULO UNIFORME (R)', 'ASIENTO SECUNDARIO DE MATERIA - TÍTULO UNIFORME (R)', 1, 0, '', 'Caracteres que no se alfabetizan', 'Tesauro', 0),
('650', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINOS TEMÁTICOS (R)', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINOS TEMÁTICOS (R)', 1, 0, '', 'Nivel del tema o materia', 'Tesauro', 0),
('651', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRES GEOGRÁFICOS (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRES GEOGRÁFICOS (R)', 1, 0, '', 'No definido', 'Tesauro', 0),
('652', 'SUBJECT ADDED ENTRY--REVERSED GEOGRAPHIC (BK MP SE) [OBSOLETE]', 'SUBJECT ADDED ENTRY--REVERSED GEOGRAPHIC (BK MP SE) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('653', 'TÉRMINO INDIZADO -NO CONTROLADO (R)', 'TÉRMINO INDIZADO -NO CONTROLADO (R)', 1, 0, '', 'Nivel del término índice', 'Tipo de término o nombre', 0),
('654', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINOS TEMÁTICOS FACETADOS (R)', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINOS TEMÁTICOS FACETADOS (R)', 1, 0, '', 'Nivel del tema o materia', 'No definido', 0),
('655', 'TÉRMINO INDIZADO - GÉNERO/FORMA (R)', 'TÉRMINO INDIZADO - GÉNERO/FORMA (R)', 1, 0, '', 'Tipo de encabezado', 'Tesauro', 0),
('656', 'TÉRMINO INDIZADO - OCUPACIÓN (R)', 'TÉRMINO INDIZADO - OCUPACIÓN (R)', 1, 0, '', 'No definido', 'Fuente del término', 0),
('657', 'TÉRMINO INDIZADO - FUNCIÓN (R)', 'TÉRMINO INDIZADO - FUNCIÓN (R)', 1, 0, '', 'No definido', 'Fuente del término', 0),
('658', 'TÉRMINO INDIZADO - OBJETIVO DEL currículo (R)', 'TÉRMINO INDIZADO - OBJETIVO DEL currículo (R)', 1, 0, '', 'No definido', 'No definido', 0),
('700', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE PERSONAL (R)', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE PERSONAL (R)', 1, 0, '', 'Tipo de nombre personal como asiento', 'Tipo de asiento adicional del título', 0),
('705', 'ADDED ENTRY--PERSONAL NAME (PERFORMER) (MU) [OBSOLETE]', 'ADDED ENTRY--PERSONAL NAME (PERFORMER) (MU) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Type of personal name entry element', 'Tipo de asiento adicional del título', 0),
('710', 'ASIENTO ADICIONAL - NOMBRE CORPORATIVO (R)', 'ASIENTO ADICIONAL - NOMBRE CORPORATIVO (R)', 1, 0, '', 'Tipo del nombre del autor corporativo como asiento', 'Tipo de asiento agregado', 0),
('711', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE DE LA REUNIÓN (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRE DE LA REUNIÓN (R)', 1, 0, '', 'Tipo del nombre de la reunión como asiento', 'Tipo de asiento adicional del título', 0),
('715', 'ADDED ENTRY--CORPORATE NAME (PERFORMING GROUP) (MU) [OBSOLETE]', 'ADDED ENTRY--CORPORATE NAME (PERFORMING GROUP) (MU) [OBSOLETE]', 0, 0, 'OBSOLETO', 'Type of corporate name entry element', 'Tipo de asiento adicional del título', 0),
('720', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRES NO CONTROLADOS (R)', 'ASIENTO SECUNDARIO DE MATERIA - NOMBRES NO CONTROLADOS (R)', 1, 0, '', 'Tipo de nombre', 'No definido', 0),
('730', 'ASIENTO ADICIONAL DEL TÍTULO - TÍTULO UNIFORME (R)', 'ASIENTO ADICIONAL DEL TÍTULO - TÍTULO UNIFORME (R)', 1, 0, '', 'Caracteres que no se alfabetizan', 'Tipo de asiento adicional del título', 0),
('740', 'ASIENTO ADICIONAL DEL TÍTULO - TÍTULO ANALÍTICO/RELACIONADO NO CONTROLADO (R)', 'ASIENTO ADICIONAL DEL TÍTULO - TÍTULO ANALÍTICO/RELACIONADO NO CONTROLADO (R)', 1, 0, '', 'Caracteres que no se alfabetizan', 'Tipo de asiento adicional del título', 0),
('752', 'ASIENTO SECUNDARIO DE MATERIA - JERARQUÍA DEL NOMBRE DE LUGAR (R)', 'ASIENTO SECUNDARIO DE MATERIA - JERARQUÍA DEL NOMBRE DE LUGAR (R)', 1, 0, '', 'No definido', 'No definido', 0),
('753', 'DETALLES DE ACCESO AL SISTEMA PARA ARCHIVOS DE COMPUTADORA (R)', 'DETALLES DE ACCESO AL SISTEMA PARA ARCHIVOS DE COMPUTADORA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('754', 'ASIENTO ADICIONAL DEL TÍTULO - IDENTIFICACIÓN TAXONÓMICA (R)', 'ASIENTO ADICIONAL DEL TÍTULO - IDENTIFICACIÓN TAXONÓMICA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('755', 'ADDED ENTRY--PHYSICAL CHARACTERISTICS (R) [OBSOLETE]', 'ADDED ENTRY--PHYSICAL CHARACTERISTICS (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'No definido', 0),
('760', 'ASIENTO PRINCIPAL DE SERIE (R)', 'ASIENTO PRINCIPAL DE SERIE (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('762', 'ASIENTO DE SUBSERIE (R)', 'ASIENTO DE SUBSERIE (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('765', 'ASIENTO DE IDIOMA ORIGINAL (R)', 'ASIENTO DE IDIOMA ORIGINAL (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('767', 'ASIENTO DE TRADUCCIÓN (R)', 'ASIENTO DE TRADUCCIÓN (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('770', 'ASIENTO DE SUPLEMENTOS/NÚMEROS ESPECIALES (R)', 'ASIENTO DE SUPLEMENTOS/NÚMEROS ESPECIALES (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('772', 'ASIENTO DE REGISTRO PRINCIPAL DE SUPLEMENTO (R)', 'ASIENTO DE REGISTRO PRINCIPAL DE SUPLEMENTO (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('773', 'ASIENTO DE REGISTRO ANFITRIÓN (R)', 'ASIENTO DE REGISTRO ANFITRIÓN (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('774', 'ASIENTO DE UNIDAD CONSTITUYENTE (R)', 'ASIENTO DE UNIDAD CONSTITUYENTE (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('775', 'ASIENTO DE OTRA EDICIÓN (R)', 'ASIENTO DE OTRA EDICIÓN (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('776', 'ASIENTO DE FORMA FÍSICA ADICIONAL (R)', 'ASIENTO DE FORMA FÍSICA ADICIONAL (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('777', 'ASIENTO DE EMITIDO CON (R)', 'ASIENTO DE EMITIDO CON (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('780', 'ASIENTO DE TÍTULO ANTERIOR (R)', 'ASIENTO DE TÍTULO ANTERIOR (R)', 1, 0, '', 'Controlador de nota', 'Tipo de relación', 0),
('785', 'ASIENTO DE TÍTULO POSTERIOR (R)', 'ASIENTO DE TÍTULO POSTERIOR (R)', 1, 0, '', 'Controlador de nota', 'Tipo de relación', 0),
('786', 'ASIENTO DE ORIGEN DE DATOS (R)', 'ASIENTO DE ORIGEN DE DATOS (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('787', 'ASIENTO DE RELACIONES NO ESPECÍFICAS (R)', 'ASIENTO DE RELACIONES NO ESPECÍFICAS (R)', 1, 0, '', 'Controlador de nota', 'Controlador de la constante de despliegue', 0),
('800', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE PERSONAL (R)', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE PERSONAL (R)', 1, 0, '', 'Tipo de elemento de asiento de nombre personal', 'No definido', 0),
('810', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE CORPORATIVO (R)', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE CORPORATIVO (R)', 1, 0, '', 'Tipo de elemento de asiento de nombre corporativo', 'No definido', 0),
('811', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE DE LA REUNIÓN (R)', 'ASIENTO ADICIONAL DE LA SERIE - NOMBRE DE LA REUNIÓN (R)', 1, 0, '', 'Tipo del nombre de la reunión como asiento', 'No definido', 0),
('830', 'ASIENTO ADICIONAL DE SERIE - TÍTULO UNIFORME (R)', 'ASIENTO ADICIONAL DE SERIE - TÍTULO UNIFORME (R)', 1, 0, '', 'No definido', 'Caracteres que no se alfabetizan', 0),
('840', 'SERIES ADDED ENTRY--TÍTULO (R) [OBSOLETE]', 'SERIES ADDED ENTRY--TÍTULO (R) [OBSOLETE]', 0, 0, 'OBSOLETO', 'No definido', 'Caracteres que no se alfabetizan', 0),
('841', 'VALORES CODIFICADOS DE INFORMACION DE EXISTENCIAS (NR)', 'VALORES CODIFICADOS DE INFORMACION DE EXISTENCIAS (NR)', 0, 0, '', '', '', 0),
('842', 'DESIGNADOR DE FORMA FÍSICA TEXTUAL (NR)', 'DESIGNADOR DE FORMA FÍSICA TEXTUAL (NR)', 0, 0, '', '', '', 0),
('843', 'NOTA DE REPRODUCCIÓN (R)', 'NOTA DE REPRODUCCIÓN (R)', 1, 0, '', '', '', 0),
('844', 'NOMBRE DE LA UNIDAD (NR)', 'NOMBRE DE LA UNIDAD (NR)', 0, 0, '', '', '', 0),
('845', 'TÉRMINOS QUE REGULAN EL USO Y LA REPRODUCCIÓN (R)', 'TÉRMINOS QUE REGULAN EL USO Y LA REPRODUCCIÓN (R)', 1, 0, '', '', '', 0),
('850', 'INSTITUCIÓN EN POSESIÓN DE LA EXISTENCIA (R)', 'INSTITUCIÓN EN POSESIÓN DE LA EXISTENCIA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('851', 'LOCATION   [OBSOLETE]', 'LOCATION   [OBSOLETE]', 1, 0, '', '', '', 0),
('852', 'UBICACIÓN (R)', 'UBICACIÓN (R)', 1, 0, '', 'Esquema de almacenamiento en los estantes', 'Orden de almacenamiento en los estantes', 0),
('853', 'ENCABEZADOS Y PATRÓN - UNIDAD BIBLIOGRÁFICA BÁSICA  (R)', 'ENCABEZADOS Y PATRÓN - UNIDAD BIBLIOGRÁFICA BÁSICA  (R)', 1, 0, '', '', '', 0),
('854', 'ENCABEZADOS Y PATRÓN - MATERIAL ADICIONAL (R)', 'ENCABEZADOS Y PATRÓN - MATERIAL ADICIONAL (R)', 1, 0, '', '', '', 0),
('855', 'ENCABEZADOS Y PATRÓN - ÍNDICES (R)', 'ENCABEZADOS Y PATRÓN - ÍNDICES (R)', 1, 0, '', '', '', 0),
('856', 'UBICACIÓN Y ACCESO ELECTRÓNICOS (R)', 'UBICACIÓN Y ACCESO ELECTRÓNICOS (R)', 1, 0, '', 'Método de acceso', 'Relación', 0),
('863', 'ENUMERACIÓN Y CRONOLOGÍA - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 'ENUMERACIÓN Y CRONOLOGÍA - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 1, 0, '', '', '', 0),
('864', 'ENUMERACIÓN Y CRONOLOGÍA - MATERIAL ADICIONAL (R)', 'ENUMERACIÓN Y CRONOLOGÍA - MATERIAL ADICIONAL (R)', 1, 0, '', '', '', 0),
('865', 'ENUMERACIÓN Y CRONOLOGÍA - ÍNDICES (R)', 'ENUMERACIÓN Y CRONOLOGÍA - ÍNDICES (R)', 1, 0, '', '', '', 0),
('866', 'INVENTARIO TEXTUAL - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 'INVENTARIO TEXTUAL - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 1, 0, '', '', '', 0),
('867', 'INVENTARIO TEXTUAL - MATERIAL ADICIONAL (R)', 'INVENTARIO TEXTUAL - MATERIAL ADICIONAL (R)', 1, 0, '', '', '', 0),
('868', 'INVENTARIO TEXTUAL - ÍNDICES (R)', 'INVENTARIO TEXTUAL - ÍNDICES (R)', 1, 0, '', '', '', 0),
('870', 'VARIANT PERSONAL NAME (SE) [OBSOLETE]', 'VARIANT PERSONAL NAME (SE) [OBSOLETE]', 0, 0, 'OBSOLETO', '', '', 0),
('871', 'VARIANT CORPORATE NAME (SE)[OBSOLETE]', 'VARIANT CORPORATE NAME (SE)[OBSOLETE]', 0, 0, 'OBSOLETO', '', '', 0),
('872', 'VARIANT CONFERENCE OR MEETING NAME (SE) [OBSOLETE]', 'VARIANT CONFERENCE OR MEETING NAME (SE) [OBSOLETE]', 0, 0, 'OBSOLETO', '', '', 0),
('873', 'VARIANT UNIFORM TITLE HEADING (SE) [OBSOLETE]', 'VARIANT UNIFORM TITLE HEADING (SE) [OBSOLETE]', 0, 0, 'OBSOLETO', '', '', 0),
('876', 'INFORMACIÓN DEL ÍTEM - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 'INFORMACIÓN DEL ÍTEM - UNIDAD BIBLIOGRÁFICA BÁSICA (R)', 1, 0, '', '', '', 0),
('877', 'INFORMACIÓN DEL ÍTEM - MATERIAL ADICIONAL (R)', 'INFORMACIÓN DEL ÍTEM - MATERIAL ADICIONAL (R)', 1, 0, '', '', '', 0),
('878', 'INFORMACIÓN DEL ÍTEM - ÍNDICES (R)', 'INFORMACIÓN DEL ÍTEM - ÍNDICES (R)', 1, 0, '', '', '', 0),
('880', 'REPRESENTACIÓN GRÁFICA ALTERNATIVA (R)', 'REPRESENTACIÓN GRÁFICA ALTERNATIVA (R)', 1, 0, '', 'Igual que el campo asociado', 'Igual que el campo asociado', 0),
('886', 'CAMPO DE INFORMACIÓN DE FORMATO MARC EXTRANJERO (R)', 'CAMPO DE INFORMACIÓN DE FORMATO MARC EXTRANJERO (R)', 1, 0, '', 'Tipo de campo', 'No definido', 0),
('995', 'Datos del Ejemplar', 'Datos del Ejemplar', 1, 0, '', '', '', 0),
('000', 'LEADER', 'LEADER', 0, 0, '', '', '', 0),
('910', 'Tipo de documento', 'Tipo de documento', 0, 1, '', '', '', 0),
('882', 'INFORMACIÓN DE REGISTRO DE REEMPLAZO (NR)', 'INFORMACIÓN DE REGISTRO DE REEMPLAZO (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('366', 'INFORMACION SOBRE DISPONIBILIDAD COMERCIAL (R)', 'INFORMACION SOBRE DISPONIBILIDAD COMERCIAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('751', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE GEOGRÁFICO (R)', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE GEOGRÁFICO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('337', 'TIPO DE MEDIO (R)', 'TIPO DE MEDIO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('648', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINO CRONOLÓGICO (R)', 'ASIENTO SECUNDARIO DE MATERIA - TÉRMINO CRONOLÓGICO (R)', 1, 0, '', 'No definido', 'Tesauro', 0),
('026', 'IDENTIFICADOR DE IDENTIDAD TIPOGRÁFICA (R)', 'IDENTIFICADOR DE IDENTIDAD TIPOGRÁFICA (R)', 1, 0, '', 'No definido', 'No definido', 0),
('662', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE DE LUGAR JERÁRQUICO (R)', 'ASIENTO ADICIONAL DEL TÍTULO - NOMBRE DE LUGAR JERÁRQUICO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('588', 'NOTA DE ORIGEN DE DESCRIPCIÓN (R)', 'NOTA DE ORIGEN DE DESCRIPCIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('542', 'INFORMACIÓN RELATIVA AL ESTADO DE DERECHO DE AUTOR (R)', 'INFORMACIÓN RELATIVA AL ESTADO DE DERECHO DE AUTOR (R)', 1, 0, '', 'Privacidad', 'No definido', 0),
('083', 'NÚMERO DE CLASIFICACIÓN DECIMAL DEWEY ADICIONAL', 'NÚMERO DE CLASIFICACIÓN DECIMAL DEWEY ADICIONAL', 0, 0, '', 'Tipo de edición', 'No definido', 0),
('887', 'CAMPO DE INFORMACIÓN QUE NO PERTENECE A MARC (R)', 'CAMPO DE INFORMACIÓN QUE NO PERTENECE A MARC (R)', 1, 0, '', 'No definido', 'No definido', 0),
('336', 'TIPO DE CONTENIDO (R)', 'TIPO DE CONTENIDO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('085', 'SÍNTESIS DE COMPONENTES DEL NÚMERO DE CLASIFICACIÓN (R)', 'SÍNTESIS DE COMPONENTES DEL NÚMERO DE CLASIFICACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('563', 'INFORMACIÓN SOBRE ENCUADERNACIÓN (R)', 'INFORMACIÓN SOBRE ENCUADERNACIÓN (R)', 1, 0, '', 'No definido', 'No definido', 0),
('258', 'FECHA DE SUPLEMENTO FILATÉLICO (R)', 'FECHA DE SUPLEMENTO FILATÉLICO (R)', 1, 0, '', 'No definido', 'No definido', 0),
('038', 'REGISTRO DEL CONCEDENTE DE LA LICENCIA DEL CONTENIDO (NR)', 'REGISTRO DEL CONCEDENTE DE LA LICENCIA DEL CONTENIDO (NR)', 0, 0, '', 'No definido', 'No definido', 0),
('365', 'PRECIO COMERCIAL (R)', 'PRECIO COMERCIAL (R)', 1, 0, '', 'No definido', 'No definido', 0),
('338', 'TIPO DE PORTADOR (R)', 'TIPO DE PORTADOR (R)', 1, 0, '', 'No definido', 'No definido', 0),
('031', 'INFORMACIÓN DE ÍNCIPITS MUSICALES (R)', 'INFORMACIÓN DE ÍNCIPITS MUSICALES (R)', 1, 0, '', 'No definido', 'No definido', 0),
('363', 'DESIGNACIÓN CRONOLÓGICA Y SECUENCIAL NORMALIZADA (R)', 'DESIGNACIÓN CRONOLÓGICA Y SECUENCIAL NORMALIZADA (R)', 1, 0, '', 'Designación de inicio/fin', 'Estado de la emisión', 0),
('900', 'Nivel Bibliográfico', 'Nivel Bibliográfico', 0, 0, NULL, NULL, NULL, 0),
('859', 'No se que es', 'No se que es', 0, 0, NULL, NULL, NULL, 2);

-- --------------------------------------------------------

--
-- Table structure for table `pref_estructura_subcampo_marc`
--

CREATE TABLE IF NOT EXISTS `pref_estructura_subcampo_marc` (
  `nivel` tinyint(1) NOT NULL DEFAULT '0',
  `obligatorio` tinyint(1) NOT NULL DEFAULT '0',
  `campo` char(3) NOT NULL DEFAULT '',
  `subcampo` char(3) NOT NULL DEFAULT '',
  `liblibrarian` char(255) DEFAULT NULL,
  `libopac` char(255) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `repetible` tinyint(4) NOT NULL DEFAULT '0',
  `mandatory` tinyint(4) NOT NULL DEFAULT '0',
  `kohafield` char(40) DEFAULT NULL,
  PRIMARY KEY (`campo`,`subcampo`),
  KEY `kohafield` (`kohafield`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pref_estructura_subcampo_marc`
--

INSERT INTO `pref_estructura_subcampo_marc` (`nivel`, `obligatorio`, `campo`, `subcampo`, `liblibrarian`, `libopac`, `descripcion`, `repetible`, `mandatory`, `kohafield`) VALUES
(0, 0, '010', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 1, NULL),
(0, 0, '010', 'a', 'Número de control de LC (NR)', 'Número de control de LC (NR)', '', 0, 1, 'biblioitems.lccn'),
(0, 0, '010', 'b', 'Número de control NUCMC (R)', 'Número de control NUCMC (R)', '', 1, 1, NULL),
(0, 0, '010', 'z', 'Número de control LC no válido/cancelado (R)', 'Número de control LC no válido/cancelado (R)', '', 1, 0, NULL),
(0, 0, '011', 'a', 'Número de control vinculante de LC (R)', 'Número de control vinculante de LC (R)', '', 1, 0, NULL),
(0, 0, '013', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '013', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '013', 'a', 'Número (NR)', 'Número (NR)', '', 0, 0, NULL),
(0, 0, '013', 'b', 'País (NR)', 'País (NR)', '', 0, 0, NULL),
(0, 0, '013', 'c', 'Tipo de número (NR)', 'Tipo de número (NR)', '', 0, 0, NULL),
(0, 0, '013', 'd', 'Fecha (R)', 'Fecha (R)', '', 1, 0, NULL),
(0, 0, '013', 'e', 'Estado (R)', 'Estado (R)', '', 1, 0, NULL),
(0, 0, '013', 'f', 'Parte del documento (R)', 'Parte del documento (R)', '', 1, 0, NULL),
(0, 0, '015', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '015', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '015', 'a', 'Número de la bibliografía nacional (R)', 'Número de la bibliografía nacional (R)', '', 1, 0, NULL),
(0, 0, '016', '2', 'Fuente (NR)', 'Fuente (NR)', '', 0, 0, NULL),
(0, 0, '016', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '016', 'a', 'Número de control de registro (NR)', 'Número de control de registro (NR)', '', 0, 0, NULL),
(0, 0, '016', 'z', 'Número de control de registro no válido/cancelado (R)', 'Número de control de registro no válido/cancelado (R)', '', 1, 0, NULL),
(0, 0, '017', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '017', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '017', 'a', 'Número de depósito legal (R)', 'Número de depósito legal (R)', '', 1, 0, NULL),
(0, 0, '017', 'b', 'Agencia que asigna el número (NR)', 'Agencia que asigna el número (NR)', '', 0, 0, NULL),
(0, 0, '017', 'c', 'Terms of availability', 'Terms of availability', '', 0, 0, NULL),
(0, 0, '017', 'z', 'Número de depósito legal o derecho de autor no válido/cancelado (R)', 'Número de depósito legal o derecho de autor no válido/cancelado (R)', '', 1, 0, NULL),
(0, 0, '018', 'a', 'Artículo registrado-código de pago (NR)', 'Artículo registrado-código de pago (NR)', '', 0, 0, NULL),
(0, 0, '020', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '020', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '020', 'a', 'Número Internacional Normalizado para Libros (NR)', 'Número Internacional Normalizado para Libros (NR)', '', 0, 1, 'isbns.isbn'),
(0, 0, '020', 'b', 'Binding information (NR) [OBSOLETE]', 'Binding information (NR) [OBSOLETE]', '', 0, 0, NULL),
(0, 0, '020', 'c', 'Términos de disponibilidad (NR)', 'Términos de disponibilidad (NR)', '', 0, 0, NULL),
(0, 0, '020', 'z', 'ISBN no válido/cancelado (R)', 'ISBN no válido/cancelado (R)', '', 1, 0, NULL),
(0, 0, '022', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '022', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '022', 'a', 'Número Internacional Normalizado para Publicaciones Seriadas (NR)', 'Número Internacional Normalizado para Publicaciones Seriadas (NR)', '', 0, 0, 'biblioitems.issn'),
(0, 0, '022', 'y', 'ISSN incorrecto (R)', 'ISSN incorrecto (R)', '', 1, 0, NULL),
(0, 0, '022', 'z', 'ISSN cancelado (R)', 'ISSN cancelado (R)', '', 1, 0, NULL),
(0, 0, '024', '2', 'Fuente del código o número (NR)', 'Fuente del código o número (NR)', '', 0, 0, NULL),
(0, 0, '024', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '024', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '024', 'a', 'Código o número estandarizado de grabación (NR)', 'Código o número estandarizado de grabación (NR)', '', 0, 0, NULL),
(0, 0, '024', 'c', 'Términos de disponibilidad (NR)', 'Términos de disponibilidad (NR)', '', 0, 0, NULL),
(0, 0, '024', 'd', 'Códigos adicionales a continuación del número o código estandarizado (NR)', 'Códigos adicionales a continuación del número o código estandarizado (NR)', '', 0, 0, NULL),
(0, 0, '024', 'z', 'Código cancelado/no válido (R)', 'Código cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '025', '6', 'Linkage See', 'Linkage See', '', 0, 0, NULL),
(0, 0, '025', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '025', 'a', 'Número de adquisición en el extranjero (R)', 'Número de adquisición en el extranjero (R)', '', 1, 0, NULL),
(0, 0, '025', 'z', 'Canceled/invalid number', 'Canceled/invalid number', '', 1, 0, NULL),
(0, 0, '027', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '027', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '027', 'a', 'Número normalizado de informe técnico (NR)', 'Número normalizado de informe técnico (NR)', '', 0, 0, NULL),
(0, 0, '027', 'z', 'Número cancelado/no válido (R)', 'Número cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '028', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '028', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '028', 'a', 'Número del editor (NR)', 'Número del editor (NR)', '', 0, 0, NULL),
(0, 0, '028', 'b', 'Fuente (NR)', 'Fuente (NR)', '', 0, 0, NULL),
(0, 0, '030', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '030', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '030', 'a', 'CODEN (NR)', 'CODEN (NR)', '', 0, 0, NULL),
(0, 0, '030', 'z', 'CODEN cancelado/no válido (R)', 'CODEN cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '032', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '032', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '032', 'a', 'Número de registro postal (NR)', 'Número de registro postal (NR)', '', 0, 0, NULL),
(0, 0, '032', 'b', 'Fuente (agencia que asigna el número) (NR)', 'Fuente (agencia que asigna el número) (NR)', '', 0, 0, NULL),
(0, 0, '033', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, ''),
(0, 0, '033', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, ''),
(0, 0, '033', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, ''),
(0, 0, '033', 'a', 'Fecha/hora formateados (R)', 'Fecha/hora formateados (R)', '', 1, 0, ''),
(0, 0, '033', 'b', 'Código de área de clasificación geográfica (R)', 'Código de área de clasificación geográfica (R)', '', 1, 0, ''),
(0, 0, '033', 'c', 'Código de sub-área de clasificación geográfica (R)', 'Código de sub-área de clasificación geográfica (R)', '', 1, 0, ''),
(0, 0, '034', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '034', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '034', 'a', 'Categoría de la escala (NR)', 'Categoría de la escala (NR)', '', 0, 0, NULL),
(0, 0, '034', 'b', 'Escala horizontal lineal de radio constante (R)', 'Escala horizontal lineal de radio constante (R)', '', 1, 0, NULL),
(0, 0, '034', 'c', 'Escala vertical lineal de radio constante (R)', 'Escala vertical lineal de radio constante (R)', '', 1, 0, NULL),
(0, 0, '034', 'd', 'Coordenadas--Longitud Oeste (NR)', 'Coordenadas--Longitud Oeste (NR)', '', 0, 0, NULL),
(0, 0, '034', 'e', 'Coordenadas--Longitud Este (NR)', 'Coordenadas--Longitud Este (NR)', '', 0, 0, NULL),
(0, 0, '034', 'f', 'Coordenadas--Longitud Norte (NR)', 'Coordenadas--Longitud Norte (NR)', '', 0, 0, NULL),
(0, 0, '034', 'g', 'Coordenadas--Longitud Sur (NR)', 'Coordenadas--Longitud Sur (NR)', '', 0, 0, NULL),
(0, 0, '034', 'h', 'Escala angular (R)', 'Escala angular (R)', '', 1, 0, NULL),
(0, 0, '034', 'j', 'Declinación--Límite Norte (NR)', 'Declinación--Límite Norte (NR)', '', 0, 0, NULL),
(0, 0, '034', 'k', 'Declinación--Límite Sur (NR)', 'Declinación--Límite Sur (NR)', '', 0, 0, NULL),
(0, 0, '034', 'm', 'Ascensión derecha--Límite Este (NR)', 'Ascensión derecha--Límite Este (NR)', '', 0, 0, NULL),
(0, 0, '034', 'n', 'Ascensión derecha--Límite Oeste (NR)', 'Ascensión derecha--Límite Oeste (NR)', '', 0, 0, NULL),
(0, 0, '034', 'p', 'Equinoccio (NR)', 'Equinoccio (NR)', '', 0, 0, NULL),
(0, 0, '034', 's', 'Latitud G-ring (R)', 'Latitud G-ring (R)', '', 1, 0, NULL),
(0, 0, '034', 't', 'Longitud G-ring (R)', 'Longitud G-ring (R)', '', 1, 0, NULL),
(0, 0, '035', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '035', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '035', 'a', 'Número de control del sistema (NR)', 'Número de control del sistema (NR)', '', 0, 0, NULL),
(0, 0, '035', 'z', 'Número de control cancelado/no válido (R)', 'Número de control cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '036', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '036', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '036', 'a', 'Número de estudio original (NR)', 'Número de estudio original (NR)', '', 0, 0, NULL),
(0, 0, '036', 'b', 'Fuente (agencia que asigna el número) (NR)', 'Fuente (agencia que asigna el número) (NR)', '', 0, 0, NULL),
(0, 0, '037', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '037', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '037', 'a', 'Número de inventario (NR)', 'Número de inventario (NR)', '', 0, 0, NULL),
(0, 0, '037', 'b', 'Fuente del número de inventario/compra (NR)', 'Fuente del número de inventario/compra (NR)', '', 0, 0, NULL),
(0, 0, '037', 'c', 'Términos de disponibilidad (R)', 'Términos de disponibilidad (R)', '', 0, 0, NULL),
(0, 0, '037', 'f', 'Forma del ejemplar (R)', 'Forma del ejemplar (R)', '', 0, 0, NULL),
(0, 0, '037', 'g', 'Características adicionales del formato (R)', 'Características adicionales del formato (R)', '', 0, 0, NULL),
(0, 0, '037', 'n', 'Nota (R)', 'Nota (R)', '', 0, 0, NULL),
(0, 0, '039', 'a', 'Level of rules in bibliographic description (NR)    0 - No level defined by rules    1 - Minimal    2 - Less than full    3 - Full', 'Level of rules in bibliographic description (NR)    0 - No level defined by rules    1 - Minimal    2 - Less than full    3 - Full', '', 0, 0, NULL),
(0, 0, '039', 'b', 'Level of effort used to assign nonsubject heading access points (NR)    2 - Less than full    3 - Full', 'Level of effort used to assign nonsubject heading access points (NR)    2 - Less than full    3 - Full', '', 0, 0, NULL),
(0, 0, '039', 'c', 'Level of effort (030, CODEN DESIGNATION, CODEN DESIGNATION, 1, 0, '', '', ''),\nused to assign subject headings  (NR)    0 - None    2 - Less than full    3 - Full', 'Level of effort used to assign subject headings  (NR)    0 - None    2 - Less than full    3 - Full', '', 0, 0, NULL),
(0, 0, '039', 'd', 'Level of effort used to assign classification  (NR)    0 - None    2 - Less than full    3 - Full', 'Level of effort used to assign classification  (NR)    0 - None    2 - Less than full    3 - Full', '', 0, 0, NULL),
(0, 0, '039', 'e', 'Number of fixed field character positions coded  (NR)    0 - None    1 - Minimal    2 - Most necessary    3 - Full', 'Number of fixed field character positions coded  (NR)    0 - None    1 - Minimal    2 - Most necessary    3 - Full', '', 0, 0, NULL),
(0, 0, '040', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '040', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '040', 'a', 'Agencia/entidad que catalogó originalmente la obra (NR)', 'Agencia/entidad que catalogó originalmente la obra (NR)', '', 0, 0, NULL),
(0, 0, '040', 'b', 'Idioma en que se cataloga (NR)', 'Idioma en que se cataloga (NR)', '', 0, 0, NULL),
(0, 0, '040', 'c', 'Entidad que transcribió la catalogación (NR)', 'Entidad que transcribió la catalogación (NR)', '', 0, 0, NULL),
(0, 0, '040', 'd', 'Entidad que modificó el registro (R)', 'Entidad que modificó el registro (R)', '', 1, 0, NULL),
(0, 0, '040', 'e', 'Convenciones de la descripción (NR)', 'Convenciones de la descripción (NR)', '', 0, 0, NULL),
(0, 0, '041', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '041', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '041', 'a', 'Código de idioma para texto o pista de sonido o título separado (R)', 'Código de idioma para texto o pista de sonido o título separado (R)', '', 1, 0, 'biblioitems.idLanguage'),
(0, 0, '041', 'b', 'Código de idioma del resumen (R)', 'Código de idioma del resumen (R)', '', 1, 0, NULL),
(0, 0, '041', 'c', 'Idiomas de traducción disponible (SE) [OBSOLETE]', 'Idiomas de traducción disponible (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '041', 'd', 'Código de idioma de texto cantado o hablado (R)', 'Código de idioma de texto cantado o hablado (R)', '', 1, 0, NULL),
(0, 0, '041', 'e', 'Código de idioma de libretos (R)', 'Código de idioma de libretos (R)', '', 1, 0, NULL),
(0, 0, '041', 'f', 'Código de idioma de la tabla de contenidos (R)', 'Código de idioma de la tabla de contenidos (R)', '', 1, 0, NULL),
(0, 0, '041', 'g', 'Código de idioma del material anexado diferente de libretos (R)', 'Código de idioma del material anexado diferente de libretos (R)', '', 1, 0, NULL),
(0, 0, '041', 'h', 'Código de idioma de la versión original y/o traducciones intermedias del texto (R)', 'Código de idioma de la versión original y/o traducciones intermedias del texto (R)', '', 1, 0, NULL),
(0, 0, '042', '6', 'Linkage See', 'Linkage See', '', 0, 0, NULL),
(0, 0, '042', '8', 'Field link and sequence number See', 'Field link and sequence number See', '', 1, 0, NULL),
(0, 0, '042', 'a', 'Código de autenticación (R)', 'Código de autenticación (R)', '', 1, 0, NULL),
(0, 0, '042', 'b', 'Formatted 9999 B', 'Formatted 9999 B', '', 1, 0, NULL),
(0, 0, '042', 'c', 'Formatted pre-9999 B', 'Formatted pre-9999 B', '', 1, 0, NULL),
(0, 0, '043', '2', 'Fuente de código local (R)', 'Fuente de código local (R)', '', 1, 0, NULL),
(0, 0, '043', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '043', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '043', 'a', 'Código de área geográfica (R)', 'Código de área geográfica (R)', '', 1, 0, NULL),
(0, 0, '043', 'c', 'Código ISO (R)', 'Código ISO (R)', '', 1, 0, 'biblioitems.idCountry'),
(0, 0, '044', '2', 'Fuente del código de sub-entidad local (R)', 'Fuente del código de sub-entidad local (R)', '', 1, 0, NULL),
(0, 0, '044', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '044', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '044', 'a', 'Código MARC del país (R)', 'Código MARC del país (R)', '', 1, 0, NULL),
(0, 0, '490', '3', 'Materiales específicos a los cuales se aplica el campo', 'Materiales específicos a los cuales se aplica el campo', '', 0, 0, NULL),
(0, 0, '044', 'b', 'Código de sub-entidad local (R)', 'Código de sub-entidad local (R)', '', 1, 0, NULL),
(0, 0, '044', 'c', 'Código ISO del país (R)', 'Código ISO del país (R)', '', 1, 0, NULL),
(0, 0, '045', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '045', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '045', 'a', 'Código de período cronológico (R)', 'Código de período cronológico (R)', '', 1, 0, NULL),
(0, 0, '045', 'b', 'Período cronológico de formato 9999 A.C. a D.C. (R)', 'Período cronológico de formato 9999 A.C. a D.C. (R)', '', 1, 0, NULL),
(0, 0, '045', 'c', 'Período cronológico de formato anterior a 9999 A.C. (R)', 'Período cronológico de formato anterior a 9999 A.C. (R)', '', 1, 0, NULL),
(0, 0, '046', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '046', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '046', 'a', 'Código de tipo de fecha (NR)', 'Código de tipo de fecha (NR)', '', 0, 0, NULL),
(0, 0, '046', 'b', 'Fecha 1 (fecha A.C.) (NR)', 'Fecha 1 (fecha A.C.) (NR)', '', 0, 0, NULL),
(0, 0, '046', 'c', 'Fecha 1 (fecha D.C.) (NR)', 'Fecha 1 (fecha D.C.) (NR)', '', 0, 0, NULL),
(0, 0, '046', 'd', 'Fecha 2 (fecha A.C.) (NR)', 'Fecha 2 (fecha A.C.) (NR)', '', 0, 0, NULL),
(0, 0, '046', 'e', 'Fecha 2 (fecha D.C.) (NR)', 'Fecha 2 (fecha D.C.) (NR)', '', 0, 0, NULL),
(0, 0, '047', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '047', 'a', 'Código de forma de la composición musical (R)', 'Código de forma de la composición musical (R)', '', 1, 0, NULL),
(0, 0, '047', 'b', 'Soloist', 'Soloist', '', 1, 0, NULL),
(0, 0, '048', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '048', 'a', 'Intérprete o conjunto (R)', 'Intérprete o conjunto (R)', '', 1, 0, NULL),
(0, 0, '048', 'b', 'Solista (R)', 'Solista (R)', '', 1, 0, NULL),
(0, 0, '050', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '050', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '050', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '050', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '050', 'b', 'Número de item (NR)', 'Número de item (NR)', '', 0, 0, NULL),
(0, 0, '050', 'd', 'Número de clase suplementario (MU) [OBSOLETE]', 'Número de clase suplementario (MU) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '051', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '051', 'a', 'Número de clasificación (NR)', 'Número de clasificación (NR)', '', 0, 0, NULL),
(0, 0, '051', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '051', 'c', 'Información de copia (NR)', 'Información de copia (NR)', '', 0, 0, NULL),
(0, 0, '052', '2', 'Fuente del código (NR)', 'Fuente del código (NR)', '', 0, 0, NULL),
(0, 0, '052', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '052', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '052', 'a', 'Código de área de clasificación geográfica (NR)', 'Código de área de clasificación geográfica (NR)', '', 0, 0, NULL),
(0, 0, '052', 'b', 'Código de subárea de clasificación geográfica (R)', 'Código de subárea de clasificación geográfica (R)', '', 1, 0, NULL),
(0, 0, '052', 'c', 'Subject (MP) [OBSOLETE]', 'Subject (MP) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '052', 'd', 'Nombre de poblado (R)', 'Nombre de poblado (R)', '', 1, 0, NULL),
(0, 0, '055', '2', 'Fuente del número de ubicación/clase (NR)', 'Fuente del número de ubicación/clase (NR)', '', 0, 0, NULL),
(0, 0, '055', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '055', 'a', 'Número de clasificación (NR)', 'Número de clasificación (NR)', '', 0, 0, NULL),
(0, 0, '055', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '060', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '060', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '060', 'b', 'Numero del ítem (NR)', 'Numero del ítem (NR)', '', 0, 0, NULL),
(0, 0, '061', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '061', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '061', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '061', 'c', 'Información de copia (NR)', 'Información de copia (NR)', '', 0, 0, NULL),
(0, 0, '066', 'a', 'Conjunto de caracteres primario G0 (NR)', 'Conjunto de caracteres primario G0 (NR)', '', 0, 0, NULL),
(0, 0, '066', 'b', 'Conjunto de caracteres G1 (NR)', 'Conjunto de caracteres G1 (NR)', '', 0, 0, NULL),
(0, 0, '066', 'c', 'Conjunto de caracteres alternos G0 o G1 (R)', 'Conjunto de caracteres alternos G0 o G1 (R)', '', 1, 0, NULL),
(0, 0, '070', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '070', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '070', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '071', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '071', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '071', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '071', 'c', 'Información de copia (NR)', 'Información de copia (NR)', '', 0, 0, NULL),
(0, 0, '072', '2', 'Fuente (NR)', 'Fuente (NR)', '', 0, 0, NULL),
(0, 0, '072', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '072', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '072', 'a', 'Código de categoría temática (NR)', 'Código de categoría temática (NR)', '', 0, 0, NULL),
(0, 0, '072', 'x', 'Subdivisión de código de categoría temática (R)', 'Subdivisión de código de categoría temática (R)', '', 1, 0, NULL),
(0, 0, '074', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '074', 'a', 'Número de ítem GPO (NR)', 'Número de ítem GPO (NR)', '', 0, 0, NULL),
(0, 0, '074', 'z', 'Número de ítem GPO cancelado/no válido (R)', 'Número de ítem GPO cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '080', '2', 'Identificador de la edición (NR)', 'Identificador de la edición (NR)', '', 0, 0, NULL),
(0, 0, '080', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '080', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '080', 'a', 'Número de Clasificación Decimal Universal (NR)', 'Número de Clasificación Decimal Universal (NR)', '', 0, 0, 'biblio.seriestitle'),
(0, 0, '080', 'b', 'Número del ítem (NR)', 'Número del ítem (NR)', '', 0, 0, NULL),
(0, 0, '080', 'x', 'Subdivisión auxiliar común (R)', 'Subdivisión auxiliar común (R)', '', 1, 0, NULL),
(0, 0, '082', '2', 'Número de la edición (NR)', 'Número de la edición (NR)', '', 0, 0, NULL),
(0, 0, '082', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '082', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '082', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '082', 'b', 'Número DDC -- versión NST abreviada (SE) [OBSOLETE]', 'Número DDC -- versión NST abreviada (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '084', '2', 'Fuente del número (NR)', 'Fuente del número (NR)', '', 0, 0, NULL),
(0, 0, '084', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '084', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '084', 'a', 'Número de clasificación (R)', 'Número de clasificación (R)', '', 1, 0, NULL),
(0, 0, '084', 'b', 'Número de ítem (NR)', 'Número de ítem (NR)', '', 0, 0, NULL),
(0, 0, '086', '2', 'Fuente del número (NR)', 'Fuente del número (NR)', '', 0, 0, NULL),
(0, 0, '086', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '086', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '086', 'a', 'Número de clasificación (NR)', 'Número de clasificación (NR)', '', 0, 0, NULL),
(0, 0, '086', 'z', 'Número de clasificación no válido/cancelado (R)', 'Número de clasificación no válido/cancelado (R)', '', 1, 0, NULL),
(0, 0, '088', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '088', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '088', 'a', 'Número de reporte (NR)', 'Número de reporte (NR)', '', 0, 0, NULL),
(0, 0, '088', 'z', 'Número de reporte cancelado/no válido (R)', 'Número de reporte cancelado/no válido (R)', '', 1, 0, NULL),
(0, 0, '090', 'a', 'Ubicación en estante (NR)', 'Ubicación en estante (NR)', '', 0, 0, NULL),
(0, 0, '090', 'b', 'Local Cutter number', 'Local Cutter number', '', 0, 0, NULL),
(0, 0, '090', 'c', 'Koha biblionumber (NR)', 'Koha biblionumber (NR)', '', 0, 0, 'biblio.biblionumber'),
(0, 0, '090', 'd', 'Koha biblioitemnumber (NR)', 'Koha biblioitemnumber (NR)', '', 0, 0, 'biblioitems.biblioitemnumber'),
(0, 0, '091', 'a', 'Microfilm shelf location (NR)', 'Microfilm shelf location (NR)', '', 0, 0, NULL),
(0, 0, '100', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '100', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '100', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '100', 'a', 'Nombre personal (NR)', 'Nombre personal (NR)', '', 0, 0, 'biblio.author'),
(0, 0, '100', 'b', 'Numeración (NR)', 'Numeración (NR)', '', 0, 0, NULL),
(0, 0, '100', 'c', 'Títulos y otras palabras asociadas con el nombre (R)', 'Títulos y otras palabras asociadas con el nombre (R)', '', 1, 0, NULL),
(0, 0, '100', 'd', 'Fechas asociadas con el nombre (NR)', 'Fechas asociadas con el nombre (NR)', '', 0, 0, NULL),
(0, 0, '100', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '100', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '100', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '100', 'j', 'Calificador de atributos (R)', 'Calificador de atributos (R)', '', 1, 0, NULL),
(0, 0, '100', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '100', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '100', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '100', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '100', 'q', 'Forma completa del nombre (NR)', 'Forma completa del nombre (NR)', '', 0, 0, NULL),
(0, 0, '100', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '100', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '110', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '110', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '110', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '110', 'a', 'Nombre de la institución, jurisdicción como asiento principal (NR)', 'Nombre de la institución, jurisdicción como asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '110', 'b', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '110', 'c', 'Ubicación de la reunión (NR)', 'Ubicación de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '110', 'd', 'Fecha de la reunión o firma de tratado (R)', 'Fecha de la reunión o firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '110', 'e', 'Relación (R)', 'Relación (R)', '', 1, 0, NULL),
(0, 0, '110', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '110', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '110', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '110', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '110', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '110', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '110', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '110', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '111', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '111', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '111', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '111', 'a', 'Nombre de la reunión como asiento principal (NR)', 'Nombre de la reunión como asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '111', 'b', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '111', 'c', 'Localización de la reunión (NR)', 'Localización de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '111', 'd', 'Fecha de la reunión (NR)', 'Fecha de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '111', 'e', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '111', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '111', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '111', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '111', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '111', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '111', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '111', 'q', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '111', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '111', 'u', 'Afiliación  (NR)', 'Afiliación  (NR)', '', 0, 0, NULL),
(0, 0, '130', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '130', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '130', 'a', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '130', 'd', 'Fecha de firma de tratado (R)', 'Fecha de firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '130', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '130', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '130', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '130', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '130', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '130', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '130', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '130', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '130', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '130', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '130', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '130', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '210', '2', 'Fuente (R)', 'Fuente (R)', '', 1, 0, NULL),
(0, 0, '210', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '210', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '210', 'a', 'Título abreviado (NR)', 'Título abreviado (NR)', '', 0, 0, NULL),
(0, 0, '210', 'b', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '211', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '211', 'a', 'Acronym or shortened Título (NR)', 'Acronym or shortened Título (NR)', '', 0, 0, NULL),
(0, 0, '212', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '212', 'a', 'Variant access Título (NR)', 'Variant access Título (NR)', '', 0, 0, NULL),
(0, 0, '214', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '214', 'a', 'Augmented Título (NR)', 'Augmented Título (NR)', '', 0, 0, NULL),
(0, 0, '222', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '222', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '222', 'a', 'Título clave (NR)', 'Título clave (NR)', '', 0, 0, NULL),
(0, 0, '222', 'b', 'Informacion calificadora (NR)', 'Informacion calificadora (NR)', '', 0, 0, NULL),
(0, 0, '240', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '240', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '240', 'a', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '240', 'd', 'Fecha de la firma del tratado (R)', 'Fecha de la firma del tratado (R)', '', 1, 0, NULL),
(0, 0, '240', 'f', 'Fecha del trabajo (NR)', 'Fecha del trabajo (NR)', '', 0, 0, NULL),
(0, 0, '240', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '240', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '240', 'k', 'Formas de subencabezados (R)', 'Formas de subencabezados (R)', '', 1, 0, NULL),
(0, 0, '240', 'l', 'Idioma del trabajo (NR)', 'Idioma del trabajo (NR)', '', 0, 0, NULL),
(0, 0, '240', 'm', 'Medio para la ejecución de música (R)', 'Medio para la ejecución de música (R)', '', 1, 0, NULL),
(0, 0, '240', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '240', 'o', 'Mención de arreglo música (NR)', 'Mención de arreglo música (NR)', '', 0, 0, NULL),
(0, 0, '240', 'p', 'Nombre de la parte/sección (R)', 'Nombre de la parte/sección (R)', '', 1, 0, NULL),
(0, 0, '240', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '240', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '241', 'a', 'Romanized Título (NR)', 'Romanized Título (NR)', '', 0, 0, NULL),
(0, 0, '241', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '242', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '242', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '242', 'a', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '242', 'b', 'Resto del título (NR)', 'Resto del título (NR)', '', 0, 0, NULL),
(0, 0, '242', 'c', 'Declaración de responsabilidad , etc. (NR)', 'Declaración de responsabilidad , etc. (NR)', '', 0, 0, NULL),
(0, 0, '242', 'd', 'Designación de la sección (BK AM MP MU VM SE) [OBSOLETE]', 'Designación de la sección (BK AM MP MU VM SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '242', 'e', 'Nombre de la parte/sección (BK AM MP MU VM SE) [OBSOLETE]', 'Nombre de la parte/sección (BK AM MP MU VM SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '242', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '242', 'n', 'Número de la parte/sección del trabajo (R)', 'Número de la parte/sección del trabajo (R)', '', 1, 0, NULL),
(0, 0, '242', 'p', 'Nombre de la parte/sección del trabajo (R)', 'Nombre de la parte/sección del trabajo (R)', '', 1, 0, NULL),
(0, 0, '242', 'y', 'Código de idioma del título traducido (NR)', 'Código de idioma del título traducido (NR)', '', 0, 0, NULL),
(0, 0, '243', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '243', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '243', 'a', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '243', 'd', 'Fecha de firma de tratado (R)', 'Fecha de firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '243', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '243', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '243', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '243', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '243', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '243', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '243', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '243', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '243', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '243', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '243', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '245', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '245', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 1, '245', 'a', 'Título (NR)', 'Título (NR)', '', 0, 0, 'biblio.title'),
(0, 0, '245', 'b', 'Resto del título (NR)', 'Resto del título (NR)', '', 0, 0, 'biblio.unititle'),
(0, 0, '245', 'c', 'Declaración de responsabilidad, etc. (NR)', 'Declaración de responsabilidad, etc. (NR)', '', 0, 0, NULL),
(0, 0, '245', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '245', 'e', 'Name of part/section (SE) [OBSOLETE]', 'Name of part/section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '245', 'f', 'Fechas inclusivas (NR)', 'Fechas inclusivas (NR)', '', 0, 0, NULL),
(0, 0, '245', 'g', 'Bulk dates (NR)', 'Bulk dates (NR)', '', 0, 0, NULL),
(0, 0, '245', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '245', 'k', 'Forma (R)', 'Forma (R)', '', 1, 0, NULL),
(0, 0, '245', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '245', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '245', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '246', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '246', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '246', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '246', 'a', 'Título propiamente dicho/título corto (NR)', 'Título propiamente dicho/título corto (NR)', '', 0, 0, 'bibliosubtitle.subtitle'),
(0, 0, '246', 'b', 'Resto del título (NR)', 'Resto del título (NR)', '', 0, 0, NULL),
(0, 0, '246', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '246', 'e', 'Name of part/section (SE) [OBSOLETE]', 'Name of part/section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '246', 'f', 'Fecha o designación secuencial (NR)', 'Fecha o designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '533', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '246', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '246', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '246', 'i', 'Texto a desplegar (NR)', 'Texto a desplegar (NR)', '', 0, 0, NULL),
(0, 0, '246', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '246', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '247', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '247', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '247', 'a', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '247', 'b', 'Resto del título (NR)', 'Resto del título (NR)', '', 0, 0, NULL),
(0, 0, '247', 'd', 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '247', 'e', 'Name of part/section (SE) [OBSOLETE]', 'Name of part/section (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '247', 'f', 'Fecha o designación secuencial (NR)', 'Fecha o designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '247', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '247', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '247', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '247', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '247', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '250', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '250', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '250', 'a', 'Mención de edición (NR)', 'Mención de edición (NR)', '', 0, 0, 'biblioitems.number'),
(0, 0, '250', 'b', 'Resto de la mención de edición (NR)', 'Resto de la mención de edición (NR)', '', 0, 0, NULL),
(0, 0, '254', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '254', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '254', 'a', 'Mención de presentación musical (NR)', 'Mención de presentación musical (NR)', '', 0, 0, NULL),
(0, 0, '255', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '255', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '255', 'a', 'Mención de escala (NR)', 'Mención de escala (NR)', '', 0, 0, NULL),
(0, 0, '255', 'b', 'Mención de proyección (NR)', 'Mención de proyección (NR)', '', 0, 0, NULL),
(0, 0, '255', 'c', 'Mención de coordenadas (NR)', 'Mención de coordenadas (NR)', '', 0, 0, NULL),
(0, 0, '255', 'd', 'Mención de zona (NR)', 'Mención de zona (NR)', '', 0, 0, NULL),
(0, 0, '255', 'e', 'Mención de equinoccio (NR)', 'Mención de equinoccio (NR)', '', 0, 0, NULL),
(0, 0, '255', 'f', 'Pares de coordenadas del G-ring externo (NR)', 'Pares de coordenadas del G-ring externo (NR)', '', 0, 0, NULL),
(0, 0, '255', 'g', 'Pares de coordenadas del G-ring de exclusión (NR)', 'Pares de coordenadas del G-ring de exclusión (NR)', '', 0, 0, NULL),
(0, 0, '256', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '256', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '256', 'a', 'Características de archivo informático (NR)', 'Características de archivo informático (NR)', '', 0, 0, NULL),
(0, 0, '257', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '257', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '257', 'a', 'País de la entidad que produce (R)', 'País de la entidad que produce (R)', '', 1, 0, NULL),
(0, 0, '260', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '260', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '260', 'a', 'Lugar de publicación, distribución, etc. (R)', 'Lugar de publicación, distribución, etc. (R)', '', 1, 0, 'biblioitems.place'),
(0, 0, '260', 'b', 'Nombre de la editorial, distribuidor, etc. (R)', 'Nombre de la editorial, distribuidor, etc. (R)', '', 1, 0, 'publisher.publisher'),
(0, 0, '260', 'c', 'Fecha de publicación, distribución, etc. (R)', 'Fecha de publicación, distribución, etc. (R)', '', 1, 0, 'biblioitems.publicationyear'),
(0, 0, '260', 'd', 'Placa o número de editor para música (Pre-AACR 2) (NR) [LOCAL]', 'Placa o número de editor para música (Pre-AACR 2) (NR) [LOCAL]', '', 0, 0, NULL),
(0, 0, '260', 'e', 'Lugar de fabricación (R)', 'Lugar de fabricación (R)', '', 1, 0, NULL),
(0, 0, '260', 'f', 'Fabricante (R)', 'Fabricante (R)', '', 1, 0, NULL),
(0, 0, '260', 'g', 'Fecha de fabricación (R)', 'Fecha de fabricación (R)', '', 1, 0, NULL),
(0, 0, '261', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '261', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '261', 'a', 'Compañía productora (R)', 'Compañía productora (R)', '', 1, 0, NULL),
(0, 0, '261', 'b', 'Compañía que comercializa (distribuidor primario) (R)', 'Compañía que comercializa (distribuidor primario) (R)', '', 1, 0, NULL),
(0, 0, '261', 'd', 'Fecha de producción, publicación, etc. (R)', 'Fecha de producción, publicación, etc. (R)', '', 1, 0, NULL),
(0, 0, '261', 'e', 'Productor contractual (R)', 'Productor contractual (R)', '', 1, 0, NULL),
(0, 0, '261', 'f', 'Lugar de producción, publicación, etc. (R)', 'Lugar de producción, publicación, etc. (R)', '', 1, 0, NULL),
(0, 0, '262', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '262', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '262', 'a', 'Lugar de producción, publicación, etc. (NR)', 'Lugar de producción, publicación, etc. (NR)', '', 0, 0, NULL),
(0, 0, '262', 'b', 'Nombre comercial o editor (NR)', 'Nombre comercial o editor (NR)', '', 0, 0, NULL),
(0, 0, '262', 'c', 'Fecha de producción, publicación, etc. (NR)', 'Fecha de producción, publicación, etc. (NR)', '', 0, 0, NULL),
(0, 0, '262', 'k', 'Identificación serial (NR)', 'Identificación serial (NR)', '', 0, 0, NULL),
(0, 0, '262', 'l', 'Número matriz o de pista (NR)', 'Número matriz o de pista (NR)', '', 0, 0, NULL),
(0, 0, '263', '4', 'Relator code', 'Relator code', '', 1, 0, NULL),
(0, 0, '263', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '263', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '263', 'a', 'Fecha de publicación estimada (NR)', 'Fecha de publicación estimada (NR)', '', 0, 0, NULL),
(0, 0, '263', 'b', 'City', 'City', '', 0, 0, NULL),
(0, 0, '263', 'c', 'State or province', 'State or province', '', 0, 0, NULL),
(0, 0, '263', 'd', 'Country', 'Country', '', 0, 0, NULL),
(0, 0, '263', 'e', 'Postal code', 'Postal code', '', 0, 0, NULL),
(0, 0, '263', 'f', 'Terms preceding attention name', 'Terms preceding attention name', '', 0, 0, NULL),
(0, 0, '263', 'g', 'Attention name', 'Attention name', '', 0, 0, NULL),
(0, 0, '263', 'h', 'Attention position', 'Attention position', '', 0, 0, NULL),
(0, 0, '263', 'i', 'Type of address', 'Type of address', '', 0, 0, NULL),
(0, 0, '263', 'j', 'Specialized telephone number', 'Specialized telephone number', '', 1, 0, NULL),
(0, 0, '263', 'k', 'Telephone number', 'Telephone number', '', 1, 0, NULL),
(0, 0, '263', 'l', 'Fax number', 'Fax number', '', 1, 0, NULL),
(0, 0, '263', 'm', 'Electronic mail address', 'Electronic mail address', '', 1, 0, NULL),
(0, 0, '263', 'n', 'TDD or TTY number', 'TDD or TTY number', '', 1, 0, NULL),
(0, 0, '263', 'p', 'Contact person', 'Contact person', '', 1, 0, NULL),
(0, 0, '263', 'q', 'Title of contact person', 'Title of contact person', '', 1, 0, NULL),
(0, 0, '263', 'r', 'Hours', 'Hours', '', 1, 0, NULL),
(0, 0, '263', 'z', 'Public note', 'Public note', '', 1, 0, NULL),
(0, 0, '265', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '265', 'a', 'Source for acquisition/subscription address (R)', 'Source for acquisition/subscription address (R)', '', 1, 0, NULL),
(0, 0, '270', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '270', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '270', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '270', 'a', 'Dirección (R)', 'Dirección (R)', '', 1, 0, NULL),
(0, 0, '270', 'b', 'Ciudad (NR)', 'Ciudad (NR)', '', 0, 0, NULL),
(0, 0, '270', 'c', 'Provincia o estado (NR)', 'Provincia o estado (NR)', '', 0, 0, NULL);
INSERT INTO `pref_estructura_subcampo_marc` (`nivel`, `obligatorio`, `campo`, `subcampo`, `liblibrarian`, `libopac`, `descripcion`, `repetible`, `mandatory`, `kohafield`) VALUES
(0, 0, '270', 'd', 'País (NR)', 'País (NR)', '', 0, 0, NULL),
(0, 0, '270', 'e', 'Código postal (NR)', 'Código postal (NR)', '', 0, 0, NULL),
(0, 0, '270', 'f', 'Términos que preceden el nombre de atención (NR)', 'Términos que preceden el nombre de atención (NR)', '', 0, 0, NULL),
(0, 0, '270', 'g', 'Nombre de atención (NR)', 'Nombre de atención (NR)', '', 0, 0, NULL),
(0, 0, '270', 'h', 'Posición de atención (NR)', 'Posición de atención (NR)', '', 0, 0, NULL),
(0, 0, '270', 'i', 'Tipo de dirección (NR)', 'Tipo de dirección (NR)', '', 0, 0, NULL),
(0, 0, '270', 'j', 'Número de teléfono especializado (R)', 'Número de teléfono especializado (R)', '', 1, 0, NULL),
(0, 0, '270', 'k', 'Número de teléfono (R)', 'Número de teléfono (R)', '', 1, 0, NULL),
(0, 0, '270', 'l', 'Número de fax (R)', 'Número de fax (R)', '', 1, 0, NULL),
(0, 0, '270', 'm', 'Dirección de correo electrónico (R)', 'Dirección de correo electrónico (R)', '', 1, 0, NULL),
(0, 0, '270', 'n', 'Número TDD o TTY (R)', 'Número TDD o TTY (R)', '', 1, 0, NULL),
(0, 0, '270', 'p', 'Persona de contacto (R)', 'Persona de contacto (R)', '', 1, 0, NULL),
(0, 0, '270', 'q', 'Título de persona de contacto (R)', 'Título de persona de contacto (R)', '', 1, 0, NULL),
(0, 0, '270', 'r', 'Horas (R)', 'Horas (R)', '', 1, 0, NULL),
(0, 0, '270', 'z', 'Nota pública (R)', 'Nota pública (R)', '', 1, 0, NULL),
(0, 0, '300', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '300', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '300', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '300', 'a', 'Extensión (R)', 'Extensión (R)', '', 1, 0, 'biblioitems.pages'),
(0, 0, '300', 'b', 'Otros detalles físicos (NR)', 'Otros detalles físicos (NR)', '', 0, 0, 'biblioitems.illus'),
(0, 0, '300', 'c', 'Dimensiones (R)', 'Dimensiones (R)', '', 1, 0, 'biblioitems.size'),
(0, 0, '300', 'e', 'Material acompañante (NR)', 'Material acompañante (NR)', '', 0, 0, NULL),
(0, 0, '300', 'f', 'Tipo de unidad (R)', 'Tipo de unidad (R)', '', 1, 0, NULL),
(0, 0, '300', 'g', 'Tamaño de unidad (R)', 'Tamaño de unidad (R)', '', 1, 0, NULL),
(0, 0, '301', 'a', 'Extensión of item (NR)', 'Extensión of item (NR)', '', 0, 0, NULL),
(0, 0, '301', 'b', 'Sound characteristics (NR)', 'Sound characteristics (NR)', '', 0, 0, NULL),
(0, 0, '301', 'c', 'Color characteristics (NR)', 'Color characteristics (NR)', '', 0, 0, NULL),
(0, 0, '301', 'd', 'Dimensions (NR)', 'Dimensions (NR)', '', 0, 0, NULL),
(0, 0, '301', 'e', 'Accompanying material (NR)', 'Accompanying material (NR)', '', 0, 0, NULL),
(0, 0, '301', 'f', 'Speed (NR)', 'Speed (NR)', '', 0, 0, NULL),
(0, 0, '302', 'a', 'Page count (NR)', 'Page count (NR)', '', 0, 0, NULL),
(0, 0, '303', 'a', 'Unit count (NR)', 'Unit count (NR)', '', 0, 0, NULL),
(0, 0, '304', 'a', 'Linear footage (NR)', 'Linear footage (NR)', '', 0, 0, NULL),
(0, 0, '305', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '305', 'a', 'Extensión (NR)', 'Extensión (NR)', '', 0, 0, NULL),
(0, 0, '305', 'b', 'Other physical details (NR)', 'Other physical details (NR)', '', 0, 0, NULL),
(0, 0, '305', 'c', 'Dimensions (NR)', 'Dimensions (NR)', '', 0, 0, NULL),
(0, 0, '305', 'd', 'Microgroove or standard (NR)', 'Microgroove or standard (NR)', '', 0, 0, NULL),
(0, 0, '305', 'e', 'Stereophonic, monaural (NR)', 'Stereophonic, monaural (NR)', '', 0, 0, NULL),
(0, 0, '305', 'f', 'Number of tracks (NR)', 'Number of tracks (NR)', '', 0, 0, NULL),
(0, 0, '305', 'm', 'Serial identification (NR)', 'Serial identification (NR)', '', 0, 0, NULL),
(0, 0, '305', 'n', 'Matrix and/or take number (NR)', 'Matrix and/or take number (NR)', '', 0, 0, NULL),
(0, 0, '306', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '306', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '306', 'a', 'Duración (R)', 'Duración (R)', '', 1, 0, NULL),
(0, 0, '306', 'b', 'Additional information', 'Additional information', '', 0, 0, NULL),
(0, 0, '307', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '307', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '307', 'a', 'Horas (NR)', 'Horas (NR)', '', 0, 0, NULL),
(0, 0, '307', 'b', 'Información adicional (NR)', 'Información adicional (NR)', '', 0, 0, NULL),
(0, 0, '308', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '308', 'a', 'Number of reels (NR)', 'Number of reels (NR)', '', 0, 0, NULL),
(0, 0, '308', 'b', 'Footage (NR)', 'Footage (NR)', '', 0, 0, NULL),
(0, 0, '308', 'c', 'Sound characteristics (NR)', 'Sound characteristics (NR)', '', 0, 0, NULL),
(0, 0, '308', 'd', 'Color characteristics (NR)', 'Color characteristics (NR)', '', 0, 0, NULL),
(0, 0, '308', 'e', 'Width (NR)', 'Width (NR)', '', 0, 0, NULL),
(0, 0, '308', 'f', 'Formato de presentación (NR)', 'Formato de presentación (NR)', '', 0, 0, NULL),
(0, 0, '310', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '310', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '310', 'a', 'Frecuencia actual de la publicación (NR)', 'Frecuencia actual de la publicación (NR)', '', 0, 0, NULL),
(0, 0, '310', 'b', 'Fecha de frecuencia actual de la publicación (NR)', 'Fecha de frecuencia actual de la publicación (NR)', '', 0, 0, NULL),
(0, 0, '315', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '315', 'a', 'Frequency (R)', 'Frequency (R)', '', 1, 0, NULL),
(0, 0, '315', 'b', 'Dates of frequency (R)', 'Dates of frequency (R)', '', 1, 0, NULL),
(0, 0, '321', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '321', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '321', 'a', 'Frecuencia anterior de publicación (NR)', 'Frecuencia anterior de publicación (NR)', '', 0, 0, NULL),
(0, 0, '321', 'b', 'Fechas de frecuencia anterior de publicación (NR)', 'Fechas de frecuencia anterior de publicación (NR)', '', 0, 0, NULL),
(0, 0, '340', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '340', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '340', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '340', 'a', 'Configuración y base material (R)', 'Configuración y base material (R)', '', 1, 0, NULL),
(0, 0, '340', 'b', 'Dimensiones (R)', 'Dimensiones (R)', '', 1, 0, NULL),
(0, 0, '340', 'c', 'Materiales aplicados a la superficie (R)', 'Materiales aplicados a la superficie (R)', '', 1, 0, NULL),
(0, 0, '340', 'd', 'Técnica de grabado de la información (R)', 'Técnica de grabado de la información (R)', '', 1, 0, NULL),
(0, 0, '340', 'e', 'Soporte (R)', 'Soporte (R)', '', 1, 0, NULL),
(0, 0, '340', 'f', 'Tasa o proporción de producción (R)', 'Tasa o proporción de producción (R)', '', 1, 0, NULL),
(0, 0, '340', 'h', 'Ubicación en el medio (R)', 'Ubicación en el medio (R)', '', 1, 0, NULL),
(0, 0, '340', 'i', 'Especificaciones técnicas del medio (R)', 'Especificaciones técnicas del medio (R)', '', 1, 0, NULL),
(0, 0, '342', '2', 'Método de referencia utilizado (NR)', 'Método de referencia utilizado (NR)', '', 0, 0, NULL),
(0, 0, '342', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '342', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '342', 'a', 'Nombre (NR)', 'Nombre (NR)', '', 0, 0, NULL),
(0, 0, '342', 'b', 'Coordenada o unidades de distancia (NR)', 'Coordenada o unidades de distancia (NR)', '', 0, 0, NULL),
(0, 0, '342', 'c', 'Resolución de latitud (NR)', 'Resolución de latitud (NR)', '', 0, 0, NULL),
(0, 0, '342', 'd', 'Resolución de longitud (NR)', 'Resolución de longitud (NR)', '', 0, 0, NULL),
(0, 0, '342', 'e', 'Latitud estándar de línea oblicua o paralela (R)', 'Latitud estándar de línea oblicua o paralela (R)', '', 1, 0, NULL),
(0, 0, '342', 'f', 'Longitud de línea oblicua (R)', 'Longitud de línea oblicua (R)', '', 1, 0, NULL),
(0, 0, '342', 'g', 'Longitud del meridiano central o centro de proyección  (NR)', 'Longitud del meridiano central o centro de proyección  (NR)', '', 0, 0, NULL),
(0, 0, '342', 'h', 'Latitud del origen de proyección o centro de proyección (NR)', 'Latitud del origen de proyección o centro de proyección (NR)', '', 0, 0, NULL),
(0, 0, '342', 'i', 'Falso este (NR)', 'Falso este (NR)', '', 0, 0, NULL),
(0, 0, '342', 'j', 'Falso norte (NR)', 'Falso norte (NR)', '', 0, 0, NULL),
(0, 0, '342', 'k', 'Factor de escala (NR)', 'Factor de escala (NR)', '', 0, 0, NULL),
(0, 0, '342', 'l', 'Altura del punto de perspectiva por sobre la superficie (NR)', 'Altura del punto de perspectiva por sobre la superficie (NR)', '', 0, 0, NULL),
(0, 0, '342', 'm', 'Ángulo acimutal (NR)', 'Ángulo acimutal (NR)', '', 0, 0, NULL),
(0, 0, '342', 'n', 'Longitud del punto de medición del acimut o longitud vertical recta desde el polo (NR)', 'Longitud del punto de medición del acimut o longitud vertical recta desde el polo (NR)', '', 0, 0, NULL),
(0, 0, '342', 'o', 'Número de LandSat y número de trayectoria (NR)', 'Número de LandSat y número de trayectoria (NR)', '', 0, 0, NULL),
(0, 0, '342', 'p', 'Identificador de zona (NR)', 'Identificador de zona (NR)', '', 0, 0, NULL),
(0, 0, '342', 'q', 'Nombre del elipsoide (NR)', 'Nombre del elipsoide (NR)', '', 0, 0, NULL),
(0, 0, '342', 'r', 'Eje semi-principal (NR)', 'Eje semi-principal (NR)', '', 0, 0, NULL),
(0, 0, '342', 's', 'Denominador de la proporción de aplanamiento (NR)', 'Denominador de la proporción de aplanamiento (NR)', '', 0, 0, NULL),
(0, 0, '342', 't', 'Resolución vertical (NR)', 'Resolución vertical (NR)', '', 0, 0, NULL),
(0, 0, '342', 'u', 'Método de codificación vertical (NR)', 'Método de codificación vertical (NR)', '', 0, 0, NULL),
(0, 0, '342', 'v', 'Plano local, local, u otra projección o descripción en malla (NR)', 'Plano local, local, u otra projección o descripción en malla (NR)', '', 0, 0, NULL),
(0, 0, '342', 'w', 'Información de georeferencia de plano local o local (NR)', 'Información de georeferencia de plano local o local (NR)', '', 0, 0, NULL),
(0, 0, '343', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '343', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '343', 'a', 'Método de codificación de las coordenadas del plano (NR)', 'Método de codificación de las coordenadas del plano (NR)', '', 0, 0, NULL),
(0, 0, '343', 'b', 'Unidades de distancia del plano (NR)', 'Unidades de distancia del plano (NR)', '', 0, 0, NULL),
(0, 0, '343', 'c', 'Resolución de abscisa (NR)', 'Resolución de abscisa (NR)', '', 0, 0, NULL),
(0, 0, '343', 'd', 'Resolución de ordenada(NR)', 'Resolución de ordenada(NR)', '', 0, 0, NULL),
(0, 0, '343', 'e', 'Resolución de distancia (NR)', 'Resolución de distancia (NR)', '', 0, 0, NULL),
(0, 0, '343', 'f', 'Resolución de orientación (NR)', 'Resolución de orientación (NR)', '', 0, 0, NULL),
(0, 0, '343', 'g', 'Unidades de orientación (NR)', 'Unidades de orientación (NR)', '', 0, 0, NULL),
(0, 0, '343', 'h', 'Dirección de referencia de orientación (NR)', 'Dirección de referencia de orientación (NR)', '', 0, 0, NULL),
(0, 0, '343', 'i', 'Meridiano de referencia de orientación (NR)', 'Meridiano de referencia de orientación (NR)', '', 0, 0, NULL),
(0, 0, '350', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '350', 'a', 'Price (R)', 'Price (R)', '', 1, 0, NULL),
(0, 0, '350', 'b', 'Form of issue (R)', 'Form of issue (R)', '', 1, 0, NULL),
(0, 0, '351', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '351', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '351', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '351', 'a', 'Organización (R)', 'Organización (R)', '', 1, 0, NULL),
(0, 0, '351', 'b', 'Arreglo (R)', 'Arreglo (R)', '', 1, 0, NULL),
(0, 0, '351', 'c', 'Nivel jerárquico (NR)', 'Nivel jerárquico (NR)', '', 0, 0, NULL),
(0, 0, '352', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '352', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '352', 'a', 'Método de referencia directa (NR)', 'Método de referencia directa (NR)', '', 0, 0, NULL),
(0, 0, '352', 'b', 'Tipo de objeto (R)', 'Tipo de objeto (R)', '', 1, 0, NULL),
(0, 0, '352', 'c', 'Conteo de objetos (R)', 'Conteo de objetos (R)', '', 1, 0, NULL),
(0, 0, '352', 'd', 'Conteo de filas (NR)', 'Conteo de filas (NR)', '', 0, 0, NULL),
(0, 0, '352', 'e', 'Conteo de columnas (NR)', 'Conteo de columnas (NR)', '', 0, 0, NULL),
(0, 0, '352', 'f', 'Conteo vertical (NR)', 'Conteo vertical (NR)', '', 0, 0, NULL),
(0, 0, '352', 'g', 'Nivel topológico VPF (NR)', 'Nivel topológico VPF (NR)', '', 0, 0, NULL),
(0, 0, '352', 'i', 'Descripción de referencia indirecta (NR)', 'Descripción de referencia indirecta (NR)', '', 0, 0, NULL),
(0, 0, '355', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '355', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '355', 'a', 'Clasificación de seguridad (NR)', 'Clasificación de seguridad (NR)', '', 0, 0, NULL),
(0, 0, '355', 'b', 'Instrucciones de manejo (R)', 'Instrucciones de manejo (R)', '', 1, 0, NULL),
(0, 0, '355', 'c', 'Información sobre diseminación externa (R)', 'Información sobre diseminación externa (R)', '', 1, 0, NULL),
(0, 0, '355', 'd', 'Evento de reclasificación a menor nivel o desclasificación (NR)', 'Evento de reclasificación a menor nivel o desclasificación (NR)', '', 0, 0, NULL),
(0, 0, '355', 'e', 'Sistema de clasificación (NR)', 'Sistema de clasificación (NR)', '', 0, 0, NULL),
(0, 0, '355', 'f', 'Código del país de origen (NR)', 'Código del país de origen (NR)', '', 0, 0, NULL),
(0, 0, '355', 'g', 'Fecha de reclasificación a menor nivel (NR)', 'Fecha de reclasificación a menor nivel (NR)', '', 0, 0, NULL),
(0, 0, '355', 'h', 'Fecha de desclasificación (NR)', 'Fecha de desclasificación (NR)', '', 0, 0, NULL),
(0, 0, '355', 'j', 'Autorización (R)', 'Autorización (R)', '', 1, 0, NULL),
(0, 0, '357', '6', 'Linkage See', 'Linkage See', '', 0, 0, NULL),
(0, 0, '357', '8', 'Field link and sequence number See', 'Field link and sequence number See', '', 1, 0, NULL),
(0, 0, '357', 'a', 'Rental price (NR)', 'Rental price (NR)', '', 0, 0, NULL),
(0, 0, '810', 'w', 'Bibliographic Número de control de registro (R)', 'Bibliographic Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '357', 'b', 'Originating agency (R)', 'Originating agency (R)', '', 1, 0, NULL),
(0, 0, '357', 'c', 'Authorized recipients of material (R)', 'Authorized recipients of material (R)', '', 1, 0, NULL),
(0, 0, '357', 'g', 'Other restrictions (R)', 'Other restrictions (R)', '', 1, 0, NULL),
(0, 0, '357', 'z', 'Source of information', 'Source of information', '', 0, 0, NULL),
(0, 0, '359', 'a', 'Rental price (NR)', 'Rental price (NR)', '', 0, 0, NULL),
(0, 0, '362', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '362', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '362', 'a', 'Fecha de publicación y/o designación secuencial (NR)', 'Fecha de publicación y/o designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '362', 'z', 'Fuente de la información (NR)', 'Fuente de la información (NR)', '', 0, 0, NULL),
(0, 0, '400', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '400', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '400', '8', 'Vínculo de campo y número de secuencia  (R)', 'Vínculo de campo y número de secuencia  (R)', '', 1, 0, NULL),
(0, 0, '400', 'a', 'Nombre personal (NR)', 'Nombre personal (NR)', '', 0, 0, NULL),
(0, 0, '400', 'b', 'Numeración (NR)', 'Numeración (NR)', '', 0, 0, NULL),
(0, 0, '400', 'c', 'Títulos y otras palabras asociadas con el nombre (R)', 'Títulos y otras palabras asociadas con el nombre (R)', '', 1, 0, NULL),
(0, 0, '400', 'd', 'Fechas asociadas con el nombre (NR)', 'Fechas asociadas con el nombre (NR)', '', 0, 0, NULL),
(0, 0, '400', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '400', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '400', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '400', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '400', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '400', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '400', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '400', 'q', 'Forma completa del nombre (NR) [OBSOLETE]', 'Forma completa del nombre (NR) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '400', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '400', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '400', 'v', 'Número de volumen/designación secuencial (NR)', 'Número de volumen/designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '400', 'x', 'ISSN  (NR)', 'ISSN  (NR)', '', 0, 0, NULL),
(0, 0, '410', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '410', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '410', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '410', 'a', 'Nombre corporativo o de jurisdicción como asiento (NR)', 'Nombre corporativo o de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '410', 'b', 'Unidad subordinada(R)', 'Unidad subordinada(R)', '', 1, 0, NULL),
(0, 0, '410', 'c', 'Ubicación de la reunión (NR)', 'Ubicación de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '410', 'd', 'Fecha de la reunión o firma de tratado (R)', 'Fecha de la reunión o firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '410', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '410', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '410', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '410', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '410', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '410', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '410', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '410', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '410', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '410', 'v', 'Número de volumen/designación secuencial (NR)', 'Número de volumen/designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '410', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '411', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '411', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '411', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '411', 'a', 'Nombre de reunión o nombre de jurisdicción como elemento de asiento (NR)', 'Nombre de reunión o nombre de jurisdicción como elemento de asiento (NR)', '', 0, 0, NULL),
(0, 0, '411', 'b', 'Number  [OBSOLETE]', 'Number  [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '411', 'c', 'Ubicación de la reunión (NR)', 'Ubicación de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '411', 'd', 'Fecha de reunión (NR)', 'Fecha de reunión (NR)', '', 0, 0, NULL),
(0, 0, '411', 'e', 'Unidad subordinada(R)', 'Unidad subordinada(R)', '', 1, 0, NULL),
(0, 0, '411', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '411', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '411', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '411', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '411', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '411', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '411', 'q', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '411', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '411', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '411', 'v', 'Número de volumen/designación secuencial (NR)', 'Número de volumen/designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '411', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '440', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '440', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '440', 'a', 'Título (NR)', 'Título (NR)', '', 0, 0, 'biblioitems.seriestitle'),
(0, 0, '440', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '440', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '440', 'v', 'Número del volumen/designación secuencial (NR)', 'Número del volumen/designación secuencial (NR)', '', 0, 0, NULL),
(0, 0, '440', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '490', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '490', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '490', 'a', 'Mención de serie (R)', 'Mención de serie (R)', '', 1, 0, NULL),
(0, 0, '490', 'l', 'Número de ubicación en la Biblioteca del Congreso (NR)', 'Número de ubicación en la Biblioteca del Congreso (NR)', '', 0, 0, NULL),
(0, 0, '490', 'v', 'Número de volumen/designación secuencial (R)', 'Número de volumen/designación secuencial (R)', '', 1, 0, NULL),
(0, 0, '490', 'x', 'ISSN (R)', 'ISSN (R)', '', 1, 0, NULL),
(0, 0, '500', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '500', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '500', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '500', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '500', 'a', 'Nota general (NR)', 'Nota general (NR)', '', 0, 0, 'biblioitems.notes'),
(0, 0, '500', 'l', 'Library of Congress call number (SE) [OBSOLETE]', 'Library of Congress call number (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '500', 'x', 'ISSN (SE) [OBSOLETE]', 'ISSN (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '500', 'z', 'Source of note information (AM SE) [OBSOLETE]', 'Source of note information (AM SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '501', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '501', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '501', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '501', 'a', 'Nota de con (NR)', 'Nota de con (NR)', '', 0, 0, NULL),
(0, 0, '502', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '502', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '502', 'a', 'Nota de tesis (NR)', 'Nota de tesis (NR)', '', 0, 0, NULL),
(0, 0, '503', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '503', 'a', 'Bibliographic Historia Nota (NR)', 'Bibliographic Historia Nota (NR)', '', 0, 0, NULL),
(0, 0, '504', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '504', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '504', 'a', 'Nota de bibliografía, etc. (NR)', 'Nota de bibliografía, etc. (NR)', '', 0, 0, NULL),
(0, 0, '504', 'b', 'Número de referencias (NR)', 'Número de referencias (NR)', '', 0, 0, NULL),
(0, 0, '505', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '505', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '505', 'a', 'Nota de contenido formateada (NR)', 'Nota de contenido formateada (NR)', '', 0, 0, NULL),
(0, 0, '505', 'g', 'Información miscelánea (R)', 'Información miscelánea (R)', '', 1, 0, NULL),
(0, 0, '505', 'r', 'Declaración de responsabilidad (R)', 'Declaración de responsabilidad (R)', '', 1, 0, NULL),
(0, 0, '505', 't', 'Título (R)', 'Título (R)', '', 1, 0, NULL),
(0, 0, '505', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '506', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '506', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '506', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '506', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '506', 'a', 'Términos que gobiernan el acceso (NR)', 'Términos que gobiernan el acceso (NR)', '', 0, 0, NULL),
(0, 0, '506', 'b', 'Jurisdicción (R)', 'Jurisdicción (R)', '', 1, 0, NULL),
(0, 0, '506', 'c', 'Provisiones de acceso físico (R)', 'Provisiones de acceso físico (R)', '', 1, 0, NULL),
(0, 0, '506', 'd', 'Usuarios autorizados (R)', 'Usuarios autorizados (R)', '', 1, 0, NULL),
(0, 0, '506', 'e', 'Autorización (R)', 'Autorización (R)', '', 1, 0, NULL),
(0, 0, '507', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '507', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '507', 'a', 'Nota de fracción representativa de escala (NR)', 'Nota de fracción representativa de escala (NR)', '', 0, 0, NULL),
(0, 0, '507', 'b', 'Nota del resto de la escala (NR)', 'Nota del resto de la escala (NR)', '', 0, 0, NULL),
(0, 0, '508', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '508', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '508', 'a', 'Nota de créditos de creación/producción (NR)', 'Nota de créditos de creación/producción (NR)', '', 0, 0, NULL),
(0, 0, '510', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '510', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '510', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '510', 'a', 'Nombre de la fuente (NR)', 'Nombre de la fuente (NR)', '', 0, 0, NULL),
(0, 0, '510', 'b', 'Cobertura de la fuente (NR)', 'Cobertura de la fuente (NR)', '', 0, 0, NULL),
(0, 0, '510', 'c', 'Ubicación dentro de la fuente (NR)', 'Ubicación dentro de la fuente (NR)', '', 0, 0, NULL),
(0, 0, '510', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '511', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '511', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '511', 'a', 'Nota de participante o intérprete (NR)', 'Nota de participante o intérprete (NR)', '', 0, 0, NULL),
(0, 0, '512', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '512', 'a', 'Earlier or later volumes separately cataloged Nota (NR)', 'Earlier or later volumes separately cataloged Nota (NR)', '', 0, 0, NULL),
(0, 0, '513', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '513', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '513', 'a', 'Tipo de reporte (NR)', 'Tipo de reporte (NR)', '', 0, 0, NULL),
(0, 0, '513', 'b', 'Período cubierto (NR)', 'Período cubierto (NR)', '', 0, 0, NULL),
(0, 0, '514', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '514', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '514', 'a', 'Informe de exactitud del atributo (NR)', 'Informe de exactitud del atributo (NR)', '', 0, 0, NULL),
(0, 0, '514', 'b', 'Valor de exactitud del atributo (R)', 'Valor de exactitud del atributo (R)', '', 1, 0, NULL),
(0, 0, '514', 'c', 'Explicación de exactitud del atributo (R)', 'Explicación de exactitud del atributo (R)', '', 1, 0, NULL),
(0, 0, '514', 'd', 'Informe de consistencia lógica (NR)', 'Informe de consistencia lógica (NR)', '', 0, 0, NULL),
(0, 0, '514', 'e', 'Informe de exhaustividad (NR)', 'Informe de exhaustividad (NR)', '', 0, 0, NULL),
(0, 0, '514', 'f', 'Informe de exactitud de la posición horizontal (NR)', 'Informe de exactitud de la posición horizontal (NR)', '', 0, 0, NULL),
(0, 0, '514', 'g', 'Valor de exactitud de la posición horizontal (R)', 'Valor de exactitud de la posición horizontal (R)', '', 1, 0, NULL),
(0, 0, '514', 'h', 'Explicación de exactitud de la posición horizontal (R)', 'Explicación de exactitud de la posición horizontal (R)', '', 1, 0, NULL),
(0, 0, '514', 'i', 'Informe de exactitud de la posición vertical (NR)', 'Informe de exactitud de la posición vertical (NR)', '', 0, 0, NULL),
(0, 0, '514', 'j', 'Valor de exactitud de la posición vertical (R)', 'Valor de exactitud de la posición vertical (R)', '', 1, 0, NULL),
(0, 0, '514', 'k', 'Explicación de exactitud de la posición vertical (R)', 'Explicación de exactitud de la posición vertical (R)', '', 1, 0, NULL),
(0, 0, '514', 'm', 'Cobertura nubosa (NR)', 'Cobertura nubosa (NR)', '', 0, 0, NULL),
(0, 0, '514', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '514', 'z', 'Mostrar nota (R)', 'Mostrar nota (R)', '', 1, 0, NULL),
(0, 0, '515', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '515', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '515', 'a', 'Nota sobre las peculiaridades en la numeración (NR)', 'Nota sobre las peculiaridades en la numeración (NR)', '', 0, 0, NULL),
(0, 0, '515', 'z', 'Source of note information (NR) (SE) [OBSOLETE]', 'Source of note information (NR) (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '516', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '516', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '516', 'a', 'Nota de tipo de archivo o datos de computadora (NR)', 'Nota de tipo de archivo o datos de computadora (NR)', '', 0, 0, NULL),
(0, 0, '517', 'a', 'Different formats (NR)', 'Different formats (NR)', '', 0, 0, NULL),
(0, 0, '517', 'b', 'Content descriptors (R)', 'Content descriptors (R)', '', 1, 0, NULL),
(0, 0, '517', 'c', 'Additional animation techniques (R)', 'Additional animation techniques (R)', '', 1, 0, NULL),
(0, 0, '518', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '518', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '518', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '518', 'a', 'Nota de fecha/hora y lugar de un acontecimiento (NR)', 'Nota de fecha/hora y lugar de un acontecimiento (NR)', '', 0, 0, NULL),
(0, 0, '520', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '520', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '520', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '520', 'a', 'Nota de resumen, etc. (NR)', 'Nota de resumen, etc. (NR)', '', 0, 0, 'biblio.abstract'),
(0, 0, '520', 'b', 'Expansión de la nota de resumen (NR)', 'Expansión de la nota de resumen (NR)', '', 0, 0, NULL),
(0, 0, '520', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '520', 'z', 'Source of note information (NR) [OBSOLETE]', 'Source of note information (NR) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '521', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '521', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '521', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '521', 'a', 'Nota de audiencia (R)', 'Nota de audiencia (R)', '', 1, 0, NULL),
(0, 0, '521', 'b', 'Fuente (NR)', 'Fuente (NR)', '', 0, 0, NULL),
(0, 0, '522', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '522', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '522', 'a', 'Nota de cobertura geográfica (NR)', 'Nota de cobertura geográfica (NR)', '', 0, 0, NULL),
(0, 0, '523', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '523', 'a', 'Time period of content Nota (NR)', 'Time period of content Nota (NR)', '', 0, 0, NULL),
(0, 0, '523', 'b', 'Dates of data collection Nota (NR)', 'Dates of data collection Nota (NR)', '', 0, 0, NULL),
(0, 0, '524', '2', 'Fuente del esquema usado (NR)', 'Fuente del esquema usado (NR)', '', 0, 0, NULL),
(0, 0, '524', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '524', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '524', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '524', 'a', 'Nota de forma preferida de citación de los materiales descritos (NR)', 'Nota de forma preferida de citación de los materiales descritos (NR)', '', 0, 0, NULL),
(0, 0, '525', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '525', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '525', 'a', 'Nota del suplemento (NR)', 'Nota del suplemento (NR)', '', 0, 0, NULL),
(0, 0, '525', 'z', 'Source of note information (NR) (SE) [OBSOLETE]', 'Source of note information (NR) (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '526', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '526', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '526', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '526', 'a', 'Nombre del programa (NR)', 'Nombre del programa (NR)', '', 0, 0, NULL),
(0, 0, '526', 'b', 'Nivel de interés (NR)', 'Nivel de interés (NR)', '', 0, 0, NULL),
(0, 0, '526', 'c', 'Nivel de lectura (NR)', 'Nivel de lectura (NR)', '', 0, 0, NULL),
(0, 0, '526', 'd', 'Puntuación del título (NR)', 'Puntuación del título (NR)', '', 0, 0, NULL),
(0, 0, '526', 'i', 'Texto a desplegar (NR)', 'Texto a desplegar (NR)', '', 0, 0, NULL),
(0, 0, '526', 'x', 'Nota sin despliegue público (R)', 'Nota sin despliegue público (R)', '', 1, 0, NULL),
(0, 0, '526', 'z', 'Nota con despliegue público (R)', 'Nota con despliegue público (R)', '', 1, 0, NULL),
(0, 0, '527', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '527', 'a', 'Censorship Nota (NR)', 'Censorship Nota (NR)', '', 0, 0, NULL),
(0, 0, '530', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '530', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '530', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '530', 'a', 'Nota de formato físico adicional disponible (NR)', 'Nota de formato físico adicional disponible (NR)', '', 0, 0, NULL),
(0, 0, '530', 'b', 'Fuente de disponibilidad (NR)', 'Fuente de disponibilidad (NR)', '', 0, 0, NULL),
(0, 0, '530', 'c', 'Condiciones de disponibilidad (NR)', 'Condiciones de disponibilidad (NR)', '', 0, 0, NULL),
(0, 0, '530', 'd', 'Número de pedido (NR)', 'Número de pedido (NR)', '', 0, 0, NULL),
(0, 0, '530', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '530', 'z', 'Source of note information (NR) (AM CF VM SE) [OBSOLETE]', 'Source of note information (NR) (AM CF VM SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '533', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '533', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '533', '7', 'Elementos de la reproducción de longitud fija (NR)', 'Elementos de la reproducción de longitud fija (NR)', '', 0, 0, NULL),
(0, 0, '533', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '533', 'a', 'Tipo de reproducción (NR)', 'Tipo de reproducción (NR)', '', 0, 0, NULL),
(0, 0, '533', 'b', 'Lugar de reproducción (R)', 'Lugar de reproducción (R)', '', 1, 0, NULL),
(0, 0, '533', 'c', 'Agencia responsable de la reproducción (R)', 'Agencia responsable de la reproducción (R)', '', 1, 0, NULL),
(0, 0, '533', 'd', 'Fecha de la reproducción (NR)', 'Fecha de la reproducción (NR)', '', 0, 0, NULL),
(0, 0, '533', 'e', 'Descripción física de la reproducción (NR)', 'Descripción física de la reproducción (NR)', '', 0, 0, NULL),
(0, 0, '533', 'f', 'Mención de serie de la reproducción (R)', 'Mención de serie de la reproducción (R)', '', 1, 0, NULL),
(0, 0, '533', 'm', 'Fechas de publicación y/o designación secuencial de los números reproducidos (R)', 'Fechas de publicación y/o designación secuencial de los números reproducidos (R)', '', 1, 0, NULL),
(0, 0, '533', 'n', 'Nota sobre reproducción (R)', 'Nota sobre reproducción (R)', '', 1, 0, NULL),
(0, 0, '534', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '534', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '534', 'a', 'Asiento principal del original (NR)', 'Asiento principal del original (NR)', '', 0, 0, 'biblio.notes'),
(0, 0, '534', 'b', 'Mención de edición del original (NR)', 'Mención de edición del original (NR)', '', 0, 0, NULL),
(0, 0, '534', 'c', 'Publicación, distribución, etc. del original (NR)', 'Publicación, distribución, etc. del original (NR)', '', 0, 0, NULL),
(0, 0, '534', 'e', 'Descripción física, etc. del original (NR)', 'Descripción física, etc. del original (NR)', '', 0, 0, NULL),
(0, 0, '534', 'f', 'Mención de serie del original (R)', 'Mención de serie del original (R)', '', 1, 0, NULL),
(0, 0, '534', 'k', 'Título clave del original (R)', 'Título clave del original (R)', '', 1, 0, NULL),
(0, 0, '534', 'l', 'Ubicación del original (NR)', 'Ubicación del original (NR)', '', 0, 0, NULL),
(0, 0, '534', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '534', 'n', 'Nota sobre el original (R)', 'Nota sobre el original (R)', '', 1, 0, NULL),
(0, 0, '534', 'p', 'Frase introductoria (NR)', 'Frase introductoria (NR)', '', 0, 0, NULL),
(0, 0, '534', 't', 'Mención de título del original (NR)', 'Mención de título del original (NR)', '', 0, 0, NULL),
(0, 0, '534', 'x', 'ISSN (R)', 'ISSN (R)', '', 1, 0, NULL),
(0, 0, '534', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '535', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '535', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '535', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '535', 'a', 'Custodio (NR)', 'Custodio (NR)', '', 0, 0, NULL),
(0, 0, '535', 'b', 'Dirección postal (R)', 'Dirección postal (R)', '', 1, 0, NULL),
(0, 0, '535', 'c', 'País (R)', 'País (R)', '', 1, 0, NULL),
(0, 0, '535', 'd', 'Dirección de telecomunicación (R)', 'Dirección de telecomunicación (R)', '', 1, 0, NULL),
(0, 0, '535', 'g', 'Código de localización del repositorio (NR)', 'Código de localización del repositorio (NR)', '', 0, 0, NULL),
(0, 0, '536', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '536', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '536', 'a', 'Texto de la nota (NR)', 'Texto de la nota (NR)', '', 0, 0, NULL),
(0, 0, '536', 'b', 'Número de contrato (R)', 'Número de contrato (R)', '', 1, 0, NULL),
(0, 0, '536', 'c', 'Número de subvención (R)', 'Número de subvención (R)', '', 1, 0, NULL),
(0, 0, '536', 'd', 'Número no diferenciado (R)', 'Número no diferenciado (R)', '', 1, 0, NULL),
(0, 0, '536', 'e', 'Número de elemento de programa (R)', 'Número de elemento de programa (R)', '', 1, 0, NULL),
(0, 0, '536', 'f', 'Número de proyecto (R)', 'Número de proyecto (R)', '', 1, 0, NULL),
(0, 0, '536', 'g', 'Número de tarea (R)', 'Número de tarea (R)', '', 1, 0, NULL),
(0, 0, '536', 'h', 'Número de unidad de trabajo (R)', 'Número de unidad de trabajo (R)', '', 1, 0, NULL),
(0, 0, '537', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '537', 'a', 'Source of data Nota (NR)', 'Source of data Nota (NR)', '', 0, 0, NULL),
(0, 0, '538', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '538', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '538', 'a', 'Nota sobre detalles del sistema (NR)', 'Nota sobre detalles del sistema (NR)', '', 0, 0, NULL),
(0, 0, '540', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '540', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '540', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '540', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '540', 'a', 'Términos que regulan el uso y reproducción (NR)', 'Términos que regulan el uso y reproducción (NR)', '', 0, 0, NULL),
(0, 0, '540', 'b', 'Jurisdicción (NR)', 'Jurisdicción (NR)', '', 0, 0, NULL),
(0, 0, '540', 'c', 'Autorización (NR)', 'Autorización (NR)', '', 0, 0, NULL),
(0, 0, '540', 'd', 'Usuarios autorizados (NR)', 'Usuarios autorizados (NR)', '', 0, 0, NULL),
(0, 0, '541', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '541', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '541', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '541', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '541', 'a', 'Fuente de adquisición (NR)', 'Fuente de adquisición (NR)', '', 0, 0, NULL),
(0, 0, '541', 'b', 'Dirección (NR)', 'Dirección (NR)', '', 0, 0, NULL),
(0, 0, '541', 'c', 'Método de adquisición (NR)', 'Método de adquisición (NR)', '', 0, 0, NULL),
(0, 0, '541', 'd', 'Fecha de adquisición (NR)', 'Fecha de adquisición (NR)', '', 0, 0, NULL),
(0, 0, '541', 'e', 'Número de acceso (NR)', 'Número de acceso (NR)', '', 0, 0, NULL),
(0, 0, '541', 'f', 'Propietario (NR)', 'Propietario (NR)', '', 0, 0, NULL),
(0, 0, '541', 'h', 'Precio de compra (NR)', 'Precio de compra (NR)', '', 0, 0, NULL),
(0, 0, '541', 'n', 'Extensión (R)', 'Extensión (R)', '', 1, 0, NULL),
(0, 0, '541', 'o', 'Tipo de unidad (R)', 'Tipo de unidad (R)', '', 1, 0, NULL),
(0, 0, '543', '6', 'Linkage (NR)', 'Linkage (NR)', '', 0, 0, NULL),
(0, 0, '543', 'a', 'Solicitation information note (NR)', 'Solicitation information note (NR)', '', 0, 0, NULL),
(0, 0, '544', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '544', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '544', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '544', 'a', 'Custodio (R)', 'Custodio (R)', '', 1, 0, NULL),
(0, 0, '544', 'b', 'Dirección (R)', 'Dirección (R)', '', 1, 0, NULL),
(0, 0, '544', 'c', 'País (R)', 'País (R)', '', 1, 0, NULL),
(0, 0, '544', 'd', 'Título (R)', 'Título (R)', '', 1, 0, NULL),
(0, 0, '544', 'e', 'Provenance (R)', 'Provenance (R)', '', 1, 0, NULL),
(0, 0, '544', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '545', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '545', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '545', 'a', 'Nota biográfica o histórica (NR)', 'Nota biográfica o histórica (NR)', '', 0, 0, NULL),
(0, 0, '545', 'b', 'Expansión (NR)', 'Expansión (NR)', '', 0, 0, NULL),
(0, 0, '545', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '546', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '546', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '546', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '546', 'a', 'Nota de idioma (NR)', 'Nota de idioma (NR)', '', 0, 0, NULL),
(0, 0, '546', 'b', 'Información sobre códigos o alfabetos (R)', 'Información sobre códigos o alfabetos (R)', '', 1, 0, NULL),
(0, 0, '546', 'z', 'Source of note information (NR) (SE) [OBSOLETE]', 'Source of note information (NR) (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '547', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '547', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '547', 'a', 'Nota compleja sobre título anterior (NR)', 'Nota compleja sobre título anterior (NR)', '', 0, 0, NULL),
(0, 0, '547', 'z', 'Source of note information (NR) (SE) [OBSOLETE]', 'Source of note information (NR) (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '550', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '550', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '550', 'a', 'Nota sobre entidad emisora (NR)', 'Nota sobre entidad emisora (NR)', '', 0, 0, NULL),
(0, 0, '550', 'z', 'Source of note information (NR) (SE) [OBSOLETE]', 'Source of note information (NR) (SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '552', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '552', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '552', 'a', 'Etiqueta de tipo de entidad (NR)', 'Etiqueta de tipo de entidad (NR)', '', 0, 0, NULL),
(0, 0, '552', 'b', 'Definición y fuente de tipo de entidad (NR)', 'Definición y fuente de tipo de entidad (NR)', '', 0, 0, NULL),
(0, 0, '552', 'c', 'Etiqueta de atributo (NR)', 'Etiqueta de atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'd', 'Definición y fuente de atributo (NR)', 'Definición y fuente de atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'e', 'Valor de dominio enumerado (R)', 'Valor de dominio enumerado (R)', '', 1, 0, NULL),
(0, 0, '552', 'f', 'Definición y fuente de valor de dominio enumerado (R)', 'Definición y fuente de valor de dominio enumerado (R)', '', 1, 0, NULL),
(0, 0, '552', 'g', 'Mínimo y máximo de dominio de rango (NR)', 'Mínimo y máximo de dominio de rango (NR)', '', 0, 0, NULL),
(0, 0, '552', 'h', 'Nombre y fuente del grupo de caracteres (NR)', 'Nombre y fuente del grupo de caracteres (NR)', '', 0, 0, NULL),
(0, 0, '552', 'i', 'Dominio no representable (NR)', 'Dominio no representable (NR)', '', 0, 0, NULL),
(0, 0, '552', 'j', 'Unidades de medida y resolución del atributo (NR)', 'Unidades de medida y resolución del atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'k', 'Fecha de inicio y de fin de los valores de atributo (NR)', 'Fecha de inicio y de fin de los valores de atributo (NR)', '', 0, 0, NULL);
INSERT INTO `pref_estructura_subcampo_marc` (`nivel`, `obligatorio`, `campo`, `subcampo`, `liblibrarian`, `libopac`, `descripcion`, `repetible`, `mandatory`, `kohafield`) VALUES
(0, 0, '552', 'l', 'Precisión del valor del atributo (NR)', 'Precisión del valor del atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'm', 'Explicación de la precisión del valor del atributo (NR)', 'Explicación de la precisión del valor del atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'n', 'Frecuencia de la medición del atributo (NR)', 'Frecuencia de la medición del atributo (NR)', '', 0, 0, NULL),
(0, 0, '552', 'o', 'Visión general de entidad y atributo (R)', 'Visión general de entidad y atributo (R)', '', 1, 0, NULL),
(0, 0, '552', 'p', 'Cita detallada de entidad y atributo (R)', 'Cita detallada de entidad y atributo (R)', '', 1, 0, NULL),
(0, 0, '552', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '552', 'z', 'Mostrar nota (R)', 'Mostrar nota (R)', '', 1, 0, NULL),
(0, 0, '555', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '555', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '555', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '555', 'a', 'Nota de ayuda acumulativa de índice/búsqueda (NR)', 'Nota de ayuda acumulativa de índice/búsqueda (NR)', '', 0, 0, NULL),
(0, 0, '555', 'b', 'Fuente de disponibilidad (R)', 'Fuente de disponibilidad (R)', '', 1, 0, NULL),
(0, 0, '555', 'c', 'Grado de control (NR)', 'Grado de control (NR)', '', 0, 0, NULL),
(0, 0, '555', 'd', 'Referencia bibliográfica (NR)', 'Referencia bibliográfica (NR)', '', 0, 0, NULL),
(0, 0, '555', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '556', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '556', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '556', 'a', 'Nota informativa sobre documentación (NR)', 'Nota informativa sobre documentación (NR)', '', 0, 0, NULL),
(0, 0, '556', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '561', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '561', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '561', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '561', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '561', 'a', 'Historia (NR)', 'Historia (NR)', '', 0, 0, NULL),
(0, 0, '561', 'b', 'Time of collation (NR) [OBSOLETE]', 'Time of collation (NR) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '562', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '562', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '562', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '562', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '562', 'a', 'Marcas identificativas (R)', 'Marcas identificativas (R)', '', 1, 0, NULL),
(0, 0, '562', 'b', 'Identificación de copia (R)', 'Identificación de copia (R)', '', 1, 0, NULL),
(0, 0, '562', 'c', 'Identificación de versión (R)', 'Identificación de versión (R)', '', 1, 0, NULL),
(0, 0, '562', 'd', 'Formato de presentación (R)', 'Formato de presentación (R)', '', 1, 0, NULL),
(0, 0, '562', 'e', 'Número de copias (R)', 'Número de copias (R)', '', 1, 0, NULL),
(0, 0, '565', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '565', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '565', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '565', 'a', 'Número de casos/variables (NR)', 'Número de casos/variables (NR)', '', 0, 0, NULL),
(0, 0, '565', 'b', 'Nombre de la variable (R)', 'Nombre de la variable (R)', '', 1, 0, NULL),
(0, 0, '565', 'c', 'Unidad de análisis (R)', 'Unidad de análisis (R)', '', 1, 0, NULL),
(0, 0, '565', 'd', 'Universo de los datos (R)', 'Universo de los datos (R)', '', 1, 0, NULL),
(0, 0, '565', 'e', 'Esquema o código con que se archiva (R)', 'Esquema o código con que se archiva (R)', '', 1, 0, NULL),
(0, 0, '567', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '567', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '567', 'a', 'Nota sobre metodología (NR)', 'Nota sobre metodología (NR)', '', 0, 0, NULL),
(0, 0, '570', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '570', 'a', 'Editor Nota (NR)', 'Editor Nota (NR)', '', 0, 0, NULL),
(0, 0, '570', 'z', 'Source of note information (NR)', 'Source of note information (NR)', '', 0, 0, NULL),
(0, 0, '580', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '580', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '580', 'a', 'Nota compleja de enlaces de asientos (NR)', 'Nota compleja de enlaces de asientos (NR)', '', 0, 0, NULL),
(0, 0, '580', 'z', 'Source of note information (NR) [OBSOLETE]', 'Source of note information (NR) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '581', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '581', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '581', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '581', 'a', 'Nota sobre publicaciones sobre el material descrito (NR)', 'Nota sobre publicaciones sobre el material descrito (NR)', '', 0, 0, NULL),
(0, 0, '581', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '582', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '582', 'a', 'Related computer files Nota (NR)', 'Related computer files Nota (NR)', '', 0, 0, NULL),
(0, 0, '583', '2', 'Fuente del término (NR)', 'Fuente del término (NR)', '', 0, 0, NULL),
(0, 0, '583', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '583', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '583', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '583', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '583', 'a', 'Acción (NR)', 'Acción (NR)', '', 0, 0, NULL),
(0, 0, '583', 'b', 'Identificación de acción (R)', 'Identificación de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'c', 'Fecha/hora de acción (R)', 'Fecha/hora de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'd', 'Intervalo de acción (R)', 'Intervalo de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'e', 'Contingencia de acción (R)', 'Contingencia de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'f', 'Autorización (R)', 'Autorización (R)', '', 1, 0, NULL),
(0, 0, '583', 'h', 'Jurisdicción (R)', 'Jurisdicción (R)', '', 1, 0, NULL),
(0, 0, '583', 'i', 'Método de acción (R)', 'Método de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'j', 'Sitio de acción (R)', 'Sitio de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'k', 'Agente de acción (R)', 'Agente de acción (R)', '', 1, 0, NULL),
(0, 0, '583', 'l', 'Estado (R)', 'Estado (R)', '', 1, 0, NULL),
(0, 0, '583', 'n', 'Extensión (R)', 'Extensión (R)', '', 1, 0, NULL),
(0, 0, '583', 'o', 'Tipo de unidad (R)', 'Tipo de unidad (R)', '', 1, 0, NULL),
(0, 0, '583', 'u', 'Identificador Uniforme de Recursos (R)', 'Identificador Uniforme de Recursos (R)', '', 1, 0, NULL),
(0, 0, '583', 'x', 'Nota no pública (R)', 'Nota no pública (R)', '', 1, 0, NULL),
(0, 0, '583', 'z', 'Nota pública (R)', 'Nota pública (R)', '', 1, 0, NULL),
(0, 0, '584', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '584', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '584', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '584', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '584', 'a', 'Acumulación (R)', 'Acumulación (R)', '', 1, 0, NULL),
(0, 0, '584', 'b', 'Frecuencia de uso (R)', 'Frecuencia de uso (R)', '', 1, 0, NULL),
(0, 0, '585', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '585', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '585', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '585', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '585', 'a', 'Nota sobre exposiciones (NR)', 'Nota sobre exposiciones (NR)', '', 0, 0, NULL),
(0, 0, '586', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '586', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '586', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '586', 'a', 'Nota de premios (NR)', 'Nota de premios (NR)', '', 0, 0, NULL),
(0, 0, '590', 'a', 'Receipt Fecha (NR)', 'Receipt Fecha (NR)', '', 0, 0, NULL),
(0, 0, '590', 'b', 'Provenance (NR)', 'Provenance (NR)', '', 0, 0, NULL),
(0, 0, '590', 'd', 'Origin of safety copy (NR)', 'Origin of safety copy (NR)', '', 0, 0, NULL),
(0, 0, '600', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '600', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '600', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '600', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '600', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '600', 'a', 'Nombre personal (NR)', 'Nombre personal (NR)', '', 0, 0, NULL),
(0, 0, '600', 'b', 'Numeración (NR)', 'Numeración (NR)', '', 0, 0, NULL),
(0, 0, '600', 'c', 'Títulos y otras palabras asociadas con el nombre (R)', 'Títulos y otras palabras asociadas con el nombre (R)', '', 1, 0, NULL),
(0, 0, '600', 'd', 'Fechas asociadas con el nombre (NR)', 'Fechas asociadas con el nombre (NR)', '', 0, 0, NULL),
(0, 0, '600', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '600', 'f', 'Fecha de una obra (NR)', 'Fecha de una obra (NR)', '', 0, 0, NULL),
(0, 0, '600', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '600', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '600', 'j', 'Calificador de atribución (R)', 'Calificador de atribución (R)', '', 1, 0, NULL),
(0, 0, '600', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '600', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '600', 'm', 'Medio de interpretación para música (R)', 'Medio de interpretación para música (R)', '', 1, 0, NULL),
(0, 0, '600', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '600', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '600', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '600', 'q', 'Forma completa del nombre (NR)', 'Forma completa del nombre (NR)', '', 0, 0, NULL),
(0, 0, '600', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '600', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '600', 't', 'Título del trabajo (NR)', 'Título del trabajo (NR)', '', 0, 0, NULL),
(0, 0, '600', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '600', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '600', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '600', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '600', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '610', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '610', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '610', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '610', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '610', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '610', 'a', 'Nombre corporativo o de jurisdicción como asiento (NR)', 'Nombre corporativo o de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '610', 'b', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '610', 'c', 'Ubicación de reunión (NR)', 'Ubicación de reunión (NR)', '', 0, 0, NULL),
(0, 0, '610', 'd', 'Fecha de reunión o firma de tratado (R)', 'Fecha de reunión o firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '610', 'e', 'Relación (R)', 'Relación (R)', '', 1, 0, NULL),
(0, 0, '610', 'f', 'Fecha de una obra (NR)', 'Fecha de una obra (NR)', '', 0, 0, NULL),
(0, 0, '610', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '610', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '610', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '610', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '610', 'm', 'Medio de interpretación de música (R)', 'Medio de interpretación de música (R)', '', 1, 0, NULL),
(0, 0, '610', 'n', 'Número de parte/sección/reunión (R)', 'Número de parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '610', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '610', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '610', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '610', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '610', 't', 'Título del trabajo (NR)', 'Título del trabajo (NR)', '', 0, 0, NULL),
(0, 0, '610', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '610', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '610', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '610', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '610', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '611', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '611', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '611', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '611', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '611', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '611', 'a', 'Nombre de la reunión o jurisdicción como elemento ingresado (NR)', 'Nombre de la reunión o jurisdicción como elemento ingresado (NR)', '', 0, 0, NULL),
(0, 0, '611', 'b', 'Número (BK CF MP MU SE VM MX) [OBSOLETE]', 'Número (BK CF MP MU SE VM MX) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '611', 'c', 'Lugar de la reunión (NR)', 'Lugar de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '611', 'd', 'Fecha de la reunión (NR)', 'Fecha de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '611', 'e', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '611', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '611', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '611', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '611', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '611', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '611', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '611', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '611', 'q', 'Nombre de la reunión luego del elemento de asiento del nombre de la jurisdicción (NR)', 'Nombre de la reunión luego del elemento de asiento del nombre de la jurisdicción (NR)', '', 0, 0, NULL),
(0, 0, '611', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '611', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '611', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '611', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '611', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '611', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '611', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '630', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '630', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '630', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '630', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '630', 'a', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '630', 'd', 'Fecha de firma del tratado (R)', 'Fecha de firma del tratado (R)', '', 1, 0, NULL),
(0, 0, '630', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '630', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '630', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '630', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '630', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '630', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '630', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '630', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '630', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '630', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '630', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '630', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '630', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '630', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '630', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '630', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '650', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '650', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '650', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '650', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '650', 'a', 'Término temático o nombre geográfico como elemento ingresado (NR)', 'Término temático o nombre geográfico como elemento ingresado (NR)', '', 0, 0, 'bibliosubject.subject'),
(0, 0, '650', 'b', 'Término temático subsiguiente a nombre geográfico como elemento ingresado (NR)', 'Término temático subsiguiente a nombre geográfico como elemento ingresado (NR)', '', 0, 0, NULL),
(0, 0, '650', 'c', 'Lugar del evento (NR)', 'Lugar del evento (NR)', '', 0, 0, NULL),
(0, 0, '650', 'd', 'Fechas activas (NR)', 'Fechas activas (NR)', '', 0, 0, NULL),
(0, 0, '650', 'e', 'Término de relación (NR)', 'Término de relación (NR)', '', 0, 0, NULL),
(0, 0, '650', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '650', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '650', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '650', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '651', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '651', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '651', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '651', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '651', 'a', 'Nombre geográfico (NR)', 'Nombre geográfico (NR)', '', 0, 0, NULL),
(0, 0, '651', 'b', 'Nombre geográfico siguiente al elemento de asiento de lugar (R) [OBSOLETE]', 'Nombre geográfico siguiente al elemento de asiento de lugar (R) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '651', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '651', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '651', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '651', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '652', 'a', 'Geographic name of place element (NR)', 'Geographic name of place element (NR)', '', 0, 0, NULL),
(0, 0, '652', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '652', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '652', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '653', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '653', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '653', 'a', 'Término no controlado (R)', 'Término no controlado (R)', '', 1, 0, NULL),
(0, 0, '654', '2', 'Fuente del encabezado o término (NR)', 'Fuente del encabezado o término (NR)', '', 0, 0, NULL),
(0, 0, '654', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '654', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '654', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '654', 'a', 'Término temático principal (R)', 'Término temático principal (R)', '', 1, 0, NULL),
(0, 0, '654', 'b', 'Término temático no principal  (R)', 'Término temático no principal  (R)', '', 1, 0, NULL),
(0, 0, '654', 'c', 'Designación de faceta/jerarquía (R)', 'Designación de faceta/jerarquía (R)', '', 1, 0, NULL),
(0, 0, '654', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '654', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '654', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '655', '2', 'Fuente del término (NR)', 'Fuente del término (NR)', '', 0, 0, NULL),
(0, 0, '655', '0', 'Número de control de registro de autoridad (R)', 'Número de control de registro de autoridad (R)', '', 1, 0, NULL),
(0, 0, '655', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '655', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '655', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '655', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '655', 'a', 'Datos de género/forma o término temático principal (NR)', 'Datos de género/forma o término temático principal (NR)', '', 0, 0, NULL),
(0, 0, '655', 'b', 'Término temático no principal (R)', 'Término temático no principal (R)', '', 1, 0, NULL),
(0, 0, '655', 'c', 'Designación de faceta/jerarquía (R)', 'Designación de faceta/jerarquía (R)', '', 1, 0, NULL),
(0, 0, '655', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '655', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '655', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '655', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '656', '2', 'Fuente del término (NR)', 'Fuente del término (NR)', '', 0, 0, NULL),
(0, 0, '656', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '656', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '656', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '656', 'a', 'Ocupación (NR)', 'Ocupación (NR)', '', 0, 0, NULL),
(0, 0, '656', 'k', 'Forma (NR)', 'Forma (NR)', '', 0, 0, NULL),
(0, 0, '656', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '656', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '656', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '656', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '657', '2', 'Fuente del término (NR)', 'Fuente del término (NR)', '', 0, 0, NULL),
(0, 0, '657', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '657', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '657', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '657', 'a', 'Función (NR)', 'Función (NR)', '', 0, 0, NULL),
(0, 0, '657', 'v', 'Subdivisión de forma (R)', 'Subdivisión de forma (R)', '', 1, 0, NULL),
(0, 0, '657', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '657', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '657', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '658', '2', 'Fuente del término o código (NR)', 'Fuente del término o código (NR)', '', 0, 0, NULL),
(0, 0, '658', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '658', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '658', 'a', 'Objetivo principal del currículo (NR)', 'Objetivo principal del currículo (NR)', '', 0, 0, NULL),
(0, 0, '658', 'b', 'Objetivo subordinado del currículo (R)', 'Objetivo subordinado del currículo (R)', '', 1, 0, NULL),
(0, 0, '658', 'c', 'Código del currículo (NR)', 'Código del currículo (NR)', '', 0, 0, NULL),
(0, 0, '658', 'd', 'Factor de correlación (NR)', 'Factor de correlación (NR)', '', 0, 0, NULL),
(0, 0, '700', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '700', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '700', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '700', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '700', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '700', 'a', 'Nombre personal (NR)', 'Nombre personal (NR)', '', 0, 0, 'additionalauthors.author'),
(0, 0, '700', 'b', 'Numeración (NR)', 'Numeración (NR)', '', 0, 0, NULL),
(0, 0, '700', 'c', 'Títulos y otras palabras asociadas con el nombre (R)', 'Títulos y otras palabras asociadas con el nombre (R)', '', 1, 0, NULL),
(0, 0, '700', 'd', 'Fechas asociadas con el nombre (NR)', 'Fechas asociadas con el nombre (NR)', '', 0, 0, NULL),
(0, 0, '700', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '700', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '700', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '700', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '700', 'j', 'Calificador de atributo (R)', 'Calificador de atributo (R)', '', 1, 0, NULL),
(0, 0, '700', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '700', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '700', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '700', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '700', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '700', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '700', 'q', 'Forma completa del nombre (NR)', 'Forma completa del nombre (NR)', '', 0, 0, NULL),
(0, 0, '700', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '700', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '700', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '700', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '700', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '705', 'a', 'Personal name (NR)', 'Personal name (NR)', '', 0, 0, NULL),
(0, 0, '705', 'b', 'Numeración (NR)', 'Numeración (NR)', '', 0, 0, NULL),
(0, 0, '705', 'c', 'Titles and other words associated with a name (R)', 'Titles and other words associated with a name (R)', '', 1, 0, NULL),
(0, 0, '705', 'd', 'Dates associated with a name (NR)', 'Dates associated with a name (NR)', '', 0, 0, NULL),
(0, 0, '705', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '705', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '705', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '705', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '705', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '705', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '705', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '705', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '705', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '705', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '705', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '705', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '705', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '710', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '710', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '710', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '710', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '710', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '710', 'a', 'Nombre corporativo o de jurisdicción como asiento (NR)', 'Nombre corporativo o de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '710', 'b', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '710', 'c', 'Ubicación de la reunión (NR)', 'Ubicación de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '710', 'd', 'Fecha de la reunión o firma de tratado (R)', 'Fecha de la reunión o firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '710', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '710', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '710', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '710', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '710', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '710', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '710', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '710', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '710', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '710', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '710', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '710', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '710', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '710', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '710', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '711', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '711', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '711', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '711', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '711', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '711', 'a', 'Tipo del nombre de la reunión o nombre de jurisdicción como asiento (NR)', 'Tipo del nombre de la reunión o nombre de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '711', 'b', 'Número (BK CF MP MU SE VM MX) [OBSOLETE]', 'Número (BK CF MP MU SE VM MX) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '711', 'c', 'Ubicación de la reunión (NR)', 'Ubicación de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '711', 'd', 'Fecha de la reunión (NR)', 'Fecha de la reunión (NR)', '', 0, 0, NULL),
(0, 0, '711', 'j', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '711', 'e', 'Unidad subordinada (R)', 'Unidad subordinada (R)', '', 1, 0, NULL),
(0, 0, '711', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '711', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '711', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '711', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '711', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '711', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '711', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '711', 'q', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', 'Tipo del nombre de la reunión siguiente al nombre de jurisdicción como asiento (NR)', '', 0, 0, NULL),
(0, 0, '711', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '711', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '711', 'u', 'Afiliación (NR)', 'Afiliación (NR)', '', 0, 0, NULL),
(0, 0, '711', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '715', 'a', 'Corporate name or Nombre de jurisdicción (NR)', 'Corporate name or Nombre de jurisdicción (NR)', '', 0, 0, NULL),
(0, 0, '715', 'b', 'Unidad subordinada(R)', 'Unidad subordinada(R)', '', 1, 0, NULL),
(0, 0, '715', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '715', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '715', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '715', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '715', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '715', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '715', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '715', 'n', 'Número de la parte/sección/reunión (R)', 'Número de la parte/sección/reunión (R)', '', 1, 0, NULL),
(0, 0, '715', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '715', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '715', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '715', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '715', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '715', 'u', 'Nonprinting information (NR)', 'Nonprinting information (NR)', '', 0, 0, NULL),
(0, 0, '720', '4', 'Código relator (R)', 'Código relator (R)', '', 1, 0, NULL),
(0, 0, '720', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '720', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '720', 'a', 'Nombre (NR)', 'Nombre (NR)', '', 0, 0, NULL),
(0, 0, '720', 'e', 'Término de relación (R)', 'Término de relación (R)', '', 1, 0, NULL),
(0, 0, '730', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '730', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '730', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '730', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '730', 'a', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '730', 'd', 'Fecha de firma de tratado (R)', 'Fecha de firma de tratado (R)', '', 1, 0, NULL),
(0, 0, '730', 'f', 'Fecha de la obra (NR)', 'Fecha de la obra (NR)', '', 0, 0, NULL),
(0, 0, '730', 'g', 'Información miscelánea (NR)', 'Información miscelánea (NR)', '', 0, 0, NULL),
(0, 0, '730', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '730', 'k', 'Subtítulo de formulario (R)', 'Subtítulo de formulario (R)', '', 1, 0, NULL),
(0, 0, '730', 'l', 'Idioma de la obra (NR)', 'Idioma de la obra (NR)', '', 0, 0, NULL),
(0, 0, '730', 'm', 'Medio de interpretación de la música (R)', 'Medio de interpretación de la música (R)', '', 1, 0, NULL),
(0, 0, '730', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '730', 'o', 'Mención del arreglo musical (NR)', 'Mención del arreglo musical (NR)', '', 0, 0, NULL),
(0, 0, '730', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '730', 'r', 'Clave para música (NR)', 'Clave para música (NR)', '', 0, 0, NULL),
(0, 0, '730', 's', 'Versión (NR)', 'Versión (NR)', '', 0, 0, NULL),
(0, 0, '730', 't', 'Título de la obra (NR)', 'Título de la obra (NR)', '', 0, 0, NULL),
(0, 0, '730', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '740', '5', 'Institución a la que se aplica el campo (NR)', 'Institución a la que se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '740', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '740', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '740', 'a', 'Título analítico/relacionado no controlado (NR)', 'Título analítico/relacionado no controlado (NR)', '', 0, 0, 'biblioitems.volumeddesc'),
(0, 0, '740', 'h', 'Medio (NR)', 'Medio (NR)', '', 0, 0, NULL),
(0, 0, '740', 'n', 'Número de la parte/sección de la obra (R)', 'Número de la parte/sección de la obra (R)', '', 1, 0, 'biblioitems.volume'),
(0, 0, '740', 'p', 'Nombre de la parte/sección de la obra (R)', 'Nombre de la parte/sección de la obra (R)', '', 1, 0, NULL),
(0, 0, '752', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '752', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '752', 'a', 'País o entidad mayor (R)', 'País o entidad mayor (R)', '', 1, 0, NULL),
(0, 0, '752', 'b', 'Jurisdicción política de primer orden (NR)', 'Jurisdicción política de primer orden (NR)', '', 0, 0, NULL),
(0, 0, '752', 'c', 'Jurisdicción política intermedia (R)', 'Jurisdicción política intermedia (R)', '', 1, 0, NULL),
(0, 0, '752', 'd', 'Ciudad (NR)', 'Ciudad (NR)', '', 0, 0, NULL),
(0, 0, '753', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '753', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '753', 'a', 'Marca y modelo de la máquina (NR)', 'Marca y modelo de la máquina (NR)', '', 0, 0, NULL),
(0, 0, '753', 'b', 'Lenguaje de programación (NR)', 'Lenguaje de programación (NR)', '', 0, 0, NULL),
(0, 0, '753', 'c', 'Sistema operativo (NR)', 'Sistema operativo (NR)', '', 0, 0, NULL),
(0, 0, '754', '2', 'Fuente de identificación taxonómica (NR)', 'Fuente de identificación taxonómica (NR)', '', 0, 0, NULL),
(0, 0, '754', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '754', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '754', 'a', 'Nombre taxonómico (R)', 'Nombre taxonómico (R)', '', 1, 0, NULL),
(0, 0, '754', 'x', 'Nota no pública (R)', 'Nota no pública (R)', '', 1, 0, NULL),
(0, 0, '755', '2', 'Fuente del término (NR)', 'Fuente del término (NR)', '', 0, 0, NULL),
(0, 0, '755', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '755', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '755', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '755', 'a', 'Access term (NR)', 'Access term (NR)', '', 0, 0, NULL),
(0, 0, '755', 'x', 'Subdivisión general (R)', 'Subdivisión general (R)', '', 1, 0, NULL),
(0, 0, '755', 'y', 'Subdivisión cronológica (R)', 'Subdivisión cronológica (R)', '', 1, 0, NULL),
(0, 0, '755', 'z', 'Subdivisión geográfica (R)', 'Subdivisión geográfica (R)', '', 1, 0, NULL),
(0, 0, '760', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '760', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '760', '4', 'Código de relación (R)', 'Código de relación (R)', '', 1, 0, NULL),
(0, 0, '760', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '760', 'a', 'Asiento principal de serie (NR)', 'Asiento principal de serie (NR)', '', 0, 0, NULL),
(0, 0, '760', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '760', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '760', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '760', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '760', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '760', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '760', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '760', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '760', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '760', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '760', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '760', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '760', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '760', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '760', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '762', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '762', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '762', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '762', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '762', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '762', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '762', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '762', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '762', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '762', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '762', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '762', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '762', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '762', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '762', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '762', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '762', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '762', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '762', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '765', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '765', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '765', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '765', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '765', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '765', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '765', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '765', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '765', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL);
INSERT INTO `pref_estructura_subcampo_marc` (`nivel`, `obligatorio`, `campo`, `subcampo`, `liblibrarian`, `libopac`, `descripcion`, `repetible`, `mandatory`, `kohafield`) VALUES
(0, 0, '765', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '765', 'k', 'Datos de serie de ítem relacionado (R)', 'Datos de serie de ítem relacionado (R)', '', 1, 0, NULL),
(0, 0, '765', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '765', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '765', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '765', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '765', 'r', 'Número de reporte (R)', 'Número de reporte (R)', '', 1, 0, NULL),
(0, 0, '765', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '765', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '765', 'u', 'Número de reporte técnico estándar (NR)', 'Número de reporte técnico estándar (NR)', '', 0, 0, NULL),
(0, 0, '765', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '765', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '765', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '765', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '767', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '767', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '767', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '767', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '767', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '767', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '767', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '767', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '767', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '767', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '767', 'k', 'Datos de serie de ítem relacionado (R)', 'Datos de serie de ítem relacionado (R)', '', 1, 0, NULL),
(0, 0, '767', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '767', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '767', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '767', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '767', 'r', 'Número de reporte (R)', 'Número de reporte (R)', '', 1, 0, NULL),
(0, 0, '767', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '767', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '767', 'u', 'Número de reporte técnico estándar (NR)', 'Número de reporte técnico estándar (NR)', '', 0, 0, NULL),
(0, 0, '767', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '767', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '767', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '767', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '770', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '770', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '770', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '770', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '770', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '770', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '770', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '770', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '770', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '770', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '770', 'k', 'Datos de serie de ítem relacionado (R)', 'Datos de serie de ítem relacionado (R)', '', 1, 0, NULL),
(0, 0, '770', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '770', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '770', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '770', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '770', 'r', 'Número de reporte (R)', 'Número de reporte (R)', '', 1, 0, NULL),
(0, 0, '770', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '770', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '770', 'u', 'Número de reporte técnico estándar (NR)', 'Número de reporte técnico estándar (NR)', '', 0, 0, NULL),
(0, 0, '770', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '770', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '770', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '770', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '772', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '772', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '772', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '772', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '772', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '772', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '772', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '772', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '772', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '772', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '772', 'k', 'Datos de serie de ítem relacionado (R)', 'Datos de serie de ítem relacionado (R)', '', 1, 0, NULL),
(0, 0, '772', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '772', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '772', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '772', 'q', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'Título paralelo (NR) (BK SE) [OBSOLETE]', 'OBSOLETO', 0, 0, NULL),
(0, 0, '772', 'r', 'Número de reporte (R)', 'Número de reporte (R)', '', 1, 0, NULL),
(0, 0, '772', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '772', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '772', 'u', 'Número de reporte técnico estándar (NR)', 'Número de reporte técnico estándar (NR)', '', 0, 0, NULL),
(0, 0, '772', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '772', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '772', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '772', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '773', '3', 'Materiales específicos a los cuales se aplica el campo (NR)', 'Materiales específicos a los cuales se aplica el campo (NR)', '', 0, 0, NULL),
(0, 0, '773', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '773', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '773', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '773', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '773', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '773', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '773', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '773', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '773', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '773', 'k', 'Datos de serie de ítem relacionado (R)', 'Datos de serie de ítem relacionado (R)', '', 1, 0, NULL),
(0, 0, '773', 'm', 'Detalles específicos del material (NR)', 'Detalles específicos del material (NR)', '', 0, 0, NULL),
(0, 0, '773', 'n', 'Nota (R)', 'Nota (R)', '', 1, 0, NULL),
(0, 0, '773', 'o', 'Otro identificador de ítem (R)', 'Otro identificador de ítem (R)', '', 1, 0, NULL),
(0, 0, '773', 'p', 'Título abreviado (NR)', 'Título abreviado (NR)', '', 0, 0, NULL),
(0, 0, '773', 'r', 'Número de reporte (R)', 'Número de reporte (R)', '', 1, 0, NULL),
(0, 0, '773', 's', 'Título uniforme (NR)', 'Título uniforme (NR)', '', 0, 0, NULL),
(0, 0, '773', 't', 'Título (NR)', 'Título (NR)', '', 0, 0, NULL),
(0, 0, '773', 'u', 'Número de reporte técnico estándar (NR)', 'Número de reporte técnico estándar (NR)', '', 0, 0, NULL),
(0, 0, '773', 'w', 'Número de control de registro (R)', 'Número de control de registro (R)', '', 1, 0, NULL),
(0, 0, '773', 'x', 'ISSN (NR)', 'ISSN (NR)', '', 0, 0, NULL),
(0, 0, '773', 'y', 'Indicador CODEN (NR)', 'Indicador CODEN (NR)', '', 0, 0, NULL),
(0, 0, '773', 'z', 'ISBN (R)', 'ISBN (R)', '', 1, 0, NULL),
(0, 0, '774', '6', 'Enlace (NR)', 'Enlace (NR)', '', 0, 0, NULL),
(0, 0, '774', '7', 'Subcampo de control (NR)', 'Subcampo de control (NR)', '', 0, 0, NULL),
(0, 0, '774', '8', 'Vínculo de campo y número de secuencia (R)', 'Vínculo de campo y número de secuencia (R)', '', 1, 0, NULL),
(0, 0, '774', 'a', 'Encabezado del asiento principal (NR)', 'Encabezado del asiento principal (NR)', '', 0, 0, NULL),
(0, 0, '774', 'b', 'Edición (NR)', 'Edición (NR)', '', 0, 0, NULL),
(0, 0, '774', 'c', 'Información calificadora (NR)', 'Información calificadora (NR)', '', 0, 0, NULL),
(0, 0, '774', 'd', 'Lugar, editor y fecha de edición (NR)', 'Lugar, editor y fecha de edición (NR)', '', 0, 0, NULL),
(0, 0, '774', 'g', 'Partes relacionadas (R)', 'Partes relacionadas (R)', '', 1, 0, NULL),
(0, 0, '774', 'h', 'Descripción física (NR)', 'Descripción física (NR)', '', 0, 0, NULL),
(0, 0, '774', 'i', 'Información sobre relaciones (R)', 'Información sobre relaciones (R)', '', 1, 0, NULL),
(0, 0, '774', 'k', 'Datos                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                és'),
(36, 'fj', 'Fidji'),
(37, 'fi', 'Finlandés'),
(38, 'fr', 'Francés'),
(39, 'fy', 'Frisón'),
(40, 'gd', 'Gaélico'),
(41, 'gl', 'Gallego'),
(42, 'cy', 'Galés'),
(43, 'ka', 'Georgiano'),
(44, 'gu', 'Gujarati'),
(45, 'el', 'Griego'),
(46, 'kl', 'Groenlandés'),
(47, 'gn', 'Guaraní'),
(48, 'ha', 'Hausa'),
(49, 'he', 'Hebreo'),
(50, 'hi', 'Hindi'),
(51, 'hu', 'Húngaro'),
(52, 'id', 'Indonesio'),
(53, 'ia', 'Interlingua'),
(54, 'ie', 'Interlingue'),
(55, 'iu', 'Inuktitut'),
(56, 'ik', 'Inupiak'),
(57, 'ga', 'Irlandés'),
(58, 'is', 'Islandés'),
(59, 'it', 'Italiano'),
(60, 'ja', 'Japonés'),
(61, 'jw', 'Javanés'),
(62, 'kn', 'Kannada'),
(63, 'kk', 'Kazaj'),
(64, 'km', 'Camboyano'),
(65, 'rw', 'Kinyarwanda'),
(66, 'ky', 'Kirghiz'),
(67, 'rn', 'Kirundi'),
(68, 'ku', 'Kurdo'),
(69, 'lo', 'Laosiano'),
(70, 'la', 'Latín'),
(71, 'lv', 'Letón'),
(72, 'ln', 'Lingala'),
(73, 'lt', 'Lituano'),
(74, 'mk', 'Macedonio'),
(75, 'ms', 'Malayo'),
(76, 'ml', 'Malayalam'),
(77, 'mg', 'Malgache'),
(78, 'mt', 'Maltés'),
(79, 'mi', 'Maori'),
(80, 'mr', 'Marathi'),
(81, 'mo', 'Moldavo'),
(82, 'mn', 'Mongol'),
(83, 'na', 'Nauri'),
(84, 'nl', 'Holandés'),
(85, 'ne', 'Nepalí'),
(86, 'no', 'Noruego'),
(87, 'oc', 'Occitán'),
(88, 'or', 'Oriya'),
(89, 'om', 'Oromo'),
(90, 'ug', 'Uigur'),
(91, 'wo', 'Uolof'),
(92, 'ur', 'Urdu'),
(93, 'uz', 'Uzbeko'),
(94, 'ps', 'Pastún'),
(95, 'pa', 'Panjabi'),
(96, 'fa', 'Farsi'),
(97, 'pl', 'Polaco'),
(98, 'pt', 'Portugués'),
(99, 'qu', 'Quechua'),
(100, 'rm', 'Reto-romance'),
(101, 'ro', 'Rumano'),
(102, 'ru', 'Ruso'),
(103, 'sm', 'Samoano'),
(104, 'sg', 'Sango'),
(105, 'sa', 'Sánscrito'),
(106, 'sc', 'Sardo'),
(107, 'sr', 'Serbio'),
(108, 'sh', 'Serbocroata'),
(109, 'tn', 'Setchwana'),
(110, 'sd', 'Sindhi'),
(111, 'ss', 'Siswati'),
(112, 'sk', 'Eslovaco'),
(113, 'sl', 'Esloveno'),
(114, 'so', 'Somalí'),
(115, 'sw', 'Swahili'),
(116, 'st', 'Sesotho'),
(117, 'sv', 'Sueco'),
(118, 'su', 'Sundanés'),
(119, 'tg', 'Tayic'),
(120, 'tl', 'Tagalo'),
(121, 'ta', 'Tamil'),
(122, 'tt', 'Tatar'),
(123, 'cs', 'Checo'),
(124, 'tw', 'Twi'),
(125, 'te', 'Telugu'),
(126, 'th', 'Thai'),
(127, 'bo', 'Tibetano'),
(128, 'ti', 'Tigrinya'),
(129, 'to', 'Tonga'),
(130, 'ts', 'Tsonga'),
(131, 'tr', 'Turco'),
(132, 'tk', 'Turcmeno'),
(133, 'uk', 'Ucraniano'),
(134, 'vi', 'Vietnamita'),
(135, 'vo', 'Volapuk'),
(136, 'xh', 'Xhosa'),
(137, 'yi', 'Yidish'),
(138, 'yo', 'Yoruba'),
(139, 'za', 'Zhuang'),
(140, 'zu', 'Zulú');

-- --------------------------------------------------------

--
-- Table structure for table `ref_localidad`
--

CREATE TABLE IF NOT EXISTS `ref_localidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `LOCALIDAD` varchar(11) DEFAULT NULL,
  `NOMBRE` varchar(100) DEFAULT NULL,
  `NOMBRE_ABREVIADO` varchar(40) DEFAULT NULL,
  `ref_dpto_partido_id` varchar(11) DEFAULT NULL,
  `DDN` varchar(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ref_localidad_ref_dpto_partido1` (`ref_dpto_partido_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `ref_localidad`
--

INSERT INTO `ref_localidad` (`id`, `LOCALIDAD`, `NOMBRE`, `NOMBRE_ABREVIADO`, `ref_dpto_partido_id`, `DDN`) VALUES
(1, 'LA PLATA', 'LA PLATA', 'LA PLATA', '1', '1');

-- --------------------------------------------------------

--
-- Table structure for table `ref_nivel_bibliografico`
--

CREATE TABLE IF NOT EXISTS `ref_nivel_bibliografico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(4) DEFAULT NULL,
  `description` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `ref_nivel_bibliografico`
--

INSERT INTO `ref_nivel_bibliografico` (`id`, `code`, `description`) VALUES
(1, 'a', 'Analítico'),
(2, 'm', 'Monográfico'),
(3, 'c', 'Colección'),
(4, 'i', 'Integrantes'),
(5, 's', 'Serie');

-- --------------------------------------------------------

--
-- Table structure for table `ref_pais`
--

CREATE TABLE IF NOT EXISTS `ref_pais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `iso` char(2) DEFAULT NULL,
  `iso3` char(3) DEFAULT NULL,
  `nombre` varchar(80) DEFAULT NULL,
  `nombre_largo` varchar(80) DEFAULT NULL,
  `codigo` varchar(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=239 ;

--
-- Dumping data for table `ref_pais`
--

INSERT INTO `ref_pais` (`id`, `iso`, `iso3`, `nombre`, `nombre_largo`, `codigo`) VALUES
(1, 'AF', 'AFG', 'Afganistán', 'Afganistán', ''),
(2, 'AL', 'ALB', 'Albania', 'Albania', '355'),
(3, 'DE', 'DEU', 'Alemania', 'Alemania', ''),
(4, 'AD', 'AND', 'Andorra', 'Andorra', '376'),
(5, 'AO', 'AGO', 'Angola', 'Angola', '244'),
(6, 'AI', 'AIA', 'Anguilla', 'Anguilla', ''),
(7, 'AQ', 'ATA', 'Antártida', 'Antártida', ''),
(8, 'AG', 'ATG', 'Antigua y Barbuda', 'Antigua y Barbuda', ''),
(9, 'AN', 'ANT', 'Antillas Holandesas', 'Antillas Holandesas', ''),
(10, 'SA', 'SAU', 'Arabia Saudí', 'Arabia Saudí', ''),
(11, 'DZ', 'DZA', 'Argelia', 'Argelia', ''),
(12, 'AR', 'ARG', 'Argentina', 'Argentina', '25'),
(13, 'AM', 'ARM', 'Armenia', 'Armenia', '374'),
(14, 'AW', 'ABW', 'Aruba', 'Aruba', ''),
(15, 'AU', 'AUS', 'Australia', 'Australia', '96'),
(16, 'AT', 'AUT', 'Austria', 'Austria', '57'),
(17, 'AZ', 'AZE', 'Azerbaiján', 'Azerbaiján', ''),
(18, 'BS', 'BHS', 'Bahamas', 'Bahamas', ''),
(19, 'BH', 'BHR', 'Bahrein', 'Bahrein', ''),
(20, 'BD', 'BGD', 'Bangladesh', 'Bangladesh', '880'),
(21, 'BB', 'BRB', 'Barbados', 'Barbados', ''),
(22, 'BE', 'BEL', 'Belgica', 'Belgica', ''),
(23, 'BZ', 'BLZ', 'Belice', 'Belice', ''),
(24, 'BJ', 'BEN', 'Benin', 'Benin', '229'),
(25, 'BM', 'BMU', 'Bermuda', 'Bermuda', ''),
(26, 'BT', 'BTN', 'Bhután', 'Bhután', ''),
(27, 'BY', 'BLR', 'Bielorrusia', 'Bielorrusia', ''),
(28, 'BO', 'BOL', 'Bolivia', 'Bolivia', '591'),
(29, 'BA', 'BIH', 'Bosnia & Herzegovina', 'Bosnia & Herzegovina', ''),
(30, 'BW', 'BWA', 'Botswana', 'Botswana', '267'),
(31, 'BR', 'BRA', 'Brasil', 'Brasil', ''),
(32, 'BN', 'BRN', 'Brunei', 'Brunei', ''),
(33, 'BG', 'BGR', 'Bulgaria', 'Bulgaria', '359'),
(34, 'BF', 'BFA', 'Burkina Faso', 'Burkina Faso', '226'),
(35, 'BI', 'BDI', 'Burundi', 'Burundi', '257'),
(36, 'CV', 'CPV', 'Cabo Verde', 'Cabo Verde', ''),
(37, 'KH', 'KHM', 'Camboya', 'Camboya', ''),
(38, 'CM', 'CMR', 'Camerún', 'Camerún', ''),
(39, 'CA', 'CAN', 'Canada', 'Canada', '51'),
(40, 'TD', 'TCD', 'Chad', 'Chad', '235'),
(41, 'CL', 'CHL', 'Chile', 'Chile', '29'),
(42, 'CN', 'CHN', 'China', 'China', '83'),
(43, 'CY', 'CYP', 'Chipre', 'Chipre', ''),
(44, 'CO', 'COL', 'Colombia', 'Colombia', '28'),
(45, 'KM', 'COM', 'Comoros', 'Comoros', ''),
(46, 'CG', 'COG', 'Congo (Rep.)', 'Congo (Rep.)', '242'),
(47, 'KP', 'PRK', 'Corea (Norte)', 'Corea (Norte)', ''),
(48, 'KR', 'KOR', 'Corea (Sur)', 'Corea (Sur)', ''),
(49, 'CI', 'CIV', 'Costa de Marfil', 'Costa de Marfil', ''),
(50, 'CR', 'CRI', 'Costa Rica', 'Costa Rica', '506'),
(51, 'HR', 'HRV', 'Croacia', 'Croacia', ''),
(52, 'CU', 'CUB', 'Cuba', 'Cuba', '39'),
(53, 'ZZ', '', 'Desconocido', 'Desconocido', ''),
(54, 'DK', 'DNK', 'Dinamarca', 'Dinamarca', ''),
(55, 'DM', 'DMA', 'Dominica', 'Dominica', ''),
(56, 'EC', 'ECU', 'Ecuador', 'Ecuador', '593'),
(57, 'EG', 'EGY', 'Egipto', 'Egipto', ''),
(58, 'SV', 'SLV', 'El Salvador', 'El Salvador', '503'),
(59, 'AE', 'ARE', 'Emiratos Árabes Unidos', 'Emiratos Árabes Unidos', ''),
(60, 'ER', 'ERI', 'Eritrea', 'Eritrea', '291'),
(61, 'SK', 'SVK', 'Eslovaquia', 'Eslovaquia', ''),
(62, 'SI', 'SVN', 'Eslovenia', 'Eslovenia', ''),
(63, 'ES', 'ESP', 'España', 'España', ''),
(64, 'US', 'USA', 'Estados Unidos', 'Estados Unidos', ''),
(65, 'EE', 'EST', 'Estonia', 'Estonia', '372'),
(66, 'ET', 'ETH', 'Etiopia', 'Etiopia', ''),
(67, 'FJ', 'FJI', 'Fiji', 'Fiji', ''),
(68, 'PH', 'PHL', 'Filipinas', 'Filipinas', ''),
(69, 'FI', 'FIN', 'Finlandia', 'Finlandia', ''),
(70, 'FR', 'FRA', 'Francia', 'Francia', ''),
(71, 'GA', 'GAB', 'Gabón', 'Gabón', ''),
(72, 'GM', 'GMB', 'Gambia', 'Gambia', '220'),
(73, 'GE', 'GEO', 'Georgia', 'Georgia', '995'),
(74, 'GS', 'SGS', 'Georgia Sur & Islas Sandwich del Sur', 'Georgia Sur & Islas Sandwich del Sur', ''),
(75, 'GH', 'GHA', 'Ghana', 'Ghana', '233'),
(76, 'GI', 'GIB', 'Gibraltar', 'Gibraltar', ''),
(77, 'GD', 'GRD', 'Granada', 'Granada', ''),
(78, 'GR', 'GRC', 'Grecia', 'Grecia', ''),
(79, 'GL', 'GRL', 'Groenlandia', 'Groenlandia', ''),
(80, 'GP', 'GLP', 'Guadalupe', 'Guadalupe', ''),
(81, 'GU', 'GUM', 'Guam', 'Guam', ''),
(82, 'GT', 'GTM', 'Guatemala', 'Guatemala', '502'),
(83, 'GN', 'GIN', 'Guinea', 'Guinea', ''),
(84, 'GQ', 'GNQ', 'Guinea Ecuatorial', 'Guinea Ecuatorial', ''),
(85, 'GW', 'GNB', 'Guinea-Bissau', 'Guinea-Bissau', ''),
(86, 'GY', 'GUY', 'Guyana', 'Guyana', '592'),
(87, 'GF', 'GUF', 'Guyana Francesa', 'Guyana Francesa', ''),
(88, 'HT', 'HTI', 'Haiti', 'Haiti', '509'),
(89, 'NL', 'NLD', 'Holanda', 'Holanda', ''),
(90, 'HN', 'HND', 'Honduras', 'Honduras', '504'),
(91, 'HK', 'HKG', 'Hong Kong', 'Hong Kong', ''),
(92, 'HU', 'HUN', 'Hungria', 'Hungria', ''),
(93, 'IN', 'IND', 'India', 'India', '84'),
(94, 'ID', 'IDN', 'Indonesia', 'Indonesia', ''),
(95, 'IR', 'IRN', 'Iran', 'Iran', ''),
(96, 'IQ', 'IRQ', 'Iraq', 'Iraq', ''),
(97, 'IE', 'IRL', 'Irlanda', 'Irlanda', ''),
(98, 'BV', 'BVT', 'Isla Bouvet', 'Isla Bouvet', ''),
(99, 'CX', 'CXR', 'Isla Christmas', 'Isla Christmas', ''),
(100, 'HM', 'HMD', 'Isla Heard & Islas McDonald', 'Isla Heard & Islas McDonald', ''),
(101, 'NF', 'NFK', 'Isla Norfolk', 'Isla Norfolk', ''),
(102, 'IS', 'ISL', 'Islandia', 'Islandia', ''),
(103, 'KY', 'CYM', 'Islas Cayman', 'Islas Cayman', ''),
(104, 'CC', 'CCK', 'Islas Cocos', 'Islas Cocos', ''),
(105, 'CK', 'COK', 'Islas Cook', 'Islas Cook', ''),
(106, 'FK', 'FLK', 'Islas Falkland (Malvinas)', 'Islas Falkland (Malvinas)', ''),
(107, 'FO', 'FRO', 'Islas Feroe', 'Islas Feroe', ''),
(108, 'MP', 'MNP', 'Islas Marianas', 'Islas Marianas', ''),
(109, 'MH', 'MHL', 'Islas Marshall', 'Islas Marshall', ''),
(110, 'UM', 'UMI', 'Islas menores y remotas de Estados Unidos', 'Islas menores y remotas de Estados Unidos', ''),
(111, 'SB', 'SLB', 'Islas Salomón', 'Islas Salomón', ''),
(112, 'VI', 'VIR', 'Islas Vírgenes (Estados Unidos )', 'Islas Vírgenes (Estados Unidos )', ''),
(113, 'VG', 'VGB', 'Islas Vírgenes (Reino Unido)', 'Islas Vírgenes (Reino Unido)', ''),
(114, 'IL', 'ISR', 'Israel', 'Israel', '972'),
(115, 'IT', 'ITA', 'Italia', 'Italia', ''),
(116, 'JM', 'JAM', 'Jamaica', 'Jamaica', '44'),
(117, 'JP', 'JPN', 'Japón', 'Japón', ''),
(118, 'JO', 'JOR', 'Jordania', 'Jordania', ''),
(119, 'KZ', 'KAZ', 'Kazajstán', 'Kazajstán', ''),
(120, 'KE', 'KEN', 'Kenya', 'Kenya', '254'),
(121, 'KG', 'KGZ', 'Kirguizstan', 'Kirguizstan', ''),
(122, 'KI', 'KIR', 'Kiribati', 'Kiribati', '686'),
(123, 'KW', 'KWT', 'Kuwait', 'Kuwait', '965'),
(124, 'LA', 'LAO', 'Laos', 'Laos', ''),
(125, 'LS', 'LSO', 'Lesotho', 'Lesotho', '266'),
(126, 'LV', 'LVA', 'Letonia', 'Letonia', ''),
(127, 'LB', 'LBN', 'Líbano', 'Líbano', ''),
(128, 'LR', 'LBR', 'Liberia', 'Liberia', '231'),
(129, 'LY', 'LBY', 'Libia', 'Libia', ''),
(130, 'LI', 'LIE', 'Liechtenstein', 'Liechtenstein', '423'),
(131, 'LT', 'LTU', 'Lituania', 'Lituania', ''),
(132, 'LU', 'LUX', 'Luxemburgo', 'Luxemburgo', ''),
(133, 'MO', 'MAC', 'Macao', 'Macao', ''),
(134, 'MG', 'MDG', 'Madagascar', 'Madagascar', '261'),
(135, 'MY', 'MYS', 'Malasia', 'Malasia', ''),
(136, 'MW', 'MWI', 'Malawi', 'Malawi', '265'),
(137, 'MV', 'MDV', 'Maldivas', 'Maldivas', ''),
(138, 'ML', 'MLI', 'Malí', 'Malí', ''),
(139, 'MT', 'MLT', 'Malta', 'Malta', '356'),
(140, 'MA', 'MAR', 'Marruecos', 'Marruecos', ''),
(141, 'MQ', 'MTQ', 'Martinica', 'Martinica', ''),
(142, 'MU', 'MUS', 'Mauricio', 'Mauricio', ''),
(143, 'MR', 'MRT', 'Mauritania', 'Mauritania', '222'),
(144, 'YT', 'MYT', 'Mayotte', 'Mayotte', ''),
(145, 'MX', 'MEX', 'México', 'México', '53'),
(146, 'FM', 'FSM', 'Micronesia', 'Micronesia', ''),
(147, 'MD', 'MDA', 'Moldavia', 'Moldavia', ''),
(148, 'MC', 'MCO', 'Mónaco', 'Mónaco', '377'),
(149, 'MN', 'MNG', 'Mongolia', 'Mongolia', '976'),
(150, 'MS', 'MSR', 'Montserrat', 'Montserrat', ''),
(151, 'MZ', 'MOZ', 'Mozambique', 'Mozambique', '258'),
(152, 'MM', 'MMR', 'Myanmar (Birmania)', 'Myanmar (Birmania)', ''),
(153, 'NA', 'NAM', 'Namibia', 'Namibia', ''),
(154, 'NR', 'NRU', 'Nauru', 'Nauru', '674'),
(155, 'NP', 'NPL', 'Nepal', 'Nepal', '977'),
(156, 'NI', 'NIC', 'Nicaragua', 'Nicaragua', '505'),
(157, 'NE', 'NER', 'Níger', 'Níger', ''),
(158, 'NG', 'NGA', 'Nigeria', 'Nigeria', '234'),
(159, 'NU', 'NIU', 'Niue', 'Niue', ''),
(160, 'NO', 'NOR', 'Noruega', 'Noruega', ''),
(161, 'NC', 'NCL', 'Nueva Caledonia', 'Nueva Caledonia', ''),
(162, 'NZ', 'NZL', 'Nueva Zelanda', 'Nueva Zelanda', ''),
(163, 'OM', 'OMN', 'Omán', 'Omán', ''),
(164, 'PK', 'PAK', 'Pakistán', 'Pakistán', ''),
(165, 'PW', 'PLW', 'Palau', 'Palau', '680'),
(166, 'PA', 'PAN', 'Panamá', 'Panamá', '507'),
(167, 'PG', 'PNG', 'Papua Nueva Guinea', 'Papua Nueva Guinea', ''),
(168, 'PY', 'PRY', 'Paraguay', 'Paraguay', '595'),
(169, 'PE', 'PER', 'Perú', 'Perú', '34'),
(170, 'PN', 'PCN', 'Pitcairn', 'Pitcairn', ''),
(171, 'PF', 'PYF', 'Polinesia Francesa', 'Polinesia Francesa', ''),
(172, 'PL', 'POL', 'Polonia', 'Polonia', ''),
(173, 'PT', 'PRT', 'Portugal', 'Portugal', '351'),
(174, 'PR', 'PRI', 'Puerto Rico', 'Puerto Rico', '47'),
(175, 'QA', 'QAT', 'Qatar', 'Qatar', '974'),
(176, 'GB', 'GBR', 'Reino Unido', 'Reino Unido', ''),
(177, 'CF', 'CAF', 'Rep. Centro Africana', 'Rep. Centro Africana', ''),
(178, 'CZ', 'CZE', 'Republica Checa', 'Republica Checa', ''),
(179, 'DO', 'DOM', 'República Dominicana', 'República Dominicana', ''),
(180, 'RE', 'REU', 'Reunión', 'Reunión', ''),
(181, 'RW', 'RWA', 'Ruanda', 'Ruanda', ''),
(182, 'RO', 'ROM', 'Rumania', 'Rumania', ''),
(183, 'RU', 'RUS', 'Rusia', 'Rusia', ''),
(184, 'EH', 'ESH', 'Sahara Occidental', 'Sahara Occidental', ''),
(185, 'AS', 'ASM', 'Samoa (Americana)', 'Samoa (Americana)', ''),
(186, 'WS', 'WSM', 'Samoa (Oeste)', 'Samoa (Oeste)', ''),
(187, 'SM', 'SMR', 'San Marino', 'San Marino', '378'),
(188, 'ST', 'STP', 'Santo Tomé & Principe', 'Santo Tomé & Principe', ''),
(189, 'SN', 'SEN', 'Senegal', 'Senegal', '221'),
(190, 'SC', 'SYC', 'Seychelles', 'Seychelles', ''),
(191, 'SL', 'SLE', 'Sierra Leona', 'Sierra Leona', ''),
(192, 'SG', 'SGP', 'Singapur', 'Singapur', ''),
(193, 'SY', 'SYR', 'Siria', 'Siria', ''),
(194, 'SO', 'SOM', 'Somalia', 'Somalia', '252'),
(195, 'LK', 'LKA', 'Sri Lanka', 'Sri Lanka', ''),
(196, 'SH', 'SHN', 'St Helena', 'St Helena', ''),
(197, 'KN', 'KNA', 'St Kitts & Nevis', 'St Kitts & Nevis', ''),
(198, 'LC', 'LCA', 'St Lucia', 'St Lucia', ''),
(199, 'PM', 'SPM', 'St Pierre & Miquelon', 'St Pierre & Miquelon', ''),
(200, 'VC', 'VCT', 'St Vincent', 'St Vincent', ''),
(201, 'ZA', 'ZAF', 'Sudáfrica', 'Sudáfrica', ''),
(202, 'SD', 'SDN', 'Sudan', 'Sudan', '249'),
(203, 'SE', 'SWE', 'Suecia', 'Suecia', ''),
(204, 'CH', 'CHE', 'Suiza', 'Suiza', ''),
(205, 'SR', 'SUR', 'Surinam', 'Surinam', ''),
(206, 'SJ', 'SJM', 'Svalbard & Jan Mayen', 'Svalbard & Jan Mayen', ''),
(207, 'SZ', 'SWZ', 'Swazilandia', 'Swazilandia', ''),
(208, 'TH', 'THA', 'Tailandia', 'Tailandia', ''),
(209, 'TW', 'TWN', 'Taiwan', 'Taiwan', ''),
(210, 'TJ', 'TJK', 'Tajikistan', 'Tajikistan', ''),
(211, 'TZ', 'TZA', 'Tanzania', 'Tanzania', ''),
(212, 'IO', 'IOT', 'Territorio Britanico del Oceano Indico', 'Territorio Britanico del Oceano Indico', ''),
(213, 'TF', 'ATF', 'Territorios Franceses del Sur y Antárticos', 'Territorios Franceses del Sur y Antárticos', ''),
(214, 'TP', 'TMP', 'Timor Oriental', 'Timor Oriental', ''),
(215, 'TG', 'TGO', 'Togo', 'Togo', ''),
(216, 'TK', 'TKL', 'Tokelau', 'Tokelau', '690'),
(217, 'TO', 'TON', 'Tonga', 'Tonga', '676'),
(218, 'TT', 'TTO', 'Trinidad & Tobago', 'Trinidad & Tobago', ''),
(219, 'TN', 'TUN', 'Tunez', 'Tunez', ''),
(220, 'TM', 'TKM', 'Turkmenistan', 'Turkmenistan', ''),
(221, 'TC', 'TCA', 'Turks & Islas Caicos', 'Turks & Islas Caicos', ''),
(222, 'TR', 'TUR', 'Turquia', 'Turquia', ''),
(223, 'TV', 'TUV', 'Tuvalu', 'Tuvalu', '688'),
(224, 'UA', 'UKR', 'Ucrania', 'Ucrania', ''),
(225, 'UG', 'UGA', 'Uganda', 'Uganda', '256'),
(226, 'UY', 'URY', 'Uruguay', 'Uruguay', '598'),
(227, 'UZ', 'UZB', 'Uzbekistán', 'Uzbekistán', ''),
(228, 'VU', 'VUT', 'Vanuatu', 'Vanuatu', '678'),
(229, 'VA', 'VAT', 'Vaticano', 'Vaticano', ''),
(230, 'VE', 'VEN', 'Venezuela', 'Venezuela', '37'),
(231, 'VN', 'VNM', 'Vietnam', 'Vietnam', ''),
(232, 'WF', 'WLF', 'Wallis & Futuna', 'Wallis & Futuna', ''),
(233, 'YE', 'YEM', 'Yemen', 'Yemen', ''),
(234, 'DJ', 'DJI', 'Yibuti', 'Yibuti', ''),
(235, 'YU', 'YUG', 'Yugoslavia', 'Yugoslavia', '381'),
(236, 'ZR', 'ZAR', 'Zaire', 'Zaire', '243'),
(237, 'ZM', 'ZMB', 'Zambia', 'Zambia', '260'),
(238, 'ZW', 'ZWE', 'Zimbabwe', 'Zimbabwe', '263');

-- --------------------------------------------------------

--
-- Table structure for table `ref_provincia`
--

CREATE TABLE IF NOT EXISTS `ref_provincia` (
  `id` varchar(11) NOT NULL DEFAULT '',
  `NOMBRE` varchar(60) DEFAULT NULL,
  `ref_pais_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ref_provincia_ref_pais1` (`ref_pais_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ref_provincia`
--

INSERT INTO `ref_provincia` (`id`, `NOMBRE`, `ref_pais_id`) VALUES
('1', 'BUENOS AIRES', 12);

-- --------------------------------------------------------

--
-- Table structure for table `ref_signatura`
--

CREATE TABLE IF NOT EXISTS `ref_signatura` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `signatura` varchar(255) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `signatura_UNIQUE` (`signatura`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `ref_signatura`
--


-- --------------------------------------------------------

--
-- Table structure for table `ref_soporte`
--

CREATE TABLE IF NOT EXISTS `ref_soporte` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idSupport` varchar(10) DEFAULT NULL,
  `description` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `ref_soporte`
--

INSERT INTO `ref_soporte` (`id`, `idSupport`, `description`) VALUES
(1, '1', 'Impreso en papel'),
(2, '2', 'Microfilm'),
(3, '3', 'Soporte Magnético');

-- --------------------------------------------------------

--
-- Table structure for table `ref_tipo_operacion`
--

CREATE TABLE IF NOT EXISTS `ref_tipo_operacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `ref_tipo_operacion`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_busqueda`
--

CREATE TABLE IF NOT EXISTS `rep_busqueda` (
  `idBusqueda` int(11) NOT NULL AUTO_INCREMENT,
  `nro_socio` varchar(16) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `categoria_socio` char(2) DEFAULT NULL,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idBusqueda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_busqueda`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_historial_busqueda`
--

CREATE TABLE IF NOT EXISTS `rep_historial_busqueda` (
  `idHistorial` int(11) NOT NULL AUTO_INCREMENT,
  `idBusqueda` int(11) NOT NULL,
  `campo` varchar(100) DEFAULT NULL,
  `valor` varchar(100) DEFAULT NULL,
  `tipo` varchar(10) DEFAULT NULL,
  `agent` varchar(255) DEFAULT NULL,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idHistorial`),
  KEY `FK_idBusqueda` (`idBusqueda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_historial_busqueda`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_historial_circulacion`
--

CREATE TABLE IF NOT EXISTS `rep_historial_circulacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id1` int(11) NOT NULL,
  `id2` int(11) NOT NULL,
  `id3` int(11) DEFAULT NULL,
  `tipo_operacion` varchar(255) DEFAULT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  `responsable` varchar(20) DEFAULT NULL,
  `id_ui` varchar(4) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha` date NOT NULL DEFAULT '0000-00-00',
  `nota` varchar(50) DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `tipo_prestamo` char(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_historial_circulacion`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_historial_prestamo`
--

CREATE TABLE IF NOT EXISTS `rep_historial_prestamo` (
  `id_historial_prestamo` int(11) NOT NULL AUTO_INCREMENT,
  `id3` int(11) NOT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  `tipo_prestamo` char(2) DEFAULT NULL,
  `fecha_prestamo` varchar(20) DEFAULT NULL,
  `id_ui_origen` char(4) DEFAULT NULL,
  `id_ui_prestamo` char(4) DEFAULT NULL,
  `fecha_devolucion` varchar(20) DEFAULT NULL,
  `fecha_ultima_renovacion` varchar(20) DEFAULT NULL,
  `fecha_vencimiento` varchar(20) NOT NULL,
  `renovaciones` tinyint(4) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_historial_prestamo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_historial_prestamo`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_historial_sancion`
--

CREATE TABLE IF NOT EXISTS `rep_historial_sancion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo_operacion` varchar(30) DEFAULT NULL,
  `nro_socio` varchar(16) DEFAULT NULL,
  `responsable` varchar(20) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `fecha` date NOT NULL DEFAULT '0000-00-00',
  `fecha_comienzo` date DEFAULT NULL,
  `fecha_final` date DEFAULT NULL,
  `tipo_sancion` int(11) DEFAULT '0',
  `dias_sancion` int(11) DEFAULT NULL,
  `id3` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_historial_sancion`
--


-- --------------------------------------------------------

--
-- Table structure for table `rep_registro_modificacion`
--

CREATE TABLE IF NOT EXISTS `rep_registro_modificacion` (
  `idModificacion` int(4) NOT NULL AUTO_INCREMENT,
  `id` int(11) NOT NULL,
  `operacion` varchar(15) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `responsable` varchar(20) DEFAULT NULL,
  `nota` text,
  `tipo` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  KEY `id_modificacion` (`idModificacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `rep_registro_modificacion`
--


-- --------------------------------------------------------

--
-- Table structure for table `sist_sesion`
--

CREATE TABLE IF NOT EXISTS `sist_sesion` (
  `sessionID` varchar(255) NOT NULL DEFAULT '',
  `userid` varchar(255) DEFAULT NULL,
  `ip` varchar(16) DEFAULT NULL,
  `lasttime` int(11) DEFAULT NULL,
  `nroRandom` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `flag` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`sessionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sist_sesion`
--


-- --------------------------------------------------------

--
-- Table structure for table `sys_externos_meran`
--

CREATE TABLE IF NOT EXISTS `sys_externos_meran` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_ui` varchar(4) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_ui` (`id_ui`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `sys_externos_meran`
--


-- --------------------------------------------------------

--
-- Table structure for table `sys_metodo_auth`
--

CREATE TABLE IF NOT EXISTS `sys_metodo_auth` (
  `id` int(12) NOT NULL AUTO_INCREMENT,
  `metodo` varchar(255) NOT NULL,
  `orden` int(12) NOT NULL,
  `enabled` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `metodo` (`metodo`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `sys_metodo_auth`
--

INSERT INTO `sys_metodo_auth` (`id`, `metodo`, `orden`, `enabled`) VALUES
(1, 'mysql', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `sys_novedad`
--

CREATE TABLE IF NOT EXISTS `sys_novedad` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(16) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `titulo` varchar(255) DEFAULT NULL,
  `categoria` varchar(255) DEFAULT NULL,
  `contenido` text NOT NULL,
  `links` varchar(1024) DEFAULT NULL,
  `adjunto` varchar(255) DEFAULT NULL,
  `nombreAdjunto` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `sys_novedad`
--


-- --------------------------------------------------------

--
-- Table structure for table `sys_novedad_intra`
--

CREATE TABLE IF NOT EXISTS `sys_novedad_intra` (
  `id` int(16) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(16) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `titulo` varchar(255) NOT NULL,
  `categoria` varchar(255) NOT NULL,
  `contenido` text NOT NULL,
  `links` varchar(1024) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `sys_novedad_intra`
--


-- --------------------------------------------------------

--
-- Table structure for table `sys_novedad_intra_no_mostrar`
--

CREATE TABLE IF NOT EXISTS `sys_novedad_intra_no_mostrar` (
  `id_novedad` int(16) NOT NULL,
  `usuario_novedad` varchar(16) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id_novedad`,`usuario_novedad`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sys_novedad_intra_no_mostrar`
--


-- --------------------------------------------------------

--
-- Table structure for table `usr_estado`
--

CREATE TABLE IF NOT EXISTS `usr_estado` (
  `id_estado` int(11) NOT NULL AUTO_INCREMENT,
  `categoria` char(2) DEFAULT NULL,
  `fuente` varchar(255) DEFAULT NULL,
  `nombre` varchar(255) NOT NULL,
  PRIMARY KEY (`id_estado`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=12 ;

--
-- Dumping data for table `usr_estado`
--

INSERT INTO `usr_estado` (`id_estado`, `categoria`, `fuente`, `nombre`) VALUES
(1, NULL, 'SISTEMA', 'ACTIVO REGULAR');

-- --------------------------------------------------------

--
-- Table structure for table `usr_login_attempts`
--

CREATE TABLE IF NOT EXISTS `usr_login_attempts` (
  `nro_socio` varchar(16) NOT NULL,
  `attempts` int(32) NOT NULL DEFAULT '0',
  PRIMARY KEY (`nro_socio`),
  UNIQUE KEY `nro_socio` (`nro_socio`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `usr_login_attempts`
--

INSERT INTO `usr_login_attempts` (`nro_socio`, `attempts`) VALUES
('meranadmin', 0);

-- --------------------------------------------------------

--
-- Table structure for table `usr_persona`
--

CREATE TABLE IF NOT EXISTS `usr_persona` (
  `id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `version_documento` char(1) DEFAULT NULL,
  `nro_documento` varchar(16) DEFAULT NULL,
  `tipo_documento` int(11) NOT NULL DEFAULT '1',
  `apellido` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `titulo` varchar(255) DEFAULT NULL,
  `otros_nombres` varchar(255) DEFAULT NULL,
  `iniciales` varchar(255) DEFAULT NULL,
  `calle` varchar(255) DEFAULT NULL,
  `barrio` varchar(255) DEFAULT NULL,
  `ciudad` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `msg_texto` varchar(255) DEFAULT NULL,
  `alt_calle` varchar(255) DEFAULT NULL,
  `alt_barrio` varchar(255) DEFAULT NULL,
  `alt_ciudad` varchar(255) DEFAULT NULL,
  `alt_telefono` varchar(255) DEFAULT NULL,
  `codigo_postal` varchar(32) DEFAULT NULL,
  `nacimiento` date DEFAULT NULL,
  `fecha_alta` date DEFAULT NULL,
  `legajo` varchar(8) DEFAULT NULL,
  `sexo` char(1) DEFAULT NULL,
  `telefono_laboral` varchar(50) DEFAULT NULL,
  `cumple_condicion` tinyint(1) NOT NULL DEFAULT '0',
  `es_socio` int(1) unsigned NOT NULL DEFAULT '0' COMMENT '1= si; 0=no',
  `institucion` varchar(255) DEFAULT NULL,
  `carrera` varchar(255) DEFAULT NULL,
  `anio` varchar(255) DEFAULT NULL,
  `division` varchar(255) DEFAULT NULL,
  `id_estado` int(11) NOT NULL,
  `id_categoria` int(2) NOT NULL DEFAULT '8',
  `foto` varchar(255) NOT NULL,
  PRIMARY KEY (`id_persona`),
  KEY `id_persona` (`id_persona`,`nro_documento`,`tipo_documento`),
  KEY `apellido` (`apellido`),
  KEY `nombre` (`nombre`),
  KEY `email` (`email`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=167909 ;

--
-- Dumping data for table `usr_persona`
--

INSERT INTO `usr_persona` (`id_persona`, `version_documento`, `nro_documento`, `tipo_documento`, `apellido`, `nombre`, `titulo`, `otros_nombres`, `iniciales`, `calle`, `barrio`, `ciudad`, `telefono`, `email`, `fax`, `msg_texto`, `alt_calle`, `alt_barrio`, `alt_ciudad`, `alt_telefono`, `codigo_postal`, `nacimiento`, `fecha_alta`, `legajo`, `sexo`, `telefono_laboral`, `cumple_condicion`, `es_socio`, `institucion`, `carrera`, `anio`, `division`, `id_estado`, `id_categoria`, `foto`) VALUES
(167908, 'P', '1000000', 1, 'Meran', 'Meran Unlp', NULL, NULL, NULL, 'Calle 50 y 120', NULL, '1', '1287423648', 'meraninfo@linti.unlp.edu.ar', NULL, NULL, '', NULL, '', '', '1900', '2009-12-23', NULL, '007', 'M', NULL, 0, 1, '', '', '', '', 46, 6, '9f5a7f3d5ab451e20e2538d5beb423a3a2a5957d.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `usr_ref_categoria_socio`
--

CREATE TABLE IF NOT EXISTS `usr_ref_categoria_socio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categorycode` char(2) DEFAULT NULL,
  `description` mediumtext,
  `enrolmentperiod` smallint(6) DEFAULT NULL,
  `upperagelimit` smallint(6) DEFAULT NULL,
  `dateofbirthrequired` tinyint(1) DEFAULT NULL,
  `finetype` varchar(30) DEFAULT NULL,
  `bulk` tinyint(1) DEFAULT NULL,
  `enrolmentfee` decimal(28,6) DEFAULT NULL,
  `overduenoticerequired` tinyint(1) DEFAULT NULL,
  `issuelimit` smallint(6) DEFAULT NULL,
  `reservefee` decimal(28,6) DEFAULT NULL,
  `borrowingdays` smallint(30) NOT NULL DEFAULT '14',
  PRIMARY KEY (`id`),
  UNIQUE KEY `categorycode` (`categorycode`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `usr_ref_categoria_socio`
--

INSERT INTO `usr_ref_categoria_socio` (`id`, `categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `borrowingdays`) VALUES
(1, 'ES', 'Estudiante', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(2, 'IN', 'Investigador', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(3, 'DO', 'Docente', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(4, 'ND', 'No Docente', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(5, 'EG', 'Egresado', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(6, 'PG', 'Postgrado', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(7, 'EX', 'Usuario externo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(8, 'BI', 'Bibliotecas', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14),
(9, 'BB', 'Bibliotecario', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 14);

-- --------------------------------------------------------

--
-- Table structure for table `usr_ref_tipo_documento`
--

CREATE TABLE IF NOT EXISTS `usr_ref_tipo_documento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `descripcion` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC AUTO_INCREMENT=8 ;

--
-- Dumping data for table `usr_ref_tipo_documento`
--

INSERT INTO `usr_ref_tipo_documento` (`id`, `nombre`, `descripcion`) VALUES
(1, 'DNI', 'DNI');

-- --------------------------------------------------------

--
-- Table structure for table `usr_regularidad`
--

CREATE TABLE IF NOT EXISTS `usr_regularidad` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usr_estado_id` int(11) NOT NULL,
  `usr_ref_categoria_id` int(11) NOT NULL,
  `condicion` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=151 ;

--
-- Dumping data for table `usr_regularidad`
--

INSERT INTO `usr_regularidad` (`id`, `usr_estado_id`, `usr_ref_categoria_id`, `condicion`) VALUES
(1, 1, 1, 1),
(7, 1, 3, 1),
(13, 1, 5, 1),
(25, 1, 2, 0),
(26, 1, 4, 0),
(27, 1, 6, 1),
(28, 1, 7, 1),
(29, 1, 8, 1),
(30, 1, 9, 1);

-- --------------------------------------------------------

--
-- Table structure for table `usr_socio`
--

CREATE TABLE IF NOT EXISTS `usr_socio` (
  `id_persona` int(11) NOT NULL,
  `id_socio` int(11) NOT NULL AUTO_INCREMENT,
  `nro_socio` varchar(16) DEFAULT NULL,
  `id_ui` varchar(4) DEFAULT NULL,
  `fecha_alta` date DEFAULT NULL,
  `expira` date DEFAULT NULL,
  `flags` int(11) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `last_change_password` date DEFAULT NULL,
  `change_password` tinyint(1) DEFAULT '0',
  `cumple_requisito` varchar(255) DEFAULT NULL,
  `nombre_apellido_autorizado` varchar(255) DEFAULT NULL,
  `dni_autorizado` varchar(16) DEFAULT NULL,
  `telefono_autorizado` varchar(255) DEFAULT NULL,
  `is_super_user` int(11) NOT NULL DEFAULT '0',
  `credential_type` varchar(255) DEFAULT NULL,
  `activo` varchar(255) DEFAULT NULL,
  `note` text,
  `agregacion_temp` varchar(255) DEFAULT NULL,
  `theme` varchar(255) DEFAULT NULL,
  `theme_intra` varchar(255) DEFAULT NULL,
  `locale` varchar(32) DEFAULT NULL,
  `lastValidation` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `id_categoria` int(2) NOT NULL DEFAULT '1',
  `recover_password_hash` varchar(255) DEFAULT NULL,
  `client_ip_recover_pwd` varchar(255) DEFAULT NULL,
  `recover_date_of` timestamp NULL DEFAULT NULL,
  `last_auth_method` varchar(255) NOT NULL DEFAULT 'mysql',
  `remindFlag` int(1) NOT NULL DEFAULT '1',
  `id_estado` int(11) NOT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `es_admin` int(1) DEFAULT NULL,
  PRIMARY KEY (`id_socio`),
  KEY `id_persona` (`id_persona`),
  KEY `nro_socio` (`nro_socio`),
  KEY `id_ui` (`id_ui`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=22104 ;

--
-- Dumping data for table `usr_socio`
--

INSERT INTO `usr_socio` (`id_persona`, `id_socio`, `nro_socio`, `id_ui`, `fecha_alta`, `expira`, `flags`, `password`, `last_login`, `last_change_password`, `change_password`, `cumple_requisito`, `nombre_apellido_autorizado`, `dni_autorizado`, `telefono_autorizado`, `is_super_user`, `credential_type`, `activo`, `note`, `agregacion_temp`, `theme`, `theme_intra`, `locale`, `lastValidation`, `id_categoria`, `recover_password_hash`, `client_ip_recover_pwd`, `recover_date_of`, `last_auth_method`, `remindFlag`, `id_estado`, `foto`, `es_admin`) VALUES
(167908, 22103, 'meranadmin', 'MERA', '2010-02-15', NULL, 1, '0385tAqkMI66N2lmUq080FtjO8Qwt0Old/tWIZczOOo', '2012-08-27 08:01:16', '2012-08-24', 0, '0000-00-00', '', '', '', 1, 'superLibrarian', '1', NULL, 'id_persona', 'DEO', 'DEO', 'es_ES', '2012-05-14 13:46:09', 9, '1s7pLVbqGrNeVBDkB9z+f05fvmQG4ygaAC7U6O0fB7g', '163.10.10.126 <>', '2012-08-22 15:05:52', 'mysql', 1, 1, 'a473a594c51a00aad2af931e85edc9e6999c7725.jpg', 1);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cat_ayuda_marc`
--
ALTER TABLE `cat_ayuda_marc`
  ADD CONSTRAINT `cat_ayuda_marc_ibfk_1` FOREIGN KEY (`ui`) REFERENCES `pref_unidad_informacion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `cat_registro_marc_n2_cover`
--
ALTER TABLE `cat_registro_marc_n2_cover`
  ADD CONSTRAINT `cat_registro_marc_n2_cover_ibfk_1` FOREIGN KEY (`id2`) REFERENCES `cat_registro_marc_n2` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `cat_registro_marc_n3`
--
ALTER TABLE `cat_registro_marc_n3`
  ADD CONSTRAINT `cat_registro_marc_n3_ibfk_1` FOREIGN KEY (`id2`) REFERENCES `cat_registro_marc_n2` (`id`),
  ADD CONSTRAINT `cat_registro_marc_n3_n1` FOREIGN KEY (`id1`) REFERENCES `cat_registro_marc_n1` (`id`);

