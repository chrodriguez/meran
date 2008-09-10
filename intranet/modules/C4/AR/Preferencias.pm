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

	&guardarVariable

	&modificarVariable
);

=item
buscarPreferencias
Busca todas las variables del sistema o las que correspondan con el parametro que viene si es distinto de ("").
=cut
sub buscarPreferencias(){
	my ($str)=@_;

	my $dbh = C4::Context->dbh;
	my @bind;
	my $query="SELECT variable,value,explanation,type,options FROM systempreferences ";
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

sub buscarPreferencia(){
	my ($var)=@_;

	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM systempreferences WHERE variable=?";
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
sub guardarVariable(){
	my ($var,$val,$exp,$tipo,$op)=@_;

	my $error=0;
	my $dbh = C4::Context->dbh;
	my $query="SELECT * FROM systempreferences WHERE variable=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($var);
	if ($sth->rows){
		$error=1;
	}
	else{
		my $sth=$dbh->prepare("INSERT INTO systempreferences (variable,value,explanation,type,options) VALUES (?,?,?,?,?)");
		$sth->execute($var,$val,$exp,$tipo,$op);
	}
	$sth->finish;

	return $error;
}


sub modificarVariable(){
	my ($var,$valor,$expl)=@_;

	my $dbh = C4::Context->dbh;
	my $query=" UPDATE systempreferences SET value=?,explanation=? WHERE variable=?";
	my $sth=$dbh->prepare($query);
	$sth->execute($valor,$expl,$var);
	$sth->finish;
}