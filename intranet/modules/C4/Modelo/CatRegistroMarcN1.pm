package C4::Modelo::CatRegistroMarcN1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_registro_marc_n1',

    columns => [
        id             => { type => 'serial', not_null => 1 },
        marc_record    => { type => 'text' },
    ],

    primary_key_columns => [ 'id' ],
);

sub agregar{
    my ($self)=shift;
    
    my ($data_hash)=@_;

    use C4::Modelo::CatNivel1Repetible;

    my @arrayNivel1;
    my @arrayNivel1Repetibles;
    my $infoArrayNivel1 = $data_hash->{'infoArrayNivel1'};

    #separo los datos del Nivel1 de los datos del Nivel1_repetible
#     foreach my $infoNivel1 (@$infoArrayNivel1){
# 
#         if($infoNivel1->{'repetible'}){
#             push(@arrayNivel1Repetibles, $infoNivel1);
#         }else{
#             push(@arrayNivel1, $infoNivel1);
#         }
#     }
    foreach my $infoNivel1 (@$infoArrayNivel1){

        if($infoNivel1->{'tiene_estructura'} eq '1'){
            #si es fijo es un campo de la tabla cat_nivel1
#             if(($infoNivel1->{'fijo'} ne '1') || !defined $infoNivel1->{'fijo'}){
            if($infoNivel1->{'fijo'} eq '1'){
                #es es un campo de la tabla cat_nivel1_repetible
                push(@arrayNivel1, $infoNivel1);
                C4::AR::Debug::debug("CatNivel1 => agregar => push en arrayNivel1");
            }else{
                push(@arrayNivel1Repetibles, $infoNivel1);
                C4::AR::Debug::debug("CatNivel1 => agregar => push en arrayNivel1Repetibles");
            }
        }
    }
    
    #se guardan los datos de Nivel1
    foreach my $infoNivel1 (@arrayNivel1){  
        $self->setDato($infoNivel1);
    }

    $self->save();

    my $id1 = $self->getId1;

    #Se guradan los datos en Nivel 1 repetibles
    foreach my $infoNivel1 (@arrayNivel1Repetibles){
        $infoNivel1->{'id1'} = $id1;
# SI NO EXISTE EL rep_n1_id hay q crear una tupla, puede q sea un registro importado que no tenia este dato
        my $nivel1Repetible;

        C4::AR::Debug::debug("CatNivel1 => campo, subcampo: ".$infoNivel1->{'campo'}.", ".$infoNivel1->{'subcampo'});

        if ( $infoNivel1->{'Id_rep'} != 0 ){
            C4::AR::Debug::debug("CatNivel1 => agregar => Se va a modificar CatNivel1, Id_rep: ". $infoNivel1->{'Id_rep'});
# getNivel2RepetibleFromId2Repetible
#             $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db, rep_n1_id => $infoNivel1->{'Id_rep'});
#             $nivel1Repetible->load();
            $nivel1Repetible = C4::AR::Nivel1::getNivel1RepetibleFromId1Repetible($infoNivel1->{'Id_rep'},$self->db);
        }else{
            C4::AR::Debug::debug("CatNivel1 => agregar => No existe el REPETIBLE se crea uno");
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
        }

        $nivel1Repetible->setId1($infoNivel1->{'id1'});
        $nivel1Repetible->setCampo($infoNivel1->{'campo'});
        $nivel1Repetible->setSubcampo($infoNivel1->{'subcampo'});

        if ($infoNivel1->{'referencia'}) {
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE con REFERENCIA: ".$infoNivel1->{'datoReferencia'});
            $nivel1Repetible->dato($infoNivel1->{'datoReferencia'});
        }else{
            $nivel1Repetible->dato($infoNivel1->{'dato'});
            C4::AR::Debug::debug("CatNivel1 => REPETIBLE sin REFERENCIA: ".$infoNivel1->{'dato'});
        }

        $nivel1Repetible->save(); 
    }

}


1;

