package C4::Modelo::PrefEstructuraCampoMarc;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_estructura_campo_marc',

    columns => [
        tagfield         => { type => 'character', length => 3, not_null => 1 },
        liblibrarian     => { type => 'character', length => 255, not_null => 1 },
        libopac          => { type => 'character', length => 255, not_null => 1 },
        repeatable       => { type => 'integer', default => '0', not_null => 1 },
        mandatory        => { type => 'integer', default => '0', not_null => 1 },
        authorised_value => { type => 'character', length => 10 },
    ],

    primary_key_columns => [ 'tagfield' ],
);


sub getTagfield{
    my ($self) = shift;
    return ($self->tagfield);
}

sub setTagfield{
    my ($self) = shift;
    my ($tagfield) = @_;
    $self->tagfield($tagfield);
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

sub getLibopac{
    my ($self) = shift;
    return ($self->libopac);
}

sub setLibopac{
    my ($self) = shift;
    my ($opac) = @_;
    $self->opac($opac);
}

sub getRepeatable{
    my ($self) = shift;
    return ($self->repeatable);
}

sub setRepeatable{
    my ($self) = shift;
    my ($repeatable) = @_;
    $self->repeatable($repeatable);
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


sub getAuthorised_value{
    my ($self) = shift;
    return ($self->authorised_value);
}

sub setAuthorised_value{
    my ($self) = shift;
    my ($authorised_value) = @_;
    $self->authorised_value($authorised_value);
}
1;

