package C4::AR::Reportes;

use strict;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(

    &getReportFilter
    &getItemTypes
);


sub getReportFilter{
    my ($params) = @_;

    my $tabla_ref = C4::Modelo::PrefTablaReferencia->new();
    my $alias_tabla = $params->{'alias_tabla'};

    $tabla_ref->createFromAlias($alias_tabla);

}


# FUNCIONES PARA ESTADISTICAS CON OpenFlashChart2
sub random_color {
  my @hex;
  for (my $i = 0; $i < 64; $i++) {
    my ($rand,$x);
    for ($x = 0; $x < 3; $x++) {
      $rand = rand(255);
      $hex[$x] = sprintf ("%x", $rand);
      if ($rand < 9) {
        $hex[$x] = "0" . $hex[$x];
      }
      if ($rand > 9 && $rand < 16) {
        $hex[$x] = "0" . $hex[$x];
      }
    }
  }
  return "\#" . $hex[0] . $hex[1] . $hex[2];
}

sub getItemTypes{

    use C4::Modelo::CatRefTipoNivel3::Manager;

    my ($tipos_item) = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(
                                                                                        group_by => ['id_tipo_doc'],
                                                                                        select => ['COUNT(*) AS agregacion_temp','id_tipo_doc','nombre'],
                                                                                        sort_by => ['id_tipo_doc ASC'],
                                                                                );

    use C4::Modelo::CatRegistroMarcN2;

    my ($cat_registro_n2) = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(select => ['*']);

    my @items;
    my @cant;
    my @colors;

    my %item_type_hash = {0};
    foreach my $record (@$cat_registro_n2){
            my $item_type = $record->getTipoDocumento;
            if (!$item_type_hash{$item_type}){
                $item_type_hash{$item_type} = 0;
            }
            $item_type_hash{$item_type}++;
    }

    foreach my $item ( keys %item_type_hash )
    {
        $item_type_hash{$item} = int $item_type_hash{$item};
        if ($item_type_hash{$item} > 0){
            push (@items, $item);
            push (@cant,$item_type_hash{$item});
            push (@colors, random_color());
        }
    }

    return (\@items,\@colors,\@cant);
}
