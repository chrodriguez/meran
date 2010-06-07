package C4::AR::Reportes;

use strict;
no strict "refs";
use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(

    &getReportFilter
    &getItemTypes
    &getConsultasOPAC
    &getArrayHash
    &toXLS
    
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


sub next_colour{

  my ($position) = @_;
  
  my @colours_array = ("#330000","#3333FF","#669900","#990000","#FF9900","#9966FF","#FF9900","#66FF66");
  
  return (@colours_array[$position]);
    

}
sub getItemTypes{
    my ($params) = @_;

    use C4::Modelo::CatRegistroMarcN2;

    my ($cat_registro_n2) = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(select => ['*']);

    my @items;
    my @cant;
    my @colours;

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

    my $limit_of_view = 0;
    
    foreach my $item ( keys %item_type_hash )
    {
        $item_type_hash{$item} = int $item_type_hash{$item};
        if ($item_type_hash{$item} > 0){
                push (@items, $item);
                push (@cant,$item_type_hash{$item});
                push (@colours, next_colour($limit_of_view++));
        }
    }

    sort_and_cumulate(\@items,\@colours,\@cant);
    
    return (\@items,\@colours,\@cant);
}

sub getConsultasOPAC{
    my ($params,$return_arrays) = @_;



    my $total       = $params->{'total'};
    my $registrados = $params->{'registrados'};
    my $tipo_socio  = $params->{'tipo_socio'};
    my $f_inicio    = $params->{'f_inicio'};
    my $f_fin       = $params->{'f_fin'};

    my $dateformat = C4::Date::get_date_format();
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
            push (@filtros, (fecha => {eq =>format_date_in_iso($f_inicio,$dateformat),gt => format_date_in_iso($f_inicio,$dateformat)}) );
        }
        if (C4::AR::Utilidades::validateString($f_fin)){
            push (@filtros, (fecha => {eq =>format_date_in_iso($f_fin,$dateformat),lt => format_date_in_iso($f_fin,$dateformat)}) );
        }
        
    }

    my ($rep_busqueda) = C4::Modelo::RepBusqueda::Manager->get_rep_busqueda(    query => \@filtros,
                                                                                group_by => ['categoria_socio'],
                                                                                select => ['COUNT(categoria_socio) AS agregacion_temp','nro_socio','categoria_socio'],
                                                                           );
    if ($return_arrays){
        return($rep_busqueda);
    }


    my @items;
    my @cant;
    my @colors;
    my $cont = 0;
    foreach my $record (@$rep_busqueda){
        push (@items,$record->getCategoria_socio_report);
        push (@cant,$record->agregacion_temp);
        push (@colors, next_colour($cont++));
    }

    sort_and_cumulate(\@items,\@colors,\@cant);
    return (\@items,\@colors,\@cant,$rep_busqueda);
}

sub getArrayHash{

    my ($function_name,$params) = @_;
    my ($items,$colours,$cant) = &$function_name($params);
    
    my $i = 0;
    my $max = scalar(@$items);
    my @data;
    
    for ($i=0;$i<$max;$i++){
        my %hash = {};
        $hash{'item'} = $items->[$i];
        $hash{'cant'} = $cant->[$i];
        $hash{'color'} = $colours->[$i];
        push (@data, \%hash);
    }

    return (\@data);

}

sub sort_and_cumulate{

    my $items = shift;
    my $colours = shift;
    my $cant = shift;
    
    
    C4::AR::Utilidades::bbl_sort($cant,$items,$colours);

    my $CUMULATIVE_LIMIT = 7;
    
    if (scalar(@$items)>$CUMULATIVE_LIMIT){
        my $cant = 0;
        for (my $i=$CUMULATIVE_LIMIT; $i<scalar(@$items); $i++){
            $cant+=$cant->[$i];
            splice(@$cant,$i,1);
            splice(@$items,$i,1);
            splice(@$colours,$i,1);
        }
        $items->[$CUMULATIVE_LIMIT] = C4::AR::Filtros::i18n("Otros");
        $cant->[$CUMULATIVE_LIMIT] += $cant;
        $colours->[$CUMULATIVE_LIMIT] = next_colour($CUMULATIVE_LIMIT);
    }
}



=head2 
sub getRepRegistroModificacion

Recupero el registro de modificacion pasado por parámetro
retorna un objeto o 0 si no existe
=cut
sub getRepRegistroModificacion{
    my ($id, $db) = @_;

    $db = $db || C4::Modelo::RepRegistroModificacion->new()->db();
    
    my $rep_registro_modificacion_array_ref = C4::Modelo::RepRegistroModificacion::Manager->get_rep_registro_modificacion(
                                                                        db => $db,    
                                                                        query => [ 
                                                                                    idModificacion => { eq => $id },
                                                                            ]
                                                                );

    if( scalar(@$rep_registro_modificacion_array_ref) > 0){
        return ($rep_registro_modificacion_array_ref->[0]);
    }else{
        return 0;
    }
}

sub titleByUser{    
    my ($fileType,$report_type) = shift;

    $report_type = $report_type || C4::AR::Filtros::i18n('reporte');
    $fileType = $fileType || 'null';
    
    my $username = C4::Auth::getSessionNroSocio() || 'GUEST_USER_WARNING';
    my $title = $report_type."_".$username.".".$fileType;
    
    return ($title);
  
}

sub toXLS{

    my ($data) = shift;
    my ($sheet) = shift;
    my ($report_type) = shift;
    my ($filename) = shift;

    use C4::Context;
    use Spreadsheet::WriteExcel;
    use C4::AR::Filtros;
    
    my $context = new C4::Context;
    my $reports_dir = $context->config('reports_dir');
    
    $sheet = $sheet || C4::AR::Filtros::i18n('Resultado');
    $filename = $filename?($report_type."_".$filename):(titleByUser('xls',$report_type));

    my $path = $reports_dir.'/'.$filename;
    my $workbook = Spreadsheet::WriteExcel->new($path);
    my $worksheet = $workbook->add_worksheet($sheet);
    my $format = $workbook->add_format();
    my $col;
    my $row;
    
    $worksheet->set_column(0, 3, 20);
    $worksheet->set_column(1, 3, 20);
    $worksheet->set_column(4, 5, 20);
    $worksheet->set_column(7, 7, 20);

    #Escribo los column titles :)

    my  $header = $workbook->add_format();
        $header->set_font('Verdana');
        $header->set_align('top');
        $header->set_bold();
        $header->set_size(12);
        $header->set_color('blue');

    my $campos = $data->[0]->getCamposAsArray;
    my $x = 0;
    foreach my $campo (@$campos){
        $worksheet->write(0, $x++, $campo,$header);
    }
    #FIN column titles
    $row = 1;
    foreach my $dato (@$data){
        my $campos = $dato->getCamposAsArray;
        $col = 0;
        foreach my $campo (@$campos){
            $worksheet->write($row, $col, $dato->{$campo}, $format);
            $col++;
        }
        $row++;
    }
    return ($path,$filename);
}


