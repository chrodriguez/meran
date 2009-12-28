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
my(@connection, @resultset);

my $options = new ZOOM::Options();
   $options->option(preferredRecordSyntax => "USMARC");
#    $options->option(charset => "UTF-8");
   $options->option(elementSetName => "f");
   $options->option(async => 1);

#Genero la conexion a todos los servidores
foreach my $servidor (@$servidores){
    #creo la conexion
    my $conn = create ZOOM::Connection($options);
    $conn->connect($servidor->getConexion);
    push(@connection,$conn);
    #Realizo la consula
#    push(@resultset,$conn->search_pqf('"'.$cola->getBusqueda.'"'));
C4::AR::Debug::debug( 'Buscamos por a : '.$cola->getBusqueda);
push(@resultset, $conn->search(new ZOOM::Query::PQF($cola->getBusqueda)));

}
C4::AR::Debug::debug( 'Esperemos resultados a :  "'.$cola->getBusqueda.'"');
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
        goto MAYBE_AGAIN; #sale del lazo por un error CHANCHOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!!!!!!!!!!!!
    }

        my $registros = $resultset[$i-1]->size();
C4::AR::Debug::debug( "Encontrados $registros registros en ".$servidores->[$i-1]->getNombre." \n");
         # Aca se puede poner una cota al resultado de cada servidor
         my $max_results=C4::AR::Preferencias->getValorPreferencia('z3950_ cant_resultados');
        if ($max_results eq "MAX") {$max_results = $registros;} #Se recuperan TODOS los registros
         my $cant_registros=0;
         if ($registros > 0){

           for (my $pos = 0; (($pos < $registros) && ($cant_registros < $max_results)); $pos++) {
            my $registro = $resultset[$i-1]->record($pos);
            if (!defined $registro) {
                C4::AR::Debug::debug( "No se puede obtener registro ".($pos+1)."\n");
            } else {
                $cant_registros++;

                 my $raw=$registro->get("raw; charset=marc-8");

                 #si obtengo algun resultado creo el resultado
                my $resultado = C4::Modelo::CatZ3950Resultado->new();
                $resultado->setServidorId($servidores->[$i-1]->getId);
                $resultado->setColaId($cola->getId);
                $resultado->setRegistro($raw);
                $resultado->save;
                push(@resultados,$resultado);
            }
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
my ($termino,$busqueda) = @_;
    my $msg_object= C4::AR::Mensajes::create();
    $msg_object->{'tipo'}="INTRA";
    my $cola = C4::Modelo::CatZ3950Cola->new();
    
    $cola->setBusqueda($termino,$busqueda);
    $cola->setCola(C4::Date::getCurrentTimestamp());
    $cola->save();
    return $msg_object;
}

sub efectuarBusquedaZ3950 {
my ($cola) = @_;

$cola->setComienzo(C4::Date::getCurrentTimestamp());
$cola->save();

my (@resultados)=C4::AR::Z3950::buscarEnZ3950($cola);

$cola->setFin(C4::Date::getCurrentTimestamp());
$cola->save();



foreach my $resultado (@resultados) {
	#Buscamos las imágenes
	my $marc  = new_from_usmarc MARC::Record($resultado->getRegistro);
       $marc->encoding( 'UTF-8' );
    my $isbn = $marc->subfield("020","a");
                
   if ($isbn){
       my @isbns=split(/\s+/,$isbn);
       $isbn=$isbns[0];
       C4::AR::PortadasRegistros::getAllImagesByIsbn($isbn);
     }
	}
	
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

# FIXME esto es igual a detalleMARC de C4::AR::Catalogacion
sub detalleMARC {
    my ($marc) = @_;

    my @MARC_result_array;

    foreach my $field ($marc->fields) {
     if(! $field->is_control_field){
        my %hash;
        my $campo= $field->tag;
        my @info_campo_array;
#         C4::AR::Debug::debug("Proceso todos los subcampos del campo: ".$campo);
            #proceso todos los subcampos del campo
               foreach my $subfield ($field->subfields()) {
                my %hash_temp;
                my $subcampo                = $subfield->[0];
                my $dato                    = $subfield->[1];
                $hash_temp{'subcampo'}      = $subcampo;
                $hash_temp{'liblibrarian'}  = C4::AR::Catalogacion::getLiblibrarian($campo, $subcampo);
                $hash_temp{'dato'}          = $dato;
                push(@info_campo_array, \%hash_temp);
#                 C4::AR::Debug::debug("agrego el subcampo: ". $subcampo);
            }
            $hash{'campo'}                  = $campo;
            $hash{'header'}                 = C4::AR::Catalogacion::getHeader($campo);
            $hash{'info_campo_array'}       = \@info_campo_array;

            push(@MARC_result_array, \%hash);
#             C4::AR::Debug::debug("cant subcampos: ".scalar(@info_campo_array));
        }
    }

    return (\@MARC_result_array);
}


sub getResultado{
my ($id) = @_;

    use C4::Modelo::CatZ3950Resultado;
    use C4::Modelo::CatZ3950Resultado::Manager;

    my @filtros;
    push(@filtros, ( id    => { eq => $id}));

    my $res_array_ref = C4::Modelo::CatZ3950Resultado::Manager->get_cat_z3950_resultado( query => \@filtros);

    if (scalar(@$res_array_ref) == 0){
        return 0;
    }else{
        return $res_array_ref->[0];
    }
}

1;
__END__
