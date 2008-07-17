package C4::AR::Nivel1;

use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&buscarNivel1PorId3
	&getAutoresAdicionales
	&getColaboradores

);


=item

=cut

=item
buscarNivel1PorId3
Devuelve los datos del nivel 1 a partir de un id3
=cut
sub buscarNivel1PorId3{
        my ($id3) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT n1.*,a.* FROM nivel1 n1 INNER JOIN nivel3 n3 ON n1.id1 = n3.id1 
		     LEFT JOIN autores a ON n1.autor = a.id WHERE id3=? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($id3);
        my $res=$sth->fetchrow_hashref;
        $sth->finish();
        return $res;
}



sub getAutoresAdicionales(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}


sub getColaboradores(){
	my ($id)=@_;

# 	falta implementar, seria un campo de nivel 1 repetibles
}
