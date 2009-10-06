package C4::AR::Z3950;
use strict;

use DBI;
use ZOOM;
use C4::Date;
use MARC::Record;
use Net::Z3950::ZOOM;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw(
	&getServidoresZ3950
	&buscarEnZ3950
    &encolarBusquedaZ3950
    &busquedasEncoladas
    &limpiarBusquedas
    &efectuarBusquedaZ3950
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

	$z[$i] = new ZOOM::Connection(
 		 	$servidor->getServidor,
  			$servidor->getPuerto,
  			databaseName => $servidor->getBase,
  			user => $servidor->getUsuario,
  			password => $servidor->getPassword,
  			elementSetName => "f",
  			preferredRecordSyntax => "1.2.840.10003.5.1", # UNIMARC
			async => 1, # asynchronous mode
			count => 1, # piggyback retrieval count
		);


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
my ($cola) = @_;

my @resultados;

my $servidores_array_ref = C4::AR::Z3950::getServidoresZ3950;
my $query = new ZOOM::Query::CQL($cola->getBusquedaFinal);
my(@connection, @resultset); # connections, result sets

my $options = new ZOOM::Options();
$options->option(async => 1);

my $c=0;
foreach my $servidor (@$servidores_array_ref){
    my $conn = create ZOOM::Connection($options);
    $conn->connect($servidor->getConexion);
    $connection[$c]=$conn;
    $c++;
}

my $r=0;
foreach my $servidor (@$servidores_array_ref){
   $resultados[$r]=  C4::Modelo::CatZ3950Resultado->new();
   $resultados[$r]->setServidorId($servidor->getId);
   $resultados[$r]->setColaId($cola->getId);
   $resultados[$r]->setRegistros("");

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
    $i--;    my $tname = $servidores_array_ref->[$i]->getNombre;

    # Display errors if any
   my($error, $errmsg, $addinfo, $diagset) = $connection[$i]->error_x();
   
 if ($error) {
#print STDERR "$tname error: $errmsg ($error) $addinfo\n";  push(@results,$marc);
	goto MAYBE_AGAIN;
    }

    # OK, no major errors.  Look at the result count
    my $size = $resultset[$i]->size();
    $resultados[$i]->setCantRegistros($resultset[$i]->size());

     print "$tname: $size hits\n";
     C4::AR::Debug::debug( "$tname: $size resultados");

    for (my $pos = 0; $pos < $size; $pos++) {
        C4::AR::Debug::debug( "$tname: buscando ".($pos+1)." de $size");
	    my $tmp = $resultset[$i]->record($pos);
	
	    if (!defined $tmp) {
            C4::AR::Debug::debug( "$tname: no se puede obtener registro ".($pos+1)."\n");
	        next;
	    }

	    my $raw = $tmp->raw();
        if ($resultados[$i]->getRegistros){    $resultados[$i]->setRegistros($resultados[$i]->getRegistros."\n".$tmp->render());}
            else{ $resultados[$i]->setRegistros($raw);}
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

return  (@resultados);
}

sub encolarBusquedaZ3950 {
my ($busqueda,$tipo) = @_;
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my $cola = C4::Modelo::CatZ3950Cola->new();
    $cola->setBusqueda($busqueda);
    $cola->setTipo($tipo);
    $cola->setCola(C4::Date::getCurrentTimestamp());
    $cola->save();
    return $msg_object;
}

sub efectuarBusquedaZ3950 {
my ($cola) = @_;

$cola->setComienzo(C4::Date::getCurrentTimestamp());
$cola->save();

my (@resultados)=C4::AR::Z3950::buscarEnZ3950Async($cola);

foreach my $zres (@resultados) {
$zres->save;
}

$cola->setFin(C4::Date::getCurrentTimestamp());
$cola->save();
}


sub getBusquedas{

    use C4::Modelo::CatZ3950Cola;
    use C4::Modelo::CatZ3950Cola::Manager;
    my $busquedas_array_ref = C4::Modelo::CatZ3950Cola::Manager->get_cat_z3950_cola(sort_by => 'cola');

    if (scalar(@$busquedas_array_ref) == 0){
        return 0;
    }else{
        return $busquedas_array_ref;
    }
}


sub busquedasEncoladas {

    use C4::Modelo::CatZ3950Cola;
    use C4::Modelo::CatZ3950Cola::Manager;

    my @filtros;
    push(@filtros, ( comienzo => undef ));

    my $busquedas_array_ref = C4::Modelo::CatZ3950Cola::Manager->get_cat_z3950_cola( query => \@filtros, sort_by => 'cola');

  if (scalar(@$busquedas_array_ref) == 0){
        return 0;
  }else{
    return $busquedas_array_ref;
  }

}

sub limpiarBusquedas {
    my $err;

    my $session = CGI::Session->load();
    print $session->param("type")."\n";

    my $hasta = Date::Manip::DateCalc("today","- 1 days",\$err);
    my $dateformat= C4::Date::get_date_format();
    $hasta = C4::Date::format_date_in_iso($hasta, $dateformat);

    use C4::Modelo::CatZ3950Cola;
    use C4::Modelo::CatZ3950Cola::Manager;
    my @filtros;
    push(@filtros, ( cola => { lt => $hasta} ));

    C4::Modelo::CatZ3950Cola::Manager->delete_cat_z3950_cola( query => \@filtros, all=>1);

}
1;
__END__
