package C4::Modelo::CatRegistroMarcN3;

use strict;

=head1 NAME

 C4::Modelo::CatRegistroMarcN3- Funciones que manipulan datos del catálogo a nivel 3

=head1 SYNOPSIS

  use C4::Modelo::CatRegistroMarcN3;

=head1 DESCRIPTION

Modulo para manejar objetos del ORM de los datos del nivel3 del catalogo

=head1 FUNCTIONS

=over 2
=cut

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n3',

    columns => [
        id              => { type => 'serial', not_null => 1 },
        marc_record     => { type => 'text' },
        id1             => { type => 'integer', not_null => 1 },
        id2             => { type => 'integer', not_null => 1 },
        date            => { type => 'varchar' },
    ],

    primary_key_columns => [ 'id' ],

    relationships => [
        nivel1  => {
            class       => 'C4::Modelo::CatRegistroMarcN1',
            key_columns => { id1 => 'id' },
            type        => 'one to one',
        },

        nivel2  => {
            class       => 'C4::Modelo::CatRegistroMarcN2',
            key_columns => { id2 => 'id' },
            type        => 'one to one',
        },
    ],
);

=head2
    sub agregar
=cut
sub agregar{
    my ($self)          = shift;
    my ($db, $params)   = @_;

    $self->setId2($params->{'id2'});
    $self->setId1($params->{'id1'});
    $self->setMarcRecord($params->{'marc_record'});


    $self->save();
}


sub modificar{
    my ($self)           = shift;
    my ($params, $db)    = @_;

    $self->setId2($params->{'id2'});
    $self->setId1($params->{'id1'});

    my $marc_record_cliente = MARC::Record->new_from_usmarc($params->{'marc_record'}); #marc_record que viene del cliente
    my $marc_record_base    = MARC::Record->new_from_usmarc($self->getMarcRecord());
#     my $marc_record_salida  = MARC::Record->new();



# TODO falta verificar el cambio de estado/disponibilidad

    my %params;

    


#     return C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record->subfield("995","o")));



# verificar_cambio 
    $params{'estado_anterior'}          = $self->getIdEstado();          #(DISPONIBLE, "NO DISPONIBLES" => BAJA, COMPARTIDO, etc)
    $params{'estado_nuevo'}             = C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record_cliente->subfield("995","e")));        
    $params{'disponibilidad_anterior'}  = $self->getIdDisponibilidad(); #(DISPONIBLE, PRESTAMO, SALA LECTURA)
    $params{'disponibilidad_nueva'}     = C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record_cliente->subfield("995","o")));
   

    if($params->{'EDICION_N3_GRUPAL'}){
    #si es una edicion grupal no se permite editar el barcode 995,f  






        foreach my $field ($marc_record_cliente->fields) {
                if(! $field->is_control_field){
                    #se verifica si el campo esta autorizado para el nivel que se estra procesando
#                         my @subcampos_array = ();
                        foreach my $subfield ($field->subfields()){
                            my $dato        = $subfield->[1];
                            my $sub_campo   = $subfield->[0];

                            C4::AR::Debug::debug("campo     => ".$field->tag);
                            C4::AR::Debug::debug("subcampo  => ".$sub_campo);
                            C4::AR::Debug::debug("dato      => ".$dato);


                            if (($field->tag eq "995")&& ($sub_campo eq "f")) {
                                #se mantiene el dato del barcode cuando es una actualizacion grupal
                            } else {

    #                             my $dato_base   = $marc_record_base->subfield($field, $sub_campo); 
                                if(($dato eq "")||($dato eq "-1")||($dato eq "NULL")){
    #                             if($dato_base eq $dato)
                                    C4::AR::Debug::debug("el dato ".$dato." no fue modificado");
                                    C4::AR::Debug::debug("se mantiene el dato ".$marc_record_base->subfield($field->tag, $sub_campo)." de la base");
                                } else {
                                    #ahora se obtienen las referencias  
                                    $dato = C4::AR::Catalogacion::_procesar_referencia($field->tag, $sub_campo, $dato, $self->nivel2->getTipoDocumento); 
                                    $marc_record_base->field($field->tag)->update( $sub_campo => $dato );
                                }
                            }
                        }

                }
        }

        $self->setMarcRecord($marc_record_base->as_usmarc);
        C4::AR::Debug::debug("marc_record as_usmarc para la base ".$marc_record_base->as_usmarc);


=item
        C4::AR::Debug::debug("EDICION GRUPAL !!!!!!!!!!!!!!!!!");
        #pisa el barcode (995, f) del marc_record del cliente con el barcode del marc_record de la base
        C4::AR::Debug::debug("barcode de la base ".$marc_record_base->subfield("995","f"));
        C4::AR::Debug::debug("marc_record as_usmarc del cliente ".$params->{'marc_record'});
        my $barcode = '';
        C4::AR::Debug::debug("EDICION GRUPAL !!!!!!!!!!!!!!!!! barcide ==========================".$marc_record_base->subfield("995","f")."================");
        if ($marc_record_base->subfield("995","f") ne "") {
        #en la edicion grupal se mantiene el barcode
            $barcode = $marc_record_base->subfield("995","f");
        }

        #aca van todos los campos a los que se les tiene que mantener el dato cuando es una edicion grupal
        $marc_record_cliente->field("995")->update( 'f' => $barcode );
        C4::AR::Debug::debug("marc_record as_usmarc para la base ".$marc_record_cliente->as_usmarc);

        $self->setMarcRecord($marc_record_cliente->as_usmarc);
=cut
    } else {
        $self->setMarcRecord($params->{'marc_record'});
    }

