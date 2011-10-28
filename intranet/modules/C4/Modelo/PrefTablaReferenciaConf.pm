package C4::Modelo::PrefTablaReferenciaConf;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_tabla_referencia_conf',

    columns => [
        id                  => { type => 'serial', overflow => 'truncate'},
        tabla               => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        campo               => { type => 'varchar', overflow => 'truncate', length => 20, not_null => 1 },
        campo_alias         => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        visible             => { type => 'varchar', overflow => 'truncate', length => 255},
    ],

    primary_key_columns => [ 'id' ],
);

use C4::Modelo::PrefTablaReferenciaConf::Manager;

sub getConf{
    my ($self) = shift;
    my ($tabla, $campo) = @_;


    my @filtros;

    push (@filtros, (campo => {eq => $campo}) );
    push (@filtros, (tabla => {eq => $tabla}) );

    my $configuarcion = C4::Modelo::PrefTablaReferenciaConf::Manager->get_pref_tabla_referencia_conf(  query => \@filtros,
#                                                                                     select    => ['id1'],
                                                                                  );

    if(scalar(@$configuarcion) > 0){
        return $configuarcion->[0];
    } else {
        return 0;
    }
}

sub getVisible{
    my ($self) = shift;

    return ($self->visible);
}

sub getCampoAlias{
    my ($self) = shift;

    return ($self->campo_alias);
}

1;

