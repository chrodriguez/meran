package C4::Modelo::PermCatalogo;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'perm_catalogo',

    columns => [
        id_persona => { type => 'integer', length => 11, not_null => 1 }, 
        ui  => { type => 'varchar', length => 4, not_null => 1 }, 
        tipo_documento => { type => 'varchar', length => 4, not_null => 1 }, 
        datos_nivel1 => { type => 'varchar', length => 8, not_null => 1 },
        datos_nivel2 => { type => 'varchar', length => 8, not_null => 1 },
        datos_nivel3 => { type => 'varchar', length => 8, not_null => 1 },
        estantes_virtuales => { type => 'varchar', length => 8, not_null => 1 },
        estructura_catalogacion_n1 => { type => 'varchar', length => 8, not_null => 1 },
        estructura_catalogacion_n2 => { type => 'varchar', length => 8, not_null => 1 },
        estructura_catalogacion_n3 => { type => 'varchar', length => 8, not_null => 1 },
        tablas_de_refencia => { type => 'varchar', length => 8, not_null => 1 },
        control_de_autoridades => { type => 'varchar', length => 8, not_null => 1 },
        id => { type => 'integer', length => 11, not_null => 1 }
    ],

    primary_key_columns => [ 'id' ],

    unique_key => [ 'id' ],
);


sub getId_persona{
    my ($self) = shift;
    return ($self->id_persona);
}

sub setId_persona{
    my ($self) = shift;
    my ($id_persona) = @_;
    $self->id_persona($id_persona);
}

sub getUI{
    my ($self) = shift;
    return ($self->ui);
}

sub setUI{
    my ($self) = shift;
    my ($ui) = @_;
    $self->ui($ui);
}

sub getTipo_documento{
    my ($self) = shift;
    return ($self->tipo_documento);
}

sub setTipo_documento{
    my ($self) = shift;
    my ($tipo_documento) = @_;
    $self->tipo_documento($tipo_documento);
}

sub getDatos_nivel1{
    my ($self) = shift;
    return ($self->datos_nivel1);
}

sub setDatos_nivel1{
    my ($self) = shift;
    my ($datos_nivel1) = @_;
    $self->datos_nivel1($datos_nivel1);
}

sub getDatos_nivel2{
    my ($self) = shift;
    return ($self->datos_nivel2);
}

sub setDatos_nivel2{
    my ($self) = shift;
    my ($datos_nivel2) = @_;
    $self->datos_nivel2($datos_nivel2);
}

sub getDatos_nivel3{
    my ($self) = shift;
    return ($self->datos_nivel3);
}

sub setDatos_nivel3{
    my ($self) = shift;
    my ($datos_nivel3) = @_;
    $self->datos_nivel3($datos_nivel3);
}
   
sub getEstantes_virtuales{
    my ($self) = shift;
    return ($self->estantes_virtuales);
}

sub setEstantes_virtuales{
    my ($self) = shift;
    my ($estantes_virtuales) = @_;
    $self->estantes_virtuales($estantes_virtuales);
}
  

sub getEstructura_catalogacion_n1{
    my ($self) = shift;
    return ($self->estructura_catalogacion_n1);
}

sub setEstructura_catalogacion_n1{
    my ($self) = shift;
    my ($estructura_catalogacion_n1) = @_;
    $self->estructura_catalogacion_n1($estructura_catalogacion_n1);
}

sub getEstructura_catalogacion_n2{
    my ($self) = shift;
    return ($self->estructura_catalogacion_n2);
}

sub setEstructura_catalogacion_n2{
    my ($self) = shift;
    my ($estructura_catalogacion_n2) = @_;
    $self->estructura_catalogacion_n2($estructura_catalogacion_n2);
}

sub getEstructura_catalogacion_n3{
    my ($self) = shift;
    return ($self->estructura_catalogacion_n3);
}

sub setEstructura_catalogacion_n3{
    my ($self) = shift;
    my ($estructura_catalogacion_n3) = @_;
    $self->estructura_catalogacion_n3($estructura_catalogacion_n3);
}
 
sub getTablas_de_referencia{
    my ($self) = shift;
    return ($self->tablas_de_refencia);
}

sub setTablas_de_referencia{
    my ($self) = shift;
    my ($tablas_de_refencia) = @_;
    $self->tablas_de_refencia($tablas_de_refencia);
}

sub getControl_de_autoridades{
    my ($self) = shift;
    return ($self->control_de_autoridades);
}

sub setControl_de_autoridades{
    my ($self) = shift;
    my ($control_de_autoridades) = @_;
    $self->control_de_autoridades($control_de_autoridades);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

# sub setId{
#     my ($self) = shift;
#     my ($id) = @_;
#     $self->control_de_autoridades($control_de_autoridades);
# }




1;