#     $self->verificar_cambio($db, \%params);

# die;  
    $self->save();
}

=head2
    sub eliminar
=cut
sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    $self->delete();    
}

=head2
sub getId3

Obteniendo el id del elemento
=cut

sub getId3{
    my ($self)  = shift;

    return $self->id;
}

=head2
sub getId2

Obteniendo el id2 al que pertenece el elemento de nivel3
=cut


sub getId2{
    my ($self)  = shift;

    return $self->id2;
}

=head2
sub getId1

Obteniendo el id1 al que pertenece el elemento de nivel3
=cut


sub getId1{
    my ($self)  = shift;

    return $self->id1;
}

=head2
sub getId1

Setea el id1 al que pertenece el elemento de nivel3
=cut

sub setId1{
    my ($self)  = shift;
    my ($id1)   = @_;

    $self->id1($id1);
}

=head2
sub setId2

Setea el id2 al que pertenece el elemento de nivel3
=cut

sub setId2{
    my ($self)  = shift;
    my ($id2)   = @_;

    $self->id2($id2);
}


sub getMarcRecord{
    my ($self) = shift;
    return (C4::AR::Utilidades::trim($self->marc_record));
}

sub setMarcRecord{
    my ($self)          = shift;
    my ($marc_record)   = @_;

    $self->marc_record($marc_record);
}

sub getBarcode{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","f"));
}

sub getSignatura_topografica{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Utilidades::trim($marc_record->subfield("995","t"));
}


sub getId_ui_origen{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("995","d"));

    return C4::AR::Utilidades::trim($ref);
}

sub getId_ui_poseedora{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref         = C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record->subfield("995","c")));

    return C4::AR::Utilidades::trim($ref);
}

=head2 sub getIdEstado
=cut
sub getIdEstado{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record->subfield("995","e")));
}


=head2 sub getEstadoObject
=cut
sub getEstadoObject{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    my $ref         = $self->getIdEstado();
     
    my $estado      = C4::Modelo::RefEstado->getByPk($self->getIdEstado());
        
    if(!$estado){
            C4::AR::Debug::debug("CatRegistroMarcN3 => getEstadoObject()=> EL OBJECTO (ID) RefEstado NO EXISTE");
            $estado = C4::Modelo::RefEstado->new();
    }

    return $estado;
}

sub getEstadoFromMarcrecord{

}

=head2 sub getIdDisponibilidad
=cut
sub getIdDisponibilidad{
    my ($self)      = shift;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());

    return C4::AR::Catalogacion::getRefFromStringConArrobas(C4::AR::Utilidades::trim($marc_record->subfield("995","o")));
}


