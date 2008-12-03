#!/usr/bin/perl

use File::Find;
use Locale::PO;
use strict;

my $directory = $ARGV[0]; #Directorios a escanear
my $output_po = $ARGV[1]; #Archivo PO resultado 

find (\&process, $directory);

sub trim
{
 my ($string)=@_;
$string =~ s/^\s+//;
$string =~ s/\s+$//;
return $string;
}

sub process
{
    my @outLines;  #Arreglo de POs
    my $line;      #Linea leida.
    my @matches;
    #Buscamos solo los  .tmpl
    if ( $File::Find::name =~ /\.tmpl$/ ) {
	print "Procesando $File::Find::name\n";
        open (FILE, $File::Find::name ) or die "No se pudo abrir el archivo: $!";

        while ( $line = <FILE> ) {
	@matches = ($line =~ /\[%\s*['"]*\s*([^{",\|,'}]*)\s*['"]*\s*\|\s*i18n\s*%]/g);
	foreach my $m (@matches)
	{
	 my $str=&trim($m);
	 my $exists=0;
	foreach my $p (@outLines) {
				if ($p->msgid() eq '"'.$str.'"'){$exists=1;} #Busco si no existe y con los ""
				} 

	 if($exists==0){
	 	my $po = new Locale::PO();
	 	$po->msgid($str);
         	$po->msgstr("");
         	$po->comment("$File::Find::name");
		 push(@outLines, $po);
	 }

	}

        }
        close FILE;



    #Salvamos el po
    open( OUT, ">>$output_po" ) or return undef;
    foreach (@outLines)  { print OUT $_->dump();}
    close OUT;

    undef( @outLines );
    }
}
