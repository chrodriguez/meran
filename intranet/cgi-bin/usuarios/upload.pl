#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use JSON;

my $query=new CGI;
my $bornum= $query->param('bornum');
my $filepath= $query->param('picture');

# my $foto_name= $query->param('foto_name');
# ($foto_name) || ($foto_name=0);
# my $msg= &C4::AR::UploadFile::uploadPhoto($bornum,$filepath);

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
