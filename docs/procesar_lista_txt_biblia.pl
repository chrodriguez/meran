#!/usr/local/perl
use strict;
require Exporter;
use C4::Context;
use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
use C4::Modelo::PrefEstructuraSubcampoMarc;
use C4::Modelo::PrefEstructuraCampoMarc::Manager;
use C4::Modelo::PrefEstructuraCampoMarc;
use C4::Modelo::PrefIndicadorPrimario::Manager;
use C4::Modelo::PrefIndicadorPrimario;
use C4::Modelo::PrefIndicadorSecundario::Manager;
use C4::Modelo::PrefIndicadorSecundario;

########Algunos metodos############
sub trim
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}


sub getCampo {
    my ($campo) = @_;
    my @filtros;
    push(@filtros, ( campo => { like => $campo} ) );
    my $db_campo_MARC = C4::Modelo::PrefEstructuraCampoMarc::Manager->get_pref_estructura_campo_marc( query => \@filtros );

    if (scalar(@$db_campo_MARC) > 0){
        return $db_campo_MARC->[0];
    }else{
        return 0;
    }
}

sub getSubCampo {
    my ($campo,$subcampo) = @_;
    my @filtros;
    push(@filtros, ( campo => { like => $campo} ) );
    push(@filtros, ( subcampo => { like => $subcampo} ) );
    my $db_subcampo_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc( query => \@filtros );

   if (scalar(@$db_subcampo_MARC) > 0){
        return $db_subcampo_MARC->[0];
    }else{
        return 0;
    }
}

my $data_file = $ARGV[0];
open(DATOS, $data_file) || die("Could not open file!");

my %datos;
my $line;
while ($line= <DATOS>) {
    while (!($line =~ /^[\d]{3,3}/)) {$line=<DATOS>;}
    
    #Campo Nuevo
    $line=trim($line);
    chomp($line);

    my $campo=substr($line,0,3);
    $datos{$campo}->{'descripcion'}=trim(substr($line,6));

    if($line =~ /\[OBSOLETE\]$/){$datos{$campo}->{'obsoleto'}=1;}
      elsif($line =~ /\[LOCAL\]$/){#print "CAMPO LOCAL WTF!!\n";
        }
	elsif($line =~ /\(R\)$/){$datos{$campo}->{'repetible'}=1;}
	  elsif($line =~ /\(NR\)$/){$datos{$campo}->{'repetible'}=0;}
	    else{#print "NO DICE NADA\n";
		  $datos{$campo}->{'repetible'}=0;}

    #Indicadores
    $line=<DATOS>;
    chomp($line);

    if($line =~ m/Indicators/) {
    
	while (!($line =~ m/First/)) {$line=<DATOS>;}
    chomp($line);
	$datos{$campo}->{'primario'}->{'descripcion'}= trim(substr($line,14));
	$line=<DATOS>;
	while (!($line =~ m/Second/)){
	
	  $line=trim($line);
	   chomp($line);
	  if($line =~ m/^0-9/){ #Caso especial - campo indicador  0-9
	    $datos{$campo}->{'primario'}->{'elementos'}->{'0-9'}=substr($line,6); 
	  }else{
	    $datos{$campo}->{'primario'}->{'elementos'}->{substr($line,0,1)}=substr($line,4);
	  }
	  
	  $line=<DATOS>;
	}
	
	$datos{$campo}->{'secundario'}->{'descripcion'}= trim(substr($line,15));
	$line=<DATOS>;
	while (!($line =~ m/Subfield Codes/)){

	  $line=trim($line);
      chomp($line);	  
	  if($line =~ m/^0-9/){ #Caso especial - campo indicador  0-9
	    $datos{$campo}->{'secundario'}->{'elementos'}->{'0-9'}=substr($line,6); 
	  }else{
	    $datos{$campo}->{'secundario'}->{'elementos'}->{substr($line,0,1)}=substr($line,4);
	  }
	  $line=<DATOS>;
	}
	
	$line=<DATOS>;
	while ((chomp($line) ne '')&&($line)) {
	  $line=trim($line);
	  my $subcampo;
	  
	  if(substr($line,2,1) eq '-'){#Caso especial por ej campo a-z!!
	    $subcampo=substr($line,1,3);
	    $datos{$campo}->{'subcampos'}->{$subcampo}->{'descripcion'}=substr($line,7);
	  }
	  else{
	    $subcampo=substr($line,1,1);
	    $datos{$campo}->{'subcampos'}->{$subcampo}->{'descripcion'}=substr($line,5);
	  }
	  if($line =~ /\[OBSOLETE\]$/){$datos{$campo}->{'subcampos'}->{$subcampo}->{'obsoleto'}=1;}
	    elsif($line =~ /\[LOCAL\]$/){#print "CAMPO LOCAL WTF!!\n";
        }
	      elsif($line =~ /\(R\)$/){$datos{$campo}->{'subcampos'}->{$subcampo}->{'repetible'}=1;}
		elsif($line =~ /\(NR\)$/){ $datos{$campo}->{'subcampos'}->{$subcampo}->{'repetible'}=0;}
		  else{	
		    #print "NO DICE NADA\n";
		    $datos{$campo}->{'subcampos'}->{$subcampo}->{'repetible'}=0;
		    }
	  
	  $line=<DATOS>;
	}
    }
}



