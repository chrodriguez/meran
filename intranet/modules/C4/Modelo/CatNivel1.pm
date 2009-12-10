package C4::Modelo::CatNivel1;

use strict;
use base qw(C4::Modelo::DB::Object::AutoBase2);
use utf8;


__PACKAGE__->meta->setup(
    table   => 'cat_nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 255, not_null => 1 },
        autor     => { type => 'integer', not_null => 0 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        cat_autor => {
            class      => 'C4::Modelo::CatAutor',
            column_map => { autor => 'id' },
            type       => 'one to one',
        },
    ],

);

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;

    my ($titulo) = @_;
    utf8::encode($titulo);
    $self->titulo($titulo);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}


sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    $self->autor($autor);
}




sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}

# ===================================================SOPORTE=====ESTRUCTURA CATALOGACION=================================================

# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================

sub getInvolvedCount{
 
    my ($self) = shift;

    my ($campo, $value)= @_;
    $campo = $campo->getReferente;
    my @filtros;

    push (@filtros, ( $campo => $value ) );

    my $cat_nivel1_count = C4::Modelo::CatNivel1::Manager->get_cat_nivel1_count( query => \@filtros );

    return ($cat_nivel1_count);
}

sub replaceBy{
    my ($self) = shift;

    my ($campo,$value,$new_value)= @_;
    
    my @filtros;

    push (  @filtros, ( $campo => { eq => $value},) );


    my $replaced = C4::Modelo::CatNivel1::Manager->update_cat_nivel1(   where => \@filtros,
                                                                        set   => { $campo => $new_value });
}

1;

