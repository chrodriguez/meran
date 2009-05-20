package C4::Modelo::CatNivel1;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'cat_nivel1',

    columns => [
        id1       => { type => 'serial', not_null => 1 },
        titulo    => { type => 'varchar', length => 100, not_null => 1 },
        autor     => { type => 'integer', not_null => 1 },
        timestamp => { type => 'timestamp' },
    ],

    primary_key_columns => [ 'id1' ],

    relationships => [
        cat_autor => {
            class      => 'C4::Modelo::CatAutor',
            column_map => { autor => 'id' },
            type       => 'one to one',
        },
    ],

);


sub agregar{
    my ($self)=shift;
	
	my ($data_hash)=@_;

    use C4::Modelo::CatNivel1Repetible;

    my @arrayNivel1;
    my @arrayNivel1Repetibles;
    my $infoArrayNivel1= $data_hash->{'infoArrayNivel1'};

	#separo los datos del Nivel1 de los datos del Nivel1_repetible
    foreach my $infoNivel1 (@$infoArrayNivel1){

        if($infoNivel1->{'repetible'}){
            push(@arrayNivel1Repetibles, $infoNivel1);
        }else{
            push(@arrayNivel1, $infoNivel1);
        }
    }
    
    #se guardan los datos de Nivel1
    foreach my $infoNivel1 (@arrayNivel1){  
		$self->setDato($infoNivel1);
    }

	$self->save();

    my $id1= $self->getId1;

    #Se guradan los datos en Nivel 1 repetibles
    foreach my $infoNivel1 (@arrayNivel1Repetibles){
        $infoNivel1->{'id1'}= $id1;

        my $nivel1Repetible;

        if ($data_hash->{'modificado'}){
C4::AR::Debug::debug('Se va a modificar CatNivel1, rep_n1_id: '. $infoNivel1->{'rep_n1_id'});
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db, rep_n1_id => $infoNivel1->{'rep_n1_id'});
            $nivel1Repetible->load();
        }else{
            $nivel1Repetible = C4::Modelo::CatNivel1Repetible->new(db => $self->db);
        }

        $nivel1Repetible->setId1($infoNivel1->{'id1'});
        $nivel1Repetible->setCampo($infoNivel1->{'campo'});
        $nivel1Repetible->setSubcampo($infoNivel1->{'subcampo'});
#         $nivel1Repetible->setDato($infoNivel1->{'dato'});
# FIXME ver si esto es asi, TODAS LAS REFERENCIAS SI SE ESTAN MODIFICANDO SE DEBEN GUARDAR LA REFERENCIA
		if( ($infoNivel1->{'modificado'})&&($data_hash->{'referencia'}) ){
				$nivel1Repetible->dato($infoNivel1->{'datoReferencia'});
			}else{
				$nivel1Repetible->dato($infoNivel1->{'dato'});
		}
        $nivel1Repetible->save(); 
    }

}

sub eliminar{

    my ($self)=shift;
    use C4::Modelo::CatNivel1Repetible;
    use C4::Modelo::CatNivel1Repetible::Manager;
    
    use C4::Modelo::CatNivel2;
    use C4::Modelo::CatNivel2::Manager;

    my ($nivel2) = C4::Modelo::CatNivel2::Manager->get_cat_nivel2(query => [ id1 => { eq => $self->getId1() } ] );
    foreach my $n2 (@$nivel2){
      $n2->eliminar();
    }
   
   
    my ($repetiblesNivel1) = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible(query => [ id1 => { eq => $self->getId1() } ] );
    foreach my $n1Rep (@$repetiblesNivel1){
      $n1Rep->eliminar();
    }

    $self->delete();
}

sub setDato{
	my ($self) = shift;
	my ($data_hash) = @_;

	if( ($data_hash->{'campo'} eq '245')&&($data_hash->{'subcampo'} eq 'a') ){
	#titulo
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
			$self->setTitulo($data_hash->{'datoReferencia'});
		}else{
			$self->setTitulo($data_hash->{'dato'});
		}
	}
	
	if( ($data_hash->{'campo'} eq '110')&&($data_hash->{'subcampo'} eq 'a') ){  
	#autor
		if( ($data_hash->{'modificado'})&&($data_hash->{'referencia'}) ){
			$self->setAutor($data_hash->{'datoReferencia'});
		}else{
			$self->setAutor($data_hash->{'dato'});
		}
	}
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

sub getTitulo{
    my ($self) = shift;
    return ($self->titulo);
}

sub setTitulo{
    my ($self) = shift;

    my ($titulo) = @_;
	utf8::encode($titulo);
    $self->titulo($titulo);
}

sub getAutor{
    my ($self) = shift;
    return ($self->autor);
}

sub setAutor{
    my ($self) = shift;
    my ($autor) = @_;
    $self->autor($autor);
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

# ===================================================SOPORTE=====ESTRUCTURA CATALOGACION=================================================

=item
Esta funcion devuelve los campos de nivel 1 mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub toMARC{
    my ($self) = shift;
	my @marc_array;

	my $campo= '245';
	my $subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= $self->getTitulo;
	$hash{'ident'}= 'TITULO'; #parece q no es necesario
 	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	

	push (@marc_array, \%hash);

	$campo= '110';
	$subcampo= 'a';
	my %hash;
	$hash{'campo'}= $campo;
	$hash{'subcampo'}= $subcampo;
	$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
	$hash{'dato'}= C4::AR::Referencias::getNombreAutor($self->getAutor);
	my $estructura= C4::AR::Catalogacion::_getEstructuraFromCampoSubCampo($campo, $subcampo);
	$hash{'liblibrarian'}= $estructura->[0]->getLiblibrarian;
	if($estructura->[0]->getReferencia){
	#tiene referencia
		$hash{'datoReferencia'}= $self->getAutor;
	}


	push (@marc_array, \%hash);
	
	return (\@marc_array);
}


=item
Esta funcion devuelve los campos de nivel 1 y nivel1Repetible mapeados en un arreglo de {campo, subcampo, dato}
=cut
sub nivel1CompletoToMARC{
    my ($self) = shift;

	my ($marc_array)= $self->toMARC;
	my ($nivel1Repetible_object_array) = C4::Modelo::CatNivel1Repetible::Manager->get_cat_nivel1_repetible( 
																						query => [ id1 => { eq => $self->getId1 } ]
																		);

	my $campo;
	my $subcampo;
	my $dato;	

	foreach my $marc_object (@$nivel1Repetible_object_array){
		$campo= $marc_object->getCampo;
		$subcampo= $marc_object->getSubcampo;
		$dato= $marc_object->getDato;
		my %hash;
		$hash{'header'}= C4::AR::Busquedas::getHeader($campo);
		$hash{'campo'}= $campo;
		$hash{'subcampo'}= $subcampo;
		$hash{'liblibrarian'}= C4::AR::Busquedas::getLiblibrarian($campo, $subcampo);
		$hash{'dato'}= $dato;

 		push(@$marc_array, \%hash);
C4::AR::Debug::debug("nivel1CompletoToMARC => ".$campo.", ".$subcampo."  ".$dato);	
	}
C4::AR::Debug::debug("nivel1CompletoToMARC => cant: ".scalar(@$marc_array));
	
	return ($marc_array);
}
# ==============================================FIN===SOPORTE=====ESTRUCTURA CATALOGACION================================================

1;

