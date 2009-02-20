package C4::AR::Preferencias;

#
#Este modulo sera el encargado del manejo de las preferencias del sistema.
#

use strict;
require Exporter;
use C4::Context;
use C4::Date;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&getPreferencia
	&getPreferenciaLike
	&t_guardarVariable
	&t_modificarVariable
);

=item
buscarPreferencias
Busca todas las variables del sistema o las que correspondan con el parametro que viene si es distinto de ("").
=cut
=item
sub buscarPreferencias(){
	my ($str)=@_;

	my $dbh = C4::Context->dbh;
	my @bind;
	my $query="SELECT variable,value,explanation,type,options FROM pref_preferencia_sistema ";
	if($str ne ""){
		$query.=" WHERE variable like ?";
		$str="%$str%";
		push(@bind,$str);
	}
	$query.=" ORDER BY variable";
	my $sth=$dbh->prepare($query);
        $sth->execute(@bind);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
        	push(@results,$data);
        }
        $sth->finish;

	return (\@results);
}

sub buscarPreferencia{
	my ($var)=@_;

	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM pref_preferencia_sistema WHERE variable=?";
	my $sth=$dbh->prepare($query);
        $sth->execute($var);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;

	return($data);
}
=cut

sub getPreferenciaLike {
	
	use C4::Modelo::PrefPreferenciaSistema;
	use C4::Modelo::PrefPreferenciaSistema::Manager;

   	my ($str,$orden)=@_;
    my $preferencias_array_ref;
    my @filtros;
    my $prefTemp = C4::Modelo::PrefPreferenciaSistema->new();
  
    $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
										query => [ variable=> { like => '%'.$str.'%' }],
    	                                sort_by => ( $prefTemp->sortByString($orden) ),
     							); 

    return (scalar($preferencias_array_ref), $preferencias_array_ref);


}


sub getPreferencia {

    use C4::Modelo::PrefPreferenciaSistema;

    my ($variable)= @_;

    my $preferencia_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [ variable => { eq => $variable} ]);

    return ($preferencia_array_ref->[0]);
}


=item
guardarVariable
guarda la variable del sistema ingresada.
=cut
sub t_guardarVariable {
	my ($var,$val,$exp,$tipo,$op)=@_;
	
	my $params;
	$params->{'variable'}= $var;
    	$params->{'value'}= $val;
	$params->{'explanation'}= $exp;
	$params->{'options'}= $op;
    	$params->{'type'}= $tipo;

    my $msg_object= C4::AR::Mensajes::create();
    _verificarDatosVariable($params,$msg_object);

    if(!$msg_object->{'error'}){
    	my ($preferencia) = C4::Modelo::PrefPreferenciaSistema->new();
        my $db = $preferencia->db;

		$db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
	eval {
        $preferencia->agregar($params);
		$db->commit;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP004', 'params' => []} ) ;
	};
	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'SP001','INTRA');
		eval{$db->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP001', 'params' => []} ) ;
	}
		$db->{connect_options}->{AutoCommit} = 1;
	}
	return ($msg_object);
}

sub _verificarDatosVariable {
	my($params,$msg_object)=@_;

	my $var= $params->{'variable'};
	my $val= $params->{'value'};
	my $type= $params->{'type'};
	my $exp= $params->{'explanation'};
	my $op= $params->{'options'};

#Se verifica que el no exista ya la variable que se quiere agregar
	if( getPreferencia($var) ){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP005', 'params' => []} ) ;
	}

}

sub t_modificarVariable {
	my ($var,$valor,$expl)=@_;
	
	my $params;
   	$params->{'value'}= $valor;
	$params->{'explanation'}= $expl;

	my $msg_object = C4::AR::Mensajes::create();
	my ($preferencia) = C4::Modelo::PrefPreferenciaSistema->new( variable => $var );
	$preferencia->load();
	my $db = $preferencia->db;	

	$db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
	eval {
		$preferencia->modificar($params);
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP003', 'params' => []} ) ;
		$db->commit;
	};

	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'SP001','INTRA');
		eval{$db->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP001', 'params' => []} ) ;
	}

	$db->{connect_options}->{AutoCommit} = 1;
	return ($msg_object);
}

=item
sub _modificarVariable(){
	my ($var,$valor,$expl)=@_;
	my $dbh = C4::Context->dbh;
	my $query=" UPDATE pref_preferencia_sistema SET value=?,explanation=? WHERE variable=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($valor,$expl,$var);
	$sth->finish;
}
=cut
