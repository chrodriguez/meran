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
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
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
        	return 0;
    	}
	return 1;
}



sub check{

	my($params)=@_;
	my($string) = $params->{'newpassword'};

	if (!(C4::AR::Utilidades::validateString($string))){
		return (1,'U314');
	}

	if (!(&checkLength($string,6))){
		return (1,'U316');
	}

	if (!(&countSymbolChars($string) >= 0)){
		return (1,'U319');
	}

	if (!(&countAlphaNumericChars($string) >= 0)){
		return (1,'U320');
	}

	if (!(&countAlphaChars($string) >= 0)){
		return (1,'U321');
	}

	if (!(&countNumericChars($string) >= 0)){
		return (1,'U322');
	}

	if (!(&countLowerChars($string) >= 0)){
		return (1,'U323');
	}

	if (!(&countUpperChars($string) >= 0)){
		return (1,'U324');
	}
	return (0,"NO ERROR");


}


sub checkPattern{

	my($string,$pattern)=@_;
	my($stringLength)=length($string);
	my($count)=0;
	my($fragment);
 	foreach $specificPattern $pattern {
		for ($charCount = 0; $charCount < $stringLength; $charCount += 1) {
			$fragment = substr $string,$charCount,1;
			if ($string =~ tr/$specificPattern/){
				$count++;
			}
		}
    	}
}







