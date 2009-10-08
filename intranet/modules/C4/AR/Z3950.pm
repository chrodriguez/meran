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
my ($cola) = @_;

my @resultados;

my $servidores = C4::AR::Z3950::getServidoresZ3950;
my $query = new ZOOM::Query::CQL($cola->getBusquedaFinal);
my(@connection, @resultset);

my $options = new ZOOM::Options();
   $options->option(preferredRecordSyntax => "USMARC");
#    $options->option(charset => "UTF-8");
   $options->option(elementSetName => "F");
   $options->option(async => 1);

#Genero la conexion a todos los servidores
foreach my $servidor (@$servidores){
    #creo la conexion
    my $conn = create ZOOM::Connection($options);
    $conn->connect($servidor->getConexion);
    push(@connection,$conn);
    #Realizo la consula
    push(@resultset,$conn->search_pqf($cola->getBusqueda));
}

# Network I/O.  Pass number of connections and array of connections
my $conexiones = scalar(@connection);
AGAIN:
my $i;
while (($i = ZOOM::event(\@connection)) != 0) {
    my $ev = $connection[$i-1]->last_event();
    last if $ev == ZOOM::Event::ZEND;
}


if ($i != 0) {
 # No es el fin, un servidor esta listo para mostrar resultados
    my($error, $errmsg, $addinfo, $diagset) = $connection[$i-1]->error_x();

    if ($error) {
         C4::AR::Debug::debug( "Error: $errmsg ($error) $addinfo\n");
        goto MAYBE_AGAIN; #sale del lazo por un error
    }

        my $registros = $resultset[$i-1]->size();
C4::AR::Debug::debug( "Encontrados $registros registros en ".$servidores->[$i-1]->getNombre." \n");
         # Aca se puede poner una cota al resultado de cada servidor
         my $max_results=C4::AR::Preferencias->getValorPreferencia('z3950_ cant_resultados');
         my $cant_registros=0;
         if ($registros > 0){
            #si obtengo algun resultado creo el resultado
            my $resultado = C4::Modelo::CatZ3950Resultado->new();
            $resultado->setServidorId($servidores->[$i-1]->getId);
            $resultado->setColaId($cola->getId);
            $resultado->setRegistros("");

           for (my $pos = 0; (($pos < $registros) && ($cant_registros < $max_results)); $pos++) {
            my $registro = $resultset[$i-1]->record($pos);
            if (!defined $registro) {
                C4::AR::Debug::debug( "No se puede obtener registro ".($pos+1)."\n");
            } else {
                $cant_registros++;

                my $raw=$registro->get("raw; charset=marc-8");

                if ($resultado->getRegistros){
                    $resultado->setRegistros($resultado->getRegistros."\n".$raw);
                }else{ 
                    $resultado->setRegistros($raw);
                }
            }
            }
            #Guardo el resultado
            if($cant_registros > 0){ #Si hay registros sin error
            $resultado->setCantRegistros($cant_registros);
            push(@resultados,$resultado);
            }
        }
}

MAYBE_AGAIN:
if (--$conexiones > 0) { # Si $conexiones se hace 0 se termino la busqueda
    goto AGAIN;
}


# Limpieza
for (my $i = 0; $i <  scalar(@connection) ; $i++) {
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

my (@resultados)=C4::AR::Z3950::buscarEnZ3950($cola);

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

sub getBusqueda{
my ($id) = @_;

    use C4::Modelo::CatZ3950Cola;
    use C4::Modelo::CatZ3950Cola::Manager;

    my @filtros;
    push(@filtros, ( id    => { eq => $id}));

    my $busqueda_array_ref = C4::Modelo::CatZ3950Cola::Manager->get_cat_z3950_cola( query => \@filtros);

    if (scalar(@$busqueda_array_ref) == 0){
        return 0;
    }else{
        return $busqueda_array_ref->[0];
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
