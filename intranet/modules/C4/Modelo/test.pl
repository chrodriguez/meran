#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# use the Rose::DB classes that match your database 
use C4::Modelo::Ref_paises;
use C4::Modelo::Ref_paises::Manager;
use C4::Modelo::Ref_provincias;
use C4::Modelo::Ref_provincias::Manager;
use C4::Modelo::Usr_persona;
use C4::Modelo::Usr_persona::Manager;
use C4::Modelo::Usr_socios;
use C4::Modelo::Usr_socios::Manager;
use C4::Modelo::Sanction::Manager;
use C4::Modelo::Sanction;

# 
# print "\n###################### Tabla Ref_paises: #############################\n\n\n:";
# my $products = Ref_paises::Manager->get_ref_paises();
# foreach my $product (@$products) {
#     print  $product->getNombre . ' available for ' .
#            $product->getCodigo . "\n";
# }
# 
# my $product;
# 
# #  $product = Ref_paises->new(
# #                             nombre      => 'Alemania',
# #                             nombre_largo      => 'Alemania Somnolienta',
# #                             codigo	=> 68,
# #                             iso => 'IS',
# #                             iso3 => 'ISO',
# #                          );
# # 
# #   $product->save;
# 
#   $product = Ref_paises->new(   iso => 'IS',   );
#   $product->load;
# print "\nNUEVO INGRESO, VIENDO...:.\n\n";
# print $product->getNombre."\n";
# print $product->getCodigo."\n";
# 
# 
# print "\n############################ FIN Ref_paises. ##############################\n\n";
# 
# 
# print "\n###################### Tabla Ref_provincias: #############################:\n\n\n";
# $products = Ref_provincias::Manager->get_ref_provincias();
# foreach my $product (@$products) {
#     print  'NOMBRE: '.$product->getNombre."\n".
#            'PROVINCIA: '.$product->getProvincia."\n".
#            'PAIS: '.$product->getPais . "\n";
# }
# 
# 
# 
# #  $product = Ref_provincias->new(
# #                             NOMBRE      => 'Bs. AS.',
# #                             PAIS      => 'BOLIVIA',
# #                             PROVINCIA	=> 'BA',
# #                          );
# # 
# #   $product->save;
# 
#   $product = Ref_provincias->new(   PROVINCIA => 'BA',   );
#   $product->load;
# print "\nNUEVO INGRESO, VIENDO...:.\n\n";
# print $product->getNombre."\n";
# print $product->getProvincia."\n";
# print $product->getPais."\n\n\n";
# 
# # $product->NOMBRE('JAJA');
# 
# $product->setNombre('JOJOJO');
# 
# print "NOMBRE CON GETTER:       ".$product->getNombre;
# 
# 
# print "\n############################ FIN Ref_provincias. ##############################\n\n";
# 
# 
# 
# 
# 
# 
# 
# 
# 
# print "\n###################### Tabla Usr_persona: #############################:\n\n\n";
# $products = Usr_persona::Manager->get_ref_provincias();
# foreach my $product (@$products) {
#     print  'NOMBRE: '.$product->getNombre."\n".
#            'PROVINCIA: '.$product->getProvincia."\n".
#            'PAIS: '.$product->getPais . "\n";
# }
# 

print "\n\n\n\n\n\n\n\n\n";
# my $loader = Rose::DB::Object::Loader->new(
#                     db_dsn       => 'dbi:mysql:dbname=V3_newAspect_EINAR;host=localhost',
#                     db_username  => 'remote',
#                     db_password  => 'remoteHOST',
#                     db_options   => { AutoCommit => 1, ChopBlanks => 1 },
#                      );
# $loader->make_modules(  module_dir => "/usr/local/koha/intranet/modules/C4/Modelo/",
#                                          );
#  my $person = Sanction->new();
# 
#     Usr_persona::Manager->delete_usr_persona(where =>
#         [
#                                             id_socio    => { eq => 58987361 },] 
#                                             );
# 
#         $person = Sanction::Manager->get_sanctions();
#         foreach my $persona (@$person) {
#              print  'NOMBRE: '.$persona->sanctionnumber."\n".
#                      '************** END TUPLA **********'."\n";
#              print  'RESERVE NUMBER: '.$persona->reservenumber."\n".
#                     '************** END TUPLA **********'."\n";
#              $persona->reservenumber(902487421);
#              $persona->save();
#              print  'RESERVE NUMBER: '.$persona->reservenumber."\n".
#                      '************** END TUPLA **********'."\n";
# 
#         }




    Usr_persona::Manager->delete_usr_persona(all => 1);
