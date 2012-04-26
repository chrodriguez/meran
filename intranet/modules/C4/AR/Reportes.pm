
package C4::AR::Reportes;


use strict;
no strict "refs";
use C4::Date;
use vars qw(@EXPORT_OK @ISA);
@ISA       = qw(Exporter);
@EXPORT_OK = qw(
  &getBusquedasDeUsuario 
  &getReportFilter
  &getItemTypes
  &getConsultasOPAC
  &getArrayHash
  &toXLS
  &registroDeUsuarios
  &altasRegistro
  &estantesVirtuales
  &listarItemsDeInventarioPorSigTop
  &listarItemsDeInventarioPorBarcode

);

sub altasRegistro {

	# FIXME Cambiar a Sphinx!
	# Filtrar por UI cuando se cambie a Sphinx

	my ( $ini, $cantR, $params, $total ) = @_;
	use C4::Modelo::CatRegistroMarcN3;

	my $f_inicio  = $params->{'date_begin'};
	my $f_fin     = $params->{'date_end'};
	my $item_type = $params->{'item_type'};

	my $dateformat = C4::Date::get_date_format();
	my @filtros;

	if ( C4::AR::Utilidades::validateString($f_inicio) ) {
		push(
			@filtros,
			(
				updated_at => {
					eq => format_date_in_iso( $f_inicio, $dateformat ),
					gt => format_date_in_iso( $f_inicio, $dateformat )
				}
			)
		);
	}

	if (   ( C4::AR::Utilidades::validateString($item_type) )
		&& ( $item_type ne 'ALL' ) )
	{
		push(
			@filtros,
			(
				'nivel2.marc_record' =>
				  { like => '%cat_ref_tipo_nivel3@' . $item_type . '%', }
			)
		);
	}

	if ( C4::AR::Utilidades::validateString($f_fin) ) {
		push(
			@filtros,
			(
				updated_at => {
					eq => format_date_in_iso( $f_fin, $dateformat ),
					lt => format_date_in_iso( $f_fin, $dateformat )
				}
			)
		);
	}

	my ($cat_registro_n3);
	if ( ( ( $cantR == 0 ) && ( $ini == 0 ) ) || ($total) ) {
		$cat_registro_n3 =
		  C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(
			query           => \@filtros,
			select          => ['*'],
			require_objects => [ 'nivel2', 'nivel1' ],
			sort_by         => 'id1 DESC',
		  );
	}
	else {
		$cat_registro_n3 =
		  C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(
			query           => \@filtros,
			select          => ['*'],
			limit           => $cantR,
			offset          => $ini,
			require_objects => [ 'nivel2', 'nivel1' ],
			sort_by         => 'id1 DESC',
		  );

	}

	## Retorna la cantidad total, sin paginar.

	## FIXME no anda el _count, tuve que poner la agregacion COUNT(*) en el campo id1.
	my ($cat_registro_n3_count) =
	  C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3(
		query           => \@filtros,
		select          => ['COUNT(*) AS agregacion_temp'],
		require_objects => [ 'nivel2', 'nivel1' ],
	  );

	$cat_registro_n3_count = $cat_registro_n3_count->[0]->{'agregacion_temp'};

#Este for es sólo para hacer el array de id1, para que se puedar usar armarInfoNivel1
	my @id1_array;

	foreach my $record (@$cat_registro_n3) {
		my $record_item_type = $record->nivel2->getTipoDocumento;
		my %hash_temp        = {};

		$hash_temp{'id1'}     = $record->getId1;
		$hash_temp{'marc_n3'} = $record;

		push( @id1_array, \%hash_temp );
	}

	$params->{'tipo_nivel3_name'} = $item_type;

	my ( $total_found_paginado, $resultsarray ) =
	  C4::AR::Busquedas::armarInfoNivel1( $params, @id1_array );

	return ( $cat_registro_n3_count, $resultsarray );

}

sub getReportFilter {
	my ($params) = @_;

	my $tabla_ref   = C4::Modelo::PrefTablaReferencia->new();
	my $alias_tabla = $params->{'alias_tabla'};

	$tabla_ref->createFromAlias($alias_tabla);

}

# FUNCIONES PARA ESTADISTICAS CON OpenFlashChart2
sub random_color {
	my @hex;
	for ( my $i = 0 ; $i < 64 ; $i++ ) {
		my ( $rand, $x );
		for ( $x = 0 ; $x < 3 ; $x++ ) {
			$rand = rand(255);
			$hex[$x] = sprintf( "%x", $rand );
			if ( $rand < 9 ) {
				$hex[$x] = "0" . $hex[$x];
			}
			if ( $rand > 9 && $rand < 16 ) {
				$hex[$x] = "0" . $hex[$x];
			}
		}
	}
	return "\#" . $hex[0] . $hex[1] . $hex[2];
}

