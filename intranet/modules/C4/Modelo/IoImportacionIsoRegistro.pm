package C4::Modelo::IoImportacionIsoRegistro;

use strict;

use C4::Modelo::IoImportacionIsoRegistro;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'io_importacion_iso_registro',

    columns => [
        id                             => { type => 'serial', overflow => 'truncate', not_null => 1 },
        id_importacion_iso             => { type => 'integer', overflow => 'truncate', not_null => 1},
        type                           => { type => 'varchar', overflow => 'truncate', length => 25},
        estado                         => { type => 'integer', overflow => 'truncate', length => 2},
        matching                       => { type => 'integer', overflow => 'truncate'},
        id_matching                    => { type => 'integer', overflow => 'truncate'},
        identificacion                 => { type => 'varchar', overflow => 'truncate', length => 255},
        relacion                       => { type => 'varchar', overflow => 'truncate', length => 255},
        id1                            => { type => 'integer', overflow => 'truncate'},
        id2                            => { type => 'integer', overflow => 'truncate'},
        id3                            => { type => 'integer', overflow => 'truncate'},
        marc_record                    => { type => 'text', overflow => 'truncate', not_null => 1},
    ],


    relationships =>
    [
      ref_importacion =>
      {
         class       => 'C4::Modelo::IoImportacionIso',
         key_columns => {id_importacion_iso => 'id' },
         type        => 'one to one',
       },
    ],

    primary_key_columns => [ 'id' ],
    unique_key          => ['id'],

);

#----------------------------------- FUNCIONES DEL MODELO ------------------------------------------------


sub agregar{
    my ($self)   = shift;
    my ($params) = @_;

    $self->setIdImportacionIso($params->{'id_importacion_iso'});
    $self->setMarcRecord($params->{'marc_record'});
    $self->save();
}


sub eliminar{
    my ($self)      = shift;
    my ($params)    = @_;

    #HACER ALGO SI ES NECESARIO

    $self->delete();
}


sub getRegistroMARCOriginal{
    my ($self)      = shift;
    my ($params) = @_;

    my $marc_record = MARC::Record->new_from_usmarc($self->getMarcRecord());
    return $marc_record;
    }

sub getRegistroMARCResultado{
    my ($self)      = shift;
    my ($params) = @_;

    my $marc_record_original = $self->getRegistroMARCOriginal();
    my $marc_record = MARC::Record->new();
    my $detalle_destino = $self->ref_importacion->esquema->getDetalleDestino();

    foreach my $detalle (@$detalle_destino){
        my $new_field=0;
        my $dato = $self->getCampoSubcampoJoined($detalle->getCampoDestino,$detalle->getSubcampoDestino);

        if ($detalle->getCampoDestino ne 'ZZZ'){
            #Sino no esta configurado
            if($detalle->getCampoDestino < '010'){
                #CONTROL FIELD
                $new_field = MARC::Field->new( $detalle->getCampoDestino, $dato );
               }
            else {
                my $ind1='#';
                my $ind2='#';
                $new_field= MARC::Field->new($detalle->getCampoDestino, $ind1, $ind2,$detalle->getSubcampoDestino => $dato);
                }
            if($new_field){
                $marc_record->append_fields($new_field);
            }
        }
       }

    return $marc_record;
    }

#----------------------------------- FIN - FUNCIONES DEL MODELO -------------------------------------------



#----------------------------------- GETTERS y SETTERS------------------------------------------------

sub setIdImportacionIso{
    my ($self) = shift;
    my ($id_imporatcion) = @_;
    utf8::encode($id_imporatcion);
    $self->id_importacion_iso($id_imporatcion);
}

sub setMarcRecord{
    my ($self)  = shift;
    my ($marc_record) = @_;
    $self->marc_record($marc_record);
}

sub getId{
    my ($self) = shift;
    return ($self->id);
}

sub getIdImportacionIso{
    my ($self) = shift;
    return ($self->id_importacion_iso);
}

sub getMarcRecord{
    my ($self) = shift;
    return ($self->marc_record);
}



sub getEstado{
    my ($self) = shift;
    return ($self->estado);
}

sub getMatching{
    my ($self) = shift;
    return ($self->matching);
}

