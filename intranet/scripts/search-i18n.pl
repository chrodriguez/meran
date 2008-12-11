#!/usr/bin/perl

use File::Find;
use Locale::PO;
use strict;

my $directory = $ARGV[0]; #Directorios a escanear
my $output_po = $ARGV[1]; #Archivo PO resultado 
my @outLines;  #Arreglo de POs

find (\&process, $directory);


#Salvamos el po
Locale::PO->save_file_fromarray($output_po,\@outLines);

#open( OUT, ">>$output_po" ) or return undef;
#foreach (@outLines)  { print OUT $_->dump();}
#close OUT;

undef( @outLines );


sub trim
{
 my ($string)=@_;
$string =~ s/^\s+//;
$string =~ s/\s+$//;
return $string;
}

sub process
{
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
 	my $po = new Locale::PO();
 	$po->msgid($str);
       	$po->msgstr("");
       	$po->comment("$File::Find::name");
	
	#Reviso si no existe!!!
	my $i=0;
	while ($i<@outLines)
  	{	if ($outLines[$i]->msgid() eq $po->msgid()) {$exists=1;}
		$i++;
	}
	 if($exists == 0){ push(@outLines, $po);}
	}
        }
        close FILE;
    }
}
