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

    my @items;
    my @cant;
    my @colors;
    foreach my $item (@$tipos_item){
        push (@items, $item->nombre." (".$item->id_tipo_doc.")");
        push (@cant, int ($item->agregacion_temp+rand(100)));
        push (@colors, random_color());
    }
    return (\@items,\@colors,\@cant);
}
