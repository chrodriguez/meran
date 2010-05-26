#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "reports/registroResult.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                            debug => 1,
                });

my $obj         = $input->param('obj');
$obj            = C4::AR::Utilidades::from_json_ISO($obj);

my $nota        = $obj->{'notas'};
my $id          = $obj->{'id'};
my $funcion     = $obj->{'funcion'};

# if ($id ne ""){
#         insertarNota($id,$nota);
# }

#Inicializo el inicio y fin de la instruccion LIMIT en la consulta
my $ini                         = $obj->{'ini'};
my ($ini,$pageNumber,$cantR)    = C4::AR::Utilidades::InitPaginador($ini);
#FIN inicializacion
$obj->{'cantR'}                 = $cantR;
$obj->{'fin'}                   = $ini;

my $dateformat                  = C4::Date::get_date_format();
#Tomo las fechas que setea el usuario y las paso a formato ISO
my $fechaInicio                 =  format_date_in_iso($obj->{'dateselected'},$dateformat);
my $fechaFin                    =  format_date_in_iso($obj->{'dateselectedEnd'},$dateformat);
my $cant;


$obj->{'orden'}                 = $obj->{'orden'}||'surname';
$obj->{'fechaInicio'}           = $fechaInicio;
$obj->{'fechaFin'}              = $fechaFin;

my ($cantidad_registros, $rep_registro_modificacion_array_ref) = C4::AR::Estadisticas::registroEntreFechas($obj);


my @results;
my $nivel;

foreach my $r (@$rep_registro_modificacion_array_ref){
    my %info;

C4::AR::Debug::debug("tipo => ".$r->getTipo());
C4::AR::Debug::debug("tipo => ".$r->getNota());

    if($r->getTipo() eq "Registro"){
        $nivel          = C4::AR::Nivel1::getNivel1FromId1($r->getNumero());
        $info{'id1'}    = $nivel->getId1();
        $info{'titulo'} = $nivel->getTitulo();
    } elsif ($r->getTipo() eq "Grupo") {
        $nivel          = C4::AR::Nivel2::getNivel2FromId2($r->getNumero());
        $info{'id1'}    = $nivel->getId1();
        $info{'titulo'} = $nivel->nivel1->getTitulo();
    } elsif ($r->getTipo() eq "Ejemplar") {
        $nivel          = C4::AR::Nivel3::getNivel3FromId3($r->getNumero());
        $info{'id1'}    = $nivel->getId1();
        $info{'titulo'} = $nivel->nivel1->getTitulo();
    }

#     my $socio_responsable       = $r->socio_responsable;
#     $info{'titulo'}             = $nivel->getTitulo();
    $info{'nro_socio'}          = $r->socio_responsable->getNro_socio();
    $info{'apellido'}           = $r->socio_responsable->persona->getApellido();
    $info{'nombre'}             = $r->socio_responsable->persona->getNombre();
#     $info{'nro_socio'}          = $socio_responsable->getNro_socio();
#     $info{'apellido'}           = $socio_responsable->persona->getApellido();
#     $info{'nombre'}             = $socio_responsable->persona->getNombre();
    $info{'fecha'}              = $r->getFecha();
    $info{'tipo'}               = $r->getTipo();
    $info{'operacion'}          = $r->getOperacion();
    $info{'idModificacion'}     = $r->getIdModificacion();
    $info{'nota'}               = $r->getNota();

    push (@results, \%info);
} 


# C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);

# $t_params->{'registros'}    = $rep_registro_modificacion_array_ref;
$t_params->{'registros'}    = \@results;
$t_params->{'cantidad'}     = $cantidad_registros;
$t_params->{'paginador'}    = C4::AR::Utilidades::crearPaginador($cantidad_registros,$cantR, $pageNumber,$funcion,$t_params);

C4::Auth::output_html_with_http_headers($template, $t_params, $session);
