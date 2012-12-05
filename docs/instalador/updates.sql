USE reemplazarDATABASE;
#UPDATES PARA ACTUALIZACIONES DE SANDBOX

#agregar al actualizar el numero de version actual (0.9.3) y los updates.sql con un postFix que sea el numero de version

ALTER TABLE  `circ_prestamo` ADD  `fecha_vencimiento_reporte` VARCHAR( 20 ) NOT NULL;

# APARTIR DE ACA ES LA v0.9.3

INSERT INTO  `pref_tabla_referencia` (
`id` ,
`nombre_tabla` ,
`alias_tabla` ,
`campo_busqueda` ,
`client_title`
)
VALUES (
NULL ,  'cat_ref_tipo_nivel3',  'tipo_ejemplar',  'nombre',  'Tipo de Documento'
);

ALTER TABLE  `cat_estructura_catalogacion` CHANGE  `itemtype`  `itemtype` VARCHAR( 8 ) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;
