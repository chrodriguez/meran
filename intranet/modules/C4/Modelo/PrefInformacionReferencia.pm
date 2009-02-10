package C4::Modelo::PrefInformacionReferencia;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_informacion_referencia',

    columns => [
        idinforef  => { type => 'serial', not_null => 1 },
        idestcat   => { type => 'integer', not_null => 1 },
        referencia => { type => 'varchar', length => 255, not_null => 1 },
        orden      => { type => 'varchar', length => 255, not_null => 1 },
        campos     => { type => 'varchar', length => 255, not_null => 1 },
        separador  => { type => 'varchar', length => 3 },
    ],

    primary_key_columns => [ 'idinforef' ],
    
     relationships =>
    [
        tipoItem => 
        {
            class       => 'C4::Modelo::CatEstructuraCatalogacion',
            key_columns => { idinforef => 'idestcat' },
            type        => 'one to one',
        },
    ],

);

sub agregar{

    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setIdEstCat($data_hash->{'id_est_cat'});
    $self->setReferencia($data_hash->{'tabla'});
    $self->setOrden($data_hash->{'orden'}||'ALL');
    $self->setCampos($data_hash->{'campos'});
    $self->setSeparador($data_hash->{'separador'});

    $self->save();
}

sub modificar{

    my ($self)=shift;
    my ($data_hash)=@_;

    $self->setIdEstCat($data_hash->{'id_est_cat'});
    $self->setReferencia($data_hash->{'tabla'});
    $self->setOrden($data_hash->{'orden'}||'ALL');
    $self->setCampos($data_hash->{'campos'});
    $self->setSeparador($data_hash->{'separador'});

    $self->save();
}

sub createFromAlias{

    use C4::Modelo::CatAutor;
    
    my ($self)=shift;
    my $classAlias = shift;
    
    my $autorTemp = C4::Modelo::CatAutor->new();

    return ($autorTemp->createFromAlias($classAlias));
}



sub getIdEstCat{
    my ($self) = shift;
    return ($self->idestcat);
}

sub setIdEstCat{
    my ($self) = shift;
    my ($idestcat) = @_;
    $self->idestcat($idestcat);
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

sub getOrden{
    my ($self) = shift;
    return ($self->orden);
}

sub setOrden{
    my ($self) = shift;
    my ($orden) = @_;
    $self->orden($orden);
}

sub getCampos{
    my ($self) = shift;
    return ($self->campos);
}

sub setCampos{
    my ($self) = shift;
    my ($campos) = @_;
    $self->campos($campos);
}

sub getSeparador{
    my ($self) = shift;
    return ($self->separador);
}

sub setSeparador{
    my ($self) = shift;
    my ($separador) = @_;
    $self->separador($separador);
}

1;

