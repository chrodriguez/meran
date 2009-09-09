package C4::Modelo::CatEstructuraCatalogacionOpac;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_estructura_catalogacion_opac',

    columns => [
        idestcatopac => { type => 'serial', not_null => 1 },
        campo        => { type => 'character', length => 3, not_null => 1 },
        subcampo     => { type => 'character', length => 1, not_null => 1 },
        textpred     => { type => 'varchar', length => 255 },
        textsucc     => { type => 'varchar', length => 255 },
        separador    => { type => 'varchar', length => 3 },
        idencabezado => { type => 'integer', not_null => 1 },
        visible      => { type => 'integer', default => 1, not_null => 1 },
    ],

    primary_key_columns => [ 'idestcatopac' ],
);

use utf8;


sub getVisible{
    my ($self)=shift;

    return $self->visible;
}

sub setVisible{
    my ($self) = shift;
    my ($visible) = @_;
    $self->visible($visible);
}

sub getIdEncabezado{
    my ($self)=shift;

    return $self->idencabezado;
}

sub setIdEncabezado{
    my ($self) = shift;
    my ($idencabezado) = @_;
    $self->idencabezado($idencabezado);
}

sub getSeparador{
    my ($self)=shift;

    return $self->separador;
}

sub setSeparador{
    my ($self) = shift;
    my ($separador) = @_;
    $self->separador($separador);
}

sub getTextoPred{
    my ($self)=shift;

    return $self->textpred;
}

sub setTextoPred{
    my ($self) = shift;
    my ($textpred) = @_;
	utf8::encode($textpred);
    $self->textpred($textpred);
}

sub getTextoSucc{
    my ($self)=shift;

    return $self->textsucc;
}

sub setTextoSucc{
    my ($self) = shift;
    my ($textsucc) = @_;
	utf8::encode($textsucc);
    $self->textsucc($textsucc);
}

sub getSuCampo{
    my ($self)=shift;

    return $self->subcampo;
}

sub setSubCampo{
    my ($self) = shift;
    my ($subcampo) = @_;
    $self->subcampo($subcampo);
}

sub getCampo{
    my ($self)=shift;

    return $self->campo;
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
}

sub getIdEstCatOpac{
    my ($self)=shift;

    return $self->idestcatopac;
}


sub agregar{
    my ($self)=shift;

    my ($data_hash)=@_;
 	
	$self->setVisible($data_hash->{'visible'});
	$self->setIdEncabezado($data_hash->{'idencabezado'});
	$self->setSeparador($data_hash->{'separador'});
	$self->setTextoPred($data_hash->{'textoPredecesor'});
	$self->setTextoSucc($data_hash->{'textoSucesor'});
   	$self->setCampo($data_hash->{'campo'});
	$self->setSubCampo($data_hash->{'subcampo'});
    $self->save();
} 


sub modificar{
    my ($self)=shift;

    my ($data_hash)=@_;
 	
	$self->setVisible($data_hash->{'visible'});
	$self->setIdEncabezado($data_hash->{'idencabezado'});
	$self->setSeparador($data_hash->{'separador'});
	$self->setTextoPred($data_hash->{'textoPredecesor'});
	$self->setTextoSucc($data_hash->{'textoSucesor'});
   	$self->setCampo($data_hash->{'campo'});
	$self->setSubCampo($data_hash->{'subcampo'});

    $self->save();
} 

sub cambiarVisibilidad{
    my ($self)=shift;

    $self->setVisible(!$self->getVisible);
    $self->save();
}

sub eliminar{
    my ($self)=shift;

    $self->delete();
}



1;