=head2 sub getDisponibilidadObject
=cut
sub getDisponibilidadObject{
    my ($self)              = shift;

    my $marc_record         = MARC::Record->new_from_usmarc($self->getMarcRecord());
#     my $ref                 = C4::AR::Catalogacion::getRefFromStringConArrobas($self->getIdDisponibilidad());

     
    my $disponibilidad      = C4::Modelo::RefDisponibilidad->getByPk($self->getIdDisponibilidad());
        
    if(!$disponibilidad){
            C4::AR::Debug::debug("CatRegistroMarcN3 => getDisponibilidadObject()=> EL OBJECTO (ID) RefDisponibilidad NO EXISTE");
            $disponibilidad = C4::Modelo::RefDisponibilidad->new();
    }

    return $disponibilidad;
}


=head2 sub estaReservado
    Verifica si el ejemplar se encuentra reservado o no
=cut
sub estaReservado {
    my ($self) = shift;

    return C4::AR::Reservas::estaReservado($self->getId3);
}


=head2  sub estaPrestado
=cut
sub estaPrestado {
    my ($self) = shift;

    return (C4::AR::Prestamos::estaPrestado($self->getId3));
}

=head2  sub getEstado
=cut
sub getEstado{
    my ($self) = shift;

    my $estado_object = C4::Modelo::RefEstado->getByPk($self->getIdEstado());

    if($estado_object){
        return C4::AR::Utilidades::trim($estado_object->getNombre());
    }

    C4::AR::Debug::debug("CatRegistroMarcN3 => getEstado => NO EXISTE EL ID ESTADO QUE SE INTENTA RECUPERAR ".$self->getIdEstado);
    return ('');
}

=head2 sub estadoDisponible

=cut
sub estadoDisponible{
    my ($self) = shift;
    
    return (C4::Modelo::RefEstado->getByPk($self->getIdEstado())->getNombre() eq "Disponible");  
}

=head2 sub esParaSala
=cut
sub esParaSala{
    my ($self) = shift;

    return (C4::Modelo::RefDisponibilidad->getByPk($self->getIdDisponibilidad)->getNombre() eq "Sala de Lectura");
}

=head2 sub toMARC

=cut
sub toMARC{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 3
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());

    my $params;
    $params->{'nivel'}          = '3';
    $params->{'id_tipo_doc'}    = $self->nivel2->getTipoDocumento;
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_meran_por_nivel($marc_record, $params);


#     my $MARC_result_array   = &C4::AR::Catalogacion::marc_record_to_meran($marc_record);

#     foreach my $m (@$MARC_result_array){
#         C4::AR::Debug::debug("CatRegistroMarcN3 => toMARC => campo => ".$m->{'campo'});
#         foreach my $s (@{$m->{'subcampos_array'}}){
#             C4::AR::Debug::debug("CatRegistroMarcN3 => toMARC => liblibrarian => ".$s->{'subcampo'});        
#             C4::AR::Debug::debug("CatRegistroMarcN3 => toMARC => liblibrarian => ".$s->{'liblibrarian'});        
#         }
#     }

    return ($MARC_result_array);
}



=head2 sub toMARC_Opac

=cut
sub toMARC_Opac{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 3
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'}          = '3';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_opac_view($marc_record, $params);

    return ($MARC_result_array);
}


=head2 sub toMARC_Intra

=cut
sub toMARC_Intra{
    my ($self) = shift;

    #obtengo el marc_record del NIVEL 3
    my $marc_record             = MARC::Record->new_from_usmarc($self->getMarcRecord());


    my $params;
    $params->{'nivel'}          = '3';
    $params->{'id_tipo_doc'}    = $self->getTipoDocumento;
    my $MARC_result_array       = &C4::AR::Catalogacion::marc_record_to_intra_view($marc_record, $params);

    return ($MARC_result_array);
}

sub ESTADO_DISPONIBLE{
=item    
ESTADO

    0   Disponible
    1   Perdido
    2   Compartido
    4   Baja
    5   Ejemplar deteriorado
    6   En Encuadernación
=cut
    
    my ($estado) = @_;

    return ($estado eq 0);
}   

=item
DISPONIBILIDAD

    1   Prestamo
    2   Sala de Lectura
=cut

sub DISPONIBILIDAD_PRESTAMO{
    my ($estado) = @_;

    return ($estado eq 1);
}

sub DISPONIBILIDAD_PARA_SALA{
    my ($estado) = @_;

    return ($estado eq 2);
}

