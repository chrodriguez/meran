#!/usr/bin/perl

use strict;
use C4::AR::Auth;

use C4::AR::UploadFile;
use C4::AR::Reportes;
use JSON;
use CGI;

my $input = new CGI;

my $authnotrequired= 0;
open(A, ">>/tmp/debug.txt");
print A "desde usuariosRealesDB=>\n";

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";

my $dateformat = C4::Date::get_date_format();

=item
Aca se maneja el cambio de la password para el usuario
=cut
if($tipoAccion eq "GUARDAR_NOTA"){

    my $session = CGI::Session->load();
    
    my %params;
    $params{'idModificacion'}   = $obj->{'registro'};
    $params{'nota'}             = $obj->{'nota'};
    
#     my $rep_reg_mod = C4::Modelo::RepRegistroModificacion->new( idModificacion => $params{'idModificacion'} );
#     $rep_reg_mod->load();
#     $rep_reg_mod->nota($params{'nota'});
#     $rep_reg_mod->save();

    my $rep_reg_mod = C4::AR::Reportes::getRepRegistroModificacion($params{'idModificacion'});
    $rep_reg_mod->nota($params{'nota'});
    $rep_reg_mod->save();

# 	my ($Message_arrayref)= C4::AR::Usuarios::cambiarPassword(\%params);
	
# 	my $infoOperacionJSON=to_json $Message_arrayref;
	
    C4::AR::Auth::print_header($session);
# 	print $infoOperacionJSON;
	
} #end if($tipoAccion eq "CAMBIAR_PASSWORD")


=item
Aca se maneja el cambio de permisos para el usuario
=cut
elsif($tipoAccion eq "GUARDAR_PERMISOS"){
my ($nro_socio, $session, $flags) = checkauth($input, $authnotrequired,{borrowers=> 1},"intranet");
	my %params;
	$params{'id_socio'}= $obj->{'usuario'};
	$params{'array_permisos'}= $obj->{'array_permisos'};
	
 	my ($Message_arrayref)= C4::AR::Usuarios::t_cambiarPermisos(\%params);
	
	my $infoOperacionJSON=to_json $Message_arrayref;
	
    C4::AR::Auth::print_header($session);
	print $infoOperacionJSON;

} #end if($tipoAccion eq "GUARDAR_PERMISOS")
