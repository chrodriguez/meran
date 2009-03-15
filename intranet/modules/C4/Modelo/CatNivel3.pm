package C4::Modelo::CatNivel3;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel3',

    columns => [
        id3                   => { type => 'serial', not_null => 1 },
        id1                   => { type => 'integer', not_null => 1 },
        id2                   => { type => 'integer', not_null => 1 },
        barcode               => { type => 'varchar', length => 20 },
        signatura_topografica => { type => 'varchar', length => 30 },
        id_ui_poseedora       => { type => 'varchar', length => 4 }, #ui que tiene el item
        id_ui_origen          => { type => 'varchar', length => 4 }, #ui de donde viene el item
        id_disponibilidad     => { type => 'integer', length => 5, default => '0', not_null => 1 },
        para_sala             => { type => 'character', default => '0', length => 2 },
        timestamp             => { type => 'timestamp', not_null => 1 },
    ],

    primary_key_columns => [ 'id3' ],

    relationships => [
        cat_nivel3_repetible => {
            class      => 'C4::Modelo::CatNivel3Repetible',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },

        circ_reserva => {
            class      => 'C4::Modelo::CircReserva',
            column_map => { id3 => 'id3' },
            type       => 'one to many',
        },
        
        ref_disponibilidad => {
            class      => 'C4::Modelo::RefDisponibilidad',
            column_map => { id_disponibilidad => 'codigo' },
            type       => 'one to many',
        },

#         ref_ui_poseedora => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_poseedora => 'id_ui' },
#             type       => 'one to many',
#         },
#         
#         ref_ui_origen => {
#             class      => 'C4::Modelo::RefUnidadInformacion',
#             column_map => { id_ui_origen => 'id_ui' },
#             type       => 'one to many',
#         },
    ],
);



sub agregar{

    my ($self)=shift;
    use C4::Modelo::CatNivel2Repetible;
    my ($data_hash)=@_;

    my @arrayNivel3;
    my @arrayNivel3Repetibles;

    my $infoArrayNivel3= $data_hash->{'infoArrayNivel3'};
    foreach my $infoNivel3 (@$infoArrayNivel3){

        if($infoNivel3->{'repetible'}){
            push(@arrayNivel3Repetibles, $infoNivel3);
        }else{
            push(@arrayNivel3, $infoNivel3);
        }
    }

    $self->setId1($data_hash->{'id1'});
    $self->setId2($data_hash->{'id2'});     

    #se guardan los datos de Nivel3
    foreach my $infoNivel3 (@arrayNivel3){  
        if( ($infoNivel3->{'campo'} eq '910')&&($infoNivel3->{'subcampo'} eq 'a') ){
        #tipo de documento
            $self->setBarcode($infoNivel3->{'dato'});
        }

        elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 't') ){
        #signatura_topografica
            $self->setSignatura_topografica($infoNivel3->{'dato'});
        }

        elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'c') ){
        #UI poseedora
            $self->setId_ui_poseedora($infoNivel3->{'dato'});
        }

        elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'd') ){
        #UI origen
            $self->setId_ui_origen($infoNivel3->{'dato'});
        }

        elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'o') ){
        #disponibilidad
            $self->setId_disponibilidad($infoNivel3->{'dato'});
        }

        elsif( ($infoNivel3->{'campo'} eq '995')&&($infoNivel3->{'subcampo'} eq 'e') ){
        #estado del ejemplar
            $self->setParaSala($infoNivel3->{'dato'});
        }
   
    } #END foreach my $infoNivel3 (@arrayNivel3)

    $self->save();

    my $id3= $self->getId3;

    #Se guradan los datos en Nivel 3 repetibles
    foreach my $infoNivel3 (@arrayNivel3Repetibles){
        $infoNivel3->{'id3'}= $id3;
            
        my $nivel3Repetible;

        if ($data_hash->{'modificado'}){
            $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $self->db, rep_n3_id => $infoNivel3->{'rep_n3_id'});
            $nivel3Repetible->load();
        }else{
            $nivel3Repetible = C4::Modelo::CatNivel3Repetible->new(db => $self->db);
        }

        $nivel3Repetible->setId3($infoNivel3->{'id3'});
        $nivel3Repetible->setCampo($infoNivel3->{'campo'});
        $nivel3Repetible->setSubcampo($infoNivel3->{'subcampo'});
        $nivel3Repetible->setDato($infoNivel3->{'dato'});
        $nivel3Repetible->save();
    }
}

