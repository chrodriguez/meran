package C4::AR::Z3950;
use strict;

use DBI;
use ZOOM;
use MARC::Record;
use Net::Z3950::ZOOM;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	&getServidoresZ3950
	&buscarEnZ3950
);

sub getServidoresZ3950 {

    use C4::Modelo::PrefServidorZ3950;
    use C4::Modelo::PrefServidorZ3950::Manager;
    my @filtros;
    push(@filtros, ( habilitado    => { eq => '1'}));

    my $servidores_array_ref = C4::Modelo::PrefServidorZ3950::Manager->get_pref_servidor_z3950( query => \@filtros);
    return ($servidores_array_ref);

}

sub buscarEnZ3950 {

my ($search) = @_;

C4::AR::Debug::debug("SE VA A BUSCAR ".$search);

my $servidores_array_ref = C4::AR::Z3950::getServidoresZ3950;

my $cant=0;
my @r;
my @z;
my $ev;
my $size;
my $i;
my @resultado;


my $query = new ZOOM::Query::CQL($search);

foreach my $servidor (@$servidores_array_ref){

C4::AR::Debug::debug("SERVIDOR".$servidor->getConexion);

    $z[$i] = new ZOOM::Connection($servidor->getConexion, 0,
				  async => 1, # asynchronous mode
				  count => 1, # piggyback retrieval count
				  preferredRecordSyntax => "usmarc");
    $r[$i] = $z[$i]->search($query);
}

while ((($i = ZOOM::event(\@z)) != 0)and($cant <= 10)) {
    $ev = $z[$i-1]->last_event();
    if ($ev == ZOOM::Event::ZEND) {

	$size = $r[$i-1]->size();
	#printf L "Se encontraron ".$size." registros\n";
	
	if ($size > 0) {
        for (my $j = 0; $j < $size; $j++) {
	        my $rec=$r[$i-1]->record($j);
        	my $raw = $rec->raw();
 	        my $marc = new_from_usmarc MARC::Record($raw);
            C4::AR::Debug::debug("Titulo ".$marc->title);
            push(@resultado,$marc);
	    }
	}
	}
}

return @resultado;
}


sub buscarEnZ3950Async {
my ($search) = @_;

my @results;

my $servidores_array_ref = C4::AR::Z3950::getServidoresZ3950;
my $query = new ZOOM::Query::CQL($search);
my(@connection, @resultset);			# connections, result sets

my $options = new ZOOM::Options();
$options->option(async => 1);
$options->option(count => 20);
$options->option(preferredRecordSyntax => "usmarc");

my $c=0;
foreach my $servidor (@$servidores_array_ref){
    my $conn = create ZOOM::Connection($options);
    $conn->connect($servidor->getConexion);
    $connection[$c]=$conn;
    $c++;
}

my $r=0;
foreach my $servidor (@$servidores_array_ref){
   $resultset[$r]=$connection[$r]->search($query);
   $r++;
}

# Network I/O.  Pass number of connections and array of connections
my $nremaining = @$servidores_array_ref;
AGAIN:
my $i;
while (($i = ZOOM::event(\@connection)) != 0) {
    my $ev = $connection[$i-1]->last_event();
    C4::AR::Debug::debug("Conexion ", $i-1, ": evento $ev (",Net::Z3950::ZOOM::event_str($ev), ")");
    last if $ev == ZOOM::Event::ZEND;
}

if ($i != 0) {
    # Not the end of the whole loop; one server is ready to display
    $i--;
    my $tname = $servidores_array_ref->[$i]->getNombre;
    # Display errors if any
   my($error, $errmsg, $addinfo, $diagset) = $connection[$i]->error_x();
   
 if ($error) {
#print STDERR "$tname error: $errmsg ($error) $addinfo\n";
	goto MAYBE_AGAIN;
    }

    # OK, no major errors.  Look at the result count
    my $size = $resultset[$i]->size();
     print "$tname: $size hits\n";
C4::AR::Debug::debug( "$tname: $size resultados");

    # Go through all records at target
    $size = 20 if $size > 20;
    for (my $pos = 0; $pos < $size; $pos++) {
C4::AR::Debug::debug( "$tname: buscando ", $pos+1, " de $size");
	my $tmp = $resultset[$i]->record($pos);
	
	if (!defined $tmp) {
C4::AR::Debug::debug( "$tname: no se puede obtener registro ", $pos+1, "\n");
	  #  print "$tname: can't get record ", $pos+1, "\n";
	    next;
	}

	my $raw = $tmp->raw();
 	my $marc = new_from_usmarc MARC::Record($raw);
    $marc->encoding( 'UTF-8' );
 C4::AR::Debug::debug("Titulo ".$marc->title);
	push(@results,$marc);

    }
}

MAYBE_AGAIN:
if (--$nremaining > 0) {
    goto AGAIN;
}

# Housekeeping
for (my $i = 0; $i < @$servidores_array_ref; $i++) {
C4::AR::Debug::debug( "Limpiando");
$resultset[$i]->destroy();
$connection[$i]->destroy();
}

$options->destroy();

return @results;
}

1;
__END__
