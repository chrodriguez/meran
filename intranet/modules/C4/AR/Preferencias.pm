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

	&buscarPreferencias
	&buscarPreferencia

	&t_guardarVariable

	&t_modificarVariable
);

=item
buscarPreferencias
Busca todas las variables del sistema o las que correspondan con el parametro que viene si es distinto de ("").
=cut
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

=item
guardarVariable
guarda la variable del sistema ingresada.
=cut
sub t_guardarVariable(){
	my ($var,$val,$exp,$tipo,$op)=@_;
	my $dbh = C4::Context->dbh;
	my $msg_object= C4::AR::Mensajes::create();

	# enable transactions, if possible
	$dbh->{AutoCommit} = 0;  
	$dbh->{RaiseError} = 1;

	eval {
		_guardarVariable($var,$val,$exp,$tipo,$op);	
		$dbh->commit;
	};

	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'SP001','INTRA');
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP001', 'params' => []} ) ;
	}
	$dbh->{AutoCommit} = 1;

	return ($msg_object);
}


sub _guardarVariable(){
	my ($var,$val,$exp,$tipo,$op)=@_;
	my $error=0;
	my $dbh = C4::Context->dbh;
	my $query=" SELECT * FROM pref_preferencia_sistema WHERE variable=? ";
	my $sth=$dbh->prepare($query);
	$sth->execute($var);
	if ($sth->rows){
		$error=1;
	}
	else{
		my $sth=$dbh->prepare("	INSERT INTO pref_preferencia_sistema (variable,value,explanation,type,options) 
					VALUES (?,?,?,?,?)");
		$sth->execute($var,$val,$exp,$tipo,$op);
	}
	$sth->finish;
}


sub t_modificarVariable(){
	my ($var,$valor,$expl)=@_;
	my $dbh = C4::Context->dbh;
	my $msg_object= C4::AR::Mensajes::create();

	# enable transactions, if possible
	$dbh->{AutoCommit} = 0;  
	$dbh->{RaiseError} = 1;

	eval {
		_modificarVariable($var,$valor,$expl);	
		$dbh->commit;
	};

	if ($@){
		#Se loguea error de Base de Datos
		&C4::AR::Mensajes::printErrorDB($@, 'SP002','INTRA');
		eval {$dbh->rollback};
		#Se setea error para el usuario
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP002', 'params' => []} ) ;
	}
	else
		{
			C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP003', 'params' => []} ) ;
		}	
	$dbh->{AutoCommit} = 1;

	return ($msg_object);
}
sub _modificarVariable(){
	my ($var,$valor,$expl)=@_;
	my $dbh = C4::Context->dbh;
	my $query=" UPDATE pref_preferencia_sistema SET value=?,explanation=? WHERE variable=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($valor,$expl,$var);
	$sth->finish;
}

