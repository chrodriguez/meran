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
    my ($params) = @_;

    use C4::Modelo::CatRegistroMarcN2;

    my ($cat_registro_n2) = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(select => ['*']);

    my @items;
    my @cant;
    my @colors;

    my %item_type_hash = {0};
    if ( ($params->{'item_type'}) && ($params->{'item_type'} ne 'ALL') ){
        foreach my $record (@$cat_registro_n2){
            my $item_type = $record->getTipoDocumento;
            if (($params->{'item_type'} eq $item_type)){
                if (!$item_type_hash{$item_type}){
                    $item_type_hash{$item_type} = 0;
                }
                $item_type_hash{$item_type}++;
            }
        }
    }else{
        foreach my $record (@$cat_registro_n2){
            my $item_type = $record->getTipoDocumento;
            if (!$item_type_hash{$item_type}){
                $item_type_hash{$item_type} = 0;
            }
            $item_type_hash{$item_type}++;
        }
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
