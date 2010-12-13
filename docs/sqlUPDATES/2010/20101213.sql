CREATE TABLE `meran`.`adq_tipo_material` (
    `id` INT( 11 ) NOT NULL ,
    `nombre` VARCHAR( 45 ) NOT NULL ,
    PRIMARY KEY ( `id` )
) ENGINE = InnoDB;



CREATE TABLE `meran`.`adq_proveedor_tipo_material` (
    `proveedor_id` INT( 11 ) NOT NULL ,
    `tipo_material_id` INT( 11 ) NOT NULL ,
    PRIMARY KEY ( `id`,`tipo_material_id` )
) ENGINE = InnoDB;


ALTER TABLE `meran`.`adq_proveedor_tipo_material` 
    ADD CONSTRAINT `fk_adq_proveedor_adq_proveedor_tipo_material1`
    FOREIGN KEY (`proveedor_id` )
    REFERENCES `adq_proveedor` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION, 
    ADD CONSTRAINT `fk_adq_tipo_material_adq_proveedor_tipo_material2`
    FOREIGN KEY (`tipo_material_id` )
    REFERENCES `adq_tipo_material` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
