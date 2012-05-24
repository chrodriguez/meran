=item

#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Auth;
use C4::AR::Utilidades;
use JSON;

my $query = new CGI;

my $input = $query;
my $authnotrequired= 0;
my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-userupdate.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
             });


my $msg_object;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

if ($tipoAccion eq 'CAMBIAR_PASSWORD'){
    my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'usuarios'
                                            },
                                            "opac"
                                );

    my $session = CGI::Session->load();

    my %params;
    $params{'nro_socio'}= $obj->{'usuario'};
    $params{'actualPassword'}= $obj->{'actualPassword'};
    $params{'newpassword'}= $obj->{'newpassword'};
    $params{'newpassword1'}= $obj->{'newpassword1'};
    $params{'session'}= $session;
#     C4::AR::Validator::validateParams('U389',\%params,['nro_socio','actualPassword','newpassword','newpassword1']);

    my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);

    my $infoOperacionJSON=to_json $Message_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

}
else{

    my $nro_socio = $session->param('nro_socio');
    # get borrower information ....
    my ($socio, $flags) = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);

    C4::AR::Validator::validateObjectInstance($socio);

    my %data_hash;

    $data_hash{'nombre'} = $input->param('nombre');
    $data_hash{'apellido'} = $input->param('apellido');
    $data_hash{'direccion'} = $input->param('direccion');
    $data_hash{'numero_telefono'} = $input->param('numero_telefono');
    $data_hash{'numero_fax'} = $input->param('numero_fax');
    $data_hash{'id_ciudad'} = $input->param('id_ciudad');
    $data_hash{'email'} = $input->param('email');

    if (C4::AR::Validator::checkParams('VT001',\%data_hash,['nombre','apellido','direccion','numero_telefono','numero_fax','id_ciudad','email'])){

        $socio->persona->modificarVisibilidadOPAC(\%data_hash);

        my $dateformat = C4::Date::get_date_format();
        # handle the new information....
        # collect the form values and send an email.
        my @fields = ('surname', 'firstname', 'phone', 'faxnumber', 'streetaddress','city', 'emailaddress');
        my $update;
        $update->{'nro_socio'}=$nro_socio;
        my $updateemailaddress= C4::AR::Preferencias::getValorPreferencia('KohaAdminEmailAddress');
        if ($updateemailaddress eq '') {
            warn "La preferencia KohaAdminEmailAddress no esta seteada. No se puede enviar la informacion de actualizacion de $socio->persona->getApellido, $socio->persona->getNombre (#$nro_socio)\n";
            my ($template, $session, $t_params)= get_template_and_user({
                                                    template_name => "kohaerror.tmpl",
                                                    query => $query,
                                                    type => "opac",
                                                    authnotrequired => 1,
                                                    flagsrequired => {  ui => 'ANY', 
                                                                        tipo_documento => 'ANY', 
                                                                        accion => 'CONSULTA', 
                                                                        entorno => 'undefined'},
                        });

            $t_params->{'errormessage'} = 'La preferencia KohaAdminEmailAddress no esta seteada. Por favor visite la biblioteca para actualizar sus datos';

            C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
        }
    }

    $t_params->{'socio'}= $socio,
#    $t_params->{'LibraryName'}= C4::AR::Preferencias::getValorPreferencia("LibraryName");

    #otra vez einar con Guarani

    $t_params->{'updatedata'} =(!C4::AR::Preferencias::getValorPreferencia('CheckUpdateDataEnabled'));

    $t_params->{'pagetitle'}= "Actualizaci&oacute;n de datos personales";

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

}

=cut