sub next_colour {

	my ($position) = @_;

	my @colours_array = (
		"#330000", "#3333FF", "#669900", "#990000",
		"#FF9900", "#9966FF", "#FF9900", "#66FF66"
	);

	return ( @colours_array[$position] );

}

sub getItemTypes {
	my ( $params, $return_arrays ) = @_;

	use C4::Modelo::CatRegistroMarcN2;

	my ($cat_registro_n2) =
	  C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2(
		select => ['*'] );

	my @items;
	my @cant;
	my @colours;
	my @array_for_file_export;

	my %item_type_hash = {0};
	if ( ( $params->{'item_type'} ) && ( $params->{'item_type'} ne 'ALL' ) ) {
		foreach my $record (@$cat_registro_n2) {
			my $item_type = $record->getTipoDocumento;
			if ( ( $params->{'item_type'} eq $item_type ) ) {
				if ( !$item_type_hash{$item_type} ) {
					$item_type_hash{$item_type} = 0;
				}
				$item_type_hash{$item_type}++;
			}
		}
	}
	else {
		foreach my $record (@$cat_registro_n2) {
			my $item_type = $record->getTipoDocumento;
			if ( !$item_type_hash{$item_type} ) {
				$item_type_hash{$item_type} = 0;
			}
			$item_type_hash{$item_type}++;
		}
	}

	my $limit_of_view = 0;

	foreach my $item ( keys %item_type_hash ) {
		$item_type_hash{$item} = int $item_type_hash{$item};
		if ( $item_type_hash{$item} > 0 ) {
			push( @items,   $item );
			push( @cant,    $item_type_hash{$item} );
			push( @colours, next_colour( $limit_of_view++ ) );

			#HASH PARA EXPORTAR
			my %hash_temp;
			$hash_temp{'Cantidad'} = $item_type_hash{$item};
			$hash_temp{'Item'}     = $item;
			push( @array_for_file_export, \%hash_temp );
		}
	}

	sort_and_cumulate( \@items, \@colours, \@cant );

	if ($return_arrays) {
		return ( \@array_for_file_export, 1 );
	}

	return ( \@items, \@colours, \@cant );
}



sub listarItemsDeInventarioPorSigTop{
    my ($params_hash_ref) = @_;

    my @filtros;
    my @info_reporte;
   
    my $ini=$params_hash_ref->{'ini'};
    my $cantR=$params_hash_ref->{'cantR'};  
    
    my $signatura= $params_hash_ref->{'sigtop'};
    
    my $ui_signatura = $params_hash_ref->{'id_ui'};
    my $tipo_ui= $params_hash_ref->{'tipoUI'};

    my $campoRegMARC;

    C4::AR::Debug::debug($tipo_ui);

    if ($tipo_ui eq "Origen"){
        $campoRegMARC= 'dpref_unidad_informacion@'.$ui_signatura;
    } else {
        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_signatura;
    }
    
   
   
    my $db= C4::Modelo::CatRegistroMarcN3->new()->db();

    my $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  signatura => { eq => $signatura },
                                                                                                  marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                            limit   => $cantR,
                                                                                            offset  => $ini,
                                                                                            sort_by => ['signatura'],
                                                                          );

   my $cat_nivel3_array_ref_count = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3_count( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  signatura => { eq => $signatura },
                                                                                                  marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                     
                                                                          ); 

    
    my($result)= armarResult($cat_nivel3_array_ref);

    return ($cat_nivel3_array_ref_count, $result);
}


sub listarItemsDeInventarioEntreSigTops{
    my ($params_hash_ref) = @_;

    my @filtros;
    my @info_reporte;
   
    my $ini=$params_hash_ref->{'ini'};
    my $cantR=$params_hash_ref->{'cantR'};  
    
    my $desde_sigtop= $params_hash_ref->{'desde_signatura'};
    my $hasta_sigtop= $params_hash_ref->{'hasta_signatura'};
   
    my $ui_signatura = $params_hash_ref->{'id_ui'};
    my $tipo_ui= $params_hash_ref->{'tipoUI'};

    my $campoRegMARC;

    C4::AR::Debug::debug($tipo_ui);

    if ($tipo_ui eq "Origen"){
        $campoRegMARC= 'dpref_unidad_informacion@'.$ui_signatura;
    } else {
        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_signatura;
    }

    my $db= C4::Modelo::CatRegistroMarcN3->new()->db();

    my $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                    signatura => { between => [ $desde_sigtop, $hasta_sigtop ] },
                                                                                                    marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                                    
                                                                                            ], 
                                                                                            sort_by => ['signatura'],
                                                                                            limit   => $cantR,
                                                                                            offset  => $ini,
                                                                             ,
                                                                          );

   my $cat_nivel3_array_ref_count = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3_count( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                    signatura => { between => [ $desde_sigtop, $hasta_sigtop ] },
                                                                                                    marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                          ); 

    
    my($result)= armarResult($cat_nivel3_array_ref);


