#!/usr/bin/perl

use File::Find;
use Locale::PO;
use strict;

my $directory = $ARGV[0]; #Directorios a escanear
my $output_po = $ARGV[1]; #Archivo PO resultado 

find (\&process, $directory);

sub process
{
    my @outLines;  #Arreglo de POs
    my $line;      #Linea leida.

    #Buscamos solo los  .tmpl
    if ( $File::Find::name =~ /\.tmpl$/ ) {
	print "Procesando $File::Find::name\n";
        open (FILE, $File::Find::name ) or die "No se pudo abrir el archivo: $!";

        while ( $line = <FILE> ) {

	 if ($line =~ /(\[%)\s*[" ']*\s*(.*)\s*[" ']*\s*(\| i18n %])/)
	{
	   my $po = new Locale::PO();
	   $po->msgid("$2");
           $po->msgstr("");
           $po->comment("$File::Find::name");
	
	   push(@outLines, $po);
	}

        }
        close FILE;

	#Salvamos el po
	Locale::PO->save_file_fromarray($output_po,\@outLines);

       undef( @outLines );
    }
}