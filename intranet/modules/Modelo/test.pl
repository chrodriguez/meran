#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# use the Rose::DB classes that match your database 
use Usr_persona;
use Usr_persona::Manager;

my $products = Usr_persona::Manager->get_usr_persona();
foreach my $product (@$products) {
    print  $product->apellido . ' available for ' .
           $product->nombre . "\n";
}

print "\nDone.\n\n";

my $product;

#  $product = Usr_persona->new(
#                           apellido      => 'Rajoy',
#                           nombre	=> 'Gaspar',
#                          );
# 
#   $product->save;

  $product = Usr_persona->new(id_persona => 2);
  $product->load;
print $product->apellido."\n";
print $product->nombre."\n";