#     my($info_reporte)= armarInforme($cat_nivel3_array_ref);

    return ($cat_nivel3_array_ref_count, $result);
}



sub listarItemsDeInventarioPorBarcode{
    my ($params_hash_ref) = @_;

    my @filtros;
    my @info_reporte;

   
    my $ini=$params_hash_ref->{'ini'};
    my $cantR=$params_hash_ref->{'cantR'};  
    
    my $codigo_barra= $params_hash_ref->{'barcode'};
   
    my $ui_barcode = $params_hash_ref->{'id_ui'};
    my $tipo_ui= $params_hash_ref->{'tipoUI'};

    my $campoRegMARC;

    if ($tipo_ui eq "Origen"){
        $campoRegMARC= 'dpref_unidad_informacion@'.$ui_barcode;
    } else {
        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_barcode;
    }

    my $db= C4::Modelo::CatRegistroMarcN3->new()->db();

    my $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  codigo_barra => { eq => $codigo_barra },
                                                                                                  marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                            sort_by => ['codigo_barra'],
                                                                                            limit   => $cantR,
                                                                                            offset  => $ini,
                                                                              
                                                                          );

   my $cat_nivel3_array_ref_count = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3_count( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  codigo_barra => { eq => $codigo_barra },
                                                                                                  marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                       
                                                                          ); 


    
    my($result)= armarResult($cat_nivel3_array_ref);

    return ($cat_nivel3_array_ref_count, $result);
}


sub listarItemsDeInventarioEntreBarcodes{
    my ($params_hash_ref) = @_;

    my @filtros;
    my @info_reporte;

   
    my $ini=$params_hash_ref->{'ini'};
    my $cantR=$params_hash_ref->{'cantR'};  

    my $desde_barcode= $params_hash_ref->{'desde_barcode'};
    my $hasta_barcode= $params_hash_ref->{'hasta_barcode'};

    my $ui_barcode = $params_hash_ref->{'id_ui'};
    my $tipo_ui= $params_hash_ref->{'tipoUI'};

    my $campoRegMARC;

    if ($tipo_ui eq "Origen"){
        $campoRegMARC= 'dpref_unidad_informacion@'.$ui_barcode;
     } else {
        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_barcode;
    }


   
    my $db= C4::Modelo::CatRegistroMarcN3->new()->db();

    my $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                   codigo_barra => { between => [ $desde_barcode, $hasta_barcode ] },
                                                                                                   marc_record => { like => '%'.$campoRegMARC.'%' }
#                                                                                                    codigo_barra => { ge => $desde_barcode },
#                                                                                                    codigo_barra => { le =>  $hasta_barcode },
                                                                                            ], 
                                                                                            sort_by => ['codigo_barra'],
                                                                                            limit   => $cantR,
                                                                                            offset  => $ini,
                                                                                        
                                                                          );

   my $cat_nivel3_array_ref_count = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3_count( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                 codigo_barra => { between => [ $desde_barcode, $hasta_barcode ] }
                                                                                            ], 
                                                                                     
                                                                          ); 

    
    my($result)= armarResult($cat_nivel3_array_ref);
  

    return ($cat_nivel3_array_ref_count, $result);
}



