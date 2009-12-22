package C4::Modelo::CatRegistroMarcN1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n1',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        marc_record    => { type => 'text' },
    ],

    primary_key_columns => [ 'id' ]
);

sub getId1{
    my ($self)  = shift;

    return $self->id;
}

sub getMarcRecord{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->marc_record));
}

sub setMarcRecord{
    my ($self)          = shift;
    my ($marc_record)   = @_;

    $self->marc_record($marc_record);
}

sub agregar{
    my ($self)          = shift;
    my ($marc_record)   = @_;


    $self->setMarcRecord($marc_record);
    $self->save();
}

sub modificar{
    my ($self)           = shift;
    my ($marc_record)    = @_;

    $self->setMarcRecord($marc_record);

    $self->save();
}


sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    my ($nivel2) = C4::AR::Nivel2::getNivel2FromId1($self->getId1(), $self->db);

    foreach my $n2 (@$nivel2){
      $n2->eliminar();
    }

    $self->delete();    
}


sub getTitulo{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
#     C4::AR::Debug::debug("CatRegistroMarcN1 => titulo ".$marc_record->subfield("245","a")); 

    return $marc_record->subfield("245","a");
}

sub getAutorObject{
    my ($self)      = shift;
    
    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    
    #obtengo la referencia al autor
    my $ref_autor   = $marc_record->subfield("110","a");
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($ref_autor);

    my $autor = C4::AR::Referencias::getAutorObject($ref);

    if(!$autor){
        C4::AR::Debug::debug("CatRegistroMarcN1 => getAutorObject()=> EL OBJECTO (ID) AUTOR NO EXISTE");
        $autor = C4::Modelo::CatAutor->new();
    }

    return ($autor);
}

=head2 sub getAutor
  Devuelve solo el completo del autor
=cut
sub getAutor{
    my ($self)      = shift;
    
    my $autor = $self->getAutorObject();

    return ($autor->getCompleto());
}

=head2 sub toMARC

=cut
sub toMARC{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 2
    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'} = '1';
    $params->{'id_tipo_doc'} = 'ALL';
    my $MARC_result_array   = &C4::AR::Catalogacion::marc_record_to_meran_por_nivel($marc_record, $params);


#     my $MARC_result_array   = &C4::AR::Catalogacion::marc_record_to_meran($marc_record);

#     foreach my $m (@$MARC_result_array){
#         C4::AR::Debug::debug("campo => ".$m->{'campo'});
#         foreach my $s (@{$m->{'subcampos_array'}}){
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'subcampo'});        
#             C4::AR::Debug::debug("liblibrarian => ".$s->{'liblibrarian'});        
#         }
#     }

    return ($MARC_result_array);
}


=head2 sub getGrupos
    Recupero todos los grupos del nivel 1.
    Retorna la referencia a un arreglo de objetos
=cut
sub getGrupos {
    my ($self) = shift;

    #recupero todos los grupos de nivel 1 
    my ($nivel2_object_array) = C4::Modelo::CatRegistroMarcN2::Manager->get_cat_registro_marc_n2( 
                                                                        query => [ id => { eq => $self->getId1 } ]
                                                                   );
    return $nivel2_object_array;
}

=head2 sub tienePrestamos
    Verifica si el nivel 1 pasado por parametro tiene ejemplares con prestamos o no
=cut
sub tienePrestamos{
    my ($self) = shift;

    my $cant = 0;
    #recupero todos los grupos del nivel 1
    my ($nivel2_object_array) = $self->getGrupos();

    #recorro los id2 del nivel 1 para verificar si tienen prestamos o no 
    foreach my $nivel2 (@$nivel2_object_array){
        $cant = C4::AR::Prestamos::getCountPrestamosDeGrupo($nivel2->getId2);
        if($cant > 0){
            last;
        }

    }

    return ($cant > 0)?1:0;
}

sub getInvolvedCount{

    my ($self) = shift;

    my ($tabla, $value)= @_;
    my @filtros;
    my $table_name = $tabla->meta->table;

    my $filter_string = $table_name."@".$value;

    push (@filtros, ( marc_record => {like => '%'.$filter_string.'%'} ) );

    my $cat_registro_marc_n1_count = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1_count( query => \@filtros );
# die;
    return ($cat_registro_marc_n1_count);
}


