package C4::Modelo::PrefEstructuraCampoMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_estructura_campo_marc',

    columns => [
        campo                   => { type => 'character', length => 3, not_null => 1 },
        liblibrarian            => { type => 'character', length => 255, not_null => 1 },
#         libopac          => { type => 'character', length => 255, not_null => 1 },
        repeatable              => { type => 'integer', default => '0', not_null => 1 },
        descripcion             => { type => 'character', length => 255, not_null => 1 },
        mandatory               => { type => 'integer', default => '0', not_null => 1 },
        indicador_primario      => { type => 'character', length => 255, default => '0', not_null => 1 },
        indicador_secundario    => { type => 'character', length => 255, default => '0', not_null => 1 },
    ],

    primary_key_columns => [ 'campo' ],
);


sub getCampo{
    my ($self) = shift;
    return ($self->campo);
}

sub setCampo{
    my ($self) = shift;
    my ($campo) = @_;
    $self->campo($campo);
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

sub getIndicadorPrimario{
    my ($self) = shift;

    if(!$self->indicador_primario =~ /\s+/){
        return C4::AR::Filtros::i18n('NO TIENE');
    }else{
        return (C4::AR::Utilidades::trim($self->indicador_primario));
    }
}

sub getIndicadorSecundario{
    my ($self) = shift;
    
    if(!$self->indicador_secundario =~ /\s+/){
        return C4::AR::Filtros::i18n('NO TIENE');
    }else{
        return (C4::AR::Utilidades::trim($self->indicador_secundario));
    }
}
# sub getLibopac{
#     my ($self) = shift;
#     return ($self->libopac);
# }
# 
# sub setLibopac{
#     my ($self) = shift;
#     my ($opac) = @_;
#     $self->opac($opac);
# }

sub getRepeatable{
    my ($self) = shift;
    return ($self->repeatable);
}

sub setRepeatable{
    my ($self) = shift;
    my ($repeatable) = @_;
    $self->repeatable($repeatable);
}

sub getDescripcion{
    my ($self) = shift;
    return ($self->descripcion);
}

sub setDescripcion{
    my ($self) = shift;
    my ($descripcion) = @_;
    $self->descripcion($descripcion);
}

sub getMandatory{
    my ($self) = shift;
    return ($self->mandatory);
}

sub setMandatory{
    my ($self) = shift;
    my ($mandatory) = @_;
    $self->mandatory($mandatory);
}


1;

