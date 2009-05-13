package C4::Modelo::CatEstructuraCatalogacion;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_estructura_catalogacion',

    columns => [
        id                  => { type => 'serial', not_null => 1 },
        campo               => { type => 'character', length => 3, not_null => 1 },
        subcampo            => { type => 'character', length => 1, not_null => 1 },
        itemtype            => { type => 'varchar', length => 4, not_null => 1 },
        liblibrarian        => { type => 'varchar', length => 255, not_null => 1 },
        tipo                => { type => 'varchar', length => 255, not_null => 1 },
        referencia          => { type => 'integer', default => '0', not_null => 1 },
        nivel               => { type => 'integer', not_null => 1 },
        obligatorio         => { type => 'integer', default => '0', not_null => 1 },
        intranet_habilitado => { type => 'integer', default => '1' },
        visible             => { type => 'integer', default => 1, not_null => 1 },
        repetible           => { type => 'integer', default => 1},
        idinforef           => { type => 'integer', length => 11, not_null => 0 },
        idCompCliente       => { type => 'varchar', length => 255, not_null => 1 },
        fijo                => { type => 'integer', length => 1, not_null => 1 },  #modificable = 0 / no modificable = 1
    ],

    
    primary_key_columns => [ 'id' ],

    relationships =>
    [
        tipoItem => 
        {
            class       => 'C4::Modelo::CatRefTipoNivel3',
            key_columns => { itemtype => 'id_tipo_doc' },
            type        => 'one to one',
        },
    
        refCampo => 
        {
            class       => 'C4::Modelo::PrefEstructuraSubcampoMarc',
            key_columns => { campo => 'tagfield',
                            subcampo => 'tagsubfield' },
            type        => 'one to one',
        },

        infoReferencia => 
        {
            class       => 'C4::Modelo::PrefInformacionReferencia',
            key_columns => { idinforef=> 'idinforef' },
            type        => 'one to one',
        },
    ]

);


sub agregar{

    use Digest::MD5 qw(md5_hex);
    use C4::Modelo::PrefInformacionReferencia;
    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setCampo($data_hash->{'campo'});
    $self->setSubcampo($data_hash->{'subcampo'});
    $self->setItemType($data_hash->{'itemtype'}||'ALL');
    $self->setLiblibrarian($data_hash->{'liblibrarian'});
    $self->setTipo($data_hash->{'tipoInput'});
    $self->setReferencia($data_hash->{'referencia'});
    $self->setNivel($data_hash->{'nivel'});
    $self->setObligatorio($data_hash->{'obligatorio'});
#     $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
    $self->setIntranet_habilitado($self->getUltimoIntranetHabilitado($self->getItemType)+1 );
    $self->setVisible($data_hash->{'visible'});
    $self->setIdCompCliente(md5_hex(time()));
    $self->setFijo(0); #por defecto, todo lo que se ingresa como estructura del catalogo NO ES FIJO
    $self->setRepetible(1); 
    $self->save();

#     if($data_hash->{'referencia'}){
    if($self->tieneReferencia){
    #si tiene referencia....
        $data_hash->{'id_est_cat'}= $self->id;
        my $pref_temp = C4::Modelo::PrefInformacionReferencia->new(db => $self->db);
        $pref_temp->agregar($data_hash);

        $self->setIdInfoRef($pref_temp->getIdInfoRef);
        $self->save();
    }
} 

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;

    if (!$self->soyFijo){
        $self->setCampo($data_hash->{'campo'});
        $self->setSubcampo($data_hash->{'subcampo'});
        $self->setItemType($data_hash->{'itemtype'});
        $self->setLiblibrarian($data_hash->{'liblibrarian'});
        $self->setTipo($data_hash->{'tipoInput'});
        $self->setReferencia($data_hash->{'referencia'});
        $self->setNivel($data_hash->{'nivel'});
        $self->setObligatorio($data_hash->{'obligatorio'});
        $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
        $self->setVisible($data_hash->{'visible'});
    
        if($self->tieneReferencia){
            my $pref_temp = C4::Modelo::PrefInformacionReferencia->new(idinforef => $self->getIdInfoRef);
            $pref_temp->load(); 
            $pref_temp->modificar($data_hash);
        }
    
        $self->save();
    }

}

sub delete{
    my $self = $_[0]; # Copy, not shift

    if ($self->soyFijo){
    #NO ESTA PERMITIDO ELIMINAR UNA TUPLA QUE SEA FIJA
    }else{
        $self->borrarYOrdenar();
    }
}



