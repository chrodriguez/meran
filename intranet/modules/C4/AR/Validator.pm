package C4::AR::Validator;


use strict;
use C4::AR::Utilidades;
use C4::AR::Address;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);
@EXPORT=qw( 
	&checkPassword,
	&checkLength,
	&countUpperChars,
	&countLowerChars,
	&countNumericChars,
	&countAlphaNumericChars,
	&countAlphaChars,
	&countSymbolChars,
	&isValidMail
	);



################################# FUNCIONES PARA PASSSWORD ########################

=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES EN MAYUSCULA 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countUpperChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if ($fragment =~ tr/A-Z//){
			$count++;
		}
	}
	return $count;
}

=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES EN MINUSCULA 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countLowerChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount=0;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if ($fragment =~ tr/a-z//){
			$count++;
		}
	}
	return $count;
}		

=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES NUMERICOS 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countNumericChars{

	my($string)=@_;
	my $stringLength=length($string);
	my $count=0;
	my $fragment;
	my $charCount;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if ($fragment =~ tr/0-9//){
			$count++;
		}
	}
	return $count;
}


=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES ALFANUMERICOS 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countAlphaNumericChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount=0;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if (($fragment =~ tr/a-z//) 
				and 
		    ($fragment =~ tr/A-Z//) 
				and  
		    ($fragment =~ tr/0-9//)){
				
				$count++;
		}
	}
	return $count;
}

=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES ALFABETICOS 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countAlphaChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount=0;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if (($fragment =~ tr/a-z//) 
				and 
		    ($fragment =~ tr/A-Z//) 
					){
				
				$count++;
		}
	}
	return $count;
}

=item
FUNCION QUE CUENTA LA CANTIDAD DE SIMBOLOS 
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub countSymbolChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount=0;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if ($fragment =~ tr/#-.//){
			$count++;
		}
	}
	return $count;
}

=item
FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES  
DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
=cut
sub checkLength{

	my($string,$min_length)=@_;

	if (length($string) >= $min_length) {
        	return 1;
    	}
	return 0;
}


=item
FUNCION QUE CHECKEA QUE UN PASSWORD CUMPLA CON TODO LO ANTERIOR,
ESPECIFICADO SEGUN LA DB.
=cut
sub checkPassword{

	my($params)=@_;

	#obtengo todas las preferencias
	my $preferences_hashref= C4::Context->preferences();
	my($string) = $params->{'newpassword'};
open(A, ">>/tmp/debug.txt");
print A "check \n";
print A "string  ".$string."\n";

	if ((C4::AR::Utilidades::validateString($string))){
		print A "entro a validateString \n";
		return (1,'U314');
	}					
print A "minPassLength ".C4::Context->preference('minPassLength')."\n";

	if (! ( &checkLength($string, C4::Context->preference('minPassLength') ) ) ){
print A "entro a checkLength \n";
		return (1,'U316');
	}

	if (!(&countSymbolChars($string) >= 0)){
print A "entro a countSymbolChars \n";
		return (1,'U319');
	}

	if (!(&countAlphaNumericChars($string) >= 0)){
print A "entro a countAlphaNumericChars \n";
		return (1,'U324');
	}

	if (!(&countAlphaChars($string) >= 0)){
print A "entro a countAlphaChars \n";
		return (1,'U325');
	}

	if (!(&countNumericChars($string) >= 0)){
print A "entro a countNumericChars \n";
		return (1,'U326');
	}

	if (!(&countLowerChars($string) >= 0)){
print A "entro a countLowerChars \n";
		return (1,'U327');
	}

	if (!(&countUpperChars($string) >= 0)){
print A "entro a countUpperChars \n";
		return (1,'U328');
	}

close(A);

	return (0,"NO ERROR");
}

# 
# sub checkPattern{
# 
# 	my($string,$pattern)=@_;
# 	my($stringLength)=length($string);
# 	my($count)=0;
# 	my($fragment);
# 	my $charCount=0; 
#  	foreach $specificPattern $pattern {
# 		for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
# 			$fragment = substr $string,$charCount,1;
# 			if ($string =~ tr/$specificPattern/){
# 				$count++;
# 			}
# 		}
#     	}
# }

################################# FIN FUNCIONES PARA PASSSWORD ########################

################################# FUNCIONES PARA MAIL ##################################


=item
FUNCION QUE CHECKEA QUE UNA DIRECCION DE MAIL CUMPLA CON UN PATRON ESTANDAR
PARA MAIL ADDRESS. RECIBE UN UNICO STRING.
=cut
sub isValidMail{

	my ($address) = @_;
	
	if($address =~ /^[A-z0-9_\-]+[@][A-z0-9_\-]+([.][A-z0-9_\-]+)+[A-z]{2,4}$/){
		return 1;
	}
	return 0;
}


################################# FIN FUNCIONES PARA MAIL ##################################









