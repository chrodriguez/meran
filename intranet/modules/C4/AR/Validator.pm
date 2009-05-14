package C4::AR::Validator;


###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
####### Este PM tiene como fin contener todas las funciones que estén dedicadas a validar #########
# # # 	algún patrón específico sobre un string (generalmente). Si se cree que se puede   #########
# # # 	contener alguna otra función que valide otro tipo de dato, y ésta ultima se utiliza  ######
# # # 	en diferentes modulos, se incluye.						       ####
# # #											      #####	
# # # 		Autor: Gaspar Rajoy							      #####	
# # # 											      #####
###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################

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
	&isValidMail,
	&isValidDocument
	);



################################# FUNCIONES PARA PASSSWORD ########################

# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES EN MAYUSCULA 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.

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

# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES EN MINUSCULA 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.

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


# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES NUMERICOS 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.

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



# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES ALFANUMERICOS 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
sub countAlphaNumericChars{

	my($string)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
	my $charCount=0;
	for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
		$fragment = substr $string,$charCount,1;
		if (($fragment =~ tr/a-z//) 
				or 
		    ($fragment =~ tr/A-Z//) 
				or 
		    ($fragment =~ tr/0-9//)){
				
				$count++;
		}
	}
	return $count;
}


# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES ALFABETICOS 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.
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


# FUNCION QUE CUENTA LA CANTIDAD DE SIMBOLOS 
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.

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


# FUNCION QUE CUENTA LA CANTIDAD DE CARACTERES  
# DE UN STRING, AL CUAL RECIBE COMO PARAMETRO.

sub checkLength{

	my($string,$min_length)=@_;

	if (length($string) >= $min_length) {
        	return 1;
    	}
	return 0;
}



# FUNCION QUE CHECKEA QUE UN PASSWORD CUMPLA CON TODO LO ANTERIOR,
# ESPECIFICADO SEGUN LA DB.

sub checkPassword{

	my($password)=@_;
	my $msg_object= C4::AR::Mensajes::create();
	if (!(C4::AR::Utilidades::validateString($password))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U314', 'params' => []} ) ;
		return ($msg_object);
	}					

	if (!(&checkLength($password, C4::AR::Preferencias->getValorPreferencia('minPassLength')))) {
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U316', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countSymbolChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassSymbol'))) {
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countAlphaNumericChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassAlphaNumeric'))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U324', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countAlphaChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassAlpha'))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U325', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countNumericChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassNumeric'))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U326', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countLowerChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassLower'))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U327', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countUpperChars($password) >= C4::AR::Preferencias->getValorPreferencia('minPassUpper'))){
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U328', 'params' => []} ) ;
		return ($msg_object);
	}

	return ($msg_object);
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



# FUNCION QUE CHECKEA QUE UNA DIRECCION DE MAIL CUMPLA CON UN PATRON ESTANDAR
# PARA MAIL ADDRESS. RECIBE UN UNICO STRING.

sub isValidMail{

	my ($address) = @_;
	
	if($address =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/){ 
		return 1;
	}
	return 0;
}


################################# FIN FUNCIONES PARA MAIL ##################################


# FUNCION QUE VALIDA QUE UN NUMERO DE DOCUMENTO SEA VALIDO; RECIBE POR PARAMETRO EL TIPO Y EL NUMERO (EN ESE ORDEN).
# PARA LOS QUE NO SON DE TIPO DNI, SE COMPRUEBA SOLO QUE LA LONGITUD EN CARACTERES NUMERICOS SEA IGUAL A LA LONGITUD TOTAL.

sub isValidDocument{

	my($docType,$docNumber) = @_;
	my($checkResult) = 0;
	
	$docType = trim($docType);
	
    C4::AR::Debug::debug("Doctype: ".$docType." Number: ".$docNumber);
	if ($docType eq "DNI"){
		if ( countAlphaNumericChars($docNumber) ){
			if (length(trim($docNumber)) > 0){
			   $checkResult = 1;
			}
		}
	}
	else
	 {
		if ((&countAlphaNumericChars($docNumber) == (length($docNumber)) )){

			$checkResult = 1;
		}
	 }

	return ($checkResult);
}




