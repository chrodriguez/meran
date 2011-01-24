#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use C4::AR::Auth;
use JSON;

my $query       = new CGI;
my $nro_socio   = $query->param('nro_socio');
my $filepath    = $query->param('planilla_xls');
my $authnotrequired = 0;

my ($loggedinuser, $session, $flags) = checkauth( 
                                                        $query, 
                                                        $authnotrequired,
                                                        {   ui              => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'MODIFICACION', 
                                                            entorno         => 'usuarios'},
                                                            "intranet"
                        );  

C4::AR::Debug::debug("uploadPicture.pl");


my ($error,$codMsg,$message) = &C4::AR::UploadFile::uploadPhoto($nro_socio, $filepath);


my %infoOperacion = (
        codMsg	=> $codMsg,
        error 	=> $error,
        message => $message,
);

my $infoOperacionJSON = to_json \%infoOperacion;

print $query->header;
# print $infoOperacionJSON;
print "<div id='responseText'>".$infoOperacionJSON."</div>";
## FIXME falta q en el cliente recupere bien la respuesta
