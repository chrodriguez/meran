#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use JSON;

my $input               = new CGI;
my $authnotrequired     = 0;
my $obj                 = $input->param('obj');
$obj                    = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion          = $obj->{'tipoAccion'}||"";

if($tipoAccion eq "ENVIAR_MAILS_PRESTAMOS_VENCIDOS"){

    my ($user, $session, $flags) = checkauth($input, 
                                            $authnotrequired, 
                                            {   ui              => 'ANY', 
                                                tipo_documento  => 'ANY', 
                                                accion          => 'ALTA', 
                                                entorno         => 'undefined' },
                                            'intranet'
                           );

    my ($Messages_arrayref)  = C4::AR::Prestamos::enviarRecordacionDePrestamoVencidos();

    my $infoOperacionJSON = to_json $Messages_arrayref;

    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
    
}
