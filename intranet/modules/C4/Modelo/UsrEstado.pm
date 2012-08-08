package C4::Modelo::UsrEstado;

# this class IS a "Usr_persona::DB::Object" 
# and contains all the methodes that 
# Usr_persona::DB::Object does
use base qw(C4::Modelo::DB::Object::AutoBase2);

# call the methode My::DB::Object->meta->setup() to 
# announce the layout of our database table;

__PACKAGE__->meta->setup
  (
    table   => 'usr_estado',
    columns => [
        id_estado        => { type => 'serial', overflow => 'truncate', not_null => 1, length => 11 },
        nombre           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
        fuente           => { type => 'varchar', overflow => 'truncate', length => 255, not_null => 1 },
    ],

    primary_key_columns => [ 'id_estado' ],
);


sub conformarUsrRegularidad{
    my ($self)=shift;

    my ($categorias_array_ref)  = C4::AR::Referencias::obtenerCategoriaDeSocio();

    foreach my $categoria (@$categorias_array_ref) {
        my $regularidad = C4::Modelo::UsrRegularidad->new();
        my %data_hash ={};

        $data_hash{'usr_estado_id'} = $self->getId_estado;
        $data_hash{'usr_ref_categoria_id'} = $categoria->getId();
        $data_hash{'Condicion'} = 0;
        $regularidad->agregar(\%data_hash);
    }    
	
}

sub agregar{
    my ($self)=shift;
    my ($data_hash)=@_;
    #Asignando data...
    $self->setFuente($data_hash->{'fuente'});
    $self->setNombre($data_hash->{'categoria'});
    $self->save();
    $self->conformarUsrRegularidad();
}

sub getId_estado{
    my ($self) = shift;
    return ($self->id_estado);
}

sub getNombre{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->nombre));
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub getFuente{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->fuente));
}

sub setFuente{
    my ($self) = shift;
    my ($fuente) = @_;
    $self->fuente($fuente);
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;

    if ($filtro){
        my @filtros_or;
        if ($matchig_or_not){
            push(@filtros_or, (nombre => {like => '%'.$filtro.'%'}) );
            push(@filtros_or, (fuente => {like => '%'.$filtro.'%'}) );
        }else{
            push(@filtros_or, (nombre => {eq => $filtro}) );
            push(@filtros_or, (fuente => {eq => $filtro}) );
        }
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::UsrEstado::Manager->get_usr_estado(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::UsrEstado::Manager->get_usr_estado_count(query => \@filtros,);
    my $self_nombre = $self->getNombre;
    my $self_nombre_abreviado = $self->getNombre;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = ((distance($self_nombre,$each->getNombre)<=2) || (distance($self_nombre_abreviado,$each->getFuente)<=2));
          if ($match){
            push (@matched_array,$each);
          }
        }
        return (scalar(@matched_array),\@matched_array);
    }
    else{
      return($ref_cant,$ref_valores);
    }
}

1;
