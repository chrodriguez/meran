package C4::Modelo::PrefServidorZ3950;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'pref_servidor_z3950',

    columns => [
        servidor => { type => 'varchar', length => 255 },
        puerto   => { type => 'integer' },
        base     => { type => 'varchar', length => 255 },
        usuario  => { type => 'varchar', length => 255 },
        password => { type => 'varchar', length => 255 },
        nombre   => { type => 'text', length => 65535 },
        id       => { type => 'serial', not_null => 1 },
        habilitado => { type => 'integer', not_null => 1 },
        sintaxis => { type => 'varchar', length => 80 },
    ],

    primary_key_columns => [ 'id' ],
);

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub setId{
    my ($self) = shift;
    my ($id) = @_;
    $self->id($id);
}

sub getServidor{
    my ($self) = shift;
    return ($self->servidor);
}

sub setServidor{
    my ($self) = shift;
    my ($servidor) = @_;
    $self->servidor($servidor);
}

sub getPuerto{
    my ($self) = shift;
    return ($self->puerto);
}

sub setPuerto{
    my ($self) = shift;
    my ($puerto) = @_;
    $self->puerto($puerto);
}

sub getBase{
    my ($self) = shift;
    return ($self->base);
}

sub setBase{
    my ($self) = shift;
    my ($base) = @_;
    $self->base($base);
}

sub getUsuario{
    my ($self) = shift;
    return ($self->usuario);
}

sub setUsuario{
    my ($self) = shift;
    my ($usuario) = @_;
    $self->usuario($usuario);
}

sub getPassword{
    my ($self) = shift;
    return ($self->password);
}

sub setPassword{
    my ($self) = shift;
    my ($password) = @_;
    $self->password($password);
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub setNombre{
    my ($self) = shift;
    my ($nombre) = @_;
    $self->nombre($nombre);
}

sub getHabilitado{
    my ($self) = shift;
    return ($self->habilitado);
}

sub setHabilitado{
    my ($self) = shift;
    my ($habilitado) = @_;
    $self->habilitado($habilitado);
}

sub getSintaxis{
    my ($self) = shift;
    return ($self->sintaxis);
}

sub setSintaxis{
    my ($self) = shift;
    my ($sintaxis) = @_;
    $self->sintaxis($sintaxis);
}

sub getConexion{
    my ($self) = shift;

	my $conexion= $self->getServidor.":".$self->getPuerto;
	
	if($self->getBase ne '') {
		$conexion .= "/".$self->getBase;
	}
	
    if ($self->getUsuario ne ''){
		$conexion.="/".$self->getUsuario."/".$self->getPassword;
     }

    return $conexion;
}

sub getAll{

    my ($self) = shift;
    my ($limit,$offset,$matchig_or_not,$filtro)=@_;
    use C4::Modelo::PrefServidorZ3950::Manager;
    use Text::LevenshteinXS;
    $matchig_or_not = $matchig_or_not || 0;
    my @filtros;
sub nextMember{
    use C4::Modelo::CatPerfilOpac;

    return(C4::Modelo::CatPerfilOpac->new());
}
    if ($filtro){
        my @filtros_or;
        push(@filtros_or, (NOMBRE => {like => '%'.$filtro.'%'}) );
        push(@filtros, (or => \@filtros_or) );
    }
    my $ref_valores;
    if ($matchig_or_not){ #ESTOY BUSCANDO SIMILARES, POR LO TANTO NO TENGO QUE LIMITAR PARA PERDER RESULTADOS
        push(@filtros, ($self->getPk => {ne => $self->getPkValue}) );
        $ref_valores = C4::Modelo::PrefServidorZ3950::Manager->get_pref_servidor_z3950(query => \@filtros,);
    }else{
        $ref_valores = C4::Modelo::PrefServidorZ3950::Manager->get_pref_servidor_z3950(query => \@filtros,
                                                                    limit => $limit, 
                                                                    offset => $offset, 
                                                                    sort_by => ['nombre'] 
                                                                   );
    }
    my $ref_cant = C4::Modelo::PrefServidorZ3950::Manager->get_pref_servidor_z3950_count(query => \@filtros,);
    my $self_nombre = $self->getNombre;

    my $match = 0;
    if ($matchig_or_not){
        my @matched_array;
        foreach my $each (@$ref_valores){
          $match = (distance($self_nombre,$each->getNombre)<=1);
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

sub lastTable{
    
    return(1);
}

1;

