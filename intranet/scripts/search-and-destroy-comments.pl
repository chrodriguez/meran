#!/usr/bin/perl

use File::Find;
use Tie::File;
use strict;

my $directory = $ARGV[0]; #Directorios a escanear

#Procesamos
find (\&process, $directory);

sub process
{
    my @lines;      #Linea leida.

    if (( $File::Find::name =~ /\.tmpl$/ ) or( $File::Find::name =~ /\.inc$/)or( $File::Find::name =~ /\.pm$/)or( $File::Find::name =~ /\.pl$/)) {

	print "Procesando $File::Find::name\n";
#     open (FILE, $File::Find::name ) or die "No se pudo abrir el archivo: $!";
    tie @lines, 'Tie::File', $File::Find::name, autochomp => 0  or die "No se pudo abrir el archivo: $!\n";
    foreach ( @lines ) {
        s/#.*\n//g;
    }
    untie @lines;
    }
 }