####A RECORRER!!!!!!!!!!!!!!

while ( my ($key, $value) = each(%datos) ) {
    #Prosesamos el campo
    my $campo=getCampo($key);

    if($campo){ #El campo existe
      $campo->setLiblibrarian($value->{'descripcion'});
      $campo->setIndicadorPrimario($value->{'primario'}->{'descripcion'});
      $campo->setIndicadorSecundario($value->{'secundario'}->{'descripcion'});
      $campo->setRepeatable($value->{'repetible'});
      if($value->{'obsoleto'}){$campo->setDescripcion("OBSOLETO");}
      $campo->save;
    } 
    else { #campo nuevo
       my  $newcampo = C4::Modelo::PrefEstructuraCampoMarc->new();
      $newcampo->setCampo($key);
      $newcampo->setLiblibrarian($value->{'descripcion'});
      $newcampo->setIndicadorPrimario($value->{'primario'}->{'descripcion'});
      $newcampo->setIndicadorSecundario($value->{'secundario'}->{'descripcion'});
      $newcampo->setRepeatable($value->{'repetible'});
      if($value->{'obsoleto'}){$newcampo->setDescripcion("OBSOLETO");}
      $newcampo->save;
    }
  
    #Prosesamos los indicadores primarios
    my $first=$value->{'primario'}->{'elementos'};
    while ( my ($keyF, $valueF) = each(%$first) ){
       my $newindicadorp = C4::Modelo::PrefIndicadorPrimario->new();
          $newindicadorp->setCampo($key);
          $newindicadorp->setIndicador($keyF);
          $newindicadorp->setDato($valueF);
          $newindicadorp->save;
    }

    #Prosesamos los indicadores secundarios
    my $second=$value->{'secundario'}->{'elementos'};
    while ( my ($keyS, $valueS) = each(%$second) ) {
      my  $newindicadors = C4::Modelo::PrefIndicadorSecundario->new();
          $newindicadors->setCampo($key);
          $newindicadors->setIndicador($keyS);
          $newindicadors->setDato($valueS);
          $newindicadors->save;
     }
    
    #Subcampos!!!!!!
    my $subcampos = $value->{'subcampos'};
    while ( my ($keySub, $valueSub) = each(%$subcampos) ) {
        my $subcampo=getSubCampo($key,$keySub);

            if($subcampo){ #El subcampo existe
              $subcampo->setLiblibrarian($valueSub->{'descripcion'});
              $subcampo->setRepetible($valueSub->{'repetible'});
              if($valueSub->{'obsoleto'}){$subcampo->setDescripcion("OBSOLETO");}
              $subcampo->save;
            } 
            else { #subcampo nuevo
              my  $newsubcampo = C4::Modelo::PrefEstructuraSubcampoMarc->new();
              $newsubcampo->setCampo($key);
              $newsubcampo->setSubcampo($keySub);
              $newsubcampo->setLiblibrarian($valueSub->{'descripcion'});
              $newsubcampo->setLibopac($valueSub->{'descripcion'});
              $newsubcampo->setRepetible($valueSub->{'repetible'});
              if($value->{'obsoleto'}){$newsubcampo->setDescripcion("OBSOLETO");}
              $newsubcampo->save;
            }
     }
}