sub getReferenced{

    my ($tabla, $value)= @_;
    my @filtros;
    my $table_name = $tabla->meta->table;

    my $filter_string = $table_name.'@'.$value;

    push (@filtros, ( marc_record => {like => '%'.$filter_string.'%'} ) );

    my $cat_registro_marc_n1 = C4::Modelo::CatRegistroMarcN1::Manager->get_cat_registro_marc_n1( query => \@filtros );
    return ($cat_registro_marc_n1);
}


# DEPRECATEDD
# actualizar segun tablas nuevas
=item
sub agregarDesdeMARC {

   my ($self)=shift;
    my ($marc)=@_;
    
    #Autor
    my $autor = $marc->subfield("100","a");
    if ($autor){
        $autor =~ s/\.//; #Saco los puntos
        my $refAutores = C4::AR::Referencias::obtenerAutoresLike($autor);
        if($refAutores) { #Se encontro una referencia al autor
            $self->setAutor($refAutores->[0]->getId);
        }
        else{ #Hay que crear el autor
                my $autoTemp = C4::Modelo::CatAutor->new();
                $autoTemp->setCompleto($autor);
                my @personal = split(/,\s/, $autor); #Divido por ,+espacio
                if ($personal[0]){$autoTemp->setApellido($personal[0]);}
                if ($personal[1]){$autoTemp->setNombre($personal[1]);}
                $autoTemp->save;
                $self->setAutor($autoTemp->getId);
        }
    }

    C4::AR::Debug::debug("agregarDesdeMARC => Autor => ".$autor);

    #Titulo
    my $titulo = $marc->subfield("245","a");
    $self->setTitulo($titulo);
    C4::AR::Debug::debug("agregarDesdeMARC => Autor => ".$titulo);
    $self->save();

    C4::AR::Debug::debug("agregarDesdeMARC => Se guarda el nivel 1 ");

    use C4::Modelo::CatNivel1Repetible;
    my $arrayNivel1Repetibles;

    my $id1 = $self->getId1;
     my ($arrayNivel1Repetibles)= C4::AR::EstructuraCatalogacionBase::getSubCampos(1); #Todos los campos MARC del nivel 1

    #Se guardan los datos en Nivel 1 repetibles
    foreach my $infoNivel1  (@$arrayNivel1Repetibles){

        my $campo = $infoNivel1->getCampo;
        my $subcampo = $infoNivel1->getSubcampo;
        if (!((($campo eq "100") || ($campo eq "245"))&&($subcampo eq "a"))){ # si es ni titulo ni autor
            my $datoRepetible=$marc->subfield($campo,$subcampo);

            if($datoRepetible){
                my $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
                $nivel1Repetible->setId1($id1);
                $nivel1Repetible->setCampo($campo);
                $nivel1Repetible->setSubcampo($subcampo);
                $nivel1Repetible->dato($datoRepetible);
                $nivel1Repetible->save();
               C4::AR::Debug::debug("agregarDesdeMARC => Se guarda el nivel 1 repetible => ".$campo." - ".$subcampo);
            }
        }
        }

          C4::AR::Debug::debug("agregarDesdeMARC => Se va a guardar el nivel 2");

        my $nivel2 = C4::Modelo::CatNivel2->new(db => $self->db);
        $nivel2->agregarDesdeMARC($id1,$marc);
}
=cut


# sub toMARC{
#     my ($self)      = shift;
# 
#     my %hash;
#     my @marc_array;
# 
#     $hash{'campo'}      = '110';
#     $hash{'subcampo'}   = 'a';
#     $hash{'header'}     = "NO SE";
#     $hash{'dato'}       = $self->getAutorObject()->getCompleto();
#     $hash{'id1'}        = $self->getId1;
#     my $estructura      = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($hash{'campo'}, $hash{'subcampo'});
# 
#     if($estructura){
#         $hash{'liblibrarian'}   = $estructura->getLiblibrarian;
#     }
# 
#     push (@marc_array, \%hash);
#     my %hash;
# 
#     $hash{'campo'}      = '245';
#     $hash{'subcampo'}   = 'a';
#     $hash{'header'}     = "NO SE";
#     $hash{'dato'}       = $self->getTitulo();
#     $hash{'id1'}        = $self->getId1;
#     my $estructura      = C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($hash{'campo'}, $hash{'subcampo'});
# 
#     if($estructura){
#         $hash{'liblibrarian'} = $estructura->getLiblibrarian;
#     }
# 
#     push (@marc_array, \%hash);
#     
#     return (\@marc_array);
# }

1;

