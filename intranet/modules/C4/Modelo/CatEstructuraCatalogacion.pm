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
        tipo                => { type => 'character', length => 5, not_null => 1 },
        referencia          => { type => 'integer', default => '0', not_null => 1 },
        nivel               => { type => 'integer', not_null => 1 },
        obligatorio         => { type => 'integer', default => '0', not_null => 1 },
        intranet_habilitado => { type => 'integer', default => '0' },
        visible             => { type => 'integer', default => 1, not_null => 1 },
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
    ]

);


sub agregar{

    use C4::Modelo::PrefInformacionReferencia;
    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setCampo($data_hash->{'campo'});
    $self->setSubCampo($data_hash->{'subcampo'});
    $self->setItemType($data_hash->{'itemtype'}||'ALL');
    $self->setLiblibrarian($data_hash->{'liblibrarian'});
    $self->setTipo($data_hash->{'tipoInput'});
    $self->setReferencia($data_hash->{'referencia'});
    $self->setNivel($data_hash->{'nivel'});
    $self->setObligatorio($data_hash->{'obligatorio'});
    $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
    $self->setVisible($data_hash->{'visible'});
    $self->save();
    $data_hash->{'id_est_cat'}=$self->id;
    my $pref_temp = C4::Modelo::PrefInformacionReferencia->new();
       $pref_temp->agregar($data_hash);

}

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setCampo($data_hash->{'campo'});
    $self->setSubCampo($data_hash->{'subcampo'});
    $self->setItemType($data_hash->{'itemtype'});
    $self->setLiblibrarian($data_hash->{'liblibrarian'});
    $self->setTipo($data_hash->{'tipo'});
    $self->setReferencia($data_hash->{'referencia'});
    $self->setNivel($data_hash->{'nivel'});
    $self->setObligatorio($data_hash->{'obligatorio'});
    $self->setIntranet_habilitado($data_hash->{'intranet_habilitado'});
    $self->setVisible($data_hash->{'visible'});

    $self->save();

}

=item
subirOrden
Sube el orden en la vista, del campo seleccionado.
=cut
sub subirOrden{

    my ($self)=shift;

    $self->setIntranet_habilitado($self->getIntranet_habilitado - 1);
    $self->save();
}

=item
bajarOrden
Baja el orden en la vista, del campo seleccionado.
=cut
sub bajarOrden{

    my ($self)=shift;

    $self->setIntranet_habilitado($self->getIntranet_habilitado + 1);
    $self->save();
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
    return ($self->campo);
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getSubCampo{
    my ($self) = shift;
    return ($self->subcampo);
}

sub setSubCampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}
      
sub getTipo{
    my ($self) = shift;
    return ($self->tipo);
}

sub setTipo{
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
}
 
sub getItemType{
    my ($self) = shift;
    return ($self->itemtype);
}

sub setItemType{
    my ($self) = shift;
    my ($itemtype) = @_;
    $self->itemtype($itemtype);
}
      
sub getLiblibrarian{
    my ($self) = shift;
    return ($self->liblibrarian);
}

sub setLiblibrarian{
    my ($self) = shift;
    my ($liblibrarian) = @_;
    $self->liblibrarian($liblibrarian);
}

sub getTipo{
    my ($self) = shift;
    return ($self->tipo);
}

sub setTipo{
    my ($self) = shift;
    my ($tipo) = @_;
    $self->tipo($tipo);
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

