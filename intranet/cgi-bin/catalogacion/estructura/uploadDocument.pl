#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use C4::AR::Auth;
use JSON;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use Digest::MD5;

C4::AR::Debug::debug("SE CREO CGI ");
my $query       = new CGI;
my $id2         = $query->url_param('id2');
my $name        = $query->url_param('qqfile');;
my $file_data   = $query->param('POSTDATA');
my $authnotrequired = 0;

C4::AR::Debug::debug("E-DOCUMENT PARA GRUPO:                 ".$id2);


my ($loggedinuser, $session, $flags) = checkauth( 
                                                        $query, 
                                                        $authnotrequired,
                                                        {   ui              => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'MODIFICACION', 
                                                            entorno         => 'usuarios'},
                                                            "intranet"
                        );  



my ($error,$msg) = C4::AR::UploadFile::uploadDocument($file_data,$name,$id2);

C4::AR::Debug::debug($msg);

print $query->header();
print $error;