sub consultaParaReporte {
    my ($params) = @_;

    my $db= C4::Modelo::CatRegistroMarcN3->new()->db();

    my $cat_nivel3_array_ref;

    if ($params->{'sigtop'}){
            
          my $ui_sigtop = $params->{'id_uisignatura'};
          my $tipo_ui= $params->{'tipoUISignatura'};

          my $campoRegMARC;

          if ($tipo_ui eq "Origen"){
              $campoRegMARC= 'dpref_unidad_informacion@'.$ui_sigtop;
           } else {
              $campoRegMARC= 'cpref_unidad_informacion@'.$ui_sigtop;
           }

        
           $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  signatura => { eq => $params->{'sigtop'} },
                                                                                                   marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                                  
                                                                                            ], 
                                                                                            sort_by => ['signatura'],
                                                                          );
    } elsif ($params->{'barcode'}){

          my $ui_barcode = $params->{'id_uibarcode'};
          my $tipo_ui= $params->{'tipoUIBarcode'};

          my $campoRegMARC;

          if ($tipo_ui eq "Origen"){
              $campoRegMARC= 'dpref_unidad_informacion@'.$ui_barcode;
          } else {
              $campoRegMARC= 'cpref_unidad_informacion@'.$ui_barcode;
          }

           $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                  codigo_barra => { eq => $params->{'barcode'} },
                                                                                                   marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                            sort_by => ['codigo_barra'],
                                                                          );

    } else {
           if ($params->{'desde_signatura'}){
                
                  my $ui_sigtop = $params->{'id_uisignatura'};
                  my $tipo_ui= $params->{'tipoUISignatura'};

                  my $campoRegMARC;

                  if ($tipo_ui eq "Origen"){
                      $campoRegMARC= 'dpref_unidad_informacion@'.$ui_sigtop;
                   } else {
                        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_sigtop;
                    }
  
                  my $orden = $params->{'sort'} || 'signatura';
                  $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                    signatura => { between => [ $params->{'desde_signatura'}, $params->{'hasta_signatura'} ] },
                                                                                                    marc_record => { like => '%'.$campoRegMARC.'%' }  
                                                                                            ], 
                                                                                            sort_by => ['signatura'],
                                                                          );
           } elsif ($params->{'desde_barcode'}){

                    my $ui_barcode = $params->{'id_uibarcode'};
                    my $tipo_ui= $params->{'tipoUIBarcode'};

                    my $campoRegMARC;

                    if ($tipo_ui eq "Origen"){
                        $campoRegMARC= 'dpref_unidad_informacion@'.$ui_barcode;
                    } else {
                        $campoRegMARC= 'cpref_unidad_informacion@'.$ui_barcode;
                    }

                    my $orden = $params->{'sort'} || 'codigo_barra';
                    $cat_nivel3_array_ref = C4::Modelo::CatRegistroMarcN3::Manager->get_cat_registro_marc_n3( 
                                                                                            db  => $db,
                                                                                            query => [  
                                                                                                   codigo_barra => { between => [ $params->{'desde_barcode'}, $params->{'hasta_barcode'} ] },
                                                                                                    marc_record => { like => '%'.$campoRegMARC.'%' }
                                                                                            ], 
                                                                                            sort_by => ['codigo_barra'],
                                                                                       
                                                                          );

           }


    }

    my $cant_total= scalar(@$cat_nivel3_array_ref);

    C4::AR::Debug::debug($cant_total);

    my ($info_reporte);

    my($info_reporte)= armarInforme($cat_nivel3_array_ref);

    return($cant_total,$info_reporte);
}



sub armarResult{

    my ($cat_nivel3_array_ref) = @_;

    my @result;

    foreach my $reg_nivel_3 (@$cat_nivel3_array_ref){
          my %hash_result;
          my $nivel1 = C4::AR::Nivel1::getNivel1FromId3($reg_nivel_3->getId3);
          my $nivel2 = C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

          $hash_result{'nivel1'}= $nivel1; 
          $hash_result{'nivel2'}=  @$nivel2[0];
          $hash_result{'nivel3'}= $reg_nivel_3;

          push(@result, \%hash_result);
    }

    return(\@result);
}


sub armarInforme{

    my ($cat_nivel3_array_ref) = @_;

    my @informe;

#     my @headers= ("Código de barra", "Signatura Topográfica", "Autor", "Título", "Editor", "Edición", "UI Origen", "UI Poseedora");

#     push(@informe,\@headers);

    foreach my $reg_nivel_3 (@$cat_nivel3_array_ref){
          my %hash_result;
          my $nivel1 = C4::AR::Nivel1::getNivel1FromId3($reg_nivel_3->getId3);
          my $nivel2 = C4::AR::Nivel2::getNivel2FromId1($nivel1->getId1);

          $hash_result{'codigo_barra'}= $reg_nivel_3->getCodigoBarra; 
          $hash_result{'signatura'}= $reg_nivel_3->getSignatura;
# @$nivel2[0]

          $hash_result{'autor'}= $nivel1->getAutor;
          $hash_result{'titulo'}= $nivel1->getTitulo;
          $hash_result{'editor'}= @$nivel2[0]->getEditor;
          $hash_result{'edicion'}= @$nivel2[0]->getEdicion." ".@$nivel2[0]->getAnio_publicacion ;
          $hash_result{'ui_origen'}= $reg_nivel_3->getId_ui_origen;
          $hash_result{'ui_poseedora'}=$reg_nivel_3->getId_ui_poseedora;       
              
          push(@informe, \%hash_result);
    }

    return(\@informe);
}


