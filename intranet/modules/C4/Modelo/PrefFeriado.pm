package C4::Modelo::PrefFeriado;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_feriado',

    columns => [
        id               => { type => 'serial', not_null => 1 },
        fecha            => { type => 'varchar', default => '0000-00-00', length => 10, not_null => 1 },
    ],

    primary_key_columns => [ 'id' ],
);

sub agregar{
    my ($self) = shift;
    my ($fecha,$status) = @_;

    $self->setFecha($fecha,$status);

}
sub getFecha{
    my ($self) = shift;
    my $dateformat = C4::Date::get_date_format();

    return (C4::Date::format_date($self->fecha,$dateformat));
}

sub setFecha{
    my ($self) = shift;
    my ($fecha,$status) = @_;

    if ($status eq "true"){
        $self->fecha($fecha);
        $self->save();
    }elsif ($status eq "false"){
        $self->delete();
    }
}
1;

