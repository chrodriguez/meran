use meran;

-- userAdmin=userAdmin
-- passAdmin=kohaadmin
CREATE USER 'userAdmin'@'localhost' IDENTIFIED BY 'kohaadmin';

-- userOPAC=userOPAC
-- passOPAC=opac
CREATE USER 'userOPAC'@'localhost' IDENTIFIED BY 'opac';

-- userINTRA=userINTRA
-- passINTRA=intra
CREATE USER 'userINTRA'@'localhost' IDENTIFIED BY 'intra';

-- userDevelop=userDevelop
-- passDevelop=dev
CREATE USER 'userDevelop'@'localhost' IDENTIFIED BY 'dev';

-- userSphinx=indice
-- passSphinx=indice
CREATE USER 'indice'@'localhost' IDENTIFIED BY 'indice';


-- Permisos del opac
GRANT SELECT on  * to userOPAC@localhost;
GRANT SELECT, INSERT, UPDATE, DELETE on   circ_reserva  to userOPAC@localhost;
GRANT SELECT, INSERT on  rep_busqueda                   to userOPAC@localhost;
GRANT SELECT, INSERT on  rep_historial_busqueda         to userOPAC@localhost;
GRANT SELECT, INSERT on  rep_historial_circulacion      to userOPAC@localhost;
GRANT SELECT, INSERT, UPDATE, DELETE on  sist_sesion    to userOPAC@localhost;
GRANT SELECT, UPDATE on  usr_persona                    to userOPAC@localhost;
GRANT SELECT, UPDATE on  usr_socio                      to userOPAC@localhost;

-- Permisos de la intra
GRANT ALTER,INSERT,UPDATE, DELETE, CREATE, DROP on  *   to userINTRA@localhost;

-- Permisos de dev
GRANT ALL on  *   to userINTRA@localhost;

-- Permisos para el indice (sphinx)
GRANT SELECT on  indice_busqueda  to indice@localhost;
