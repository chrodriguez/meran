#!/usr/local/perl
sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
my $data_file = $ARGV[0];
open(DATOS, $data_file) || die("Could not open file!");

my %datos;
my $line;
while ($line= <DATOS>) {
    while (!($line =~ /^[\d]{3,3}/)) {$line=<DATOS>;}
    
    #Campo Nuevo
    $line=trim($line);
    
    my $campo=substr($line,0,3);
    $datos{$campo}->{'descripcion'}=trim(substr($line,6));
    
    if($line =~ /\[OBSOLETE\]$/){$datos{$campo}->{'obsoleto'}=1;}
      elsif($line =~ /\[LOCAL\]$/){print "CAMPO LOCAL WTF!!\n";}
	elsif($line =~ /\(R\)$/){$datos{$campo}->{'repetible'}=1;}
	  elsif($line =~ /\(NR\)$/){$datos{$campo}->{'repetible'}=0;}
	    else{#print "NO DICE NADA\n";
		  $datos{$campo}->{'repetible'}=0;}

    #Indicadores
    $line=<DATOS>;
    
    if($line =~ m/Indicators/) {
    
	while (!($line =~ m/First/)) {$line=<DATOS>;}
	$datos{$campo}->{'primario'}->{'descripcion'}= trim(substr($line,14));
	$line=<DATOS>;
	while (!($line =~ m/Second/)){
	  chomp($line);
	  $line=trim($line);
	  
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
	  chomp($line);
	  $line=trim($line);
	  
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
	    elsif($line =~ /\[LOCAL\]$/){print "CAMPO LOCAL WTF!!\n";}
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
    print "UPDATE pref_estructura_campo_marc set indicadorPrimario=".'"'.$value->{'primario'}->{'descripcion'}.'"'.", IndicadorSecundario=".'"'.$value->{'secundario'}->{'descripcion'}.'"'." where campo=".$key.";\n";
    
    # print "campo".$key."\n";
    #print "descripcion del first".($value->{"FIRST"}->{'descripcion'})."\n";

    my $first=$value->{'primario'}->{'elementos'};
    while ( my ($keyF, $valueF) = each(%$first) ){
        print "INSERT into pref_indicadores_primarios (indicador,dato, campo_marc) values (".'"'.$keyF.'"'.",".'"'.$valueF.'"'.",".$key.");\n"
    }
    #print "descripcion del second".$value->{"SECOND"}->{'descripcion'}."\n";
    my $second=$value->{'secundario'}->{'elementos'};
    while ( my ($keyS, $valueS) = each(%$second) ) {
    #print "Indicador ".$keyS." es igual a ".$valueS."\n";}
        print "INSERT into pref_indicadores_secundarios (indicador,dato, campo_marc) values  (".'"'.$keyS.'"'.",".'"'.$valueS.'"'.",".$key.");\n"
     }

}

