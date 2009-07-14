#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;
use C4::Auth;         # checkauth, getnro_socio.
use C4::Circulation::Circ2;
use C4::Interface::CGI::Output;
use C4::Date;

my $query = new CGI;

my $input = $query;

my ($template, $session, $t_params)= get_template_and_user({
                                    template_name => "opac-userupdate.tmpl",
                                    query => $query,
                                    type => "opac",
                                    authnotrequired => 1,
                                    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
             });


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

C4::AR::Validator::validateParams('VT001',\%data_hash,['nombre','apellido','direccion','numero_telefono','numero_fax','id_ciudad','email']);

$socio->persona->modificarVisibilidadOPAC(\%data_hash);

my $dateformat = C4::Date::get_date_format();
# handle the new information....
# collect the form values and send an email.
my @fields = ('surname', 'firstname', 'phone', 'faxnumber', 'streetaddress','city', 'emailaddress');
my $update;
$update->{'nro_socio'}=$nro_socio;
my $updateemailaddress= C4::AR::Preferencias->getValorPreferencia('KohaAdminEmailAddress');
if ($updateemailaddress eq '') {
    warn "La preferencia KohaAdminEmailAddress no esta seteada. No se puede enviar la informacion de actualizacion de $socio->persona->getApellido, $socio->persona->getNombre (#$nro_socio)\n";
    my ($template, $session, $t_params)= get_template_and_user({
                                            template_name => "kohaerror.tmpl",
                                            query => $query,
                                            type => "opac",
                                            authnotrequired => 1,
                                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                });

    $t_params->{'errormessage'} = 'La preferencia KohaAdminEmailAddress no esta seteada. Por favor visite la biblioteca para actualizar sus datos';

    C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
}

if ( C4::AR::Preferencias->getValorPreferencia('CheckUpdateDataEnabled')) {


#     if ($query->{'surname'}) {
#         # get all the fields:
#         my $message =  "El usuario  $socio->{'cardnumber'}
#                             ha requerido cambiar sus datos personales.
#                             Por favor chequee los cambios realizados:
#                             \nEOF";
#         foreach my $field (@fields){
#             my $newfield = $query->param($field);
#             $message .= "$field : $socio->$field  -->  $newfield\n";
#             $update->{$field}=$newfield;
#             
#         }
#         $message .= "\n\nGracias,\nKoha\n\n";
#         my %mail = ( To      => $updateemailaddress ,
#             From    => $updateemailaddress ,
#             Subject => "Cambio de caracteristicas de usuario.",
#             Message => $message );
#         if (sendmail %mail) {
#     # do something if it works....
#     
#             C4::AR::Usuarios::updateOpacBorrower($update);  #Se actualiza el registro del usuario
#         
#             warn "Mail sent ok\n";
#             print $query->redirect('/cgi-bin/koha/opac-user.pl');
#             exit;
#             } else {
#         # do something if it doesnt work....
#                 warn "Error sending mail: $Mail::Sendmail::error \n";
#         }
#     }
}

# $socio->{'dateenrolled'} = format_date($socio->{'dateenrolled'},$dateformat);
# $socio->{'expiry'}       = format_date($socio->{'expiry'},$dateformat);
# $socio->{'dateofbirth'}  = format_date($socio->{'dateofbirth'},$dateformat);


$t_params->{'socio'}= $socio,
$t_params->{'LibraryName'}= C4::AR::Preferencias->getValorPreferencia("LibraryName");

#otra vez einar con Guarani

$t_params->{'updatedata'} =(!C4::AR::Preferencias->getValorPreferencia('CheckUpdateDataEnabled'));


$t_params->{'pagetitle'}= "Actualizaci&oacute;n de datos personales";

C4::Auth::output_html_with_http_headers($query, $template, $t_params, $session);