sub verificar_cambio {
    my ($self) = shift;

    my ($db, $params) = @_;

    my $estado_anterior             = $params->{'estado_anterior'};          #(DISPONIBLE, "NO DISPONIBLES" => BAJA, COMPARTIDO, etc)
    my $estado_nuevo                = $params->{'estado_nuevo'};
    my $disponibilidad_anterior     = $params->{'disponibilidad_anterior'};  #(DISPONIBLE, PRESTAMO, SALA LECTURA)
    my $disponibilidad_nueva        = $params->{'disponibilidad_nueva'};
    C4::AR::Debug::debug("verificar_cambio => estado_anterior: ".$params->{'estado_anterior'});
    C4::AR::Debug::debug("verificar_cambio => estado_nuevo: ".$params->{'estado_nuevo'});
    C4::AR::Debug::debug("verificar_cambio => disponibilidad_anterior: ".$params->{'disponibilidad_anterior'});
    C4::AR::Debug::debug("verificar_cambio => disponibilidad_nueva: ".$params->{'disponibilidad_nueva'});

    #  ESTADOS
    #   wthdrawn = 0 => DISPONIBLE
    #   wthdrawn > => NO DISPONIBLE

    #  DISPONIBILIDADES
    #   notforloan = 1 => PARA SALA
    #   notforload = 0 => PARA PRESTAMO
        
    my $msg_object;
    
    if( ESTADO_DISPONIBLE($estado_anterior) && (!ESTADO_DISPONIBLE($estado_nuevo)) && DISPONIBILIDAD_PRESTAMO($disponibilidad_anterior) ){
    #pasa de NO DISPONIBLE a DISPONIBLE con disponibilidad_anterior PRESTAMO
    #Si estado_anterior es DISPONIBLE y estado_nuevo es NO DISPONIBLE y disponibilidad_anterior es PARA PRESTAMO
    #hay que reasignar las reservas que existen para el ejemplar, si no se puede reasignar se eliminan las reservas y sanciones
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE a NO DISPONIBLE con disponibilidad anterior PRESTAMO");
        
#         C4::AR::Reservas::reasignarNuevoEjemplarAReserva($db, $params, $msg_object);

    }elsif ( (!ESTADO_DISPONIBLE($estado_anterior)) && ESTADO_DISPONIBLE($estado_nuevo) && DISPONIBILIDAD_PRESTAMO($disponibilidad_nueva) ){
    #pasa de DISPONIBLE a NO DISPONIBLE con disponibilidad_nueva PRESTAMO
    #Si estado_anterior es NO DISPONIBLE  y  estado_nuevo es DISPONIBLE  y  disponibilidad_nueva es PRESTAMO
    #hay que verificar si hay reservas en espera, si hay se reasignan al nuevo ejemplar
        C4::AR::Debug::debug("verificar_cambio => NO DISPONIBLE a DISPONIBLE con disponibilidad nueva PRESTAMO");
#         C4::AR::Reservas::asignarEjemplarASiguienteReservaEnEspera($params);

    }elsif ( ESTADO_DISPONIBLE($estado_anterior) && DISPONIBILIDAD_PRESTAMO($disponibilidad_anterior) && 
             DISPONIBILIDAD_PARA_SALA($disponibilidad_nueva) ){
    #Si estaba DISPONIBLE y pasa de disponibilidad_anterior PRESTAMO a disponibilidad_nueva SALA
    #hay que verificar si tiene reservas, si tiene se reasignan si no se puden reasignar se cancelan
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE de disponibilidad anterior PRESTAMO a disponibilidad nueva PARA SALA");
        C4::AR::Reservas::reasignarNuevoEjemplarAReserva($db, $params, $msg_object);            

    }elsif ( ESTADO_DISPONIBLE($estado_anterior) && DISPONIBILIDAD_PARA_SALA($disponibilidad_anterior) &&
             DISPONIBILIDAD_PRESTAMO($disponibilidad_nueva) ){
    #Si estaba DISPONIBLE y pasa de disponibilidad_anterior PARA SALA a disponibilidad_nueva PRESTAMO
    #Se verifica si hay reservas en espera, si hay se reasignan al nuevo ejemplar
        C4::AR::Debug::debug("verificar_cambio => DISPONIBLE de disponibilidad anterior PARA SALA a disponibilidad nueva PRESTAMO");
#         C4::AR::Reservas::asignarEjemplarASiguienteReservaEnEspera($params);
    }
    
}


1;