sub getEstantes {
    my ( $params, $return_arrays ) = @_;

    use C4::Modelo::CatContenidoEstante;
    use C4::Modelo::CatContenidoEstante::Manager;
    use C4::Modelo::CatEstante;
    
    my ($cat_estante) = C4::Modelo::CatEstante::Manager->get_cat_estante();

    my @items;
    my @cant;
    my @colours;
    my @array_for_file_export;
    my %estante_hash = {0};

    if ( (C4::AR::Utilidades::validateString($params->{'estante'})) && ($params->{'estante'} ne 'ALL') ){    
        foreach my $record (@$cat_estante) {
            my @filtros = ();
            my $estante = $record->getEstante;
            if ($record->getId == $params->{'estante'}){
                 push(
                 @filtros,
                 (
                      id_estante => {
                           eq => $record->getId,
                       }
                  )
                );
               $estante_hash{$estante} = C4::Modelo::CatContenidoEstante::Manager->get_cat_contenido_estante_count(
                        query => \@filtros,
               );
            }
        }
    }else{
        foreach my $record (@$cat_estante) {
            my @filtros = ();
            my $estante = $record->getEstante;
            push(
                 @filtros,
                 (
                      id_estante => {
                           eq => $record->getId,
                       }
                  )
                );
               $estante_hash{$estante} = C4::Modelo::CatContenidoEstante::Manager->get_cat_contenido_estante_count(
                        query => \@filtros,
               );
        }
    }

    my $limit_of_view = 0;

    foreach my $item ( keys %estante_hash ) {
        $estante_hash{$item} = int $estante_hash{$item};
        if ( $estante_hash{$item} > 0 ) {
            push( @items,   $item );
            push( @cant,    $estante_hash{$item} );
            push( @colours, next_colour( $limit_of_view++ ) );

            #HASH PARA EXPORTAR
            my %hash_temp;
            $hash_temp{'Cantidad'} = $estante_hash{$item};
            $hash_temp{'Item'}     = $item;
            push( @array_for_file_export, \%hash_temp );
        }
    }

    sort_and_cumulate( \@items, \@colours, \@cant );

    if ($return_arrays) {
        return ( \@array_for_file_export, 1 );
    }

    return ( \@items, \@colours, \@cant );
}







sub getConsultasOPAC {
	my ( $params, $return_arrays ) = @_;

	my $total       = $params->{'total'};
	my $registrados = $params->{'registrados'};
	my $tipo_socio  = $params->{'tipo_socio'};
	my $f_inicio    = $params->{'f_inicio'};
	my $f_fin       = $params->{'f_fin'};

	my $dateformat = C4::Date::get_date_format();
	my @filtros;
	use C4::Modelo::RepBusqueda::Manager;

	if ( !$total ) {
		if ($registrados) {
			push( @filtros, ( nro_socio => { ne => undef } ) );
		}
		else {
			push( @filtros, ( nro_socio => { eq => undef } ) );
		}
		if ( C4::AR::Utilidades::validateString($tipo_socio) ) {
			push( @filtros, ( categoria_socio => { eq => $tipo_socio } ) );
		}
		if ( C4::AR::Utilidades::validateString($f_inicio) ) {
			push(
				@filtros,
				(
					fecha => {
						eq => format_date_in_iso( $f_inicio, $dateformat ),
						gt => format_date_in_iso( $f_inicio, $dateformat )
					}
				)
			);
		}
		if ( C4::AR::Utilidades::validateString($f_fin) ) {
			push(
				@filtros,
				(
					fecha => {
						eq => format_date_in_iso( $f_fin, $dateformat ),
						lt => format_date_in_iso( $f_fin, $dateformat )
					}
				)
			);
		}

	}

	my ($rep_busqueda) = C4::Modelo::RepBusqueda::Manager->get_rep_busqueda(
		query    => \@filtros,
		group_by => ['categoria_socio'],
		select   => [
			'COUNT(categoria_socio) AS agregacion_temp', 'nro_socio',
			'categoria_socio'
		],
	);
	if ($return_arrays) {
		return ( $rep_busqueda, 0 );
	}

	my @items;
	my @cant;
	my @colors;
	my $cont = 0;
	foreach my $record (@$rep_busqueda) {
		push( @items,  $record->getCategoria_socio_report );
		push( @cant,   $record->agregacion_temp );
		push( @colors, next_colour( $cont++ ) );
	}

	sort_and_cumulate( \@items, \@colors, \@cant );
	return ( \@items, \@colors, \@cant, $rep_busqueda );
}

sub getArrayHash {

	my ( $function_name, $params ) = @_;
	my ( $items, $colours, $cant ) = &$function_name($params);

	my $i   = 0;
	my $max = scalar(@$items);
	my @data;

	for ( $i = 0 ; $i < $max ; $i++ ) {
		my %hash = {};
		$hash{'item'}  = $items->[$i];
		$hash{'cant'}  = $cant->[$i];
		$hash{'color'} = $colours->[$i];
		push( @data, \%hash );
	}

	return ( \@data );

}

