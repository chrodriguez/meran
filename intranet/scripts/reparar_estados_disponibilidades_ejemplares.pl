#!/usr/bin/perl

use C4::Modelo::CatRegistroMarcN3;
use C4::Modelo::CatRegistroMarcN3::Manager;
use MARC::Record;

my $nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( query => \@filtros ); 

foreach my $n3 (@$nivel3_array_ref){

  my $marc_record_base    = MARC::Record->new_from_usmarc($n3->getMarcRecord());
  # ACA HAY QUE OBTENER EL ESTADO (995,e), LA DISPONIBILIDAD (995,o) Y TRANFORMAR EL ID POR EL CÓDIGO

  my $dato = C4::AR::Catalogacion::_procesar_referencia($field->tag, $sub_campo, $dato, $n3->nivel2->getTipoDocumento);
  $marc_record_base->field($field->tag)->update( $sub_campo => $dato );

}

1;