sub borrarYOrdenar{

    my ($self)=shift;

    my $siguientes_catalogaciones = C4::Modelo::CatEstructuraCatalogacion::Manager->update_cat_estructura_catalogacion( 
                                                            set => [
                                                                    intranet_habilitado=> { sql => 'intranet_habilitado -1'},
                                                            ],
                                                            where => [
                                                                    intranet_habilitado => { gt => $self->getIntranet_habilitado },
#                                                                     or => [
#                                                                        and => [
#                                                                             itemtype=> { eq => $self->getItemType},
#                                                                             nivel=> { eq => $self->getNivel},
#                                                                        ],
#                                                                         and => [
#                                                                             itemtype=> { eq => 'ALL'},
                                                                            nivel=> { eq => $self->getNivel},
                                                                            fijo => { eq => 1},
#                                                                         ],
#                                                                     ],
                                                            ],
                                                         );

    $self->realDelete();
}

sub realDelete{

    my ($self)=shift;

    $self->SUPER::delete();

}


=item
indica si la estructura de catalogacion tiene (=1) o no (=0) informacion de referencia
=cut
sub tieneReferencia{
    my ($self)=shift;

    return $self->getReferencia;
}

sub bajarAnterior{
        
    my ($self)=shift;
    my ($itemtype) = @_;
    my $catalogaciones = C4::Modelo::CatEstructuraCatalogacion::Manager->update_cat_estructura_catalogacion( 
                                                            set => [
                                                                    intranet_habilitado=> $self->getIntranet_habilitado,
                                                            ],
                                                            where => [
                                                                    intranet_habilitado => { eq => $self->getIntranet_habilitado-1 },
#                                                                     or => [
#                                                                        and => [
#                                                                             itemtype=> { eq => $itemtype},
#                                                                             nivel=> { eq => $self->getNivel},
#                                                                        ],
#                                                                         and => [
#                                                                             itemtype=> { eq => 'ALL'},
#                                                                             nivel=> { eq => $self->getNivel},
# #                                                                             fijo => { eq => 1},
#                                                                         ],
#                                                                     ],
                                                                    nivel=> { eq => $self->getNivel},
                                                            ],
                                                         );
}

sub subirSiguiente{
        
    my ($self)=shift;
    my ($itemtype) = @_;
    my $catalogaciones = C4::Modelo::CatEstructuraCatalogacion::Manager->update_cat_estructura_catalogacion( 
                                                            set => [
                                                                    intranet_habilitado=> $self->getIntranet_habilitado,
                                                            ],
                                                            where => [
                                                                    intranet_habilitado => { eq => $self->getIntranet_habilitado+1 },
#                                                                     or => [
#                                                                        and => [
#                                                                             itemtype=> { eq => $itemtype},
#                                                                             nivel=> { eq => $self->getNivel},
#                                                                        ],
#                                                                         and => [
#                                                                             itemtype=> { eq => 'ALL'},
#                                                                             nivel=> { eq => $self->getNivel},
# #                                                                             fijo => { eq => 1},
#                                                                         ],
#                                                                     ],
                                                                     nivel=> { eq => $self->getNivel},

                                                            ],
                                                         );
}


=item
subirOrden
Sube el orden en la vista, del campo seleccionado.
=cut

sub subirOrden{
    my ($self)=shift;
    my ($itemtype) = @_;
    if (!($self->soyElPrimero)){
        $self->bajarAnterior();
        $self->setIntranet_habilitado($self->getIntranet_habilitado - 1);
        $self->save();
    }
}

=item
bajarOrden
Baja el orden en la vista, del campo seleccionado.
=cut
sub bajarOrden{

    my ($self)=shift;
    my ($itemtype) = @_;
    if (!($self->soyElUltimo($itemtype))){
        $self->subirSiguiente($itemtype);
        $self->setIntranet_habilitado($self->getIntranet_habilitado + 1);
        $self->save();
    }
}

sub getUltimoIntranetHabilitado{

    my ($self)=shift;
    my ($itemtype) = @_;
    my $catalogaciones_count = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion_count( 
                                                            query => [
                                                                    or => [
                                                                            itemtype=> { eq => $itemtype},
                                                                            itemtype=> { eq => 'ALL'},
                                                                    ],
                                                                    nivel=> { eq => $self->getNivel},
                                                                ],
                                                        );

    return ($catalogaciones_count);
}