sub sort_and_cumulate {

	my $items   = shift;
	my $colours = shift;
	my $cant    = shift;

	C4::AR::Utilidades::bbl_sort( $cant, $items, $colours );

	my $CUMULATIVE_LIMIT = 7;

	if ( scalar(@$items) > $CUMULATIVE_LIMIT ) {
		my $cant = 0;
		for ( my $i = $CUMULATIVE_LIMIT ; $i < scalar(@$items) ; $i++ ) {
			$cant += $cant->[$i];
			splice( @$cant,    $i, 1 );
			splice( @$items,   $i, 1 );
			splice( @$colours, $i, 1 );
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

sub getRepRegistroModificacion {
	my ( $id, $db ) = @_;

	$db = $db || C4::Modelo::RepRegistroModificacion->new()->db();

	my $rep_registro_modificacion_array_ref =
	  C4::Modelo::RepRegistroModificacion::Manager
	  ->get_rep_registro_modificacion(
		db    => $db,
		query => [ idModificacion => { eq => $id }, ]
	  );

	if ( scalar(@$rep_registro_modificacion_array_ref) > 0 ) {
		return ( $rep_registro_modificacion_array_ref->[0] );
	}
	else {
		return 0;
	}
}

sub titleByUser {
	my ($fileType)    = shift;
	my ($report_type) = shift;

	$report_type = $report_type || C4::AR::Filtros::i18n('reporte');
	$fileType    = $fileType    || 'null';

	my $username = C4::AR::Auth::getSessionNroSocio() || 'GUEST_USER_WARNING';
	my $title = $report_type . "_" . $username . "." . $fileType;

	return ($title);

}

sub toXLS {

	my ($data)             = shift;
	my ($is_array_of_hash) = shift;
	my ($sheet)            = shift;
	my ($report_type)      = shift;
	my ($filename)         = shift;

	use C4::Context;
	use Spreadsheet::WriteExcel;
	use C4::AR::Filtros;

	my $context     = new C4::Context;
	my $reports_dir = $context->config('reports_dir');

	$sheet = $sheet || C4::AR::Filtros::i18n('Resultado');
	$filename =
	  $filename
	  ? ( $report_type . "_" . $filename )
	  : ( titleByUser( 'xls', $report_type ) );

	my $path      = $reports_dir . '/' . $filename;

    C4::AR::Debug::debug($path);
    
	my $workbook  = Spreadsheet::WriteExcel->new($path);
	
    die "Problems creating new Excel file: $!" unless defined $workbook;

	my $worksheet = $workbook->add_worksheet($sheet);
	my $format    = $workbook->add_format();
	my $col;
	my $row;

	$worksheet->set_column( 0, 3, 20 );
	$worksheet->set_column( 1, 3, 20 );
	$worksheet->set_column( 4, 5, 20 );
	$worksheet->set_column( 7, 7, 20 );

	#Escribo los column titles :)

	my $header = $workbook->add_format();
	$header->set_font('Verdana');
	$header->set_align('top');
	$header->set_bold();
	$header->set_size(12);
	$header->set_color('blue');

	if ( !$is_array_of_hash ) {
		if ( scalar(@$data) ) {
			my $campos = $data->[0]->getCamposAsArray;
			my $x      = 0;

			foreach my $campo (@$campos) {
				$worksheet->write( 0, $x++, $campo, $header );
			}

			#FIN column titles
			$row = 1;
			foreach my $dato (@$data) {
				my $campos = $dato->getCamposAsArray;
				$col = 0;
				foreach my $campo (@$campos) {
					$worksheet->write( $row, $col,
						Encode::decode_utf8( $dato->{$campo} ), $format );
					$col++;
				}
				$row++;
			}
		}
	}
	else {

		my $x = 0;

		my $hash_temp = $data->[0];
		foreach my $key ( keys(%$hash_temp) ) {
			$worksheet->write( 0, $x++, $key, $header );
		}

		#FIN column titles
		$row = 1;
		foreach my $hash (@$data) {
			$col = 0;
			foreach my $key ( keys %$hash ) {
				$worksheet->write( $row, $col++,
					Encode::decode_utf8( $hash->{$key} ), $format );
			}
			$row++;
		}
	}

	return ( $path, $filename );
}

sub getBusquedasOPAC {

	my ( $params, $limit, $offset ) = @_;

	my $total       = $params->{'total'};
	my $registrados = $params->{'registrados'};
	my $tipo_socio  = $params->{'tipo_socio'};
	my $f_inicio    = $params->{'f_inicio'};
	my $f_fin       = $params->{'f_fin'};

	my $dateformat = C4::Date::get_date_format();
	my @filtros;

	use C4::Modelo::RepHistorialBusqueda::Manager;

	if ( !$total ) {
		if ($registrados) {
			push( @filtros, ( 'busqueda.socio.nro_socio' => { ne => undef } ) );
		}
		else {
			push( @filtros, ( 'busqueda.nro_socio' => { eq => undef } ) );
		}
		if (   ( C4::AR::Utilidades::validateString($tipo_socio) )
			&& ($registrados) )
		{
			push( @filtros,
			
#			FIXME: ver si anda! cambiado 16/05 porque ahora no esta mas el cod_categoria, esta el id. 
#				( 'usr_socio.cod_categoria' => { eq => $tipo_socio } ) );

                ( 'usr_socio.id_categoria' => { eq => $tipo_socio } ) );
		}
		if ( C4::AR::Utilidades::validateString($f_inicio) ) {
			push(
				@filtros,
				(
					fecha => {
						eq => format_date_in_iso( $f_inicio, $dateformat ),
						gt => format_date_in_iso( $f_inicio, $dateformat )
					}
				)
			);
		}
		if ( C4::AR::Utilidades::validateString($f_fin) ) {
			push(
				@filtros,
				(
					fecha => {
						eq => format_date_in_iso( $f_fin, $dateformat ),
						lt => format_date_in_iso( $f_fin, $dateformat )
					}
				)
			);
		}

	}

	my ($rep_busqueda);

	if ( ( $limit == 0 ) && ( $offset == 0 ) ) {

		($rep_busqueda) =
		  C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda(
			query => \@filtros,
			require_objects =>
			  [ 'busqueda', 'busqueda.socio', 'busqueda.socio.persona' ],
			select => [ '*', 'busqueda.*' ],
		  );
	}
	else {

		($rep_busqueda) =
		  C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda(
			query => \@filtros,
			require_objects =>
			  [ 'busqueda', 'busqueda.socio', 'busqueda.socio.persona' ],
			limit  => $limit,
			offset => $offset,
			select => [ '*', 'busqueda.*' ],
		  );
	}

	my ($rep_busqueda_count) =
	  C4::Modelo::RepHistorialBusqueda::Manager
	  ->get_rep_historial_busqueda_count(
		query           => \@filtros,
		require_objects => [ 'busqueda', 'busqueda.socio', 'busqueda.socio.persona' ],
		
	  );
	return ( $rep_busqueda_count, $rep_busqueda );
}

sub registroDeUsuarios {

	my ( $params, $limit, $offset, $total ) = @_;

	my $anio      = $params->{'year'};

	my $categoria = $params->{'category'};
	my $ui        = $params->{'ui'};
	my $name_from = $params->{'name_from'};
	my $name_to   = $params->{'name_to'};

	my $dateformat       = C4::Date::get_date_format();
	my $anio_fecha_start = "01/01/" . $anio;
	my $anio_fecha_end   = "12/31/" . $anio;
	my @filtros;

	use C4::Modelo::UsrSocio::Manager;

	if ($categoria) {
	
#		FIXME: ver si anda! cambiado 16/05 porque ahora no esta mas el cod_categoria, esta el id. 
#       push( @filtros, ( 'cod_categoria' => { eq => $categoria } ) );

		push( @filtros, ( 'id_categoria' => { eq => $categoria } ) );
	}
	if ($ui) {
		push( @filtros, ( 'id_ui' => { eq => $ui } ) );
	}
	if ( ( C4::AR::Utilidades::validateString($name_to) ) ) {
		push( @filtros,
			( 'persona.apellido' => { like => $name_to.'%', lt => $name_to } ) );
	}
	if ( ( C4::AR::Utilidades::validateString($name_from) ) ) {
		push( @filtros,
			( 'persona.apellido' => { like => $name_from.'%', gt => $name_from } ) );
	}
	if ( ($anio) && ( $anio =~ /^-?[\.|\d]*\Z/ ) ) {
		push(
			@filtros,
			(
				'fecha_alta' =>
				  { eq => $anio_fecha_start, gt => $anio_fecha_start }
			)
		);
		push(
			@filtros,
			(
				'fecha_alta' => { eq => $anio_fecha_end, lt => $anio_fecha_end }
			)
		);
	}

	my ($rep_busqueda);
	if ( ( ( $limit == 0 ) && ( $offset == 0 ) ) || ($total) ) {
		($rep_busqueda) = C4::Modelo::UsrSocio::Manager->get_usr_socio(
			query           => \@filtros,
			require_objects => ['persona', 'categoria'],
			select          => [ '*', 'persona.*' ],
		);
	}
	else {

		($rep_busqueda) = C4::Modelo::UsrSocio::Manager->get_usr_socio(
			query           => \@filtros,
			require_objects => ['persona', 'categoria'],
			select          => [ '*', 'persona.*' ],
			limit           => $limit,
			offset          => $offset,
		);
	}

	my ($rep_busqueda_count) =
	  C4::Modelo::UsrSocio::Manager->get_usr_socio_count(
		query           => \@filtros,
		require_objects => ['persona', 'categoria'],
	  );
	  
	  
	return ( $rep_busqueda_count, $rep_busqueda );

}

sub estantesVirtuales {

	my ( $id_estante ) = @_;

    use C4::Modelo::CatEstante;
    use C4::Modelo::CatEstante::Manager;
    use C4::Modelo::CatContenidoEstante;
    use C4::Modelo::CatContenidoEstante::Manager;

	my @filtros;
    my $resultsarray;
    
	push( @filtros, ( id => { eq => $id_estante } ) );
    
    $resultsarray = C4::Modelo::CatEstante::Manager->get_cat_estante(
                            query   => \@filtros,
                            
    );

	return ( $resultsarray );

}

sub getBusquedasDeUsuario {

    my ( $datos_busqueda, $ini, $cantR ) = @_;


    my $limit_pref          = C4::AR::Preferencias::getValorPreferencia('renglones') || 20;
    $cantR                  = $cantR || $limit_pref;

    my $nro_socio= $datos_busqueda->{'usuario'};
    
    my $categoria= $datos_busqueda->{'categoria'};
    my $interfaz= $datos_busqueda->{'interfaz'};
    my $valor= $datos_busqueda->{'valor'};
    my $fecha_inicio= $datos_busqueda->{'fecha_inicio'};
    my $fecha_fin= $datos_busqueda->{'fecha_fin'};
    my $statistics= $datos_busqueda->{'statistics'};
    my $orden= $datos_busqueda->{'orden'};


    my @filtros;
    my $resultsarray;

    my @filtro;
    
    if ($nro_socio){
         push(@filtro,('nro_socio' => {eq  => $nro_socio }));
    }
    if ($categoria){
         push(@filtro,('busqueda.categoria_socio' =>  {eq => $categoria} ));
    }
  
    if ($interfaz ne "Ambas" ){     
             push(@filtro,('tipo' => { eq => $interfaz}));
    }   

    if ($valor){
        push(@filtro, ('valor'  =>  { like => '% '.$valor.'%'}));
    }
   
    if ($fecha_inicio != 'Desde' && $fecha_fin != 'Hasta'){
        push( @filtro, and => [ 'busqueda.fecha' => { gt => $fecha_inicio, eq => $fecha_inicio },
                                'busqueda.fecha' => { lt => $fecha_fin, eq => $fecha_fin} ] ); 
    }

     push( @filtros,( and => [@filtro] ));
#     if ($statistics){
# 
#     }

    my $resultsarray = C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda( 
                                                                      query   => \@filtros,
                                                                      limit   => $cantR,
                                                                      offset  => $ini,
                                                                      require_objects => ['busqueda'],
                                                                      with_objects => [],
                                                                      select       => ['busqueda.*','rep_historial_busqueda.*'],
                                                                      sort_by => $orden,
                                                          );

   
    my ($rep_busqueda_count) = C4::Modelo::RepHistorialBusqueda::Manager->get_rep_historial_busqueda_count(
                                                                              query   => \@filtros,
                                                                              require_objects => ['busqueda'],
                                                                              with_objects => [],
                                                              
                                                                            );
                                                                            


    return ($resultsarray, $rep_busqueda_count);

}

=item
	Funcion que busca las reservas en circulacion
=cut
sub getReservasCirculacion {

    my ( $datos_busqueda, $ini, $cantR ) = @_;


    my $limit_pref 		= C4::AR::Preferencias::getValorPreferencia('renglones') || 20;
    $cantR          	= $cantR || $limit_pref;
 
    my $categoria 		= $datos_busqueda->{'categoriaSocio'};
    my $tipoReserva 	= $datos_busqueda->{'tipoReserva'};
    my $tipoDoc 		= $datos_busqueda->{'tipoDoc'};
    my $titulo 			= $datos_busqueda->{'titulo'};
    my $edicion 		= $datos_busqueda->{'edicion'};
    my $estadoReserva 	= $datos_busqueda->{'estadoReserva'};
    my $fecha_inicio 	= $datos_busqueda->{'fecha_inicio'};
    my $fecha_fin 		= $datos_busqueda->{'fecha_fin'};
    my $statistics 		= $datos_busqueda->{'statistics'};
    my $orden 			= $datos_busqueda->{'orden'};

    my @filtros;
    my $resultsarray;

    my @filtro;

    #OK
    if ($categoria){
         push(@filtros,('socio.id_categoria' =>  {eq => $categoria} ));
    }

#    if ($fecha_inicio != 'Desde' && $fecha_fin != 'Hasta'){
#        push( @filtro, and => [ 'busqueda.fecha' => { gt => $fecha_inicio, eq => $fecha_inicio },
#                                'busqueda.fecha' => { lt => $fecha_fin, eq => $fecha_fin} ] ); 
#    }

#     push( @filtros,( and => [@filtro] ));
#     if ($statistics){
# 
#     }

    my $resultsarray = C4::Modelo::RepHistorialCirculacion::Manager->get_rep_historial_circulacion( 
                                                                      query   => \@filtros,
                                                                      limit   => $cantR,
                                                                      offset  => $ini,
                                                                      require_objects   => ['socio'],
                                                                      # with_objects => [],
                                                                      select            => ['socio.*'],
                                                                      # sort_by => $orden,
                                                          );

   
    my ($rep_busqueda_count) = C4::Modelo::RepHistorialCirculacion::Manager->get_rep_historial_circulacion_count(
                                                                              # query   => \@filtros,
                                                                              require_objects => ['socio'],
                                                                              # with_objects => [],                                                           
                                                                            );
                                                                            


    return ($resultsarray, $rep_busqueda_count);

}

END { }    # module clean-up code here (global destructor)

1;
__END__
