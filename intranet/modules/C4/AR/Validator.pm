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
				and 
		    ($fragment =~ tr/A-Z//) 
				and  
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

	my($params)=@_;
	my $msg_object= C4::AR::Mensajes::create();

	#obtengo todas las preferencias
	my $preferences_hashref= C4::Context->preferences();
	my($string) = $params->{'newpassword'};

	if (!(C4::AR::Utilidades::validateString($string))){
# 		print A "entro a validateString \n";
# 		return (1,'U314');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U314', 'params' => []} ) ;
		return ($msg_object);
	}					

	if (! ( &checkLength($string, C4::Context->preference('minPassLength') ) ) ){
# 		return (1,'U316');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U316', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countSymbolChars($string) >= 0)){
# 		return (1,'U319');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countAlphaNumericChars($string) >= 0)){
# 		return (1,'U324');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U324', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countAlphaChars($string) >= 0)){
# 		return (1,'U325');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U325', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countNumericChars($string) >= 0)){
# 		return (1,'U326');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U326', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countLowerChars($string) >= 0)){
# 		return (1,'U327');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U327', 'params' => []} ) ;
		return ($msg_object);
	}

	if (!(&countUpperChars($string) >= 0)){
# 		return (1,'U328');
		$msg_object->{'error'}= 1;
		C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U328', 'params' => []} ) ;
		return ($msg_object);
	}

# close(A);
	C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U314', 'params' => []} ) ;
	return ($msg_object);
# 	return (0,"NO ERROR");
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
	
	if ($docType eq "DNI"){
		if (&countNumericChars($docNumber) == 8){
			if (length($docNumber) == 8){
			   $checkResult = 1;
			}
		}
	}
	else
	 {
		if ((&countNumericChars($docNumber) == (length($docNumber)) )){

			$checkResult = 1;
		}
	 }

	return ($checkResult);

}