sub getCampoSubcampoJoined{
    my ($self) = shift;
    my ($campo,$subcampo) = @_;

    my $marc = $self->getRegistroMARCOriginal;

    my $detalle_completo = $self->ref_importacion->esquema->getDetalleByCampoSubcampoDestino($campo,$subcampo);

    my $join='';
    foreach my $detalle (@$detalle_completo){
        my $dato ='';
        my $field = $marc->field($detalle->getCampoOrigen);
        if ($field){
            if($field->is_control_field()){
                    #Campo de Control
                   $dato = $field->data();
                }
                else {
                    $dato = $field->subfield($detalle->getSubcampoOrigen);
                }
            if ($dato){
                    $join.=$detalle->getSeparador . $dato;
             }
        }
     }

    return ($join);
}

sub getIdentificacion{
    my ($self)   = shift;
    return ($self->identificacion);
}

sub getTitulo{
    my ($self) = shift;
    my $titulo = ($self->getCampoSubcampoJoined('245','a'));

    if(!$titulo){
        my $padre=$self->getRegistroPadre;
        if ($padre){
            $titulo=$padre->getTitulo;
            }
        }
    return $titulo;
}

sub getAutor{
    my ($self) = shift;
    my $autor = ($self->getCampoSubcampoJoined('100','a'));

    if(!$autor){
        my $padre=$self->getRegistroPadre;
        if ($padre){
            $autor=$padre->getAutor;
            }
        }
    return $autor;
}


sub setIdentificacion{
    my ($self)   = shift;
    my ($ident) = @_;
    $self->identificacion($ident);
}

sub getIdentificacionFromRecord{
    my ($self)   = shift;

    my $identificacion='';
    my $marc = $self->getRegistroMARCOriginal();

    my $campo =$self->ref_importacion->getCampoFromCampoIdentificacion;
    if ($campo){
        my $field = $marc->field($campo);
        if ($field){
            if ($field->is_control_field()){
                #Si es de control devuelvo el dato;
                $identificacion = $field->data();
                }
            else{
                #Si no es de control tiene subcampo
                my $subcampo =$self->ref_importacion->getSubcampoFromCampoIdentificacion;
                if ($subcampo){
                    $identificacion = $field->subfield($subcampo);
                    }
            }
        }
    }

    return $identificacion;
}


sub setRelacion{
    my ($self)   = shift;
    my ($rel) = @_;
    $self->relacion($rel);
}

sub getRelacionFromRecord{
    my ($self)   = shift;

    my $relacion='';
    my $marc = $self->getRegistroMARCOriginal();

    my $campo =$self->ref_importacion->getCampoFromCampoRelacion;
    if ($campo){
        my $field = $marc->field($campo);
        if ($field->is_control_field()){
            #Si es de control devuelvo el dato;
            $relacion = $field->data();
            }
        else{
            #Si no es de control tiene subcampo
            my $subcampo =$self->ref_importacion->getSubcampoFromCampoRelacion;
            if ($subcampo){
                $relacion = $field->subfield($subcampo);
                }
        }


        if ($relacion){
            #Para identificar si es un campo de realcion debe comenzar con este string
            my $pre =$self->ref_importacion->getPreambuloFromCampoRelacion;
            if($pre){
                #todo a  minuscula
                $relacion=lc($relacion);
                $pre=lc($pre);
                if($relacion =~ m/^$pre/){
                    $relacion =~ s/^$pre//;
                }
                else{
                    $relacion ='';
                    }
            }
        }
    }

    return $relacion;
}


sub getRelacion{
    my ($self)   = shift;
    return ($self->relacion);
}


sub getCantidadDeRegistrosHijo{
     my ($self)   = shift;

     my ($cantidad,$registros) = C4::AR::ImportacionIsoMARC::getRegistrosHijoFromRegistroDeImportacionById($self->getId);

    return $cantidad;
}

sub getRegistrosHijo{
     my ($self)   = shift;

     my ($cantidad,$registros) = C4::AR::ImportacionIsoMARC::getRegistrosHijoFromRegistroDeImportacionById($self->getId);

    return $registros;
}

sub getRegistroPadre{
     my ($self)   = shift;

     my $registro_padre = C4::AR::ImportacionIsoMARC::getRegistroPadreFromRegistroDeImportacionById($self->getId);

    return $registro_padre;
}

sub getTipo{
     my ($self)   = shift;

    if($self->getIdentificacion){
        if(($self->getRelacion)&&($self->getRegistroPadre)) {
             return "Registro Hijo";
            }
        else{
        return "Registro";
        }
    }
    return "Desconocido";
}
