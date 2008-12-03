#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# use the Rose::DB classes that match your database 
use Ref_paises;
use Ref_paises::Manager;
use Ref_provincias;
use Ref_provincias::Manager;


print "\n###################### Tabla Ref_paises: #############################\n\n\n:";
my $products = Ref_paises::Manager->get_ref_paises();
foreach my $product (@$products) {
    print  $product->nombre . ' available for ' .
           $product->codigo . "\n";
}

my $product;

#  $product = Ref_paises->new(
#                             nombre      => 'Alemania',
#                             nombre_largo      => 'Alemania Somnolienta',
#                             codigo	=> 68,
#                             iso => 'IS',
#                             iso3 => 'ISO',
#                          );
# 
#   $product->save;

  $product = Ref_paises->new(   iso => 'IS',   );
  $product->load;
print "\nNUEVO INGRESO, VIENDO...:.\n\n";
print $product->nombre."\n";
print $product->codigo."\n";


print "\n############################ FIN Ref_paises. ##############################\n\n";


print "\n###################### Tabla Ref_provincias: #############################:\n\n\n";
my $products = Ref_provincias::Manager->get_ref_provincias();
foreach my $product (@$products) {
    print  'NOMBRE: '.$product->NOMBRE."\n".
           'PROVINCIA: '.$product->PROVINCIA."\n".
           'PAIS: '.$product->PAIS . "\n";
}

my $product;

#  $product = Ref_provincias->new(
#                             NOMBRE      => 'Bs. AS.',
#                             PAIS      => 'BOLIVIA',
#                             PROVINCIA	=> 'BA',
#                          );
# 
#   $product->save;

  $product = Ref_provincias->new(   PROVINCIA => 'BA',   );
  $product->load;
print "\nNUEVO INGRESO, VIENDO...:.\n\n";
print $product->NOMBRE."\n";
print $product->PROVINCIA."\n";
print $product->PAIS."\n\n\n";

# $product->NOMBRE('JAJA');

$product->setNombre('JOJOJO');

print "NOMBRE CON GETTER:       ".$product->getNombre;


print "\n############################ FIN Ref_provincias. ##############################\n\n";

