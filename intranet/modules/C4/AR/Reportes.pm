package C4::AR::Reportes;

use strict;


use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(

    &getReportFilter
    &getItemTypes
    &getConsultasOPAC
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

sub getConsultasOPAC{
    my ($params) = @_;



    my $total       = $params->{'total'};
    my $registrados = $params->{'registrados'};
    my $tipo_socio  = $params->{'tipo_socio'};
    my $f_inicio    = $params->{'f_inicio'};
    my $f_fin       = $params->{'f_fin'};
    my @filtros;
    use C4::Modelo::RepBusqueda::Manager;
    
    if (!$total){
        if ($registrados){
            push (@filtros, (nro_socio => {ne =>undef}) );
        }else{
            push (@filtros, (nro_socio => {eq =>undef}) );
        }
        if (C4::AR::Utilidades::validateString($tipo_socio)){
            push (@filtros, (categoria_socio => {eq =>$tipo_socio}) );
        }
        if (C4::AR::Utilidades::validateString($f_inicio)){
            push (@filtros, (fecha => {eq =>$f_inicio,gt => $f_inicio}) );
        }
        if (C4::AR::Utilidades::validateString($f_fin)){
            push (@filtros, (fecha => {eq =>$f_fin,lt => $f_fin}) );
        }
        
    }

    my ($rep_busqueda) = C4::Modelo::RepBusqueda::Manager->get_rep_busqueda(    query => \@filtros,
                                                                                group_by => ['categoria_socio'],
                                                                                select => ['COUNT(categoria_socio) AS agregacion_temp','nro_socio','categoria_socio'],
                                                                           );

    my @items;
    my @cant;
    my @colors;
    foreach my $record (@$rep_busqueda){
        push (@items,$record->getCategoria_socio_report);
        push (@cant,$record->agregacion_temp);
        push (@colors, random_color());
    }

    return (\@items,\@colors,\@cant);
}