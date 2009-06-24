#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use JSON;

my $query=new CGI;
my $bornum= $query->param('nro_socio');
my $filepath= $query->param('picture');

my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'CONSULTA', 
                                                entorno => 'usuarios'},
                                            "intranet"
                                );

my ($error,$codMsg,$message)= &C4::AR::UploadFile::uploadPhoto($bornum,$filepath);


my %infoOperacion = (
			codMsg	=> $codMsg,
			error 	=> $error,
			message => $message,
);

my $infoOperacionJSON=to_json \%infoOperacion;

print $query->header;
# print $infoOperacionJSON;
print "<div id='responseText'>".$infoOperacionJSON."</div>";
## FIXME falta q en el cliente recupere bien la respuesta
