#!/usr/bin/perl
use CGI;
use C4::Context;
use C4::AR::UploadFile;
use C4::AR::Auth;
use JSON;
use strict;
use CGI::Carp qw(fatalsToBrowser);
use Digest::MD5;

my $query       = new CGI;
my $nro_socio   = $query->url_param('nro_socio');

my $authnotrequired = 0;

C4::AR::Debug::debug("NRO SOCIO FOTO:                 ".$nro_socio);



my ($nro_socio, $session, $flags) = checkauth( 
                                                        $query, 
                                                        $authnotrequired,
                                                        {   ui              => 'ANY', 
                                                            tipo_documento  => 'ANY', 
                                                            accion          => 'MODIFICACION', 
                                                            entorno         => 'usuarios'},
                                                            "intranet"
                        );  


#my ($error,$codMsg,$message) = C4::AR::UploadFile::uploadPhoto($nro_socio, $filepath);


################### PASARLO A C4::AR::UploadFile::uploadPhoto()

    my $uploaddir = C4::Context->config("picturesdir");


    my $maxFileSize = 2048 * 2048; # 1/2mb max file size...


    my $IN = $query;

    my $file = $IN->param('POSTDATA');

    my $name = $nro_socio;

    my $type;
    if ($file =~ /^GIF/i) {
        $type = "gif";
    } elsif ($file =~ /PNG/i) {
        $type = "png";
    } elsif ($file =~ /JFIF/i) {
        $type = "jpg";
    } else {
        $type = "jpg";
    }

    C4::AR::Debug::debug("ARCHIVO:        "."$name                     "."$uploaddir/$name.$type");


    if (!$type) {
        print qq|{ "success": false, "error": "Invalid file type..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    }

    open(WRITEIT, ">$uploaddir/$name.$type") or die "Cant write to $uploaddir/$name.$type. Reason: $!";
        print WRITEIT $file;
    close(WRITEIT);

    my $check_size = -s "$uploaddir/$name.$type";

    print STDERR qq|Main filesize: $check_size  Max Filesize: $maxFileSize \n\n|;

    print $IN->header();
    if ($check_size < 1) {
        print STDERR "ooops, its empty - gonna get rid of it!\n";
        print qq|{ "success": false, "error": "File is empty..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    } elsif ($check_size > $maxFileSize) {
        print STDERR "ooops, its too large - gonna get rid of it!\n";
        print qq|{ "success": false, "error": "File is too large..." }|;
        print STDERR "file has been NOT been uploaded... \n";
    } else  {
        print qq|{ "success": true }|;

        print STDERR "file has been successfully uploaded... thank you.\n";
    }

