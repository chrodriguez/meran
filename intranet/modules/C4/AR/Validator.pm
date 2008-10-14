package C4::AR::Validator;


use strict;
use C4::AR::Utilidades;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);
@EXPORT=qw( 
	&check,
	&checkLength,
	&countUpperChars,
	&countLowerChars,
	&countNumericChars,
	&countAlphaNumericChars,
	&countAlphaChars,
	&countSymbolChars	
	);


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

sub checkLength{

	my($string,$min_length)=@_;

	if (length($string) >= $min_length) {
        	return 1;
    	}
	return 0;
}



sub check{

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