sub eliminar{

    my ($self)=shift;

    use C4::Modelo::CatNivel3Repetible;
    use C4::Modelo::CatNivel3Repetible::Manager;

    my ($repetiblesNivel3) = C4::Modelo::CatNivel3Repetible::Manager->get_cat_nivel3_repetible( query => [ id3 => { eq => $self->getId3 } ] );
    foreach my $n3Rep (@$repetiblesNivel3){
      $n3Rep->eliminar();
    }
    $self->delete();

}

sub toMARC{
    my ($self) = shift;
	my @marc_array;

	my %hash;
	$hash{'campo'}= '995';
	$hash{'subcampo'}= 'd';
	$hash{'dato'}= $self->getId_ui_origen;
	$hash{'ident'}= 'id_ui_origen';

	push (@marc_array, \%hash);

	my %hash;
	$hash{'campo'}= '995';
	$hash{'subcampo'}= 'c';
	$hash{'dato'}= $self->getId_ui_poseedora;
	$hash{'ident'}= 'id_ui_poseedora';

	push (@marc_array, \%hash);

	my %hash;
	$hash{'campo'}= '995';
	$hash{'subcampo'}= 't';
	$hash{'dato'}= $self->getSignatura_topografica;
	$hash{'ident'}= 'signatura_topografica';

	push (@marc_array, \%hash);

	my %hash;
	$hash{'campo'}= '995';
	$hash{'subcampo'}= 'e';
	$hash{'dato'}= $self->getPara_Sala;
	$hash{'ident'}= 'estado';

	push (@marc_array, \%hash);

	my %hash;
	$hash{'campo'}= '995';
	$hash{'subcampo'}= 'o';
	$hash{'dato'}= $self->getId_disponibilidad;
	$hash{'ident'}= 'id_disponibilidad';

	push (@marc_array, \%hash);

	
	return (\@marc_array);
}

sub getId_ui_poseedora{
    my ($self) = shift;
    return ($self->id_ui_poseedora);
}

sub setId_ui_poseedora{
    my ($self) = shift;
    my ($id_ui_poseedora) = @_;
    $self->id_ui_poseedora($id_ui_poseedora);
}

sub getId_ui_origen{
    my ($self) = shift;
    return ($self->id_ui_origen);
}

sub setId_ui_origen{
    my ($self) = shift;
    my ($id_ui_origen) = @_;
    $self->id_ui_origen($id_ui_origen);
}

sub getId1{
    my ($self) = shift;
    return ($self->id1);
}

sub setId1{
    my ($self) = shift;
    my ($id1) = @_;
    $self->id1($id1);
}

sub getId2{
    my ($self) = shift;
    return ($self->id2);
}

sub setId2{
    my ($self) = shift;
    my ($id2) = @_;
    $self->id2($id2);
}

sub getId3{
    my ($self) = shift;
    return ($self->id3);
}

sub setId3{
    my ($self) = shift;
    my ($id3) = @_;
    $self->id3($id3);
}

sub getBarcode{
    my ($self) = shift;
    return ($self->barcode);
}

sub setBarcode{
    my ($self) = shift;
    my ($barcode) = @_;
    $self->barcode($barcode);
}

sub getSignatura_topografica{
    my ($self) = shift;
    return ($self->signatura_topografica);
}

sub setSignatura_topografica{
    my ($self) = shift;
    my ($signatura_topografica) = @_;
    $self->signatura_topografica($signatura_topografica);
}

sub getId_disponibilidad{
    my ($self) = shift;
    return ($self->id_disponibilidad);
}

sub setId_disponibilidad{
    my ($self) = shift;
    my ($id_disponibilidad) = @_;
    $self->id_disponibilidad($id_disponibilidad);
}

sub setParaSala{
    my ($self) = shift;
    my ($para_sala) = @_;
    $self->para_sala($para_sala);
}

sub getPara_Sala{
    my ($self) = shift;
    return ($self->para_sala);
}

sub getTimestamp{
    my ($self) = shift;
    return ($self->timestamp);
}

sub setTimestamp{
    my ($self) = shift;
    my ($timestamp) = @_;
    $self->timestamp($timestamp);
}

1;

