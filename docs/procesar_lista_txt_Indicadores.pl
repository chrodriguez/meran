#!/usr/local/perl
open(DATOS,'/tmp/ecadlist.txt');
my %datos;
my $campo;
while(<DATOS>){
  chomp; 
  if ($_ =~ m/Indicators/ ){
		my $line=$_;
		while((!($line =~ m/Subfield Codes/))&&($line)){
		 $line=<DATOS>;
		 chomp($line);
		 #print "Indicators.$line";
		 if ($line =~ m/First/){
                 	$datos{$campo}->{"FIRST"}->{'descripcion'}= (split('-',$line))[1] ;
		 	#print  $datos{$campo}->{"FIRST"};
		 	$line=<DATOS>;
			chomp($line);
			while ((!($line =~ m/Second/))&&($line)){
			   my @dato=split('-',$line);
			   $datos{$campo}->{"FIRST"}->{'elementos'}->{$dato[0]}=$dato[1];
			   $line=<DATOS>;
			   chomp($line);
			} 
			$datos{$campo}->{"SECOND"}->{'descripcion'}=(split('-',$line))[1] ;
		 	$line=<DATOS>;
			chomp($line);
			
 			while((!($line =~ m/Subfield Codes/))&&($line)){
 			   my @dato=split('-',$line);
			   $datos{$campo}->{"SECOND"}->{'elementos'}->{$dato[0]}=$dato[1];
 			   $line=<DATOS>;
 			   chomp($line);
 			   #print $campo;
 		  	}
			while((!($line eq "\n"))&&($line)){
		 		$line=<DATOS>;
		 		chomp($line);
				
		 
			}
		}	

		}
		 
	}
  else{ if (substr($_,0,1) =~ m/[0-9]/ ){
	$campo= substr($_,0,3);
	print $campo;}
	}
}
while ( my ($key, $value) = each(%datos) ) {
           print "campo".$key."\n";
	   print "descripcion del first".($value->{"FIRST"}->{'descripcion'})."\n";
	   my $first=$value->{"FIRST"}->{'elementos'};
	   while ( my ($keyF, $valueF) = each(%$first) ){
		print "Indicador ".$keyF." es igual a ".$valueF."\n";}
           print "descripcion del second".$value->{"SECOND"}->{'descripcion'}."\n";
	   my $second=$value->{"SECOND"}->{'elementos'};
	   while ( my ($keyS, $valueS) = each(%$second) ) {
		print "Indicador ".$keyS." es igual a ".$valueS."\n";}
		
            }
