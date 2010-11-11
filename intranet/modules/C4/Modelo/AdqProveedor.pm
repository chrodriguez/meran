package C4::Modelo::AdqProveedor;

use strict;
use utf8;
use C4::AR::Permisos;
use C4::AR::Utilidades;
use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'adq_proveedor',

    columns => [
        id_proveedor   => { type => 'integer', not_null => 1 },
        nombre  => { type => 'varchar', length => 255, not_null => 1},
        direccion    => { type => 'varchar', length =>  255 },
        telefono => { type => 'varchar', length => 255 },
        email  => { type => 'varchar', length => 255},
        activo => { type => 'integer', default => 0, not_null => 1},
    ],
    
    primary_key_columns => [ 'id_proveedor' ],

);



sub desactivar{
    my ($self) = shift;
    $self->setActivo(0);
    $self->save();
}

sub agregarProveedor{

    my ($self) = shift;
    my ($params) = @_;



    $self->setNombreProveedor($params->{'nombre'});
    $self->setDireccion($params->{'direccion'});
    $self->setTelefono($params->{'telefono'});
    $self->setMail($params->{'email'});
    $self->setActivo(1);

    $self->save();
}

# sub getProveedorInfo {
# 
#     my ($id_proveedor) = @_;
#     my @filtros;
# 
#     use C4::Modelo::AdqProveedor::Manager;
#     push (@filtros, (id_proveedor => {eq =>$id_proveedor}) );
# 
#     my  $proveedor = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor(query => \@filtros,
#                                                               require_objects => ['persona','ui','categoria','estado','persona.ciudad_ref',
#                                                                                   'persona.documento'],
#                                                               with_objects => ['persona.alt_ciudad_ref'],
#                                                              );
# 
#     if (scalar(@$proveedor)){
#         return ($proveedor->[0]);
#     }else{
#         return (0);
#     }
# }


sub setActivo{
    my ($self) = shift;
    my ($activo) = @_;
   $self->activo($activo);
}

sub setMail{
    my ($self) = shift;
    my ($email) = @_;
    utf8::encode($email);
    if (C4::AR::Utilidades::validateString($email)){
      $self->email($email);
    }
}

sub setTelefono{
    my ($self) = shift;
    my ($telefono) = @_;
    utf8::encode($telefono);
    if (C4::AR::Utilidades::validateString($telefono)){
      $self->telefono($telefono);
    }
}

sub setNombreProveedor{
    my ($self) = shift;
    my ($nombre) = @_;
    utf8::encode($nombre);
    if (C4::AR::Utilidades::validateString($nombre)){
      $self->nombre($nombre);
    }
}

sub getNombre{
    my ($self) = shift;
    return ($self->nombre);
}

sub getDireccion{
    my ($self) = shift;
    return ($self->direccion);
}

sub getTelefono{
    my ($self) = shift;
    return ($self->telefono);
}

sub getEmail{
    my ($self) = shift;
    return ($self->email);
}

sub setDireccion{
    my ($self) = shift;
    my ($direccion) = @_;
    utf8::encode($direccion);
    if (C4::AR::Utilidades::validateString($direccion)){
      $self->direccion($direccion);
    }
}

sub getProveedorLike {

    use C4::Modelo::AdqProveedor;
    use C4::Modelo::AdqProveedor::Manager;
    my ($proveedor,$orden,$ini,$cantR,$habilitados,$inicial) = @_;
    my @filtros;
    my $proveedorTemp = C4::Modelo::AdqProveedor->new();
    my @searchstring_array= C4::AR::Utilidades::obtenerBusquedas($proveedor);

    if($proveedor ne 'TODOS'){
        #SI VIENE INICIAL, SE BUSCA SOLAMENTE POR APELLIDOS QUE COMIENCEN CON ESA LETRA, SINO EN TODOS LADOS CON LIKE EN AMBOS LADOS
        if (!($inicial)){
            foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   nombre => { like => '%'.$s.'%'},          
                                            ])
                     );
            }
        }else{
            foreach my $s (@searchstring_array){ 
                push (  @filtros, ( or   => [   nombre => { like => $s.'%'}, 
                                            ])
                                    );
            }
        }
    }

    if (!defined $habilitados){
        $habilitados = 1;
    }

    push(@filtros, ( activo => { eq => $habilitados}));
 #   push(@filtros, ( es_socio => { eq => $habilitados}));
    my $ordenAux= $proveedorTemp->sortByString($orden);

    my $proveedores_array_ref = C4::Modelo::UsrSocio::Manager->get_adq_proveedor(   query => \@filtros,
                                                                            sort_by => $ordenAux,
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
                                                              require_objects => ['nombre','direccion','telefono',
                                                                                  'email'],
     ); 

    #Obtengo la cant total de socios para el paginador
    my $proveedores_array_ref_count = C4::Modelo::AdqProveedor::Manager->get_adq_proveedor( query => \@filtros,
                                                              require_objects => ['nombre','direccion','telefono',
                                                                                  'email'],
                                                                     );

    if(scalar(@$proveedores_array_ref) > 0){
        return ($proveedores_array_ref_count, $proveedores_array_ref);
    }else{
        return (0,0);
    }
}


1;