sub ultimoDelTipo{

    my ($self)=shift;
    my ($itemType)=@_;
       my $mismo_tipo = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion( 
                                                            query => [
                                                                    or => [
                                                                            itemtype=> { eq => $itemType},
                                                                            itemtype=> { eq => 'ALL'},
                                                                    ],
                                                                    nivel=> { eq => $self->getNivel},
                                                                   ],
                                                            sort_by => ['intranet_habilitado DESC'],
                                                            );

    return ($self->getIntranet_habilitado == $mismo_tipo->[0]->getIntranet_habilitado);
}


sub primeroDelTipo{

    my ($self)=shift;
    my ($itemType)=@_;
       my $mismo_tipo = C4::Modelo::CatEstructuraCatalogacion::Manager->get_cat_estructura_catalogacion( 
                                                            query => [or => [
                                                                            itemtype=> { eq => $itemType},
                                                                            itemtype=> { eq => 'ALL'},
                                                                    ],
                                                                           
                                                                            nivel=> { eq => $self->getNivel},
                                                                     ],
                                                            sort_by => ['intranet_habilitado ASC'],
                                                            );

    return ($self->getIntranet_habilitado == $mismo_tipo->[0]->getIntranet_habilitado);
}
=item
Esta funcion retorna 1 si es el ultimo en el orden a mostrar segun intranet_habilitado
=cut
sub soyElUltimo{
    my ($self)=shift;
    my ($itemtype) = @_;
    return ( ($self->intranet_habilitado == $self->getUltimoIntranetHabilitado($self->getItemType)) 
                                                        && 
                                            ($self->ultimoDelTipo)
            );
}


sub soyElPrimero{
    my ($self)=shift;
    return (($self->intranet_habilitado == 1));
}
=item
Esta funcion retorna 1 si la tupla es fija (no se puede modificar) 0  si no es fijo (se puede modificar)
=cut
sub soyFijo{
    my ($self)=shift;

    return ($self->getFijo);
}

sub getFijo{
    my ($self)=shift;

    return $self->fijo;
}

sub setFijo{
    my ($self) = shift;
    my ($fijo) = @_;
    $self->fijo($fijo);
}

sub cambiarVisibilidad{

    my ($self)=shift;

    $self->setVisible(!$self->getVisible);
    $self->save();
}

sub defaultSort{
    return ("intranet_habilitado");
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getCampo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->campo));
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getRepetible{
    my ($self) = shift;
    return ($self->repetible);
}

sub setRepetible{
    my ($self) = shift;
    my ($repetible) = @_;
    $self->repetible($repetible);
}


sub getIdCompCliente{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->idCompCliente));
}

sub setIdCompCliente{
    my ($self) = shift;
    my ($IdCompCliente) = @_;
    $self->idCompCliente($IdCompCliente);
}

# FIXME hace falta esto?
sub setIdInfoRef{
    my ($self) = shift;
    my ($id_info_ref) = @_;
    
    $self->idinforef($id_info_ref);
}

sub getIdInfoRef{
    my ($self) = shift;
    return ($self->idinforef);
}

sub getSubcampo{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->subcampo));
}

sub setSubcampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

sub getTipo{
    my ($self) = shift;

    return (C4::AR::Utilidades::trim($self->tipo));
}
      

sub setTipo{
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
}
 
sub getItemType{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->itemtype));
}

sub setItemType{
    my ($self) = shift;
    my ($itemtype) = @_;
    $self->itemtype($itemtype);
}
      
sub getLiblibrarian{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->liblibrarian));
}

sub setLiblibrarian{
    my ($self) = shift;
    my ($liblibrarian) = @_;
    $self->liblibrarian($liblibrarian);
}
        
sub getReferencia{
    my ($self) = shift;
    return ($self->referencia);
}

sub setReferencia{
    my ($self) = shift;
    my ($referencia) = @_;
    $self->referencia($referencia);
}
       
sub getNivel{
    my ($self) = shift;
    return ($self->nivel);
}

sub setNivel{
    my ($self) = shift;
    my ($nivel) = @_;
    $self->nivel($nivel);
}
        
sub getObligatorio{
    my ($self) = shift;
    return ($self->obligatorio);
}

sub setObligatorio{
    my ($self) = shift;
    my ($obligatorio) = @_;
    $self->obligatorio($obligatorio);
}
       
sub getIntranet_habilitado{
    my ($self) = shift;
    return ($self->intranet_habilitado);
}

sub setIntranet_habilitado{
    my ($self) = shift;
    my ($intranet_habilitado) = @_;
    $self->intranet_habilitado($intranet_habilitado);
}


sub getVisible{
    my ($self) = shift;
    return ($self->visible);
}

sub setVisible{
    my ($self) = shift;
    my ($visible) = @_;
    $self->visible($visible);
}





1;

