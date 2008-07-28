package C4::AR::Amazon;


use strict;
require Exporter;

use C4::Context;
use Net::Amazon;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(&getImageByIsbn &getImage);


sub getImageByIsbn{
my ($isbn,$size)=@_;
my $url='';
#Se Conecta
my $ua = Net::Amazon->new(token => '09RZQDPDWPQK1WWVSH02');
#Realiza la Busqueda
my $resp = $ua->search(isbn => $isbn);

if($resp->is_success()) {
  for my $prop ($resp->properties) {
  	if ($size eq 'small'){$url=$prop->SmallImageUrl();} else{ $url=$prop->MediumImageUrl();}
 }
}#succes

return ($url)
}

sub getImage{
	my ($id2,$size)=@_;
	my $url='';
	my $isbn=C4::AR::Nivel2::getISBN($id2);
	if ($isbn ne ''){
		$isbn =~ s/-//g;
		$url= getImageByIsbn($isbn,$size);
	}

return($url);
}
