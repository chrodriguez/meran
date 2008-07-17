package C4::AR::Nivel3;


use strict;
require Exporter;
use C4::Context;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&detalleDisponibilidad
);


=item

=cut

=item
detalleDisponibilidad
Devuelve la disponibilidad del item que viene por paramentro.
=cut
sub detalleDisponibilidad{
        my ($item) = @_;
        my $dbh = C4::Context->dbh;
        my $query = "SELECT * FROM availability WHERE item = ? ORDER BY date DESC";
        my $sth = $dbh->prepare($query);
        $sth->execute($item);
	my @results;
	my $i=0;
	while (my $data=$sth->fetchrow_hashref){$results[$i]=$data; $i++; }
	$sth->finish;
	return(scalar(@results),\@results);
}