#     Usr_socios::Manager->delete_usr_socios(all => 1);
	my $new = Usr_persona->new();
       my %data_hash;
        
        $data_hash{'nombre'} = "PEPITO NEW";
        $data_hash{'apellido'} = "PEREZ";
        $data_hash{'version_documento'} = 'C';
        $data_hash{'nro_documento'} = 31836547;
        $data_hash{'tipo_documento'} = 'DNI';
        $data_hash{'titulo'} = "SEÑOR";
        $data_hash{'otros_nombres'} = "NI IDEA QUE OTROS NOMBRES";
        $data_hash{'iniciales'} = "DGR";
        $data_hash{'calle'} = "DIAGONAL 73";
        $data_hash{'barrio'} = "MONDONGO";
        $data_hash{'ciudad'} = "LA PLATA";
        $data_hash{'telefono'} = "23423034";
        $data_hash{'email'} = 'gaspo53@gmail.com';
        $data_hash{'fax'} = "123874234";
        $data_hash{'msg_texto'} = "HOLA, ESTE ES EL MSG DE TEXTO";
        $data_hash{'alt_calle'} = "67 y 115";
        $data_hash{'alt_barrio'} = "MONDONGO";
        $data_hash{'alt_ciudad'} = "LA PLATA";
        $data_hash{'alt_telefono'} = "23423034";
        $data_hash{'nacimiento'} = "1985-10-18";
        $data_hash{'fecha_alta'} = "2008-10-12";
        $data_hash{'sexo'} = 'M';
        $data_hash{'telefono_laboral'} = "4234342";
        $data_hash{'cumple_condicion'} = '1';
        $new->agregar(\%data_hash);


        my %data_hash2;

        $data_hash2{'nro_socio'} = "893247247";
        $data_hash2{'id_ui'} = 'C';
        $data_hash2{'cod_categoria'} = 'C3';
        $data_hash2{'fecha_alta'} = "1985-12-12";
        $data_hash2{'expira'}="1985-12-14";
        $data_hash2{'flags'};
        $data_hash2{'password'} = "MIRA MIRA";
        $data_hash2{'last_login'}="1985-12-12";
        $data_hash2{'last_change_password'}="1985-12-12";;
        $data_hash2{'change_password'}="1985-12-12";;
        $data_hash2{'cumple_resuiqisto'}="1985-12-12";;
        $data_hash2{'id_estado'}=1;
        $new->convertirEnSocio(\%data_hash2);

    



        my $personas = Usr_persona::Manager->get_usr_persona();

            foreach my $person (@$personas) {
               print  'NOMBRE: '.$person->getNombre."\n".
                 'APELLIDO: '.$person->getApellido."\n".
                'SEXO: '.$person->getSexo . "\n";
            }
#     $person->setId_socio(58987361);
#     $person->setVersion_documento('Z');
#     $person->setNro_documento(10949341);
#     $person->setTipo_documento('DNI');
#     $person->setApellido('PEREZ');
#     $person->setNombre('JOJO');
#     $person->setIniciales('JP');
#     $person->setCalle('DIAGONAL 74');
#     $person->setCumple_condicion(1);


    

=item
print "\n###################### Tabla Usr_persona: #############################:\n\n\n";
my $products = Usr_persona::Manager->get_usr_persona();
foreach my $product (@$products) {
    print  'NOMBRE: '.$product->getNombre."\n".
           'APELLIDO: '.$product->getApellido."\n".
           'CALLE: '.$product->getCalle . "\n".
            '************** END TUPLA **********'."\n";
            
}
#   $product->save;
# 
#   $product = Ref_provincias->new(   PROVINCIA => 'BA',   );
#   $product->load;
# print "\nNUEVO INGRESO, VIENDO...:.\n\n";
# print $product->getNombre."\n";
# print $product->getProvincia."\n";
# print $product->getPais."\n\n\n";
# 
# # $product->NOMBRE('JAJA');
# 
# $product->setNombre('JOJOJO');
# 
# print "NOMBRE CON GETTER:       ".$product->getNombre;
# 
# 
# print "\n############################ FIN Ref_provincias. ##############################\n\n";
=cut
