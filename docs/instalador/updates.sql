USE reemplazarDATABASE;
#UPDATES PARA ACTUALIZACIONES DE SANDBOX

INSERT INTO usr_login_attempts (nro_socio, attempts) VALUES ('TEST_UPDATE', '100');
ALTER TABLE  `circ_prestamo` ADD  `fecha_vencimiento_reporte` VARCHAR( 20 ) NOT NULL;

