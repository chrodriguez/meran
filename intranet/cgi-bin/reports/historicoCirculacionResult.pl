#!/usr/bin/perl

use strict;
use C4::Auth;

use CGI;
use C4::AR::Estadisticas;
use C4::Date;

my $input = new CGI;


my ($template, $session, $t_params) = get_template_and_user({
                    template_name => "reports/historicoCirculacionResult.tmpl",
                    query => $input,
                    type => "intranet",
                    authnotrequired => 0,
                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                    debug => 1,
                });

my $orden= "fecha";  # $input->param('orden')||'operacion';

###Marca la Fecha de Hoy
my @datearr = localtime(time);
my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
my $dateformat = C4::Date::get_date_format();

$t_params->{'todaydate'}= format_date($today,$dateformat);


my $obj=$input->param('obj');

$obj= C4::AR::Utilidades::from_json_ISO($obj);
my $accion = $obj->{'accion'} || undef;
if ($accion){
    if ($accion = "NOTA_HISTORICO"){
        my $historico_tmp = C4::AR::Estadisticas::actualizarNotaHistoricoCirculacion($obj);
        C4::AR::Validator::validateObjectInstance($historico_tmp);
    }
}else{
    $obj->{'fechaIni'} =  format_date_in_iso($obj->{'fechaIni'},$dateformat);
    $obj->{'fechaFin'} =  format_date_in_iso($obj->{'fechaFin'},$dateformat);

    C4::AR::Validator::validateParams('VA001',$obj,['socio','tipoPrestamo','tipoOperacion']);

    my $dateformat = C4::Date::get_date_format();
    my $ini= ($obj->{'ini'});
    my ($ini,$pageNumber,$cantR)=&C4::AR::Utilidades::InitPaginador($ini);

    $obj->{'cantR'} = $cantR;
    $obj->{'pageNumber'} = $pageNumber;
    $obj->{'ini'} = $ini;

    my ($cantidad,$historicoCirculacionResult)= C4::AR::Estadisticas::historicoCirculacion($obj);

    $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$obj->{'funcion'},$t_params);
    $t_params->{'historico'}= $historicoCirculacionResult;
    $t_params->{'cantidad'}= $cantidad;
    $t_params->{'fechaFin'}= $obj->{'fechaFin'};
    $t_params->{'fechaInicio'}= $obj->{'fechaInicio'};
    $t_params->{'chkfecha'}= $obj->{'chkfecha'};
    $t_params->{'dateselected'}= $input->param('fechaIni');
    $t_params->{'dateselectedEnd'}= $input->param('fechaFin');
    $t_params->{'socio'}= $obj->{'socio'};
    $t_params->{'tiposPrestamos'}= $obj->{'tipoPrestamo'};
    $t_params->{'tipoOperacion'}= $obj->{'tipoOperacion'};

}
C4::Auth::output_html_with_http_headers($template, $t_params, $session);
